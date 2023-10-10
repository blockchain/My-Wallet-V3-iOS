// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureSettingsDomain
import Localization
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RxSwift
import WalletPayloadKit
import XCTest

@testable import BlockchainApp
@testable import FeatureAppUI

@MainActor final class LoggedInReducerTests: XCTestCase {

    var mockSettingsApp: MockBlockchainSettingsApp!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockRemoteNotificationAuthorizer: MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockNabuUserService: MockNabuUserService!
    var mockAnalyticsRecorder: MockAnalyticsRecorder!
    var mockAppDeeplinkHandler: MockAppDeeplinkHandler!
    var mockMainQueue: ImmediateSchedulerOf<DispatchQueue>!
    var mockDeepLinkRouter: MockDeepLinkRouter!
    var fiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceMock!
    var performanceTracingMock: PerformanceTracingServiceAPI!
    var mockReactiveWallet: MockReactiveWallet!

    var testStore: TestStore<
        LoggedIn.State,
        LoggedIn.Action
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockSettingsApp = MockBlockchainSettingsApp()
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
        mockAppDeeplinkHandler = MockAppDeeplinkHandler()
        mockMainQueue = DispatchQueue.immediate
        mockDeepLinkRouter = MockDeepLinkRouter()
        fiatCurrencySettingsServiceMock = FiatCurrencySettingsServiceMock(expectedCurrency: .USD)
        mockNabuUserService = MockNabuUserService()
        performanceTracingMock = PerformanceTracing.mock
        mockReactiveWallet = MockReactiveWallet()

        testStore = TestStore(
            initialState: LoggedIn.State(),
            reducer: {
                LoggedInReducer(
                    analyticsRecorder: mockAnalyticsRecorder,
                    app: App.test,
                    appSettings: mockSettingsApp,
                    deeplinkRouter: mockDeepLinkRouter,
                    exchangeRepository: mockExchangeAccountRepository,
                    fiatCurrencySettingsService: fiatCurrencySettingsServiceMock,
                    loadingViewPresenter: LoadingViewPresenter(),
                    mainQueue: mockMainQueue.eraseToAnyScheduler(),
                    nabuUserService: mockNabuUserService,
                    performanceTracing: performanceTracingMock,
                    reactiveWallet: mockReactiveWallet,
                    remoteNotificationAuthorizer: mockRemoteNotificationServiceContainer.authorizer,
                    remoteNotificationTokenSender: mockRemoteNotificationServiceContainer.tokenSender,
                    unifiedActivityService: UnifiedActivityPersistenceServiceMock()
                )
            }
        )
    }

    override func tearDownWithError() throws {
        mockSettingsApp = nil
        mockAlertPresenter = nil
        mockExchangeAccountRepository = nil
        mockRemoteNotificationAuthorizer = nil
        mockRemoteNotificationServiceContainer = nil
        mockAnalyticsRecorder = nil
        mockAppDeeplinkHandler = nil
        mockMainQueue = nil
        mockDeepLinkRouter = nil
        fiatCurrencySettingsServiceMock = nil
        mockReactiveWallet = nil

        testStore = nil

        try super.tearDownWithError()
    }

    func test_calling_start_on_reducer_should_post_login_notification() async {
        let expectation = expectation(forNotification: .login, object: nil)

        await performSignIn()
        wait(for: [expectation], timeout: 2)
        await performSignOut()
    }

    func test_calling_start_calls_required_services() async {
        await performSignIn()

        XCTAssertTrue(mockExchangeAccountRepository.syncDepositAddressesIfLinkedCalled)

        XCTAssertTrue(mockRemoteNotificationServiceContainer.sendTokenIfNeededPublisherCalled)

        XCTAssertTrue(mockRemoteNotificationAuthorizer.requestAuthorizationIfNeededCalled)

        await performSignOut()
    }

    func test_reducer_handles_new_wallet_correctly_should_show_postSignUp_onboarding() async {
        // given
        let context = LoggedIn.Context.wallet(.new)
        await testStore.send(.start(context))

        // then
        await testStore.receive(.handleNewWalletCreation)

        await testStore.receive(.showPostSignUpOnboardingFlow) { state in
            state.displayPostSignUpOnboardingFlow = true
        }

        await performSignOut()
    }

    func test_reducer_handles_plain_signins_correctly_should_show_postSignIn_onboarding() async {
        // given
        let context = LoggedIn.Context.none
        await testStore.send(.start(context))

        // then
        await testStore.receive(.handleExistingWalletSignIn)

        await testStore.receive(.showPostSignInOnboardingFlow) { state in
            state.displayPostSignInOnboardingFlow = true
        }

        await performSignOut()
    }

    func test_reducer_handles_deeplink_sendCrypto_correctly() async {
        let uriContent = URIContent(url: URL(string: "https://")!, context: .sendCrypto)
        let context = LoggedIn.Context.deeplink(uriContent)
        await testStore.send(.start(context))

        // then
        await testStore.receive(.deeplink(uriContent)) { state in
            state.displaySendCryptoScreen = true
        }

        await testStore.receive(.deeplinkHandled) { state in
            state.displaySendCryptoScreen = false
        }

        await performSignOut(stageWillChangeToLoggedInState: false)
    }

    func test_reducer_handles_deeplink_executeDeeplinkRouting_correctly() async {
        let uriContent = URIContent(url: URL(string: "https://")!, context: .executeDeeplinkRouting)
        let context = LoggedIn.Context.deeplink(uriContent)
        await testStore.send(.start(context))

        // then
        await testStore.receive(.deeplink(uriContent))

        XCTAssertTrue(mockDeepLinkRouter.routeIfNeededCalled)

        await performSignOut(stageWillChangeToLoggedInState: false)
    }

    // MARK: - Helpers

    private func performSignIn(file: StaticString = #file, line: UInt = #line) async {
        await testStore.send(.start(.none))
        await testStore.receive(.handleExistingWalletSignIn)
        await testStore.receive(.showPostSignInOnboardingFlow) {
            $0.displayPostSignInOnboardingFlow = true
        }
    }

    private func performSignOut(
        stageWillChangeToLoggedInState: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        await testStore.send(
            .logout,
            assert: stageWillChangeToLoggedInState ? { $0 = LoggedIn.State() } : nil,
            file: file,
            line: line
        )
    }
}
