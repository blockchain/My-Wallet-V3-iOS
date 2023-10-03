// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import DIKit
@testable import FeatureTourUI
import MoneyKit
import SnapshotTesting
import XCTest

final class TourViewTests: XCTestCase {

    override func setUp() {
        _ = App.preview
        super.setUp()
        isRecording = false
    }

    func testCarousel_manualLoginDisabled() {
        let view = OnboardingCarouselView(
            store: Store(
                initialState: TourState(),
                reducer: NoOpReducer()
            ),
            manualLoginEnabled: false
        )
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }

    func testCarousel_manualLoginEnabled() {
        let view = OnboardingCarouselView(
            store: Store(
                initialState: TourState(),
                reducer: NoOpReducer()
            ),
            manualLoginEnabled: true
        )
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }

    func testBrokerage() {
        let view = OnboardingCarouselView.Carousel.brokerage.makeView()
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }

    func testEarn() {
        let view = OnboardingCarouselView.Carousel.earn.makeView()
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }

    func testKeys() {
        let view = OnboardingCarouselView.Carousel.keys.makeView()
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }

    func testPrices() {
        let state = TourState(
            items: [
                Price(currency: .bitcoin, value: .loaded(next: "$55,343.76"), deltaPercentage: .loaded(next: 7.88)),
                Price(currency: .ethereum, value: .loaded(next: "$3,585.69"), deltaPercentage: .loaded(next: 1.82)),
                Price(currency: .bitcoinCash, value: .loaded(next: "$618.05"), deltaPercentage: .loaded(next: -3.46)),
                Price(currency: .stellar, value: .loaded(next: "$0.36"), deltaPercentage: .loaded(next: 12.50))
            ]
        )
        let store = Store(
            initialState: state,
            reducer: NoOpReducer()
        )
        let view = LivePricesView(
            store: store,
            list: LivePricesList(store: store)
        )
        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8Plus),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }

}
