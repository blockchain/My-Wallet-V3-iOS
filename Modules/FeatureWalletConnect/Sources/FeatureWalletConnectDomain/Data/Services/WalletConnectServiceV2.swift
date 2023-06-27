// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CryptoSwift
import DIKit
import EthereumKit
import Foundation
import MoneyKit
import NetworkKit
import PlatformKit
import ToolKit
import WalletConnectNetworking
import WalletConnectPairing
import WalletConnectRelay
import WalletConnectSign
import Web3Wallet

final class WalletConnectServiceV2: WalletConnectServiceV2API {

    private let _sessionEvents: PassthroughSubject<SessionEvent, Never> = .init()
    var sessionEvents: AnyPublisher<SessionEvent, Never> {
        _sessionEvents.eraseToAnyPublisher()
    }

    private let _userEvents: PassthroughSubject<WalletConnectUserEvent, Never> = .init()
    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> {
        _userEvents.eraseToAnyPublisher()
    }

    var sessions: AnyPublisher<[WalletConnectSign.Session], Never> {
        Web3Wallet.instance.sessionsPublisher
    }

    private var lifetimeBag: Set<AnyCancellable> = []
    private var bag: Set<AnyCancellable> = []

    private let productId: String
    private let app: AppProtocol
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let publicKeyProvider: WalletConnectPublicKeyProviderAPI
    private let accountProvider: WalletConnectAccountProviderAPI
    private let ethereumKeyPairProvider: EthereumKeyPairProvider
    private let txTargetFactory: (WalletConnectSign.Request) -> (any TransactionTarget)?

    private let messageSignerFactory: MessageSignerFactory

    private lazy var ethereumMessageSigner: MessageSigner = {
        messageSignerFactory.create()
    }()

