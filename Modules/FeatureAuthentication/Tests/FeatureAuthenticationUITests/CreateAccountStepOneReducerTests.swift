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

@MainActor final class CreateAccountStepOneReducerTests: XCTestCase {

    private var testStore: TestStore<
        CreateAccountStepOneState,
        CreateAccountStepOneAction
    >!
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    override func setUpWithError() throws {
        try super.setUpWithError()
        testStore = TestStore(
            initialState: CreateAccountStepOneState(context: .createWallet),
            reducer: {
                CreateAccountStepOneReducer(
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
            }
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        try super.tearDownWithError()
    }

    func test_tapping_next_validates_input_invalidCountry() async throws {
        // GIVEN: The form is invalid
        // WHEN: The user taps on the Next button in either part of the UI
        await testStore.send(.nextStepButtonTapped) {
            $0.validatingInput = true
            $0.isGoingToNextStep = true
        }
        // THEN: The form is validated
        await mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        await testStore.receive(.didUpdateInputValidation(.invalid(.noCountrySelected))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.noCountrySelected)
        }
        await testStore.receive(.didUpdateReferralValidation(.unknown))
        await testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_validates_input_invalidState() async throws {
        // GIVEN: The form is invalid
        await fillFormCountryField()
        // WHEN: The user taps on the Next button in either part of the UI
        await testStore.send(.nextStepButtonTapped) {
            $0.validatingInput = true
            $0.isGoingToNextStep = true
        }
        // THEN: The form is validated
        await mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        await testStore.receive(.didUpdateInputValidation(.invalid(.noCountryStateSelected))) {
            $0.validatingInput = false
            $0.inputValidationState = .invalid(.noCountryStateSelected)
        }
        await testStore.receive(.didUpdateReferralValidation(.unknown))
        await testStore.receive(.didValidateAfterFormSubmission)
    }

    func test_tapping_next_goes_to_next_step_form() async throws {
        testStore = TestStore(
            initialState: CreateAccountStepOneState(context: .createWallet),
            reducer: {
                CreateAccountStepOneReducer(
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
            }
        )
        // GIVEN: The form is valid
        await fillFormWithValidData()
        // WHEN: The user taps on the Next button in either part of the UI
        await testStore.send(.nextStepButtonTapped) {
            $0.validatingInput = true
            $0.isGoingToNextStep = true
        }
        // THEN: The form is validated
        await mainScheduler.advance() // let the validation complete
        // AND: The state is updated
        await testStore.receive(.didUpdateInputValidation(.valid)) {
            $0.validatingInput = false
            $0.inputValidationState = .valid
        }
        await testStore.receive(.didUpdateReferralValidation(.unknown))
        await testStore.receive(.didValidateAfterFormSubmission)
        // AND: The form submission creates an account
        await testStore.receive(.goToStepTwo)
        await testStore.receive(.route(.navigate(to: .createWalletStepTwo))) {
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

    private func fillFormWithValidData() async {
        await fillFormCountryField()
        await fillFormCountryStateField()
    }

    private func fillFormCountryField(country: SearchableItem<String> = .init(id: "US", title: "United States")) async {
        await testStore.send(.binding(.set(\.$country, country))) {
            $0.country = country
        }
        await testStore.receive(.didUpdateInputValidation(.unknown))
        await testStore.receive(.binding(.set(\.$selectedAddressSegmentPicker, nil)))
        await testStore.receive(.route(nil))
    }

    private func fillFormCountryStateField(state: SearchableItem<String> = SearchableItem(id: "FL", title: "Florida")) async {
        await testStore.send(.binding(.set(\.$countryState, state))) {
            $0.countryState = state
        }
        await testStore.receive(.didUpdateInputValidation(.unknown))
        await testStore.receive(.binding(.set(\.$selectedAddressSegmentPicker, nil)))
        await testStore.receive(.route(nil))
    }
}
