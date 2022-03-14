// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import WalletPayloadKit
import XCTest

@testable import Blockchain
@testable import FeatureAppUI

// swiftlint:disable type_body_length
final class LoggedInReducerTests: XCTestCase {

    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet! = MockWallet()
    var mockReactiveWallet = MockReactiveWallet()
    var mockSettingsApp: MockBlockchainSettingsApp!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockRemoteNotificationAuthorizer: MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockAnalyticsRecorder: MockAnalyticsRecorder!
    var onboardingSettings: MockOnboardingSettings!
    var mockAppDeeplinkHandler: MockAppDeeplinkHandler!
    var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    var mockDeepLinkRouter: MockDeepLinkRouter!
    var mockFeatureFlagsService: MockFeatureFlagsService!
    var fiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceMock!

    var testStore: TestStore<
        LoggedIn.State,
        LoggedIn.State,
        LoggedIn.Action,
        LoggedIn.Action,
        LoggedIn.Environment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockSettingsApp = MockBlockchainSettingsApp()
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: mockSettingsApp,
            reactiveWallet: mockReactiveWallet
        )
        mockAlertPresenter = MockAlertViewPresenter()
        mockExchangeAccountRepository = MockExchangeAccountRepository()
        mockRemoteNotificationAuthorizer = MockRemoteNotificationAuthorizer(
            expectedAuthorizationStatus: UNAuthorizationStatus.authorized,
            authorizationRequestExpectedStatus: .success(())
        )
        mockRemoteNotificationServiceContainer = MockRemoteNotificationServiceContainer(
            authorizer: mockRemoteNotificationAuthorizer
        )
        mockAnalyticsRecorder = MockAnalyticsRecorder()
        onboardingSettings = MockOnboardingSettings()
        mockAppDeeplinkHandler = MockAppDeeplinkHandler()
        mockMainQueue = DispatchQueue.test
        mockDeepLinkRouter = MockDeepLinkRouter()
        mockFeatureFlagsService = MockFeatureFlagsService()
        fiatCurrencySettingsServiceMock = FiatCurrencySettingsServiceMock(expectedCurrency: .USD)

        testStore = TestStore(
            initialState: LoggedIn.State(),
            reducer: loggedInReducer,
            environment: LoggedIn.Environment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                analyticsRecorder: mockAnalyticsRecorder,
                loadingViewPresenter: LoadingViewPresenter(),
                exchangeRepository: mockExchangeAccountRepository,
                remoteNotificationTokenSender: mockRemoteNotificationServiceContainer.tokenSender,
                remoteNotificationAuthorizer: mockRemoteNotificationServiceContainer.authorizer,
                walletManager: mockWalletManager,
                appSettings: mockSettingsApp,
                deeplinkRouter: mockDeepLinkRouter,
                featureFlagsService: mockFeatureFlagsService,
                fiatCurrencySettingsService: fiatCurrencySettingsServiceMock
            )
        )
    }

    override func tearDownWithError() throws {
        mockSettingsApp = nil
        mockAlertPresenter = nil
        mockExchangeAccountRepository = nil
        mockRemoteNotificationAuthorizer = nil
        mockRemoteNotificationServiceContainer = nil
        mockAnalyticsRecorder = nil
        onboardingSettings = nil
        mockAppDeeplinkHandler = nil
        mockMainQueue = nil
        mockDeepLinkRouter = nil
        mockFeatureFlagsService = nil
        fiatCurrencySettingsServiceMock = nil

        testStore = nil

        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = LoggedIn.State()
        XCTAssertNil(state.displayWalletAlertContent)
        XCTAssertFalse(state.reloadAfterMultiAddressResponse)
        XCTAssertFalse(state.reloadAfterSymbolChanged)
    }

    func test_calling_start_on_reducer_should_post_login_notification() {
        let expectation = expectation(forNotification: .login, object: nil)

        performSignIn()
        mockMainQueue.advance()

        wait(for: [expectation], timeout: 2)
        performSignOut()
    }

    func test_calling_start_calls_required_services() {
        performSignIn()
        mockMainQueue.advance()

        XCTAssertTrue(mockExchangeAccountRepository.syncDepositAddressesIfLinkedCalled)

        XCTAssertTrue(mockRemoteNotificationServiceContainer.sendTokenIfNeededPublisherCalled)

        XCTAssertTrue(mockRemoteNotificationAuthorizer.requestAuthorizationIfNeededPublisherCalled)

        performSignOut()
    }

    func test_reducer_handles_new_wallet_correctly_should_show_postSignUp_onboarding() {
        // given
        let context = LoggedIn.Context.wallet(.new)
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.handleNewWalletCreation)

        testStore.receive(.showPostSignUpOnboardingFlow) { state in
            state.displayPostSignUpOnboardingFlow = true
        }

        performSignOut()
    }

    func test_reducer_handles_plain_signins_correctly_should_show_postSignIn_onboarding() {
        // given
        let context = LoggedIn.Context.none
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.handleExistingWalletSignIn)

        testStore.receive(.showPostSignInOnboardingFlow) { state in
            state.displayPostSignInOnboardingFlow = true
        }

        performSignOut()
    }

    func test_reducer_handles_deeplink_sendCrypto_correctly() {
        let uriContent = URIContent(url: URL(string: "https://")!, context: .sendCrypto)
        let context = LoggedIn.Context.deeplink(uriContent)
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.deeplink(uriContent)) { state in
            state.displaySendCryptoScreen = true
        }

        testStore.receive(.deeplinkHandled) { state in
            state.displaySendCryptoScreen = false
        }

        performSignOut()
    }

    func test_reducer_handles_deeplink_executeDeeplinkRouting_correctly() {
        let uriContent = URIContent(url: URL(string: "https://")!, context: .executeDeeplinkRouting)
        let context = LoggedIn.Context.deeplink(uriContent)
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.deeplink(uriContent))

        XCTAssertTrue(mockDeepLinkRouter.routeIfNeededCalled)

        performSignOut()
    }

    func test_verify_start_action_observers_symbol_changes() {
        performSignIn()

        mockSettingsApp.symbolLocal = false
        mockSettingsApp.symbolLocal = true

        testStore.receive(.symbolChanged) { state in
            state.reloadAfterSymbolChanged = true
        }

        testStore.receive(.symbolChangedHandled) { state in
            state.reloadAfterSymbolChanged = false
        }

        performSignOut()
    }

    func test_verify_sending_wallet_accountInfoAndExchangeRates_updates_the_state() {
        performSignIn()

        testStore.send(.wallet(.accountInfoAndExchangeRates)) { state in
            state.reloadAfterMultiAddressResponse = true
        }

        testStore.receive(.wallet(.accountInfoAndExchangeRatesHandled)) { state in
            state.reloadAfterMultiAddressResponse = false
        }

        performSignOut()
    }

    func test_verify_sending_wallet_handleWalletBackup() {
        performSignIn()

        testStore.send(.wallet(.handleWalletBackup))

        XCTAssertTrue(mockWallet.getHistoryForAllAssetsCalled)

        performSignOut()
    }

    func test_verify_sending_wallet_handleFailToLoadHistory() {
        performSignIn()

        // when sending an non nil error
        testStore.send(.wallet(.handleFailToLoadHistory(nil))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork
            )
        }

        // when sending an non nil error
        let errorMessage = "this is an error message"
        testStore.send(.wallet(.handleFailToLoadHistory(errorMessage))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.balancesGeneric
            )
        }

        performSignOut()
    }

    func test_reducer_handles_walletDidGetAccountInfoAndExchangeRates() {
        // given
        performSignIn()

        // when
        mockWallet.delegate.walletDidGetAccountInfoAndExchangeRates?(mockWallet)
        mockMainQueue.advance()

        // then
        testStore.receive(.wallet(.accountInfoAndExchangeRates)) { state in
            state.reloadAfterMultiAddressResponse = true
        }
        testStore.receive(.wallet(.accountInfoAndExchangeRatesHandled)) { state in
            state.reloadAfterMultiAddressResponse = false
        }

        performSignOut()
    }

    func test_reducer_handles_walletBackupFailed() {
        // given
        performSignIn()

        // when
        mockWallet.delegate?.didBackupWallet?()
        mockMainQueue.advance()

        // then
        XCTAssertTrue(mockWallet.getHistoryForAllAssetsCalled)
        testStore.receive(.wallet(.handleWalletBackup))

        performSignOut()
    }

    func test_reducer_handles_walletBackupSuccess() {
        // given
        performSignIn()

        // when
        mockWallet.delegate?.didFailBackupWallet?()
        mockMainQueue.advance()

        // then
        XCTAssertTrue(mockWallet.getHistoryForAllAssetsCalled)
        testStore.receive(.wallet(.handleWalletBackup))

        performSignOut()
    }

    func test_reducer_handles_walletFailedToGetHistory_with_an_error_message() {
        // given
        performSignIn()

        // when
        let errorMessage = "an error message"
        mockWallet.delegate?.didFailGetHistory?(errorMessage)
        mockMainQueue.advance()

        // then
        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        testStore.receive(.wallet(.handleFailToLoadHistory(errorMessage))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.balancesGeneric
            )
        }

        performSignOut()
    }

    func test_reducer_handles_walletFailedToGetHistory_with_an_empty_error_message() {
        // given
        performSignIn()

        // when
        let emptyErrorMessage = ""
        mockWallet.delegate?.didFailGetHistory?(emptyErrorMessage)
        mockMainQueue.advance()

        // then
        testStore.receive(.wallet(.handleFailToLoadHistory(emptyErrorMessage))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork
            )
        }

        performSignOut()
    }

    // MARK: - Helpers

    private func performSignIn(file: StaticString = #file, line: UInt = #line) {
        testStore.send(.start(.none), file: file, line: line)
        testStore.receive(.handleExistingWalletSignIn, file: file, line: line)
        testStore.receive(.showPostSignInOnboardingFlow, file: file, line: line) {
            $0.displayPostSignInOnboardingFlow = true
        }
    }

    private func performSignOut(file: StaticString = #file, line: UInt = #line) {
        testStore.send(.logout, file: file, line: line) {
            $0 = LoggedIn.State()
        }
    }
}

// swiftlint:enable type_body_length
