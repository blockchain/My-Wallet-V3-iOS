// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
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

    lazy var userDidLogout = app.on(blockchain.session.event.did.sign.out) { [weak self] _ in
        guard let self else {
            return
        }
        app.state.clear(blockchain.app.mode.has.been.force.defaulted.to.mode)
        app.state.clear(blockchain.app.mode)
    }

    lazy var userDidUpdate = app.on(blockchain.user.event.did.update) { [weak self] _ in
        guard let self else { return }
        Task { [productsService = self.productsService, app = self.app] in
            async let useTradingAccountProduct = try? await productsService
                .fetchProducts()
                .await()
                .filter { $0.id == ProductIdentifier.useTradingAccount }
                .first

            let defaultingIsEnabled = try? await app.get(blockchain.app.configuration.app.mode.defaulting.is.enabled, as: Bool.self)
            let hasBeenDefaultedAlready = (try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self) == AppMode.pkw) ?? false

            guard defaultingIsEnabled == true,
                  hasBeenDefaultedAlready == false,
                  let useTradingAccountProduct = await useTradingAccountProduct,
                  useTradingAccountProduct.defaultProduct == false || useTradingAccountProduct.enabled == false
            else {
                return
            }
            app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
            app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode.has.been.force.defaulted.to.mode)
        }
    }
}
