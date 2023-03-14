// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AnalyticsKitMock
import ComposableArchitecture
@testable import FeatureKYCDomain
@testable import FeatureKYCDomainMock
@testable import FeatureKYCUI
@testable import FeatureKYCUIMock
import Localization
import TestKit
import XCTest

private typealias L10n = LocalizationConstants.NewKYC

final class EmailVerificationReducerTests: XCTestCase {

    fileprivate struct RecordedInvocations {
        var flowCompletionCallback: [FlowResult] = []
    }

    fileprivate struct StubbedResults {
        var canOpenMailApp: Bool = false
    }

    private var recordedInvocations: RecordedInvocations!
    private var stubbedResults: StubbedResults!

    private var testPollingQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        EmailVerificationState,
        EmailVerificationAction,
        EmailVerificationState,
        EmailVerificationAction,
        EmailVerificationEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        recordedInvocations = RecordedInvocations()
        stubbedResults = StubbedResults()
        testPollingQueue = DispatchQueue.test
        resetTestStore()
    }

    override func tearDownWithError() throws {
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

    func test_closes_flow_as_abandoned_when_closeButton_tapped() throws {
        XCTAssertEqual(recordedInvocations.flowCompletionCallback, [])
        testStore.assert(
            .send(.closeButtonTapped),
            .do {
                XCTAssertEqual(self.recordedInvocations.flowCompletionCallback, [.abandoned])
            }
        )
    }

    func test_polls_verificationStatus_every_few_seconds_while_on_screen() throws {
        // poll currently set to 5 seconds
        testStore.assert(
            .send(.didAppear),
            .do {
                // nothing should happen after 1 second
                self.testPollingQueue.advance(by: 1)
            },
            .do {
                // poll should happen after 4 more seconds (5 seconds in total)
                self.testPollingQueue.advance(by: 4)
            },
            .receive(.loadVerificationState),
            .receive(
                .didReceiveEmailVerficationResponse(
                    .success(
                        .init(emailAddress: "test@example.com", status: .unverified)
                    )
                )
            ),
            .receive(.presentStep(.verifyEmailPrompt)),
            .send(.didDisappear),
            .do {
                // no more actions should be received after view disappears
                self.testPollingQueue.advance(by: 15)
            }
        )
    }

    func test_polling_verificationStatus_doesNot_redirectTo_anotherStep_when_editingEmail() throws {
        // poll currently set to 5 seconds
        testStore.assert(
            .send(.didAppear),
            .do {
                // nothing should happen after 1 second
                self.testPollingQueue.advance(by: 1)
            },
            .send(.presentStep(.editEmailAddress)) {
                $0.flowStep = .editEmailAddress
            },
            .do {
                // poll should happen after 4 more seconds (5 seconds in total)
                self.testPollingQueue.advance(by: 4)
            },
            .receive(.loadVerificationState),
            .receive(
                .didReceiveEmailVerficationResponse(
                    .success(
                        .init(emailAddress: "test@example.com", status: .unverified)
                    )
                )
            ),
            .send(.didDisappear),
            .do {
                // no more actions should be received after view disappears
                self.testPollingQueue.advance(by: 15)
            }
        )
    }

    func test_loads_verificationStatus_when_app_opened_unverified() throws {
        testStore.assert(
            .send(.didEnterForeground),
            .receive(.presentStep(.loadingVerificationState)) {
                $0.flowStep = .loadingVerificationState
            },
            .receive(.loadVerificationState),
            .receive(
                .didReceiveEmailVerficationResponse(
                    .success(
                        .init(emailAddress: "test@example.com", status: .unverified)
                    )
                )
            ),
            .receive(.presentStep(.verifyEmailPrompt)) {
                $0.flowStep = .verifyEmailPrompt
            }
        )
    }

    func test_loads_verificationStatus_when_app_opened_verified() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.checkEmailVerificationStatus = .just(
            .init(emailAddress: "test@example.com", status: .verified)
        )
        testStore.assert(
            .send(.didEnterForeground),
            .receive(.presentStep(.loadingVerificationState)) {
                $0.flowStep = .loadingVerificationState
            },
            .receive(.loadVerificationState),
            .receive(
                .didReceiveEmailVerficationResponse(
                    .success(.init(emailAddress: "test@example.com", status: .verified))
                )
            ),
            .receive(.presentStep(.emailVerifiedPrompt)) {
                $0.flowStep = .emailVerifiedPrompt
            }
        )
    }

    func test_loads_verificationStatus_when_app_opened_error() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.checkEmailVerificationStatus = .failure(.unknown(MockError.unknown))
        testStore.assert(
            .send(.didEnterForeground),
            .receive(.presentStep(.loadingVerificationState)) {
                $0.flowStep = .loadingVerificationState
            },
            .receive(.loadVerificationState),
            .receive(.didReceiveEmailVerficationResponse(.failure(.unknown(MockError.unknown)))) {
                $0.emailVerificationFailedAlert = AlertState(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                    primaryButton: AlertState.Button.default(
                        TextState(L10n.GenericError.retryButtonTitle),
                        action: .send(.loadVerificationState)
                    ),
                    secondaryButton: AlertState.Button.cancel(TextState(L10n.GenericError.cancelButtonTitle))
                )
            },
            .receive(.presentStep(.verificationCheckFailed)) {
                $0.flowStep = .verificationCheckFailed
            }
        )
    }

    func test_dismisses_verification_status_error() throws {
        testStore.assert(
            .send(.didReceiveEmailVerficationResponse(.failure(.unknown(MockError.unknown)))) {
                $0.emailVerificationFailedAlert = AlertState(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                    primaryButton: AlertState.Button.default(
                        TextState(L10n.GenericError.retryButtonTitle),
                        action: .send(.loadVerificationState)
                    ),
                    secondaryButton: AlertState.Button.cancel(TextState(L10n.GenericError.cancelButtonTitle))
                )
            },
            .receive(.presentStep(.verificationCheckFailed)) {
                $0.flowStep = .verificationCheckFailed
            },
            .send(.dismissEmailVerificationFailedAlert) {
                $0.emailVerificationFailedAlert = nil
            },
            .receive(.presentStep(.verifyEmailPrompt)) {
                $0.flowStep = .verifyEmailPrompt
            }
        )
    }

    // MARK: Verify Email State Manipulation

    func test_opens_inbox_failed() throws {
        testStore.assert(
            .send(.verifyEmail(.tapCheckInbox)),
            .receive(.verifyEmail(.presentCannotOpenMailAppAlert)) {
                $0.verifyEmail.cannotOpenMailAppAlert = AlertState(title: .init("Cannot Open Mail App"))
            },
            .send(.verifyEmail(.dismissCannotOpenMailAppAlert)) {
                $0.verifyEmail.cannotOpenMailAppAlert = nil
            }
        )
    }

    func test_opens_inbox_success() throws {
        stubbedResults.canOpenMailApp = true
        testStore.assert(
            .send(.verifyEmail(.tapCheckInbox)),
            .receive(.verifyEmail(.dismissCannotOpenMailAppAlert))
        )
    }

    func test_navigates_to_help() throws {
        testStore.assert(
            .send(.verifyEmail(.tapGetEmailNotReceivedHelp)),
            .receive(.presentStep(.emailVerificationHelp)) {
                $0.flowStep = .emailVerificationHelp
            }
        )
    }

    // MARK: Email Verified State Manipulation

    func test_email_verified_continue_calls_flowCompletion_as_completed() throws {
        XCTAssertEqual(recordedInvocations.flowCompletionCallback, [])
        testStore.assert(
            .send(.emailVerified(.acknowledgeEmailVerification)),
            .do {
                XCTAssertEqual(self.recordedInvocations.flowCompletionCallback, [.completed])
            }
        )
    }

    // MARK: Edit Email State Manipulation

    func test_edit_email_validates_email_on_appear_validEmail() throws {
        XCTAssertTrue(testStore.state.editEmailAddress.isEmailValid)
        XCTAssertEqual(testStore.state.flowStep, .verifyEmailPrompt)
        XCTAssertFalse(testStore.state.editEmailAddress.savingEmailAddress)
        testStore.send(.editEmailAddress(.didAppear))
    }

    func test_edit_email_validates_email_on_appear_invalidEmail() throws {
        resetTestStore(emailAddress: "test_example.com")
        XCTAssertFalse(testStore.state.editEmailAddress.isEmailValid)
        testStore.send(.editEmailAddress(.didAppear))
    }

    func test_edit_email_validates_email_on_appear_emptyEmail() throws {
        resetTestStore(emailAddress: "")
        XCTAssertFalse(testStore.state.editEmailAddress.isEmailValid)
        testStore.send(.editEmailAddress(.didAppear))
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_validEmail() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("example@test.com"))) {
                $0.editEmailAddress.emailAddress = "example@test.com"
                $0.editEmailAddress.isEmailValid = true
            }
        )
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_invalidEmail() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("example_test.com"))) {
                $0.editEmailAddress.emailAddress = "example_test.com"
                $0.editEmailAddress.isEmailValid = false
            }
        )
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_emptyEmail() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress(""))) {
                $0.editEmailAddress.emailAddress = ""
                $0.editEmailAddress.isEmailValid = false
            }
        )
    }

    func test_edit_email_save_success() throws {
        testStore.send(.editEmailAddress(.didAppear))
        testStore.send(.editEmailAddress(.save)) {
            $0.editEmailAddress.savingEmailAddress = true
        }
        testStore.receive(.editEmailAddress(.didReceiveSaveResponse(.success(0)))) {
            $0.editEmailAddress.savingEmailAddress = false
        }
        testStore.receive(.presentStep(.verifyEmailPrompt))
    }

    func test_edit_email_edit_and_save_success() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("someone@example.com"))) {
                $0.editEmailAddress.emailAddress = "someone@example.com"
                $0.editEmailAddress.isEmailValid = true
            },
            .send(.editEmailAddress(.save)) {
                $0.editEmailAddress.savingEmailAddress = true
            },
            .receive(.editEmailAddress(.didReceiveSaveResponse(.success(0)))) {
                $0.editEmailAddress.savingEmailAddress = false
                $0.verifyEmail.emailAddress = "someone@example.com"
                $0.emailVerificationHelp.emailAddress = "someone@example.com"
            },
            .receive(.presentStep(.verifyEmailPrompt))
        )
    }

    func test_edit_email_attemptingTo_save_invalidEmail_does_nothing() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("someone_example.com"))) {
                $0.editEmailAddress.emailAddress = "someone_example.com"
                $0.editEmailAddress.isEmailValid = false
            },
            .send(.editEmailAddress(.save))
        )
    }

    func test_edit_email_save_failure() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.updateEmailAddress = .failure(.missingCredentials)
        testStore.assert(
            .send(.editEmailAddress(.didAppear)),
            .send(.editEmailAddress(.save)) {
                $0.editEmailAddress.savingEmailAddress = true
            },
            .receive(.editEmailAddress(.didReceiveSaveResponse(.failure(.missingCredentials)))) {
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
            },
            .send(.editEmailAddress(.dismissSaveEmailFailureAlert)) {
                $0.editEmailAddress.saveEmailFailureAlert = nil
            }
        )
    }

    // MARK: Email Verification Help State Manipulation

    func test_help_navigates_to_edit_email() throws {
        testStore.assert(
            .send(.emailVerificationHelp(.editEmailAddress)),
            .receive(.presentStep(.editEmailAddress)) {
                $0.flowStep = .editEmailAddress
            }
        )
    }

    func test_help_resend_verificationEmail_success() throws {
        testStore.assert(
            .send(.emailVerificationHelp(.sendVerificationEmail)) {
                $0.emailVerificationHelp.sendingVerificationEmail = true
            },
            .receive(.emailVerificationHelp(.didReceiveEmailSendingResponse(.success(0)))) {
                $0.emailVerificationHelp.sendingVerificationEmail = false
            },
            .receive(.presentStep(.verifyEmailPrompt))
        )
    }

    func test_help_resend_verificationEmail_failure() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.sendVerificationEmail = .failure(.missingCredentials)
        testStore.assert(
            .send(.emailVerificationHelp(.sendVerificationEmail)) {
                $0.emailVerificationHelp.sendingVerificationEmail = true
            },
            .receive(.emailVerificationHelp(.didReceiveEmailSendingResponse(.failure(.missingCredentials)))) {
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
            },
            .send(.emailVerificationHelp(.dismissEmailSendingFailureAlert)) {
                $0.emailVerificationHelp.sentFailedAlert = nil
            }
        )
    }

    // MARK: - Helpers

    private func resetTestStore(emailAddress: String = "test@example.com") {
        testStore = TestStore(
            initialState: EmailVerificationState(emailAddress: emailAddress),
            reducer: emailVerificationReducer,
            environment: EmailVerificationEnvironment(
                analyticsRecorder: MockAnalyticsRecorder(),
                emailVerificationService: MockEmailVerificationService(),
                flowCompletionCallback: { [weak self] result in
                    self?.recordedInvocations.flowCompletionCallback.append(result)
                },
                openMailApp: { [unowned self] in
                    Effect(value: stubbedResults.canOpenMailApp)
                },
                mainQueue: .immediate,
                pollingQueue: testPollingQueue.eraseToAnyScheduler()
            )
        )
    }
}