    init(
        productId: String,
        app: AppProtocol,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        publicKeyProvider: WalletConnectPublicKeyProviderAPI,
        accountProvider: WalletConnectAccountProviderAPI,
        ethereumKeyPairProvider: EthereumKeyPairProvider,
        ethereumSignerFactory: SignerFactory,
        txTargetFactory: @escaping (WalletConnectSign.Request) -> (any TransactionTarget)? = { _ in nil }
    ) {
        self.productId = productId
        self.app = app
        self.enabledCurrenciesService = enabledCurrenciesService
        self.publicKeyProvider = publicKeyProvider
        self.accountProvider = accountProvider
        self.ethereumKeyPairProvider = ethereumKeyPairProvider
        self.txTargetFactory = txTargetFactory

        messageSignerFactory = MessageSignerFactory(signerFactory: ethereumSignerFactory)

        app.publisher(for: blockchain.user.id)
            .map(\.value.isNotNil)
            .combineLatest(app.publisher(for: blockchain.app.configuration.wallet.connect.is.enabled, as: Bool.self).map(\.value))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signedIn, isEnabled in
                guard let isEnabled else {
                    self?.bag = []
                    return
                }
                if signedIn, isEnabled {
                    self?.cleanupPairings()
                    self?.extendSessions()
                    self?.setup()
                } else {
                    self?.bag = []
                }
            }
            .store(in: &lifetimeBag)
    }

    func extendSessions()  {
        Task { [app] in
            let sessions = Web3Wallet.instance.getSessions()
            for session in sessions {
                do {
                    try await Web3Wallet.instance.extend(topic: session.topic)
                } catch {
                    app.post(error: error)
                }
            }
        }
    }

    func cleanupPairings() {
        Task {
            let pairings = getPairings()
            for pairing in pairings where pairing.peer == nil {
                try await disconnectPairing(topic: pairing.topic)
            }
        }
    }

    func setup() {
        let settled = Web3Wallet.instance
            .sessionSettlePublisher
            .map { SessionEvent.pairSettled(WalletConnectSession(session: $0)) }
            .eraseToAnyPublisher()

        let proposal = Web3Wallet.instance
            .sessionProposalPublisher
            .map(\.proposal)
            .flatMapLatest { [app, publicKeyProvider, enabledCurrenciesService] proposal -> AnyPublisher<WalletConnectProposalResult, Never> in
                let networks = networks(from: proposal, enabledCurrenciesService: enabledCurrenciesService)
                if networks.unsupported.isNotEmpty {
                    return .just(
                        .failure(
                            message: WalletConnectServiceError.unknownNetwork.errorDescription,
                            metadata: proposal.proposer
                        )
                    )
                }
                // we only support one ETH wallet at the moment
                return publicKeyProvider.publicKey(network: .ethereum)
                    .map { address in
                        .request(
                            WalletConnectProposal(
                                proposal: proposal,
                                account: address,
                                networks: networks.supported
                            )
                        )
                    }
                    .ignoreFailure(redirectsErrorTo: app)
                    .eraseToAnyPublisher()
            }
            .map { [app] result -> SessionEvent in
                switch result {
                case .request(let proposal):
                    app.state.set(blockchain.ux.wallet.connect.pair.request.proposal, to: proposal)
                    return .pairRequest(proposal)
                case .failure(let message, let appMetadata):
                    return .failure(message, appMetadata)
                }
            }
            .eraseToAnyPublisher()

        Publishers.Merge(proposal, settled)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: _sessionEvents.send)
            .store(in: &bag)

        Web3Wallet.instance
            .authRequestPublisher
            .flatMapLatest { [weak self, accountProvider] authRequest -> AnyPublisher<WalletConnectUserEvent, Never> in
                let payload = authRequest.request.payload
                guard let self else {
                    return .just(.authFailure(error: WalletConnectServiceError.unknown, domain: payload.domain))
                }
                guard let chain = Blockchain(payload.chainId) else {
                    return .just(.authFailure(error: WalletConnectServiceError.unknown, domain: payload.domain))
                }
                guard let network = self.getNetwork(from: chain) else {
                    return .just(.authFailure(error: WalletConnectServiceError.unknownNetwork, domain: payload.domain))
                }
                return accountProvider
                    .defaultAccount(network: network)
                    .eraseError()
                    .flatMapLatest { singleAccount -> AnyPublisher<(acc: SingleAccount, address: String), Error> in
                        singleAccount.receiveAddress
                            .map(\.address)
                            .map { (singleAccount, $0) }
                            .eraseToAnyPublisher()
                    }
                    .tryMap { value -> (info: WalletConnectAuthRequest.AccountInfo, message: String) in
                        let formattedMessage = try Web3Wallet.instance.formatMessage(payload: payload, address: value.address)
                        let info = WalletConnectAuthRequest.AccountInfo(
                            label: value.acc.label,
                            identifier: value.acc.identifier,
                            address: value.address,
                            network: network
                        )
                        return (info, formattedMessage)
                    }
                    .map { value in
                        WalletConnectUserEvent.authRequest(
                            WalletConnectAuthRequest(
                                request: authRequest.request,
                                accountInfo: value.info,
                                formattedMessage: value.message
                            )
                        )
                    }
                    .catch { error in
                        WalletConnectUserEvent.authFailure(error: error, domain: payload.domain)
                    }
                    .eraseToAnyPublisher()
            }
            .sink(receiveValue: _userEvents.send)
            .store(in: &bag)

        Web3Wallet.instance
            .sessionRequestPublisher
            .map(\.request)
            .flatMapLatest { [weak self, accountProvider] request -> AnyPublisher<WalletConnectUserEvent, Never> in
                guard let self else {
                    return .just(.failure(message: WalletConnectServiceError.unknown.localizedDescription, metadata: nil))
                }
                let peerMetadata = self.session(from: request.topic)?.peer
                guard let method = WalletConnectSupportedMethods(rawValue: request.method) else {
                    return .just(.failure(message: WalletConnectServiceError.unsupportedMethod.localizedDescription, metadata: peerMetadata))
                }
                guard let network = self.getNetwork(from: request.chainId) else {
                    return .just(.failure(message: WalletConnectServiceError.unknownNetwork.localizedDescription, metadata: peerMetadata))
                }
                return accountProvider
                    .defaultAccount(network: network)
                    .eraseError()
                    .flatMapLatest { account -> AnyPublisher<WalletConnectUserEvent, Error> in
                        self.createTxTarget(from: request, network: network)
                            .map { txTarget in
                                self.createUserEvent(from: method, account: account, txTarget: txTarget)
                            }
                            .eraseToAnyPublisher()
                    }
                    .catch { [app] error -> WalletConnectUserEvent in
                        app.post(error: error)
                        return .failure(
                            message: error.localizedDescription,
                            metadata: peerMetadata
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: _userEvents.send)
            .store(in: &bag)
    }

    func pair(uri: WalletConnectURI) async throws {
        try await Web3Wallet.instance.pair(uri: uri)
    }

    func disconnect(topic: String) async throws {
        try await Web3Wallet.instance.disconnect(topic: topic)
    }

    func disconnectPairing(topic: String) async throws {
        try await Web3Wallet.instance.disconnectPairing(topic: topic)
    }

    func disconnectAll() async throws {
        let sessions = Web3Wallet.instance.getSessions()
        let pairings = Web3Wallet.instance.getPairings()
        for session in sessions {
            try await Web3Wallet.instance.disconnect(topic: session.topic)
        }
        for pairing in pairings {
            try await Web3Wallet.instance.disconnectPairing(topic: pairing.topic)
        }
    }

    func approve(proposal: WalletConnectSign.Session.Proposal) async throws {
        let requiredChains: [Blockchain] = proposal.requiredNamespaces.values.reduce(into: [Blockchain]()) { partialResult, next in
            partialResult.append(contentsOf: Array(next.chains ?? []))
        }
        var optionalChains: [Blockchain] = []
        if let optional = proposal.optionalNamespaces {
            optionalChains = optional.values.reduce(into: [Blockchain]()) { partialResult, next in
                partialResult.append(contentsOf: Array(next.chains ?? []))
            }
        }
        let supportedBlockchains: [Blockchain] = (requiredChains + optionalChains).compactMap { chain in
            guard isSupportedChain(id: chain.reference) else {
                return nil
            }
            return chain
        }
        let accounts = try await accounts(from: supportedBlockchains)
        let namespaces = try AutoNamespaces.build(
            sessionProposal: proposal,
            chains: supportedBlockchains,
            methods: Array(WalletConnectSupportedMethods.allMethods),
            events: ["accountsChanged", "chainChanged"],
            accounts: accounts
        )
        try await Web3Wallet.instance.approve(proposalId: proposal.id, namespaces: namespaces)
    }

    func reject(proposal: WalletConnectSign.Session.Proposal) async throws {
        try await Web3Wallet.instance.reject(proposalId: proposal.id, reason: .userRejected)
    }

    func authApprove(request: AuthRequest) async throws {
        let pair = try await ethereumKeyPairProvider.keyPair.stream().next()
        guard let chain = Blockchain(request.payload.chainId) else {
            throw WalletConnectServiceError.unknown
        }
        guard let account = Account(blockchain: chain, address: pair.address) else {
            throw WalletConnectServiceError.unknown
        }
        let signature = try ethereumMessageSigner.sign(
            payload: request.payload.cacaoPayload(address: pair.address),
            privateKey: pair.privateKey.data,
            type: .eip191
        )
        try await Web3Wallet.instance.respond(requestId: request.id, signature: signature, from: account)
    }

    func authReject(request: AuthRequest) async throws {
        try await Web3Wallet.instance.reject(requestId: request.id)
    }

    func getPairings() -> [Pairing] {
        Web3Wallet.instance.getPairings()
    }

    func cleanup() {
        Task(priority: .high) {
            try await Web3Wallet.instance.cleanup()
        }
    }

    // MARK: Request methods

    func sign(request: WalletConnectSign.Request, response: RPCResult) async throws {
        try await Web3Wallet.instance.respond(topic: request.topic, requestId: request.id, response: response)
    }

    func createUserEvent(
        from method: WalletConnectSupportedMethods,
        account: SingleAccount,
        txTarget: any TransactionTarget
    ) -> WalletConnectUserEvent {
        switch method {
        case .ethSendTransaction:
            return .sendTransaction(account, txTarget)
        case .ethSignTransaction:
            return .signTransaction(account, txTarget)
        case .ethSign,
                .ethSignTypedData,
                .personalSign:
            return .signMessage(account, txTarget)
        }
    }

    func createTxTarget(from request: WalletConnectSign.Request, network: EVMNetwork) -> AnyPublisher<any TransactionTarget, Error> {
        guard let session = session(from: request.topic) else {
            return .failure(WalletConnectServiceError.missingSession)
        }
        let txRejected: () -> AnyPublisher<Void, Never> = { [weak self, app] in
            Task.Publisher { [weak self] in
                try await self?.sign(request: request, response: .error(.userRejected))
            }
            .catch { [app] error -> AnyPublisher<Void, Never> in
                app.post(error: error)
                return .just(())
            }
            .eraseToAnyPublisher()
        }
        let txCompleted: TransactionTarget.TxCompleted = { [weak self] result in
            Task.Publisher { [weak self] in
                switch result {
                case .signed(let string):
                    try await self?.sign(request: request, response: .response(AnyCodable(string)))
                case .hashed(let txHash, _):
                    try await self?.sign(request: request, response: .response(AnyCodable(txHash)))
                case .unHashed:
                    throw WalletConnectServiceError.invalidTxCompletion
                }
            }
            .eraseToAnyPublisher()
        }
        guard let target = txTarget(request, session: session, network: network, txCompleted: txCompleted, txRejected: txRejected) else {
            return .failure(WalletConnectServiceError.invalidTxTarget)
        }
        return .just(target)
    }

    // MARK: - Private

    func session(from topic: String) -> WalletConnectSign.Session? {
        Web3Wallet.instance.getSessions().first(where: { $0.topic == topic })
    }

    func accounts(from chains: [Blockchain]) async throws -> [WalletConnectSign.Account] {
        var accounts: [WalletConnectSign.Account] = []
        for blockchain in chains {
            guard let network = enabledCurrenciesService.network(for: blockchain.reference) else {
                continue
            }
            let address = try await address(from: network)
            if let account = WalletConnectSign.Account(blockchain: blockchain, address: address) {
                accounts.append(account)
            }
        }
        return accounts
    }

    func address(from network: EVMNetwork) async throws -> String {
        try await publicKeyProvider.publicKey(network: network).receive(on: DispatchQueue.main).await()
    }

    /// `true` if the chain id of a network is supported
    func isSupportedChain(id: String) -> Bool {
        enabledCurrenciesService.network(for: id) != nil
    }

    func getNetwork(from blockchain: Blockchain) -> EVMNetwork? {
        enabledCurrenciesService.network(for: blockchain.reference)
    }

    func supportChains() -> [EVMNetwork] {
        enabledCurrenciesService.allEnabledEVMNetworks
    }
}

