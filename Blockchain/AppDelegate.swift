//
//  AppDelegate.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import ActivityKit
import ActivityUIKit
import AlgorandKit
import BitcoinCashKit
import BitcoinChainKit
import BitcoinKit
import DebugUIKit
import DIKit
import EthereumKit
import Firebase
import FirebaseCrashlytics
import FirebaseDynamicLinks
import KYCKit
import KYCUIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import PolkadotKit
import RIBs
import RxSwift
import ToolKit
import TransactionUIKit
import WalletPayloadKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var isDebug: Bool {
        var isDebug = false
        #if DEBUG
        isDebug = true
        #endif
        return isDebug
    }
    
    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.frame = UIScreen.main.bounds
        view.alpha = 0
        return view
    }()

    // MARK: - Properties
    
    /// The overlay shown when the application resigns active state.
    private lazy var deepLinkHandler: DeepLinkHandler = {
        DeepLinkHandler()
    }()

    @LazyInject private var deepLinkRouter: DeepLinkRouting

    /// A service that provides remote notification registration logic,
    /// thus taking responsibility off `AppDelegate` instance.
    private lazy var remoteNotificationRegistrationService: RemoteNotificationRegistering = {
        RemoteNotificationServiceContainer.default.authorizer
    }()
    
    /// A receipient for device tokens
    private lazy var remoteNotificationTokenReceiver: RemoteNotificationDeviceTokenReceiving = {
        RemoteNotificationServiceContainer.default.tokenReceiver
    }()

    @LazyInject(tag: DebugScreenContext.tag)
    private var debugCoordinator: DebugCoordinating
    
    private let disposeBag = DisposeBag()
    private var appCoordinator: AppCoordinator { .shared }
    private lazy var bitpayRouter = BitPayLinkRouter()

    override init() {
        super.init()
        
        FirebaseApp.configure()
        
        // swiftlint:disable trailing_semicolon
        DependencyContainer.defined(by: modules {
            DependencyContainer.toolKit;
            DependencyContainer.networkKit;
            DependencyContainer.walletPayloadKit;
            DependencyContainer.platformKit;
            DependencyContainer.interestKit;
            DependencyContainer.platformUIKit;
            DependencyContainer.algorandKit;
            DependencyContainer.polkadotKit;
            DependencyContainer.ethereumKit;
            DependencyContainer.erc20Kit;
            DependencyContainer.bitcoinChainKit;
            DependencyContainer.bitcoinKit;
            DependencyContainer.bitcoinCashKit;
            DependencyContainer.stellarKit;
            DependencyContainer.transactionKit;
            DependencyContainer.transactionUIKit;
            DependencyContainer.buySellKit;
            DependencyContainer.activityKit;
            DependencyContainer.activityUIKit;
            DependencyContainer.kycKit;
            DependencyContainer.kycUIKit;
            DependencyContainer.blockchain;
            #if INTERNAL_BUILD
            DependencyContainer.debugUIKit;
            #endif
        })
        // swiftlint:enable trailing_semicolon
    }

    // MARK: - Lifecycle Methods

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            // Do not disable LeakDetector  
        } else {
            LeakDetector.disableLeakDetectorOverride = true
        }

        if ProcessInfo.processInfo.environmentBoolean(for: .eraseWallet) == true {
            // If ProcessInfo environment contains "automation_erase_data": true, erase wallet and settings.
            // This behaviour happens even on non-debug builds, this is necessary because our UI tests
            //   run on real devices with 'release-staging' builds.
            WalletManager.shared.forgetWallet()
            BlockchainSettings.App.shared.clear()
        }

        if isDebug, ProcessInfo.processInfo.isUnitTesting {
            // If isDebug build, and we are running unit test, skip rest of AppDelegate.
            return true
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = #colorLiteral(red: 0.0431372549, green: 0.1019607843, blue: 0.2784313725, alpha: 1)

        // Trigger routing hierarchy
        appCoordinator.window = window
        
        // Migrate announcements
        AnnouncementRecorder.migrate(errorRecorder: CrashlyticsRecorder())
        
        // Register the application for remote notifications
        remoteNotificationRegistrationService.registerForRemoteNotificationsIfAuthorized()
            .subscribe()
            .disposed(by: disposeBag)
        
        BlockchainSettings.App.shared.appBecameActiveCount += 1
        
        // MARK: - Global Appearance
        
        //: Navigation Bar
        let defaultBarStyle = Screen.Style.Bar.lightContent()
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.isTranslucent = defaultBarStyle.isTranslucent
        navigationBarAppearance.titleTextAttributes = defaultBarStyle.titleTextAttributes
        navigationBarAppearance.barTintColor = defaultBarStyle.backgroundColor
        navigationBarAppearance.tintColor = defaultBarStyle.tintColor

        if isDebug {
            let cacheSuite: CacheSuite = resolve()

            let securityReminderKey = UserDefaults.DebugKeys.securityReminderTimer.rawValue
            cacheSuite.removeObject(forKey: securityReminderKey)

            let appReviewPromptKey = UserDefaults.DebugKeys.appReviewPromptCount.rawValue
            cacheSuite.removeObject(forKey: appReviewPromptKey)

            let zeroTickerKey = UserDefaults.DebugKeys.simulateZeroTicker.rawValue
            cacheSuite.set(false, forKey: zeroTickerKey)

            let simulateSurgeKey = UserDefaults.DebugKeys.simulateSurge.rawValue
            cacheSuite.set(false, forKey: simulateSurgeKey)

        }
        #if INTERNAL_BUILD
        debugCoordinator.enableDebugMenu(for: window)
        #endif

        // TODO: prevent any other data tasks from executing until cert is pinned
        let certificatePinner: CertificatePinnerAPI = resolve()
        certificatePinner.pinCertificateIfNeeded()

        let sift: SiftServiceAPI = DIKit.resolve()
        sift.enable()

        checkForNewInstall()
        
        appCoordinator.start()
        WalletActionSubscriber.shared.subscribe()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        changeBlurVisibility(true)
    }

    func delayedApplicationDidEnterBackground(_ application: UIApplication) {
        // Wallet-related background actions

        // TODO: This should be moved into a component that performs actions to the wallet
        // on different lifecycle events (e.g. "WalletAppLifecycleListener")
        let appSettings = BlockchainSettings.App.shared
        let wallet = WalletManager.shared.wallet

        AssetAddressRepository.shared.fetchSwipeToReceiveAddressesIfNeeded()

        NotificationCenter.default.post(name: Constants.NotificationKeys.appEnteredBackground, object: nil)

        wallet.didReceiveMessageForLastTransaction = false

        WalletManager.shared.closeWebSockets(withCloseCode: .backgroundedApp)

        if wallet.isInitialized() {
            if appSettings.guid != nil && appSettings.sharedKey != nil {
                appSettings.hasEndedFirstSession = true
            }
            WalletManager.shared.close()
        }

        // UI-related background actions
        ModalPresenter.shared.closeAllModals()

        /// TODO: Remove this - we don't want any such logic in `AppDelegate`
        /// We have to make sure the 2FA alerts (email / auth app) are still showing
        /// when the user goes back to foreground
        if appCoordinator.onboardingRouter.state != .pending2FA {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
        }

        appCoordinator.cleanupOnAppBackgrounded()
        AuthenticationCoordinator.shared.cleanupOnAppBackgrounded()

        let defaultSession: URLSession = resolve()
        defaultSession.reset {
            Logger.shared.debug("URLSession reset completed.")
        }
    }

    var backgroundTaskTimer = BackgroundTaskTimer(invalidBackgroundTaskIdentifier: BackgroundTaskIdentifier(identifier: UIBackgroundTaskIdentifier.invalid))
    func applicationDidEnterBackground(_ application: UIApplication) {
        DataProvider.default.syncing.sync()
        backgroundTaskTimer.begin(application) { [weak self] in
            self?.delayedApplicationDidEnterBackground(application)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        backgroundTaskTimer.stop(application)
        Logger.shared.debug("applicationWillEnterForeground")

        BlockchainSettings.App.shared.appBecameActiveCount += 1

        if !WalletManager.shared.wallet.isInitialized() {
            if BlockchainSettings.App.shared.guid != nil && BlockchainSettings.App.shared.sharedKey != nil {
                AuthenticationCoordinator.shared.start()
            } else {
                if appCoordinator.onboardingRouter.state == .standard {
                    appCoordinator.onboardingRouter.start(in: UIApplication.shared.keyWindow!)
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        changeBlurVisibility(false)
        Logger.shared.debug("applicationDidBecomeActive")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        let urlString = url.absoluteString

        guard BlockchainSettings.App.shared.isPinSet else {
            if "\(AssetConstants.URLSchemes.blockchainWallet)loginAuthorized" == urlString {
                // TODO: Link to manual pairing
                appCoordinator.onboardingRouter.start()
                return true
            }
            return false
        }

        guard let urlScheme = url.scheme else {
            return true
        }

        if urlScheme == AssetConstants.URLSchemes.blockchainWallet {
            // Redirect from browser to app - do nothing.
            return true
        }

        if urlScheme == AssetConstants.URLSchemes.blockchain {
            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)
            return true
        }
        
        let isInitialized = WalletManager.shared.wallet.isInitialized()
        let hasGuid = BlockchainSettings.App.shared.guid != nil
        let hasSharedKey = BlockchainSettings.App.shared.sharedKey != nil
        let authenticated = isInitialized && hasGuid && hasSharedKey
        
        if BitPayLinkRouter.isBitPayURL(url) {
            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)
            BitpayService.shared.contentRelay.accept(url)
            guard authenticated else { return true }
            return bitpayRouter.routeIfNeeded()
        }

        // Handle "bitcoin://" scheme
        if let bitcoinUrlPayload = BitcoinURLPayload(url: url) {

            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)

            AuthenticationCoordinator.shared.postAuthenticationRoute = .sendCoins

            appCoordinator.tabControllerManager?.setupBitcoinPaymentFromURLHandler(
                with: bitcoinUrlPayload.amount,
                address: bitcoinUrlPayload.address
            )

            return true
        }
        
        if authenticated {
            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)
            deepLinkRouter.routeIfNeeded()
            return true
        }

        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let webpageUrl = userActivity.webpageURL else { return false }

        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webpageUrl) { [weak self] dynamicLink, error in
            guard error == nil else {
                Logger.shared.error("Got error handling universal link: \(error!.localizedDescription)")
                return
            }

            guard let deepLinkUrl = dynamicLink?.url else {
                return
            }

            // Check that the version of the link (if provided) is supported, if not, prompt the user to update
            if let minimumAppVersionStr = dynamicLink?.minimumAppVersion,
                let minimumAppVersion = AppVersion(string: minimumAppVersionStr),
                let appVersionStr = Bundle.applicationVersion,
                let appVersion = AppVersion(string: appVersionStr),
                appVersion < minimumAppVersion {
                self?.showUpdateAppAlert()
                return
            }

            Logger.shared.info("Deeplink: \(deepLinkUrl.absoluteString)")
            self?.deepLinkHandler.handle(deepLink: deepLinkUrl.absoluteString)
        }
        return handled
    }

    // MARK: - State Checks

    func checkForNewInstall() {

        let appSettings = BlockchainSettings.App.shared
        let onboardingSettings = BlockchainSettings.Onboarding.shared

        guard !onboardingSettings.firstRun else {
            Logger.shared.info("This is not the 1st time the user is running the app.")
            return
        }

        onboardingSettings.firstRun = true

        if appSettings.guid != nil && appSettings.sharedKey != nil && !appSettings.isPinSet {
            AlertViewPresenter.shared.alertUserAskingToUseOldKeychain { _ in
                AuthenticationCoordinator.shared.showPasswordRequiredViewController()
            }
        }
    }

    // MARK: - Blur

    private func changeBlurVisibility(_ isVisible: Bool) {
        let alpha: CGFloat = isVisible ? 1 : 0
        UIApplication.shared.keyWindow?.addSubview(visualEffectView)
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.visualEffectView.alpha = alpha
            },
            completion: { finished in
                if finished {
                    if !isVisible {
                        self.visualEffectView.removeFromSuperview()
                    }
                }
            })
    }
    
    // MARK: - Private

    private func showUpdateAppAlert() {
        let actions = [
            UIAlertAction(title: LocalizationConstants.DeepLink.updateNow, style: .default, handler: { _ in
                UIApplication.shared.openAppStore()
            }),
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        ]
        AlertViewPresenter.shared.standardNotify(
            title: LocalizationConstants.DeepLink.deepLinkUpdateTitle,
            message: LocalizationConstants.DeepLink.deepLinkUpdateMessage,
            actions: actions
        )
    }
}

// MARK: - Remote Notification Registration

extension AppDelegate {
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        remoteNotificationTokenReceiver.appDidFailToRegisterForRemoteNotifications(with: error)
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        remoteNotificationTokenReceiver.appDidRegisterForRemoteNotifications(with: deviceToken)
    }
}

extension UIDevice: DeviceInfo {
    public var uuidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}
