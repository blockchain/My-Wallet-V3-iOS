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

@MainActor class NotificationPreferencesReducerTest: XCTestCase {
    private var testStore: TestStore<
        NotificationPreferencesState,
        NotificationPreferencesAction
    >!

    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private var notificationRepoMock: NotificationPreferencesRepositoryMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationRepoMock = NotificationPreferencesRepositoryMock()
        testStore = TestStore(
            initialState: .init(viewState: .loading),
            reducer: {
                NotificationPreferencesReducer(
                    mainQueue: mainScheduler.eraseToAnyScheduler(),
                    notificationPreferencesRepository: notificationRepoMock,
                    analyticsRecorder: MockAnalyticsRecorder()
                )
            }
        )
    }

    func test_initial_state() {
        let state = testStore.state
        XCTAssertNil(state.route)
        XCTAssertNil(state.notificationDetailsState)
        XCTAssertEqual(state.viewState, .loading)
    }

    func test_fetchSettings_on_startup() async {
        await testStore.send(.onAppear)
    }

    func test_reload_tap() async {
        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]
        notificationRepoMock.fetchPreferencesSubject.send(preferencesToReturn)

        await testStore.send(.onReloadTap)

        XCTAssertTrue(notificationRepoMock.fetchSettingsCalled)

        await mainScheduler.advance()

        await testStore.receive(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
            state.viewState = .data(notificationDetailsState: preferencesToReturn)
        }
    }

    func test_onFetchedSettings_success() async {
        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]

        await testStore.send(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
            state.viewState = .data(notificationDetailsState: preferencesToReturn)
        }
    }

    func test_onFetchedSettings_failure() async {
        await testStore.send(.onFetchedSettings(Result.failure(NetworkError.unknown))) { state in
            state.viewState = .error
        }
    }

    func test_onSaveSettings_reload_triggered() async {
        testStore = TestStore(
            initialState:
            .init(
                notificationDetailsState:
                NotificationPreferencesDetailsState(
                    notificationPreference: MockGenerator.marketingNotificationPreference),
                viewState: .loading
            ),
            reducer: {
                FeatureNotificationPreferencesMainReducer(
                    mainQueue: mainScheduler.eraseToAnyScheduler(),
                    notificationPreferencesRepository: notificationRepoMock,
                    analyticsRecorder: MockAnalyticsRecorder()
                )
            }
        )

        await testStore.send(.notificationDetailsChanged(.save))
        await mainScheduler.advance()
        XCTAssertTrue(notificationRepoMock.updateCalled)
        await testStore.receive(.onReloadTap)
    }

    func test_OnPreferenceSelected() async {
        let selectedPreference = MockGenerator.marketingNotificationPreference
        await testStore.send(.onPreferenceSelected(selectedPreference)) { state in
            state.notificationDetailsState = NotificationPreferencesDetailsState(notificationPreference: selectedPreference)
        }
    }

    func test_navigate_to_details_route() async {
        await testStore.send(.route(.navigate(to: .showDetails))) { state in
            state.route = RouteIntent.navigate(to: .showDetails)
        }
    }
}