// MARK: - Private Methods

/// Returns a tuple of the supported network(s) and any unsupported network(s) based on the given Wallet Connect Proposal
private func networks(
    from proposal: WalletConnectSign.Session.Proposal,
    enabledCurrenciesService: EnabledCurrenciesServiceAPI
) -> (supported: [EVMNetwork], unsupported: [Blockchain]) {
    let foundRequired = findNetworks(on: proposal.requiredNamespaces, enabledCurrenciesService: enabledCurrenciesService)
    var foundOptional: ([EVMNetwork], [Blockchain]) = ([], [])
    if let optional = proposal.optionalNamespaces {
        foundOptional = findNetworks(on: optional, enabledCurrenciesService: enabledCurrenciesService)
    }
    return (foundRequired.supported + foundOptional.0, foundRequired.unsupported)
}

private func findNetworks(
    on namespaces: [String: ProposalNamespace],
    enabledCurrenciesService: EnabledCurrenciesServiceAPI
) -> (supported: [EVMNetwork], unsupported: [Blockchain]) {
    var supported: [EVMNetwork] = []
    var unsuported: [Blockchain] = []
    for value in namespaces.values {
        let chains = value.chains ?? []
        for chain in chains {
            guard let network = enabledCurrenciesService.network(for: chain.reference) else {
                unsuported.append(chain)
                continue
            }
            supported.append(network)
        }
    }
    return (supported, unsuported)
}

extension JSONRPCError {
    static let userRejected = JSONRPCError(code: -32500, message: "User cancelled the request")
}
