// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AnalyticsKitMock
import Blockchain
import ComposableArchitecture
@testable import FeatureKYCDomainMock
@testable import FeatureKYCUI
@testable import FeatureKYCUIMock
import SnapshotTesting
import SwiftUI
import TestKit
import XCTest

final class EmailVerificationSnapshotTests: XCTestCase {

    private var rootStore: Store<EmailVerificationState, EmailVerificationAction>!
    private var mockEmailVerificationService: MockEmailVerificationService!

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = false

        mockEmailVerificationService = MockEmailVerificationService()
        rebuildRootStore()
    }

    override func tearDownWithError() throws {
        mockEmailVerificationService = nil
        rootStore = nil
        try super.tearDownWithError()
    }

    func test_iPhoneSE_snapshot_step_verify_email() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.verifyEmailPrompt))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneX_snapshot_step_verify_email() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.verifyEmailPrompt))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_help() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneX_snapshot_step_help() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_help_resending() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.emailVerificationHelp(.sendVerificationEmail))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneX_snapshot_step_help_resending() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.emailVerificationHelp(.sendVerificationEmail))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_email() throws {
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneX_snapshot_step_edit_email() throws {
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_email_invalid() throws {
        rebuildRootStore(emailAddress: "test_example.com")
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneX_snapshot_step_edit_email_invalid() throws {
        rebuildRootStore(emailAddress: "test_example.com")
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_saving() throws {
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.save))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneX_snapshot_step_edit_saving() throws {
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.save))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_email_verified() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerifiedPrompt))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneX_snapshot_step_email_verified() throws {
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerifiedPrompt))
        assert(view, on: .iPhoneX)
    }

    // MARK: - Helpers

    private func rebuildRootStore(emailAddress: String = "test@example.com") {
        rootStore = Store(
            initialState: EmailVerificationState(emailAddress: emailAddress),
            reducer: EmailVerificationReducer(
                    analyticsRecorder: MockAnalyticsRecorder(),
                    emailVerificationService: mockEmailVerificationService,
                    flowCompletionCallback: { _ in },
                    openMailApp: { .none },
                    app: App.test,
                    mainQueue: .immediate,
                    pollingQueue: .immediate
            )
        )
    }

    private func presentEditEmailScreen() -> some View {
        // due to what seems a limitation on SwiftUI, trying to push twice programmatically from the root view doesn't work
        NavigationView {
            EditEmailView(
                store: rootStore.scope(
                    state: \.editEmailAddress,
                    action: EmailVerificationAction.editEmailAddress
                )
            )
            .trailingNavigationButton(.close, action: {})
            .navigationBarTitle("", displayMode: .inline)
            .whiteNavigationBarStyle()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
