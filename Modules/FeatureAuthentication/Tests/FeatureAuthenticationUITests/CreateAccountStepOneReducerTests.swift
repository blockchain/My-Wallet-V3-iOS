// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
@testable import FeatureAuthenticationUI
import ToolKitMock
import UIComponentsKit
import XCTest

final class CreateAccountStepOneReducerTests: XCTestCase {

    private var testStore: TestStore<
        CreateAccountStepOneState,
        CreateAccountStepOneAction,
        CreateAccountStepOneState,
        CreateAccountStepOneAction,
        CreateAccountStepOneEnvironment
    >!
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    override func setUpWithError() throws {
        try super.setUpWithError()
        testStore = TestStore(
            initialState: CreateAccountStepOneState(context: .createWallet),
            reducer: createAccountStepOneReducer,
            environment: CreateAccountStepOneEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                passwordValidator: PasswordValidator(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock(),
                walletFetcherService: WalletFetcherServiceMock().mock(),
                signUpCountriesService: MockSignUpCountriesService(),
                recaptchaService: MockRecaptchaService(),
                app: App.test
            )
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        try super.tearDownWithError()
    }

    func test_tapping_next_validates_input_invalidCountry() throws {
        // GIVEN: The form is invalid
        // WHEN: The user taps on the Next button in either part of the UI
        testStore.send(.nextStepButtonTapped) {
            $0.validatingInput = true
            $0.isGoingToNextStep = true
        }
        // THEN: The form is validated
        mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        testStore.receive(.didUpdateInputValidation(.invalid(.noCountrySelected))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.noCountrySelected)
        }
        testStore.receive(.didUpdateReferralValidation(.unknown))
        testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_validates_input_invalidState() throws {
        // GIVEN: The form is invalid
        fillFormCountryField()
        // WHEN: The user taps on the Next button in either part of the UI
        testStore.send(.nextStepButtonTapped) {
            $0.validatingInput = true
            $0.isGoingToNextStep = true
        }
        // THEN: The form is validated
        mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        testStore.receive(.didUpdateInputValidation(.invalid(.noCountryStateSelected))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.noCountryStateSelected)
        }
        testStore.receive(.didUpdateReferralValidation(.unknown))
        testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_goes_to_next_step_form() throws {
        testStore = TestStore(
            initialState: CreateAccountStepOneState(context: .createWallet),
            reducer: createAccountStepOneReducer,
            environment: CreateAccountStepOneEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                passwordValidator: PasswordValidator(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .failing(),
                walletFetcherService: WalletFetcherServiceMock().mock(),
                signUpCountriesService: MockSignUpCountriesService(),
                recaptchaService: MockRecaptchaService(),
                app: App.test
            )
        )
        // GIVEN: The form is valid
        fillFormWithValidData()
        // WHEN: The user taps on the Next button in either part of the UI
        testStore.send(.nextStepButtonTapped) {
            $0.validatingInput = true
            $0.isGoingToNextStep = true
        }
        // THEN: The form is validated
        mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        testStore.receive(.didUpdateInputValidation(.valid)) {
            $0.validatingInput = false
            $0.inputValidationState = .valid
        }
        testStore.receive(.didUpdateReferralValidation(.unknown))
        testStore.receive(.didValidateAfterFormSubmission)
        // AND: The form submission creates an account
        testStore.receive(.goToStepTwo)
        testStore.receive(.route(.navigate(to: .createWalletStepTwo))) {
            $0.route = RouteIntent(route: .createWalletStepTwo, action: .navigateTo)
            $0.createWalletStateStepTwo = .init(
                context: .createWallet,
                country: SearchableItem(id: "US", title: "United States"),
                countryState: SearchableItem(id: "FL", title: "Florida"),
                referralCode: ""
            )
        }
    }

    // MARK: - Helpers

    private func fillFormWithValidData() {
        fillFormCountryField()
        fillFormCountryStateField()
    }

    private func fillFormCountryField(country: SearchableItem<String> = .init(id: "US", title: "United States")) {
        testStore.send(.binding(.set(\.$country, country))) {
            $0.country = country
        }
        testStore.receive(.didUpdateInputValidation(.unknown))
        testStore.receive(.binding(.set(\.$selectedAddressSegmentPicker, nil)))
        testStore.receive(.route(nil))
    }

    private func fillFormCountryStateField(state: SearchableItem<String> = SearchableItem(id: "FL", title: "Florida")) {
        testStore.send(.binding(.set(\.$countryState, state))) {
            $0.countryState = state
        }
        testStore.receive(.didUpdateInputValidation(.unknown))
        testStore.receive(.binding(.set(\.$selectedAddressSegmentPicker, nil)))
        testStore.receive(.route(nil))
    }
}
