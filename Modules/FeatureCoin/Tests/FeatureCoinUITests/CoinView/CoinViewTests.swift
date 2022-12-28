// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureCoinDomain
@testable import FeatureCoinUI

import BlockchainComponentLibrary
import BlockchainNamespace
import Errors
import SnapshotTesting
import SwiftUI
import XCTest

final class CoinViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

//    func test_CoinView_goldUser() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .bitcoin,
//                        kycStatus: .gold,
//                        accounts: [
//                            .preview.privateKey,
//                            .preview.trading,
//                            .preview.rewards
//                        ],
//                        assetInformation: .preview,
//                        interestRate: 5,
//                        isFavorite: true,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 1100)
//
//        assertSnapshot(matching: coinView, as: .image)
//    }
//
//    func test_CoinView_silverUser() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .ethereum,
//                        kycStatus: .silver,
//                        accounts: [
//                            .preview.privateKey,
//                            .preview.trading,
//                            .preview.rewards
//                        ],
//                        assetInformation: .preview,
//                        interestRate: 7,
//                        isFavorite: false,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 1100)
//
//        assertSnapshot(matching: coinView, as: .image)
//    }

//    func test_CoinView_UnverifiedUser() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .bitcoin,
//                        kycStatus: .unverified,
//                        accounts: [
//                            .preview.privateKey
//                        ],
//                        assetInformation: .preview,
//                        isFavorite: false,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 1100)
//
//        assertSnapshot(matching: coinView, as: .image)
//    }

    func test_CoinView_Error() {
        let coinView = PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .bitcoin,
                        kycStatus: .unverified,
                        error: .failedToLoad,
                        isFavorite: false,
                        graph: .init(
                            interval: .day,
                            result: .failure(NetworkError.unknown)
                        )
                    ),
                    reducer: coinViewReducer,
                    environment: .previewEmpty
                )
            )
            .app(App.preview)
        }
        .frame(width: 375, height: 650)

        assertSnapshot(matching: coinView, as: .image)
    }

    func test_CoinView_Loading() {
        let coinView = PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .stellar,
                        graph: .init(isFetching: true)
                    ),
                    reducer: coinViewReducer,
                    environment: .previewEmpty
                )
            )
            .app(App.preview)
        }
        .frame(width: 375, height: 600)

        assertSnapshot(matching: coinView, as: .image)
    }

//    func test_CoinView_notTradable() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .nonTradable,
//                        kycStatus: .unverified,
//                        assetInformation: .preview,
//                        isFavorite: false,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 900)
//
//        assertSnapshot(matching: coinView, as: .image)
//    }
}
