// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
@testable import FeatureAuthenticationUI
import ToolKit
@testable import WalletPayloadKit
import XCTest

@testable import AnalyticsKitMock
@testable import ToolKitMock

final class SeedPhraseReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        SeedPhraseState,
        SeedPhraseAction,
        SeedPhraseState,
        SeedPhraseAction,
        SeedPhraseEnvironment
    >!

    private let recoverFromMetadata = PassthroughSubject<EmptyValue, WalletRecoveryError>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        let walletFetcherServiceMock = WalletFetcherServiceMock()
        testStore = TestStore(
            initialState: .init(context: .restoreWallet),
            reducer: seedPhraseReducer,
            environment: SeedPhraseEnvironment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                validator: SeedPhraseValidator(words: Set(WordList.defaultWords)),
                passwordValidator: PasswordValidator(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock(),
                walletFetcherService: walletFetcherServiceMock.mock(),
                accountRecoveryService: MockAccountRecoveryService(),
                signUpCountriesService: MockSignUpCountriesService(),
                errorRecorder: MockErrorRecorder(),
                recaptchaService: MockRecaptchaService(),
                app: App.test
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = SeedPhraseState(context: .restoreWallet)
        XCTAssertEqual(state.seedPhrase, "")
        XCTAssertEqual(state.seedPhraseScore, .none)
    }

    func test_seed_phrase_validator_should_update_score() {
        let completePhrase = "echo abandon dose scheme win real fiber snake void board utility jacket"
        let incompletePhrase = "echo"
        let excessPhrase = "echo abandon dose scheme win real fiber snake void board utility jacket more"
        let invalidPhrase = "echo abandon dose scheme win real fiber snake void board utility mac"
        let invalidRange = NSRange(location: 65, length: 3)
        // GIVEN: Complete Seed Phrase
        testStore.send(.didChangeSeedPhrase(completePhrase)) { state in
            state.seedPhrase = completePhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `complete`
        testStore.receive(.didChangeSeedPhraseScore(.valid)) { state in
            state.seedPhraseScore = .valid
        }

        // GIVEN: Incomplete Seed Phrase
        testStore.send(.didChangeSeedPhrase(incompletePhrase)) { state in
            state.seedPhrase = incompletePhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `incomplete`
        testStore.receive(.didChangeSeedPhraseScore(.incomplete)) { state in
            state.seedPhraseScore = .incomplete
        }

        // GIVEN: Excess Seed Phrase
        testStore.send(.didChangeSeedPhrase(excessPhrase)) { state in
            state.seedPhrase = excessPhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `excess`
        testStore.receive(.didChangeSeedPhraseScore(.excess)) { state in
            state.seedPhraseScore = .excess
        }

        // GIVEN: Invalid Seed Phrase
        testStore.send(.didChangeSeedPhrase(invalidPhrase)) { state in
            state.seedPhrase = invalidPhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `invalid`
        testStore.receive(.didChangeSeedPhraseScore(.invalid([invalidRange]))) { state in
            state.seedPhraseScore = .invalid([invalidRange])
        }
    }

    func test_account_resetting() {
        let walletFetcherServiceMock = WalletFetcherServiceMock()
        // given a valid `Nabu` model
        let nabuInfo = WalletInfo.Nabu(
            userId: "userId",
            recoveryToken: "recoveryToken",
            recoverable: true
        )
        testStore = TestStore(
            initialState: .init(context: .troubleLoggingIn, emailAddress: "email@email.com", nabuInfo: nabuInfo),
            reducer: seedPhraseReducer,
            environment: SeedPhraseEnvironment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                validator: SeedPhraseValidator(words: Set(WordList.defaultWords)),
                passwordValidator: PasswordValidator(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock(),
                walletFetcherService: walletFetcherServiceMock.mock(),
                accountRecoveryService: MockAccountRecoveryService(),
                signUpCountriesService: MockSignUpCountriesService(),
                errorRecorder: MockErrorRecorder(),
                recaptchaService: MockRecaptchaService(),
                app: App.test
            )
        )

        testStore.send(.setLostFundsWarningScreenVisible(true)) { state in
            state.lostFundsWarningState = .init()
            state.isLostFundsWarningScreenVisible = true
        }

        testStore.send(.lostFundsWarning(.setResetPasswordScreenVisible(true))) { state in
            state.lostFundsWarningState?.resetPasswordState = .init()
            state.lostFundsWarningState?.isResetPasswordScreenVisible = true
            state.isLostFundsWarningScreenVisible = true
        }

        testStore.send(.lostFundsWarning(.resetPassword(.reset(password: "password")))) { state in
            state.lostFundsWarningState?.resetPasswordState?.isLoading = true
        }
        mockMainQueue.advance()
        let walletCreatedContext = WalletCreatedContext(
            guid: "guid",
            sharedKey: "sharedKey",
            password: "password"
        )
        let passwordHash = "5e884" // hash for "password" from `hashPasword`
        testStore.receive(.triggerAuthenticate)
        testStore.receive(.accountCreation(.success(walletCreatedContext)))
        mockMainQueue.advance()
        let accountRecoverContext = AccountResetContext(
            walletContext: walletCreatedContext,
            offlineToken: NabuOfflineToken(userId: "", token: "")
        )
        testStore.receive(.accountRecovered(accountRecoverContext))
        mockMainQueue.advance()
        let context = WalletFetchedContext(
            guid: "guid",
            sharedKey: "sharedKey",
            passwordPartHash: passwordHash
        )
        XCTAssertTrue(walletFetcherServiceMock.fetchWalletAfterAccountRecoveryCalled)
        testStore.receive(.walletFetched(.success(.right(context))))
        testStore.receive(.informWalletFetched(context))
    }
}
