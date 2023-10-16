// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
import ErrorsUI
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
@testable import FeatureAuthenticationUI
import Localization
import ToolKitMock
import UIComponentsKit
import XCTest

@MainActor final class CreateAccountStepTwoReducerTests: XCTestCase {

    private var testStore: TestStore<
        CreateAccountStepTwoState,
        CreateAccountStepTwoAction
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
            reducer: {
                CreateAccountStepTwoReducer(
                    mainQueue: mainScheduler.eraseToAnyScheduler(),
                    passwordValidator: PasswordValidator(),
                    externalAppOpener: MockExternalAppOpener(),
                    analyticsRecorder: MockAnalyticsRecorder(),
                    walletRecoveryService: .mock(),
                    walletCreationService: .mock(),
                    walletFetcherService: WalletFetcherServiceMock().mock(),
                    recaptchaService: MockRecaptchaService()
                )
            }
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        try super.tearDownWithError()
    }

    func test_tapping_next_validates_input_invalidEmail() async throws {
        // GIVEN: The form is invalid
        // no-op as form starts emapty
        // WHEN: The user taps on the Next button in either part of the UI
        await testStore.send(.createButtonTapped) {
            $0.validatingInput = true
        }
        // THEN: The form is validated
        await mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        await testStore.receive(.didUpdateInputValidation(.invalid(.invalidEmail))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.invalidEmail)
            $0.inputConfirmationValidationState = .valid
        }
        await testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_validates_input_invalidPassword() async throws {
        // GIVEN: The form is invalid
        await fillFormEmailField()
        // WHEN: The user taps on the Next button in either part of the UI
        await testStore.send(.createButtonTapped) {
            $0.validatingInput = true
        }
        // THEN: The form is validated
        await mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        await testStore.receive(
            .didUpdateInputValidation(
                .invalid(
                    .weakPassword(
                        [
                            .lowercaseLetter,
                            .uppercaseLetter,
                            .number,
                            .specialCharacter,
                            .length
                        ]
                    )
                )
            )
        ) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.weakPassword([.lowercaseLetter, .uppercaseLetter, .number, .specialCharacter, .length]))
            $0.inputConfirmationValidationState = .valid
        }
        await testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_creates_an_account_when_valid_form() async throws {
        testStore = TestStore(
            initialState: CreateAccountStepTwoState(
                context: .createWallet,
                country: SearchableItem(id: "US", title: "United States"),
                countryState: SearchableItem(id: "FL", title: "Florida"),
                referralCode: ""
            ),
            reducer: {
                CreateAccountStepTwoReducer(
                    mainQueue: mainScheduler.eraseToAnyScheduler(),
                    passwordValidator: PasswordValidator(),
                    externalAppOpener: MockExternalAppOpener(),
                    analyticsRecorder: MockAnalyticsRecorder(),
                    walletRecoveryService: .mock(),
                    walletCreationService: .failing(),
                    walletFetcherService: WalletFetcherServiceMock().mock(),
                    recaptchaService: MockRecaptchaService()
                )
            }
        )
        // GIVEN: The form is valid
        await fillFormWithValidData()
        // WHEN: The user taps on the Next button in either part of the UI
        await testStore.send(.createButtonTapped) {
            $0.validatingInput = true
        }
        // THEN: The form is validated
        await mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        await testStore.receive(.didUpdateInputValidation(.valid)) {
            $0.validatingInput = false
            $0.inputConfirmationValidationState = .valid
            $0.inputValidationState = .valid
        }
        await testStore.receive(.didValidateAfterFormSubmission)
        // AND: The form submission creates an account
        await testStore.receive(.createOrImportWallet(.createWallet))
        let token = ""
        await testStore.receive(.createAccount(.success(token))) {
            $0.isCreatingWallet = true
        }
        await testStore.receive(.triggerAuthenticate)
        await testStore.receive(.accountCreation(.failure(.creationFailure(.genericFailure)))) {
            $0.isCreatingWallet = false
            $0.fatalError = UX.Error(
                source: WalletCreationServiceError.creationFailure(.genericFailure),
                title: LocalizationConstants.FeatureAuthentication.CreateAccount.FatalError.title,
                message: "Something went wrong.",
                actions: [UX.Action(title: LocalizationConstants.FeatureAuthentication.CreateAccount.FatalError.action)]
            )
        }
    }

    // MARK: - Helpers

    private func fillFormWithValidData() async {
        await fillFormEmailField()
        await fillFormPasswordField()
    }

    private func fillFormEmailField(email: String = "test@example.com") async {
        await testStore.send(.binding(.set(\.$emailAddress, email))) {
            $0.emailAddress = email
        }
        await testStore.receive(.didUpdateInputValidation(.unknown)) {
            $0.inputConfirmationValidationState = .valid
        }
    }

    private func fillFormPasswordField(
        password: String = "MyPass124(",
        expectedScore: [PasswordValidationRule] = []
    ) async {
        await testStore.send(.binding(.set(\.$password, password))) {
            $0.password = password
        }
        await testStore.receive(.didUpdateInputValidation(.unknown))
        await testStore.receive(.validatePasswordStrength)
        await mainScheduler.advance()

        if expectedScore.isEmpty {
            await testStore.receive(.didUpdatePasswordRules(expectedScore))
        } else {
            await testStore.receive(.didUpdatePasswordRules(expectedScore)) {
                $0.passwordRulesBreached = expectedScore
            }
        }
    }
}
