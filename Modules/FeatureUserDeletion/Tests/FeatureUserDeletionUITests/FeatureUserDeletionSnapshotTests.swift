import AnalyticsKitMock
import ComposableArchitecture
import ComposableArchitectureExtensions
@testable import FeatureUserDeletionDomainMock
@testable import FeatureUserDeletionUI
import SnapshotTesting
import SwiftUI
import TestKit
import XCTest

final class FeatureUserDeletionSnapshotTests: XCTestCase {

    private var environment: UserDeletionEnvironment!
    private var mockEmailVerificationService: MockUserDeletionRepositoryAPI!
    private var analyticsRecorder: MockAnalyticsRecorder!
    private var userDeletionState: UserDeletionState!

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = false

        mockEmailVerificationService = MockUserDeletionRepositoryAPI()
        analyticsRecorder = MockAnalyticsRecorder()
        environment = UserDeletionEnvironment(
            mainQueue: .immediate,
            userDeletionRepository: mockEmailVerificationService,
            analyticsRecorder: analyticsRecorder,
            dismissFlow: {},
            logoutAndForgetWallet: {}
        )
    }

    override func tearDownWithError() throws {
        mockEmailVerificationService = nil
        environment = nil
        analyticsRecorder = nil
        try super.tearDownWithError()
    }

    func test_iPhoneSE_onAppear() throws {
        let view = UserDeletionView(store: buildStore())
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneXsMax_onAppear() throws {
        let view = UserDeletionView(store: buildStore())

        assertSnapshot(
            matching: view,
            as: .image(perceptualPrecision: 0.98, layout: .device(config: .iPhoneXsMax))
        )
    }

    // MARK: - Helpers

    private func buildStore(
        confirmViewState: DeletionConfirmState? = DeletionConfirmState(),
        route: RouteIntent<UserDeletionRoute>? = nil
    ) -> Store<UserDeletionState, UserDeletionAction> {
        .init(
            initialState: UserDeletionState(
                confirmViewState: confirmViewState,
                route: route
            ),
            reducer: UserDeletionModule.reducer,
            environment: environment
        )
    }
}
