// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
@testable import FeatureTourUI
import MoneyKit
import PlatformKit
import SnapshotTesting
import XCTest

final class TourViewTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        DependencyContainer.defined(by: modules {
            DependencyContainer.mockDependencyContainer
        })
    }

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testTourView_manualLogin_disabled() {
        let view = OnboardingCarouselView(
            environment: TourEnvironment(
                createAccountAction: {},
                restoreAction: {},
                logInAction: {},
                manualLoginAction: {}
            ),
            manualLoginEnabled: false
        )
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let brokerageView = OnboardingCarouselView.Carousel.brokerage.makeView()
        assertSnapshot(
            matching: brokerageView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let earnView = OnboardingCarouselView.Carousel.earn.makeView()
        assertSnapshot(
            matching: earnView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let keysView = OnboardingCarouselView.Carousel.keys.makeView()
        assertSnapshot(
            matching: keysView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let items = [
            Price(currency: .bitcoin, value: .loaded(next: "$55,343.76"), deltaPercentage: .loaded(next: 7.88)),
            Price(currency: .ethereum, value: .loaded(next: "$3,585.69"), deltaPercentage: .loaded(next: 1.82)),
            Price(currency: .bitcoinCash, value: .loaded(next: "$618.05"), deltaPercentage: .loaded(next: -3.46)),
            Price(currency: .stellar, value: .loaded(next: "$0.36"), deltaPercentage: .loaded(next: 12.50))
        ]
        var tourState = TourState()
        tourState.items = IdentifiedArray(uniqueElements: items)
        let mockTourReducer: Reducer<TourState, TourAction, TourEnvironment> = Reducer { _, _, _ in
            .none
        }
        let tourStore = Store(
            initialState: tourState,
            reducer: mockTourReducer,
            environment: TourEnvironment(
                createAccountAction: {},
                restoreAction: {},
                logInAction: {},
                manualLoginAction: {}
            )
        )
        let livePricesView = LivePricesView(
            store: tourStore,
            list: LivePricesList(store: tourStore)
        )
        assertSnapshot(
            matching: livePricesView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )
    }

    func testTourView_manualLogin_enabled() {
        let view = OnboardingCarouselView(
            environment: TourEnvironment(
                createAccountAction: {},
                restoreAction: {},
                logInAction: {},
                manualLoginAction: {}
            ),
            manualLoginEnabled: true
        )
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let brokerageView = OnboardingCarouselView.Carousel.brokerage.makeView()
        assertSnapshot(
            matching: brokerageView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let earnView = OnboardingCarouselView.Carousel.earn.makeView()
        assertSnapshot(
            matching: earnView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let keysView = OnboardingCarouselView.Carousel.keys.makeView()
        assertSnapshot(
            matching: keysView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )

        let items = [
            Price(currency: .bitcoin, value: .loaded(next: "$55,343.76"), deltaPercentage: .loaded(next: 7.88)),
            Price(currency: .ethereum, value: .loaded(next: "$3,585.69"), deltaPercentage: .loaded(next: 1.82)),
            Price(currency: .bitcoinCash, value: .loaded(next: "$618.05"), deltaPercentage: .loaded(next: -3.46)),
            Price(currency: .stellar, value: .loaded(next: "$0.36"), deltaPercentage: .loaded(next: 12.50))
        ]
        var tourState = TourState()
        tourState.items = IdentifiedArray(uniqueElements: items)
        let mockTourReducer: Reducer<TourState, TourAction, TourEnvironment> = Reducer { _, _, _ in
            .none
        }
        let tourStore = Store(
            initialState: tourState,
            reducer: mockTourReducer,
            environment: TourEnvironment(
                createAccountAction: {},
                restoreAction: {},
                logInAction: {},
                manualLoginAction: {}
            )
        )
        let livePricesView = LivePricesView(
            store: tourStore,
            list: LivePricesList(store: tourStore)
        )
        assertSnapshot(
            matching: livePricesView,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus)
            )
        )
    }
}

/// This is needed in order to resolve the dependencies
struct MockEnabledCurrenciesServiceAPI: EnabledCurrenciesServiceAPI {
    var allEnabledEVMNetworks: [MoneyDomainKit.EVMNetwork] { [] }
    var allEnabledCurrencies: [CurrencyType] { [] }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { [] }
    var allEnabledFiatCurrencies: [FiatCurrency] { [] }
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { [] }
}

extension DependencyContainer {

    static var mockDependencyContainer = module {
        factory { MockEnabledCurrenciesServiceAPI() as EnabledCurrenciesServiceAPI }
    }
}
