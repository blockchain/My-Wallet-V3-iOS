// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
@testable import FeatureAuthenticationUI
import ToolKitMock
import UIComponentsKit
import XCTest

final class CreateAccountStepTwoReducerTests: XCTestCase {

    private var testStore: TestStore<
        CreateAccountStepTwoState,
        CreateAccountStepTwoAction,
        CreateAccountStepTwoState,
        CreateAccountStepTwoAction,
        CreateAccountStepTwoEnvironment
    >!
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    override func setUpWithError() throws {
        try super.setUpWithError()
        testStore = TestStore(
            initialState: CreateAccountStepTwoState(
                context: .createWallet,
                country: SearchableItem(id: "US", title: "United States"),
                countryState: SearchableItem(id: "FL", title: "Florida"),
                referralCode: ""
            ),
            reducer: createAccountStepTwoReducer,
            environment: CreateAccountStepTwoEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                passwordValidator: PasswordValidator(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock(),
                walletFetcherService: WalletFetcherServiceMock().mock(),
                featureFlagsService: MockFeatureFlagsService(),
                recaptchaService: MockRecaptchaService()
            )
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        try super.tearDownWithError()
    }

    func test_tapping_next_validates_input_invalidEmail() throws {
        // GIVEN: The form is invalid
        // no-op as form starts emapty
        // WHEN: The user taps on the Next button in either part of the UI
        testStore.send(.createButtonTapped) {
            $0.validatingInput = true
        }
        // THEN: The form is validated
        mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        testStore.receive(.didUpdateInputValidation(.invalid(.invalidEmail))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.invalidEmail)
        }
        testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_validates_input_invalidPassword() throws {
        // GIVEN: The form is invalid
        fillFormEmailField()
        // WHEN: The user taps on the Next button in either part of the UI
        testStore.send(.createButtonTapped) {
            $0.validatingInput = true
        }
        // THEN: The form is validated
        mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        testStore.receive(.didUpdateInputValidation(.invalid(.weakPassword))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.weakPassword)
        }
        testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_validates_input_termsNotAccepted() throws {
        // GIVEN: The form is invalid
        fillFormEmailField()
        fillFormPasswordField()
        // WHEN: The user taps on the Next button in either part of the UI
        testStore.send(.createButtonTapped) {
            $0.validatingInput = true
        }
        // THEN: The form is validated
        mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        testStore.receive(.didUpdateInputValidation(.invalid(.termsNotAccepted))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.termsNotAccepted)
        }
        testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_creates_an_account_when_valid_form() throws {
        testStore = TestStore(
            initialState: CreateAccountStepTwoState(
                context: .createWallet,
                country: SearchableItem(id: "US", title: "United States"),
                countryState: SearchableItem(id: "FL", title: "Florida"),
                referralCode: ""
            ),
            reducer: createAccountStepTwoReducer,
            environment: CreateAccountStepTwoEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                passwordValidator: PasswordValidator(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .failing(),
                walletFetcherService: WalletFetcherServiceMock().mock(),
                featureFlagsService: MockFeatureFlagsService(),
                recaptchaService: MockRecaptchaService()
            )
        )
        // GIVEN: The form is valid
        fillFormWithValidData()
        // WHEN: The user taps on the Next button in either part of the UI
        testStore.send(.createButtonTapped) {
            $0.validatingInput = true
        }
        // THEN: The form is validated
        mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        testStore.receive(.didUpdateInputValidation(.valid)) {
            $0.validatingInput = false
            $0.inputValidationState = .valid
        }
        testStore.receive(.didValidateAfterFormSubmission)
        // AND: The form submission creates an account
        testStore.receive(.createOrImportWallet(.createWallet))
        let token = ""
        testStore.receive(.createAccount(.success(token))) {
            $0.isCreatingWallet = true
        }
        testStore.receive(.triggerAuthenticate)
        testStore.receive(.accountCreation(.failure(.creationFailure(.genericFailure)))) {
            $0.isCreatingWallet = false
        }
        testStore.receive(
            .alert(
                .show(
                    title: "Error",
                    message: "Something went wrong."
                )
            )
        ) {
            $0.failureAlert = AlertState(
                title: TextState("Error"),
                message: TextState("Something went wrong."),
                dismissButton: AlertState.Button.default(
                    TextState("OK"),
                    action: AlertState.ButtonAction.send(
                        CreateAccountStepTwoAction.alert(CreateAccountStepTwoAction.AlertAction.dismiss)
                    )
                )
            )
        }
    }

    // MARK: - Helpers

    private func fillFormWithValidData() {
        fillFormEmailField()
        fillFormPasswordField()
        fillFormAcceptanceOfTermsAndConditions()
    }

    private func fillFormEmailField(email: String = "test@example.com") {
        testStore.send(.binding(.set(\.$emailAddress, email))) {
            $0.emailAddress = email
        }
        testStore.receive(.didUpdateInputValidation(.unknown))
    }

    private func fillFormPasswordField(
        password: String = "MyPass124)",
        expectedScore: PasswordValidationScore = .normal
    ) {
        testStore.send(.binding(.set(\.$password, password))) {
            $0.password = password
        }
        testStore.receive(.didUpdateInputValidation(.unknown))
        testStore.receive(.validatePasswordStrength)
        mainScheduler.advance()
        testStore.receive(.didUpdatePasswordStrenght(expectedScore)) {
            $0.passwordStrength = expectedScore
        }
    }

    private func fillFormAcceptanceOfTermsAndConditions(termsAccepted: Bool = true) {
        testStore.send(.binding(.set(\.$termsAccepted, termsAccepted))) {
            $0.termsAccepted = termsAccepted
        }
        testStore.receive(.didUpdateInputValidation(.unknown))
    }
}
