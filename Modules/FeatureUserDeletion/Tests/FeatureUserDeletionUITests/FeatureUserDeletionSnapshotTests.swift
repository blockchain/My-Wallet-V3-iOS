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

    private var mockEmailVerificationService: MockUserDeletionRepositoryAPI!
    private var analyticsRecorder: MockAnalyticsRecorder!
    private var userDeletionState: UserDeletionState!

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = false

        mockEmailVerificationService = MockUserDeletionRepositoryAPI()
        analyticsRecorder = MockAnalyticsRecorder()
    }

    override func tearDownWithError() throws {
        mockEmailVerificationService = nil
        analyticsRecorder = nil
        try super.tearDownWithError()
    }

    func x_test_iPhoneSE_onAppear() throws {
        let view = UserDeletionView(store: buildStore())

        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhoneSe),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
        )
    }

    func x_test_iPhoneXsMax_onAppear() throws {
        let view = UserDeletionView(store: buildStore())

        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhoneXsMax),
                traits: UITraitCollection(userInterfaceStyle: .light)
            )
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
            reducer: UserDeletionReducer(
                mainQueue: .immediate,
                userDeletionRepository: mockEmailVerificationService,
                analyticsRecorder: analyticsRecorder,
                dismissFlow: {},
                logoutAndForgetWallet: {}
            )
        )
    }
}
