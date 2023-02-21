// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
@testable import BlockchainApp
import Combine
import Errors
import Extensions
import FeatureProductsDomain
import Foundation
import XCTest

final class DefaultAppModeTests: XCTestCase {
    private var app: App.Test!
    private var productServiceMock: ProductServiceMock!
    var sut: DefaultAppModeObserver!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = App.test
        app.signIn(userId: "TestUser")
        app.remoteConfiguration.override(blockchain.app.configuration.app.mode.defaulting.is.enabled, with: true)
        productServiceMock = ProductServiceMock()

        sut = DefaultAppModeObserver(
            app: app,
            productsService: productServiceMock
        )
    }

    override func tearDownWithError() throws {
        sut.stop()
        app = nil
        productServiceMock = nil
        try super.tearDownWithError()
    }

    func test_default_true_tradingAccount() async {
        // GIVEN: Blockchain.com Account is being returned as default produdct
        sut.start()
        productServiceMock.stubbedResponses.fetchProducts = .just([
            ProductValue(
                id: .useTradingAccount,
                enabled: true,
                defaultProduct: true
            ),
            ProductValue(
                id: .sell,
                enabled: false,
                maxOrdersCap: 1,
                maxOrdersLeft: 0,
                suggestedUpgrade: ProductSuggestedUpgrade(requiredTier: 2)
            )
        ])
        // WHEN
        await app.post(event: blockchain.user.event.did.update)
        try? await app.wait(blockchain.app.mode.has.been.force.defaulted.to.mode, timeout: .seconds(1))

        // THEN: User is not defaulted to PKW
        XCTAssertNil(try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self))
    }

    func test_default_false_tradingAccount() async {
        // GIVEN: Blockchain.com Account is being returned as non-default product
        app.state.set(blockchain.app.mode.has.been.force.defaulted.to.mode, to: nil)
        sut.start()
        productServiceMock.stubbedResponses.fetchProducts = .just([
            ProductValue(
                id: .useTradingAccount,
                enabled: true,
                defaultProduct: false
            ),
            ProductValue(
                id: .sell,
                enabled: false,
                maxOrdersCap: 1,
                maxOrdersLeft: 0,
                suggestedUpgrade: ProductSuggestedUpgrade(requiredTier: 2)
            )
        ])
        // WHEN
        await app.post(event: blockchain.user.event.did.update)
        try? await app.wait(blockchain.app.mode.has.been.force.defaulted.to.mode, timeout: .seconds(1))

        let focedAppMode = try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self)
        let appMode = try? app.state.get(blockchain.app.mode, as: AppMode.self)
        // THEN: User is defaulted to PKW
        XCTAssertEqual(appMode, AppMode.pkw)
        XCTAssertEqual(focedAppMode, AppMode.pkw)
    }

    func test_default_no_tradingAccount() async {
        // GIVEN: Blockchain.com Account is being returned but disabled
        app.state.set(blockchain.app.mode.has.been.force.defaulted.to.mode, to: nil)
        sut.start()
        productServiceMock.stubbedResponses.fetchProducts = .just([
            ProductValue(
                id: .useTradingAccount,
                enabled: false,
                defaultProduct: false
            ),
            ProductValue(
                id: .sell,
                enabled: false,
                maxOrdersCap: 1,
                maxOrdersLeft: 0,
                suggestedUpgrade: ProductSuggestedUpgrade(requiredTier: 2)
            )
        ])
        // WHEN
        await app.post(event: blockchain.user.event.did.update)
        try? await app.wait(blockchain.app.mode.has.been.force.defaulted.to.mode, timeout: .seconds(1))
        let focedAppMode = try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self)
        let appMode = try? app.state.get(blockchain.app.mode, as: AppMode.self)
        // THEN: User is defaulted to PKW
        XCTAssertEqual(appMode, AppMode.pkw)
        XCTAssertEqual(focedAppMode, AppMode.pkw)
    }
}

class ProductServiceMock: ProductsServiceAPI {
    struct RecordedInvocations {
        var fetchProducts: [Void] = []
        var streamProducts: [Void] = []
    }

    struct StubbedResponses {
        var fetchProducts: AnyPublisher<[ProductValue], ProductsServiceError> = .empty()
        var streamProducts: AnyPublisher<Result<[ProductValue], ProductsServiceError>, Never> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResponses = StubbedResponses()

    func fetchProducts() -> AnyPublisher<
        [FeatureProductsDomain.ProductValue],
        FeatureProductsDomain.ProductsServiceError
    > {
        recordedInvocations.fetchProducts.append(())
        return stubbedResponses.fetchProducts
    }

    func streamProducts() -> AnyPublisher<Result<
        [FeatureProductsDomain.ProductValue],
        FeatureProductsDomain.ProductsServiceError
    >, Never> {
        recordedInvocations.streamProducts.append(())
        return stubbedResponses.streamProducts
    }
}
