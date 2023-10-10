// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AnalyticsKitMock
import Blockchain
import ComposableArchitecture
@testable import FeatureKYCDomain
@testable import FeatureKYCDomainMock
@testable import FeatureKYCUI
@testable import FeatureKYCUIMock
import Localization
import TestKit
import XCTest

private typealias L10n = LocalizationConstants.NewKYC

@MainActor final class EmailVerificationReducerTests: XCTestCase {

    fileprivate struct RecordedInvocations {
        var flowCompletionCallback: [FlowResult] = []
    }

    fileprivate struct StubbedResults {
        var canOpenMailApp: Bool = false
    }

    private var recordedInvocations: RecordedInvocations!
    private var stubbedResults: StubbedResults!
    private var emailVerificationService: MockEmailVerificationService!

    private var testPollingQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        EmailVerificationState,
        EmailVerificationAction
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        emailVerificationService = MockEmailVerificationService()
        recordedInvocations = RecordedInvocations()
        stubbedResults = StubbedResults()
        testPollingQueue = DispatchQueue.test
        resetTestStore()
    }

    override func tearDownWithError() throws {
        emailVerificationService = nil
        recordedInvocations = nil
        stubbedResults = nil
        testStore = nil
        testPollingQueue = nil
        try super.tearDownWithError()
    }

    // MARK: Root State Manipulation

    func test_substates_init() throws {
        let emailAddress = "test@example.com"
        let state = EmailVerificationState(emailAddress: emailAddress)
        XCTAssertEqual(state.verifyEmail.emailAddress, emailAddress)
        XCTAssertEqual(state.editEmailAddress.emailAddress, emailAddress)
        XCTAssertEqual(state.emailVerificationHelp.emailAddress, emailAddress)
    }

    func test_flowStep_startsAt_verifyEmail() throws {
        let state = EmailVerificationState(emailAddress: "test@example.com")
        XCTAssertEqual(state.flowStep, .verifyEmailPrompt)
    }

    func test_closes_flow_as_abandoned_when_closeButton_tapped() async throws {
        XCTAssertEqual(recordedInvocations.flowCompletionCallback, [])
        await testStore.send(.closeButtonTapped)
        XCTAssertEqual(self.recordedInvocations.flowCompletionCallback, [.abandoned])
    }

    func test_polls_verificationStatus_every_few_seconds_while_on_screen() async throws {
        // poll currently set to 5 seconds
        await testStore.send(.didAppear)
            // nothing should happen after 1 second
        await testPollingQueue.advance(by: 1)
        // poll should happen after 4 more seconds (5 seconds in total)
        await testPollingQueue.advance(by: 4)
        await testStore.receive(.loadVerificationState)
        await testStore.receive(
            .didReceiveEmailVerficationResponse(
                .success(
                    .init(emailAddress: "test@example.com", status: .unverified)
                )
            )
        )
        await testStore.receive(.presentStep(.verifyEmailPrompt))
        await testStore.send(.didDisappear)
        // no more actions should be received after view disappears
        await testPollingQueue.advance(by: 15)
    }

    func test_polling_verificationStatus_doesNot_redirectTo_anotherStep_when_editingEmail() async throws {
        // poll currently set to 5 seconds
        await testStore.send(.didAppear)
            // nothing should happen after 1 second
        await testPollingQueue.advance(by: 1)
        await testStore.send(.presentStep(.editEmailAddress)) {
            $0.flowStep = .editEmailAddress
        }
        // poll should happen after 4 more seconds (5 seconds in total)
        await testPollingQueue.advance(by: 4)
        await testStore.receive(.loadVerificationState)
        await testStore.receive(
            .didReceiveEmailVerficationResponse(
                .success(
                    .init(emailAddress: "test@example.com", status: .unverified)
                )
            )
        )
        await testStore.send(.didDisappear)
        // no more actions should be received after view disappears
        await testPollingQueue.advance(by: 15)
    }

    func test_loads_verificationStatus_when_app_opened_unverified() async throws {
        await testStore.send(.didEnterForeground)
        await testStore.receive(.presentStep(.loadingVerificationState)) {
            $0.flowStep = .loadingVerificationState
        }
        await testStore.receive(.loadVerificationState)
        await testStore.receive(
            .didReceiveEmailVerficationResponse(
                .success(
                    .init(emailAddress: "test@example.com", status: .unverified)
                )
            )
        )
        await testStore.receive(.presentStep(.verifyEmailPrompt)) {
            $0.flowStep = .verifyEmailPrompt
        }
    }

    func test_loads_verificationStatus_when_app_opened_verified() async throws {
        emailVerificationService?.stubbedResults.checkEmailVerificationStatus = .just(
            .init(emailAddress: "test@example.com", status: .verified)
        )
        await testStore.send(.didEnterForeground)
        await testStore.receive(.presentStep(.loadingVerificationState)) {
            $0.flowStep = .loadingVerificationState
        }
        await testStore.receive(.loadVerificationState)
        await testStore.receive(
            .didReceiveEmailVerficationResponse(
                .success(.init(emailAddress: "test@example.com", status: .verified))
            )
        )
        await testStore.receive(.presentStep(.emailVerifiedPrompt)) {
            $0.flowStep = .emailVerifiedPrompt
        }
    }

    func test_loads_verificationStatus_when_app_opened_error() async throws {
        emailVerificationService?.stubbedResults.checkEmailVerificationStatus = .failure(.unknown(MockError.unknown))
        await testStore.send(.didEnterForeground)
        await testStore.receive(.presentStep(.loadingVerificationState)) {
            $0.flowStep = .loadingVerificationState
        }
        await testStore.receive(.loadVerificationState)
        await testStore.receive(.didReceiveEmailVerficationResponse(.failure(.unknown(MockError.unknown)))) {
            $0.emailVerificationFailedAlert = AlertState(
                title: TextState(L10n.GenericError.title),
                message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                primaryButton: ButtonState.default(
                    TextState(L10n.GenericError.retryButtonTitle),
                    action: .send(.loadVerificationState)
                ),
                secondaryButton: ButtonState.cancel(TextState(L10n.GenericError.cancelButtonTitle))
            )
        }
        await testStore.receive(.presentStep(.verificationCheckFailed)) {
            $0.flowStep = .verificationCheckFailed
        }
    }

    func test_dismisses_verification_status_error() async throws {
        await testStore.send(.didReceiveEmailVerficationResponse(.failure(.unknown(MockError.unknown)))) {
            $0.emailVerificationFailedAlert = AlertState(
                title: TextState(L10n.GenericError.title),
                message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                primaryButton: ButtonState.default(
                    TextState(L10n.GenericError.retryButtonTitle),
                    action: .send(.loadVerificationState)
                ),
                secondaryButton: ButtonState.cancel(TextState(L10n.GenericError.cancelButtonTitle))
            )
        }
        await testStore.receive(.presentStep(.verificationCheckFailed)) {
            $0.flowStep = .verificationCheckFailed
        }
        await testStore.send(.alert(.presented(.dismiss))) {
            $0.emailVerificationFailedAlert = nil
        }
        await testStore.receive(.presentStep(.verifyEmailPrompt)) {
            $0.flowStep = .verifyEmailPrompt
        }
    }

    // MARK: Verify Email State Manipulation

    func test_opens_inbox_failed() async throws {
        await testStore.send(.verifyEmail(.tapCheckInbox))
        await testStore.receive(.verifyEmail(.alert(.presented(.present)))) {
            $0.verifyEmail.cannotOpenMailAppAlert = AlertState(title: .init("Cannot Open Mail App"))
        }
        await testStore.send(.verifyEmail(.alert(.presented(.dismiss)))) {
            $0.verifyEmail.cannotOpenMailAppAlert = nil
        }
    }

    func test_opens_inbox_success() async throws {
        stubbedResults.canOpenMailApp = true
        await testStore.send(.verifyEmail(.tapCheckInbox))
        await testStore.receive(.verifyEmail(.alert(.presented(.dismiss))))
    }

    func test_navigates_to_help() async throws {
        await testStore.send(.verifyEmail(.tapGetEmailNotReceivedHelp))
        await testStore.receive(.presentStep(.emailVerificationHelp)) {
            $0.flowStep = .emailVerificationHelp
        }
    }

    // MARK: Email Verified State Manipulation

    func test_email_verified_continue_calls_flowCompletion_as_completed() async throws {
        XCTAssertEqual(recordedInvocations.flowCompletionCallback, [])
        await testStore.send(.emailVerified(.acknowledgeEmailVerification))
        XCTAssertEqual(self.recordedInvocations.flowCompletionCallback, [.completed])
    }

    // MARK: Edit Email State Manipulation

    func test_edit_email_validates_email_on_appear_validEmail() async throws {
        XCTAssertTrue(testStore.state.editEmailAddress.isEmailValid)
        XCTAssertEqual(testStore.state.flowStep, .verifyEmailPrompt)
        XCTAssertFalse(testStore.state.editEmailAddress.savingEmailAddress)
        await testStore.send(.editEmailAddress(.didAppear))
    }

    func test_edit_email_validates_email_on_appear_invalidEmail() async throws {
        resetTestStore(emailAddress: "test_example.com")
        XCTAssertFalse(testStore.state.editEmailAddress.isEmailValid)
        await testStore.send(.editEmailAddress(.didAppear))
    }

    func test_edit_email_validates_email_on_appear_emptyEmail() async throws {
        resetTestStore(emailAddress: "")
        XCTAssertFalse(testStore.state.editEmailAddress.isEmailValid)
        await testStore.send(.editEmailAddress(.didAppear))
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_validEmail() async throws {
        await testStore.send(.editEmailAddress(.didChangeEmailAddress("example@test.com"))) {
            $0.editEmailAddress.emailAddress = "example@test.com"
            $0.editEmailAddress.isEmailValid = true
        }
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_invalidEmail() async throws {
        await testStore.send(.editEmailAddress(.didChangeEmailAddress("example_test.com"))) {
            $0.editEmailAddress.emailAddress = "example_test.com"
            $0.editEmailAddress.isEmailValid = false
        }
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_emptyEmail() async throws {
        await testStore.send(.editEmailAddress(.didChangeEmailAddress(""))) {
            $0.editEmailAddress.emailAddress = ""
            $0.editEmailAddress.isEmailValid = false
        }
    }

    func test_edit_email_save_success() async throws {
        await testStore.send(.editEmailAddress(.didAppear))
        await testStore.send(.editEmailAddress(.save)) {
            $0.editEmailAddress.savingEmailAddress = true
        }
        await testStore.receive(.editEmailAddress(.didReceiveSaveResponse(.success(0)))) {
            $0.editEmailAddress.savingEmailAddress = false
        }
        await testStore.receive(.presentStep(.verifyEmailPrompt))
    }

    func test_edit_email_edit_and_save_success() async throws {
        await testStore.send(.editEmailAddress(.didChangeEmailAddress("someone@example.com"))) {
            $0.editEmailAddress.emailAddress = "someone@example.com"
            $0.editEmailAddress.isEmailValid = true
        }
        await testStore.send(.editEmailAddress(.save)) {
            $0.editEmailAddress.savingEmailAddress = true
        }
        await testStore.receive(.editEmailAddress(.didReceiveSaveResponse(.success(0)))) {
            $0.editEmailAddress.savingEmailAddress = false
            $0.verifyEmail.emailAddress = "someone@example.com"
            $0.emailVerificationHelp.emailAddress = "someone@example.com"
        }
        await testStore.receive(.presentStep(.verifyEmailPrompt))
    }

    func test_edit_email_attemptingTo_save_invalidEmail_does_nothing() async throws {
        await testStore.send(.editEmailAddress(.didChangeEmailAddress("someone_example.com"))) {
            $0.editEmailAddress.emailAddress = "someone_example.com"
            $0.editEmailAddress.isEmailValid = false
        }
        await testStore.send(.editEmailAddress(.save))
    }

    func test_edit_email_save_failure() async throws {
        emailVerificationService?.stubbedResults.updateEmailAddress = .failure(.missingCredentials)
        await testStore.send(.editEmailAddress(.didAppear))
        await testStore.send(.editEmailAddress(.save)) {
            $0.editEmailAddress.savingEmailAddress = true
        }
        await testStore.receive(.editEmailAddress(.didReceiveSaveResponse(.failure(.missingCredentials)))) {
            $0.editEmailAddress.savingEmailAddress = false
            $0.editEmailAddress.saveEmailFailureAlert = AlertState(
                title: TextState(L10n.GenericError.title),
                message: TextState(L10n.EditEmail.couldNotUpdateEmailAlertMessage),
                primaryButton: .default(
                    TextState(L10n.GenericError.retryButtonTitle),
                    action: .send(.save)
                ),
                secondaryButton: .cancel(TextState(L10n.GenericError.cancelButtonTitle))
            )
        }
        await testStore.send(.editEmailAddress(.alert(.presented(.dismiss)))) {
            $0.editEmailAddress.saveEmailFailureAlert = nil
        }
    }

    // MARK: Email Verification Help State Manipulation

    func test_help_navigates_to_edit_email() async throws {
        await testStore.send(.emailVerificationHelp(.editEmailAddress))
        await testStore.receive(.presentStep(.editEmailAddress)) {
            $0.flowStep = .editEmailAddress
        }
    }

    func test_help_resend_verificationEmail_success() async throws {
        await testStore.send(.emailVerificationHelp(.alert(.presented(.sendVerificationEmail)))) {
            $0.emailVerificationHelp.sendingVerificationEmail = true
        }
        await testStore.receive(.emailVerificationHelp(.didReceiveEmailSendingResponse(.success(0)))) {
            $0.emailVerificationHelp.sendingVerificationEmail = false
        }
        await testStore.receive(.presentStep(.verifyEmailPrompt))
    }

    func test_help_resend_verificationEmail_failure() async throws {
        emailVerificationService?.stubbedResults.sendVerificationEmail = .failure(.missingCredentials)
        await testStore.send(.emailVerificationHelp(.alert(.presented(.sendVerificationEmail)))) {
            $0.emailVerificationHelp.sendingVerificationEmail = true
        }
        await testStore.receive(.emailVerificationHelp(.didReceiveEmailSendingResponse(.failure(.missingCredentials)))) {
            $0.emailVerificationHelp.sendingVerificationEmail = false
            $0.emailVerificationHelp.sentFailedAlert = AlertState(
                title: TextState(L10n.GenericError.title),
                message: TextState(L10n.EmailVerificationHelp.couldNotSendEmailAlertMessage),
                primaryButton: .default(
                    TextState(L10n.GenericError.retryButtonTitle),
                    action: .send(.sendVerificationEmail)
                ),
                secondaryButton: .cancel(TextState(L10n.GenericError.cancelButtonTitle))
            )
        }
        await testStore.send(.emailVerificationHelp(.alert(.presented(.dismiss)))) {
            $0.emailVerificationHelp.sentFailedAlert = nil
        }
    }

    // MARK: - Helpers

    private func resetTestStore(emailAddress: String = "test@example.com") {
        emailVerificationService = MockEmailVerificationService()
        testStore = TestStore(
            initialState: EmailVerificationState(emailAddress: emailAddress),
            reducer: {
                EmailVerificationReducer(
                    analyticsRecorder: MockAnalyticsRecorder(),
                    emailVerificationService: emailVerificationService,
                    flowCompletionCallback: { [weak self] result in
                        self?.recordedInvocations.flowCompletionCallback.append(result)
                    },
                    openMailApp: { [unowned self] in
                        stubbedResults.canOpenMailApp
                    },
                    app: App.test,
                    mainQueue: .immediate,
                    pollingQueue: testPollingQueue.eraseToAnyScheduler()
                )
            }
        )
    }
}
