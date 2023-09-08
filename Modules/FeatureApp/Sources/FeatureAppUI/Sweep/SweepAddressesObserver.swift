// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import BlockchainNamespace
import Combine
import DIKit
import PlatformKit
import WalletPayloadKit

public final class SweepAddressesObserver: Client.Observer {

    enum SweepAddressesState {
        case noAction
        case allGood
        case shouldSweep
    }

    private static let filteringPrefix = "1"

    private let app: AppProtocol
    private let service: SweepImportedAddressesServiceAPI
    private let settingsService: SettingsServiceAPI
    private let walletHolder: WalletHolderAPI

    private var bag: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        service: SweepImportedAddressesServiceAPI = DIKit.resolve(),
        settingsService: SettingsServiceAPI = DIKit.resolve(),
        walletHolder: WalletHolderAPI = resolve()
    ) {
        self.app = app
        self.service = service
        self.settingsService = settingsService
        self.walletHolder = walletHolder
    }

    public func start() {
        let flag = app
            .publisher(for: blockchain.app.configuration.sweep.is.enabled, as: Bool.self)
            .replaceError(with: false)
            .eraseToAnyPublisher()

        let recommendImportedSweep: AnyPublisher<Bool, Never> = settingsService
            .valuePublisher
            .map(\.recommendImportedSweep)
            .catch { _ in false }
            .removeDuplicates()
            .eraseToAnyPublisher()

        let isEnabled: AnyPublisher<Bool, Never> = flag
            .flatMap { enabled -> AnyPublisher<Bool, Never> in
                enabled ? recommendImportedSweep : .just(false)
            }
            .eraseToAnyPublisher()

        let addresses: AnyPublisher<[String], Never> = walletHolder
            .walletStatePublisher
            .filter { state -> Bool in
                guard case .loaded = state else {
                    return false
                }
                return true
            }
            .map { state -> [String] in
                guard case .loaded(wrapper: let wrapper, metadata: _) = state else {
                    return []
                }
                return wrapper.wallet
                    .addresses
                    .map(\.addr)
                    .filter { $0.hasPrefix(Self.filteringPrefix) }
            }
            .eraseToAnyPublisher()

        let shouldProccessAddresses: AnyPublisher<(Bool, [String]), Never> = isEnabled
            .combineLatest(addresses)
            .flatMap { enabled, addresses -> AnyPublisher<(Bool, [String]), Never> in
                guard enabled else {
                    return .just((false, []))
                }
                // no need to procceed if there are no addresses
                if addresses.isEmpty {
                    return .just((enabled, []))
                }
                return .just((enabled, addresses))
            }
            .handleEvents(receiveOutput: { [app] enabled, addresses in
                if enabled && addresses.isNotEmpty {
                    app.post(event: blockchain.app.coin.core.load.pkw.assets)
                }
            })
            .eraseToAnyPublisher()

        shouldProccessAddresses
            .flatMap { [service, app] enabled, addresses -> AnyPublisher<SweepAddressesState, Error> in
                guard enabled else {
                    return .just(.noAction)
                }
                // no need to procceed if there are no addresses
                if enabled && addresses.isEmpty {
                    return .just(.allGood)
                }

                return app.on(blockchain.app.coin.core.pkw.assets.loaded)
                    .prefix(1)
                    .flatMap { _ -> AnyPublisher<SweepAddressesState, Error> in
                        service.prepare(force: false)
                            .prefix(1)
                            .map { accounts -> SweepAddressesState in
                                if accounts.isNotEmpty {
                                    return .shouldSweep
                                } else {
                                    return .allGood
                                }
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { [app] state in
                app.publisher(for: blockchain.ux.home.dashboard)
                    .first()
                    .map { _ in state }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] state in
                switch state {
                case .noAction:
                    break
                case .shouldSweep:
                    self?.showSweepAddressesModal()
                case .allGood:
                    self?.showNoActionNeededModalIfNeeded()
                }
            }
            .store(in: &bag)
    }

    public func stop() {
        bag = []
    }

    private func showSweepAddressesModal() {
        Task { [app] in
            try await app.set(
                blockchain.ux.sweep.imported.addresses.transfer.entry.paragraph.row.tap.then.enter.into,
                to: blockchain.ux.sweep.imported.addresses.transfer
            )

            await MainActor.run {
                app.post(
                    event: blockchain.ux.sweep.imported.addresses.transfer.entry.paragraph.row.tap,
                    context: [
                        blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                    ]
                )
            }

            // reset no action has seen state
            app.state.set(blockchain.ux.sweep.imported.addresses.no.action.has.seen, to: false)
        }
    }

    private func showNoActionNeededModalIfNeeded() {
        Task { [app] in
            let hasSeen: Bool = try await app.get(blockchain.ux.sweep.imported.addresses.no.action.has.seen)
            guard !hasSeen else {
                return
            }

            try await app.set(
                blockchain.ux.sweep.imported.addresses.no.action.entry.paragraph.row.tap.then.enter.into,
                to: blockchain.ux.sweep.imported.addresses.no.action
            )

            await MainActor.run {
                app.post(
                    event: blockchain.ux.sweep.imported.addresses.no.action.entry.paragraph.row.tap,
                    context: [
                        blockchain.ui.type.action.then.enter.into.embed.in.navigation: false,
                        blockchain.ui.type.action.then.enter.into.grabber.visible: false,
                        blockchain.ui.type.action.then.enter.into.detents: [
                            blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                        ]
                    ]
                )
            }

            app.state.set(blockchain.ux.sweep.imported.addresses.no.action.has.seen, to: true)
        }
    }
}
