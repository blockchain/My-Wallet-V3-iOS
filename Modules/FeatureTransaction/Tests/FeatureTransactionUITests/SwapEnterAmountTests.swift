//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import XCTest
import ComposableArchitecture
import MoneyKit
import Combine
@testable import FeatureTransactionUI
import BlockchainUI
import FeatureTransactionDomain
import SwiftUI
import DIKit
import PlatformKit

class MockSupportedPairsInteractorService: SupportedPairsInteractorServiceAPI {
    var pairs: AnyPublisher<PlatformKit.SupportedPairs, Error> = .empty()

    func fetchSupportedTradingCryptoCurrencies() -> AnyPublisher<[MoneyKit.CryptoCurrency], Error> {
        return .empty()
    }
}

class MockDefaultSwapCurrencyPairsService: DefaultSwapCurrencyPairsServiceAPI {
    var pairsToReturn: (source: FeatureTransactionDomain.SelectionInformation, target: FeatureTransactionDomain.SelectionInformation)?

    var getDefaultPairsCalled: Bool = false
    func getDefaultPairs(sourceInformation: FeatureTransactionDomain.SelectionInformation?) async -> (source: FeatureTransactionDomain.SelectionInformation, target: FeatureTransactionDomain.SelectionInformation)? {
        getDefaultPairsCalled = true
        return pairsToReturn
    }
}

@MainActor
class SwapEnterAmountTests: XCTestCase {
    var mockDefaultPairsService: MockDefaultSwapCurrencyPairsService!
    var testStore: TestStore<
        SwapEnterAmount.State,
        SwapEnterAmount.Action,
        SwapEnterAmount.State,
        SwapEnterAmount.Action,
        ()
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        DependencyContainer.defined(by: modules {
            DependencyContainer.mockDependencyContainer
        })

        mockDefaultPairsService = MockDefaultSwapCurrencyPairsService()
        let onPreviewTapped: (MoneyValue) -> Void = { _ in

        }

        let onAmountChanged: (MoneyValue) -> Void = { _ in

        }

        let onPairsSelected: (String, String, MoneyValue?) -> Void = { _,_,_ in

        }

        let onDismiss: () -> Void = {

        }

        let minMaxAmountsPublisher: AnyPublisher<TransactionMinMaxValues,Never> = .just(TransactionMinMaxValues(maxSpendableFiatValue: .zero(currency: .EUR),
                                                                                                                maxSpendableCryptoValue: .zero(currency: .bitcoin),
                                                                                                                minSpendableFiatValue: .zero(currency: .EUR),
                                                                                                                minSpendableCryptoValue: .zero(currency: .bitcoin))
        )

        testStore = TestStore(initialState: SwapEnterAmount.State(), reducer: SwapEnterAmount(app: App.test, defaultSwaptPairsService: mockDefaultPairsService,
                                                                                              minMaxAmountsPublisher: minMaxAmountsPublisher,
                                                                                              dismiss: onDismiss, onPairsSelected: onPairsSelected,
                                                                                              onAmountChanged: onAmountChanged,
                                                                                              onPreviewTapped: onPreviewTapped))
    }


    func test_initial_state() async {
        await testStore.send(.onAppear)
        XCTAssertTrue(mockDefaultPairsService.getDefaultPairsCalled)
    }

    //    func test_initial_state() {
    //        let state = testStore.state
    //        XCTAssertNil(state.route)
    //        XCTAssertNil(state.notificationDetailsState)
    //        XCTAssertEqual(state.viewState, .loading)
    //    }
    //
    //    func test_fetchSettings_on_startup() {
    //        testStore.send(.onAppear)
    //    }
    //
    //    func test_reload_tap() {
    //        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]
    //        notificationRepoMock.fetchPreferencesSubject.send(preferencesToReturn)
    //
    //        testStore.send(.onReloadTap)
    //
    //        XCTAssertTrue(notificationRepoMock.fetchSettingsCalled)
    //
    //        mainScheduler.advance()
    //
    //        testStore.receive(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
    //            state.viewState = .data(notificationDetailsState: preferencesToReturn)
    //        }
    //    }
    //
    //    func test_onFetchedSettings_success() {
    //        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]
    //
    //        testStore.send(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
    //            state.viewState = .data(notificationDetailsState: preferencesToReturn)
    //        }
    //    }
    //
    //    func test_onFetchedSettings_failure() {
    //        testStore.send(.onFetchedSettings(Result.failure(NetworkError.unknown))) { state in
    //            state.viewState = .error
    //        }
    //    }
    //
    //    func test_onSaveSettings_reload_triggered() {
    //        testStore = TestStore(
    //            initialState:
    //            .init(
    //                notificationDetailsState:
    //                NotificationPreferencesDetailsState(
    //                    notificationPreference: MockGenerator.marketingNotificationPreference),
    //                viewState: .loading
    //            ),
    //            reducer: featureNotificationPreferencesMainReducer,
    //            environment: NotificationPreferencesEnvironment(
    //                mainQueue: mainScheduler.eraseToAnyScheduler(),
    //                notificationPreferencesRepository: notificationRepoMock,
    //                analyticsRecorder: MockAnalyticsRecorder()
    //            )
    //        )
    //
    //        testStore.send(.notificationDetailsChanged(.save))
    //        mainScheduler.advance()
    //        XCTAssertTrue(notificationRepoMock.updateCalled)
    //        testStore.receive(.onReloadTap)
    //    }
    //
    //    func test_OnPreferenceSelected() {
    //        let selectedPreference = MockGenerator.marketingNotificationPreference
    //        testStore.send(.onPreferenceSelected(selectedPreference)) { state in
    //            state.notificationDetailsState = NotificationPreferencesDetailsState(notificationPreference: selectedPreference)
    //        }
    //    }
    //
    //    func test_navigate_to_details_route() {
    //        testStore.send(.route(.navigate(to: .showDetails))) { state in
    //            state.route = RouteIntent.navigate(to: .showDetails)
    //        }
    //    }
}



extension DependencyContainer {
    static var mockDependencyContainer = module {
        factory { MockSupportedPairsInteractorService() as SupportedPairsInteractorServiceAPI }
    }
}
