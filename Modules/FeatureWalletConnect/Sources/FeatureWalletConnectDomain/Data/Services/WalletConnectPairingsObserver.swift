// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit
import BlockchainNamespace
import Combine
import DIKit
import Foundation
import MetadataKit
import MoneyKit
import WalletConnectSign
import Web3Wallet

public final class WalletConnectPairingsObserver: BlockchainNamespace.Client.Observer {

    private let app: AppProtocol
    private let service: WalletConnectServiceV2API

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    private var lifetimeBag: Set<AnyCancellable> = []
    private var bag: Set<AnyCancellable> = []

    private var refresh = PassthroughSubject<Void, Never>()

    public init(
        app: AppProtocol,
        v2Service: WalletConnectServiceV2API = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.app = app
        self.service = v2Service
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    public func start() {
        lifetimeBag = []
        app.publisher(for: blockchain.user.id)
            .map(\.value.isNotNil)
            .combineLatest(app.publisher(for: blockchain.app.configuration.wallet.connect.is.enabled, as: Bool.self).map(\.value))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signedIn, isEnabled in
                guard let isEnabled else {
                    self?.stop()
                    return
                }
                if signedIn, isEnabled {
                    self?.setup()
                } else {
                    self?.stop()
                }
            }
            .store(in: &lifetimeBag)
    }

    func setup() {

        let v2Pairings = refresh
            .prepend(())
            .flatMapLatest { [service, enabledCurrenciesService] _ -> AnyPublisher<[DAppPairing], Never> in
                service.sessions
                    .prepend([])
                    .map { (sessions: [WalletConnectSign.Session]) -> [DAppPairing] in
                        sessions.map { session in
                            let networks = networks(from: session.namespaces, enabledCurrenciesService: enabledCurrenciesService)
                            return DAppPairing(
                                pairingTopic: session.pairingTopic,
                                name: session.peer.name,
                                description: session.peer.description,
                                url: session.peer.url,
                                iconUrlString: session.peer.icons.first,
                                networks: networks,
                                activeSession: WalletConnectSession(session: session)
                            )
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .map { pairings -> [WalletConnectPairings] in
                pairings.map(WalletConnectPairings.v2)
            }

        v2Pairings
            .sink(receiveValue: { [app] v2Pairings in
                app.state.set(blockchain.ux.wallet.connect.active.sessions, to: v2Pairings)
            })
            .store(in: &bag)

        app.on(blockchain.ux.wallet.connect.auth.request.approved)
            .mapToVoid()
            .sink(receiveValue: refresh.send)
            .store(in: &bag)

        // Disconnect observation

        app.on(blockchain.ux.wallet.connect.manage.sessions.disconnect.all) { [app, service, refresh] _ in
            do {
                try await service.disconnectAll()
                refresh.send(())
                app.post(event: blockchain.ux.wallet.connect.manage.sessions.disconnect.all.success)
            } catch {
                app.post(error: error)
                app.post(event: blockchain.ux.wallet.connect.manage.sessions.disconnect.all.failure)
            }
        }
        .store(in: &bag)

        app.on(blockchain.ux.wallet.connect.session.details.disconnect)
            .tryMap { [service] event -> AnyPublisher<Result<Void, Error>, Never> in
                let model: WalletConnectPairings = try event.context[blockchain.ux.wallet.connect.session.details.model].decode(WalletConnectPairings.self)
                switch model {
                case .v2(let dAppPairing):
                    return Task.Publisher {
                        if let session = dAppPairing.activeSession {
                            try await service.disconnect(topic: session.topic)
                        }
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

func networks(
    from namespaces: [String: SessionNamespace],
    enabledCurrenciesService: EnabledCurrenciesServiceAPI
) -> [EVMNetwork] {
    namespaces.flatMap { namespace -> [EVMNetwork] in
        Array(namespace.value.chains ?? []).compactMap { blockchain -> EVMNetwork? in
            guard let network = enabledCurrenciesService.network(for: blockchain.reference) else {
                return nil
            }
            return network
        }
    }
}
