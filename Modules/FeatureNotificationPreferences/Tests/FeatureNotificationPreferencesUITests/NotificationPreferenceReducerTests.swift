// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
import ComposableNavigation
import Errors
import FeatureNotificationPreferencesDetailsUI
import FeatureNotificationPreferencesMocks
@testable import FeatureNotificationPreferencesUI
import UIComponentsKit
import XCTest

class NotificationPreferencesReducerTest: XCTestCase {
    private var testStore: TestStore<
        NotificationPreferencesState,
        NotificationPreferencesAction,
        NotificationPreferencesState,
        NotificationPreferencesAction,
        Void
    >!

    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private var notificationRepoMock: NotificationPreferencesRepositoryMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationRepoMock = NotificationPreferencesRepositoryMock()
        testStore = TestStore(
            initialState: .init(viewState: .loading),
            reducer: NotificationPreferencesReducer(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                notificationPreferencesRepository: notificationRepoMock,
                analyticsRecorder: MockAnalyticsRecorder()
            )
        )
    }

    func test_initial_state() {
        let state = testStore.state
        XCTAssertNil(state.route)
        XCTAssertNil(state.notificationDetailsState)
        XCTAssertEqual(state.viewState, .loading)
    }

    func test_fetchSettings_on_startup() {
        testStore.send(.onAppear)
    }

    func test_reload_tap() {
        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]
        notificationRepoMock.fetchPreferencesSubject.send(preferencesToReturn)

        testStore.send(.onReloadTap)

        XCTAssertTrue(notificationRepoMock.fetchSettingsCalled)

        mainScheduler.advance()

        testStore.receive(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
            state.viewState = .data(notificationDetailsState: preferencesToReturn)
        }
    }

    func test_onFetchedSettings_success() {
        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]

        testStore.send(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
            state.viewState = .data(notificationDetailsState: preferencesToReturn)
        }
    }

    func test_onFetchedSettings_failure() {
        testStore.send(.onFetchedSettings(Result.failure(NetworkError.unknown))) { state in
            state.viewState = .error
        }
    }

    func test_onSaveSettings_reload_triggered() {
        testStore = TestStore(
            initialState:
            .init(
                notificationDetailsState:
                NotificationPreferencesDetailsState(
                    notificationPreference: MockGenerator.marketingNotificationPreference),
                viewState: .loading
            ),
            reducer: FeatureNotificationPreferencesMainReducer(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                notificationPreferencesRepository: notificationRepoMock,
                analyticsRecorder: MockAnalyticsRecorder()
            )
        )

        testStore.send(.notificationDetailsChanged(.save))
        mainScheduler.advance()
        XCTAssertTrue(notificationRepoMock.updateCalled)
        testStore.receive(.onReloadTap)
    }

    func test_OnPreferenceSelected() {
        let selectedPreference = MockGenerator.marketingNotificationPreference
        testStore.send(.onPreferenceSelected(selectedPreference)) { state in
            state.notificationDetailsState = NotificationPreferencesDetailsState(notificationPreference: selectedPreference)
        }
    }

    func test_navigate_to_details_route() {
        testStore.send(.route(.navigate(to: .showDetails))) { state in
            state.route = RouteIntent.navigate(to: .showDetails)
        }
    }
}
