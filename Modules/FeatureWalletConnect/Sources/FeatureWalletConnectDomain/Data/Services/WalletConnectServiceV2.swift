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
    var sessionEvents: AnyPublisher<SessionV2Event, Never> = .empty()

    var sessions: AnyPublisher<[SessionV2], Never> {
        Web3Wallet.instance.sessionsPublisher
    }

    private var lifetimeBag: Set<AnyCancellable> = []
    private var bag: Set<AnyCancellable> = []

    private let productId: String
    private let app: AppProtocol
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let publicKeyProvider: WalletConnectPublicKeyProviderAPI

    init(
        productId: String,
        app: AppProtocol,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        publicKeyProvider: WalletConnectPublicKeyProviderAPI
    ) {
        self.productId = productId
        self.app = app
        self.enabledCurrenciesService = enabledCurrenciesService
        self.publicKeyProvider = publicKeyProvider

        // TODO: Remove this
#if DEBUG
        Task(priority: .high) {
            try await Web3Wallet.instance.cleanup()
        }
#endif

        app.publisher(for: blockchain.user.id)
            .map(\.value.isNotNil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signedIn in
                if signedIn {
                    self?.setup()
                } else {
                    self?.bag = []
                }
            }
            .store(in: &lifetimeBag)
    }

    func setup() {
        Web3Wallet.instance
            .sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (sessions: [SessionV2]) in
                // Update sessions
            }.store(in: &bag)

        Web3Wallet.instance
            .sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                // TODO: store new session
            }
            .store(in: &bag)

        Web3Wallet.instance
            .sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionProposal in
                // TODO: Display sheet with details and approve or decline actions
                Task(priority: .high) { [weak self] in
                    try await self?.approve(proposal: sessionProposal)
                }
            }
            .store(in: &bag)

        Web3Wallet.instance
            .sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] request in
                // process request
            }
            .store(in: &bag)
    }

    func pair(uri: WalletConnectURI) async throws {
        try await Web3Wallet.instance.pair(uri: uri)
    }

    func disconnect(topic: String) async throws {
        try await Web3Wallet.instance.disconnect(topic: topic)
    }

    func approve(proposal: WalletConnectSign.Session.Proposal) async throws {
        let blockchains = proposal.requiredNamespaces.flatMap { namespace -> [Blockchain] in
            Array(namespace.value.chains ?? []).compactMap { blockchain -> Blockchain? in
                guard isSupportedChain(id: blockchain.reference) else {
                    print("Unsupported Chain Id: \(blockchain) on \(proposal)")
                    return nil
                }
                return blockchain
            }
        }
        let accounts = try await accounts(from: blockchains)
        let namespaces = try AutoNamespaces.build(
            sessionProposal: proposal,
            chains: blockchains,
            methods: Array(WalletConnectSupportedMethods.allMethods),
            events: ["accountsChanged", "chainChanged"],
            accounts: accounts
        )
        try await Web3Wallet.instance.approve(proposalId: proposal.id, namespaces: namespaces)
    }

    func reject(proposal: WalletConnectSign.Session.Proposal) async throws {
        try await Web3Wallet.instance.reject(proposalId: proposal.id, reason: .userRejected)
    }

    // MARK: - Private

    func accounts(from chains: [Blockchain]) async throws -> [WalletConnectSign.Account] {
        var accounts: [WalletConnectSign.Account] = []
        for blockchain in chains {
            guard let network = network(enabledCurrenciesService: enabledCurrenciesService, chainID: blockchain.reference) else {
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

    func isSupportedChain(id: String) -> Bool {
        network(enabledCurrenciesService: enabledCurrenciesService, chainID: id) != nil
    }
}

private func network(enabledCurrenciesService: EnabledCurrenciesServiceAPI, chainID: String) -> EVMNetwork? {
    enabledCurrenciesService
        .allEnabledEVMNetworks
        .first(where: { network in
            network.networkConfig.chainID == BigUInt(chainID)
        })
}
