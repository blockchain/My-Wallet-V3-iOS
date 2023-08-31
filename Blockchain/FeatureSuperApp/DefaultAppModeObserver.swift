// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Extensions
import FeatureProductsDomain

// Observer used for high risk countries. Using the products API to determine if the user should be defaulted to a certain mode.

public final class DefaultAppModeObserver: Client.Observer {
    let app: AppProtocol
    let productsService: FeatureProductsDomain.ProductsServiceAPI
    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        productsService: FeatureProductsDomain.ProductsServiceAPI
    ) {
        self.app = app
        self.productsService = productsService
    }

    var observers: [BlockchainEventSubscription] {
        [
            userDidUpdate,
            userDidLogout
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var userDidLogout = app.on(blockchain.session.event.did.sign.out) { [app] _ in
        app.state.clear(blockchain.app.mode.has.been.force.defaulted.to.mode)
        app.state.clear(blockchain.app.mode)
    }

    lazy var userDidUpdate = app.on(blockchain.user.event.did.update) { [app, weak self] _ async throws in
        guard let self else { return }

        let products = try await productsService.fetchProducts().await()
        let useTradingAccount = products.first(where: \.id == ProductIdentifier.useTradingAccount)
        let useExternalTradingAccount = products.first(where: \.id == ProductIdentifier.useExternalTradingAccount)

        let isDefaultingEnabled = await app.get(blockchain.app.configuration.app.mode.defaulting.is.enabled, as: Bool.self, or: false)
        let hasBeenDefaultedAlready = (try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self) == AppMode.pkw) ?? false

        let decision = AppModeDecision(
            useTradingAccount: useTradingAccount,
            useExternalTradingAccount: useExternalTradingAccount,
            isDefaultingEnabled: isDefaultingEnabled,
            hasBeenDefaultedAlready: hasBeenDefaultedAlready
        )

        if decision.shouldDefaultToDeFi() {
            app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
            app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode.has.been.force.defaulted.to.mode)
        }
    }
}

struct AppModeDecision {

    var useTradingAccount: ProductValue?
    var useExternalTradingAccount: ProductValue?
    var isDefaultingEnabled: Bool
    var hasBeenDefaultedAlready: Bool

    func shouldDefaultToDeFi() -> Bool {

        guard isDefaultingEnabled else { return false }
        guard !hasBeenDefaultedAlready else { return false }

        let isTradingAccountDisabled = (
            useTradingAccount?.defaultProduct == false || useTradingAccount?.enabled == false
        )

        let isExternalTradingAccountDisabled = (
            useExternalTradingAccount?.defaultProduct == false || useExternalTradingAccount?.enabled == false
        )

        return isTradingAccountDisabled && isExternalTradingAccountDisabled
    }
}
