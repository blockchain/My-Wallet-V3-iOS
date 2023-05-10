// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation
import MetadataKit
import MoneyKit
import WalletConnectSign
import WalletConnectSwift
import Web3Wallet

public final class WalletConnectPairingsObserver: BlockchainNamespace.Client.Observer {

    private let app: AppProtocol
    private let v1Service: WalletConnectServiceAPI
    private let v2Service: WalletConnectServiceV2API

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    private var lifetimeBag: Set<AnyCancellable> = []
    private var bag: Set<AnyCancellable> = []

    private var refresh = PassthroughSubject<Void, Never>()

    public init(
        app: AppProtocol,
        v1Service: WalletConnectServiceAPI = resolve(),
        v2Service: WalletConnectServiceV2API = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.app = app
        self.v1Service = v1Service
        self.v2Service = v2Service
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    public func start() {
        lifetimeBag = []
        app.publisher(for: blockchain.user.id)
            .map(\.value.isNotNil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signedIn in
                if signedIn {
                    self?.setup()
                } else {
                    self?.stop()
                }
            }
            .store(in: &lifetimeBag)
    }

    func setup() {

        let v1Pairings = v1Service.sessions
            .prepend([])
            .map { [enabledCurrenciesService] sessions -> [DAppPairingV1] in
                sessions.map { session -> DAppPairingV1 in
                    let networks: [EVMNetwork] = networks(v1Session: session, enabledCurrenciesService: enabledCurrenciesService)
                    return DAppPairingV1(
                        name: session.dAppInfo.peerMeta.name,
                        description: session.dAppInfo.peerMeta.description ?? "",
                        url: session.dAppInfo.peerMeta.url.relativeString,
                        iconUrlString: session.dAppInfo.peerMeta.icons.first?.absoluteString,
                        networks: networks,
                        activeSession: session
                    )
                }
            }
            .map { v1Pairings -> [WalletConnectPairings] in
                v1Pairings.map(WalletConnectPairings.v1)
            }

        let v2Pairings = refresh
            .prepend(())
            .flatMapLatest { [v2Service] _ -> AnyPublisher<[SessionV2], Never> in
                v2Service.sessions
                    .prepend([])
                    .eraseToAnyPublisher()
            }
            .map { [v2Service, enabledCurrenciesService] sessions -> [DAppPairing] in
                v2Service.getPairings().map { pairing -> DAppPairing in
                    let activeSession: SessionV2? = sessions.first(where: { $0.pairingTopic == pairing.topic })
                    var currentNetworks: [EVMNetwork] = []
                    if let activeSession {
                        currentNetworks = networks(from: activeSession.namespaces, enabledCurrenciesService: enabledCurrenciesService)
                    }
                    return DAppPairing(
                        pairingTopic: pairing.topic,
                        name: pairing.peer?.name ?? "",
                        description: pairing.peer?.description ?? "",
                        url: pairing.peer?.url ?? "",
                        iconUrlString: pairing.peer?.icons.first,
                        networks: currentNetworks,
                        activeSession: activeSession.map(WalletConnectSessionV2.init(session:))
                    )
                }
            }
            .map { pairings -> [WalletConnectPairings] in
                pairings.map(WalletConnectPairings.v2)
            }

        Publishers.CombineLatest(v1Pairings, v2Pairings)
            .sink(receiveValue: { [app] v1Pairings, v2Pairings in
                let combined = v1Pairings + v2Pairings
                app.state.set(blockchain.ux.wallet.connect.active.sessions, to: combined)
            })
            .store(in: &bag)

        // Disconnect observation

        app.on(blockchain.ux.wallet.connect.session.details.disconnect)
            .tryMap { [v1Service, v2Service] event -> AnyPublisher<Result<Void, Error>, Never> in
                let model: WalletConnectPairings = try event.context[blockchain.ux.wallet.connect.session.details.model].decode(WalletConnectPairings.self)
                switch model {
                case .v1(let dAppPairingV1):
                    guard let session = dAppPairingV1.activeSession else {
                        return .just(.failure(WalletConnectServiceError.unknown))
                    }
                    v1Service.disconnect(session)
                    return v1Service.sessionEvents
                        .filter { event -> Bool in
                            guard case .didDisconnect = event else {
                                return false
                            }
                            return true
                        }
                        .mapError()
                        .map { _ -> Result<Void, Error> in .success(()) }
                        .catch { error -> Result<Void, Error> in
                            .failure(error)
                        }
                        .eraseToAnyPublisher()
                case .v2(let dAppPairing):
                    return Task.Publisher {
                        if let session = dAppPairing.activeSession {
                            try await v2Service.disconnect(topic: session.topic)
                        }
                        try await v2Service.disconnectPairing(topic: dAppPairing.pairingTopic)
                    }
                    .map { _ -> Result<Void, Error> in .success(()) }
                    .catch { error -> Result<Void, Error> in
                        .failure(error)
                    }
                    .eraseToAnyPublisher()
                }
            }
            .catch { error -> AnyPublisher<Result<Void, Error>, Never> in
                .just(.failure(error))
            }
            .switchToLatest()
            .sink(receiveValue: { [app, refresh] success in
                switch success {
                case .success:
                    app.post(event: blockchain.ux.wallet.connect.session.details.disconnect.success)
                    refresh.send(())
                case .failure:
                    app.post(event: blockchain.ux.wallet.connect.session.details.disconnect.failure)
                }
            })
            .store(in: &bag)
    }

    public func stop() {
        bag = []
    }
}

func networks(v1Session: WalletConnectSwift.Session, enabledCurrenciesService: EnabledCurrenciesServiceAPI) -> [EVMNetwork] {
    if let chainId = v1Session.dAppInfo.chainId {
        if let network = network(enabledCurrenciesService: enabledCurrenciesService, chainID: String(chainId)) {
            return [network]
        }
    }
    return []
}

func networks(
    from namespaces: [String: SessionNamespace],
    enabledCurrenciesService: EnabledCurrenciesServiceAPI
) -> [EVMNetwork] {
    namespaces.flatMap { namespace -> [EVMNetwork] in
        Array(namespace.value.chains ?? []).compactMap { blockchain -> EVMNetwork? in
            guard let network = network(enabledCurrenciesService: enabledCurrenciesService, chainID: blockchain.reference) else {
                return nil
            }
            return network
        }
    }
}
