//
//  RootService.m
//  Blockchain
//
//  Created by Kevin Wu on 8/15/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "RootService.h"
#import "Blockchain-Swift.h"
#import <QuartzCore/QuartzCore.h>

#import "ExchangeOverviewViewController.h"
#import "BuyBitcoinViewController.h"
#import "MultiAddressResponse.h"
#import "Wallet.h"
#import "BCFadeView.h"
#import "TabViewController.h"
#import "TransactionsBitcoinViewController.h"
#import "BCCreateWalletView.h"
#import "BCManualPairView.h"
#import "Transaction.h"
#import "UIDevice+Hardware.h"
#import "UncaughtExceptionHandler.h"
#import "UITextField+Blocks.h"
#import "PairingCodeParser.h"
#import "PrivateKeyReader.h"
#import "NSData+Hex.h"
#import "Reachability.h"
#import "SideMenuViewController.h"
#import "BCWelcomeView.h"
#import "BCWebViewController.h"
#import "KeychainItemWrapper.h"
#import "UpgradeViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIViewController+AutoDismiss.h"
#import "DebugTableViewController.h"
#import "KeychainItemWrapper+Credentials.h"
#import "KeychainItemWrapper+SwipeAddresses.h"
#import "NSString+SHA256.h"
//#import "ContactsViewController.h"
//#import "ContactTransaction.h"
#import "BuyBitcoinNavigationController.h"
#import "BCEmptyPageView.h"
#import "WebLoginViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define URL_SUPPORT_FORGOT_PASSWORD @"https://support.blockchain.com/hc/en-us/articles/211205343-I-forgot-my-password-What-can-you-do-to-help-"
//#define USER_DEFAULTS_KEY_DID_FAIL_TOUCH_ID_SETUP @"didFailTouchIDSetup"
//#define USER_DEFAULTS_KEY_SHOULD_SHOW_TOUCH_ID_SETUP @"shouldShowTouchIDSetup"

@implementation RootService

RootService * app;

//@synthesize wallet;
//@synthesize modalView;
//@synthesize latestResponse;

typedef enum {
    ShowTypeNone = 100,
    ShowTypeSendCoins = 200,
//    ShowTypeNewContact = 300,
    ShowTypeNewPayment = 400
} ShowType;

ShowType showType;

enum {
    ShowReminderTypeNone,
    ShowReminderTypeTwoFactor,
    ShowReminderTypeEmail
};

typedef NSInteger ShowReminderType;

ShowReminderType showReminderType;

SideMenuViewController *sideMenuViewController;

//UNNotification *pushNotificationPendingAction;

void (^addPrivateKeySuccess)(NSString *);
void (^secondPasswordSuccess)(NSString *);

- (id)init {

    if (self = [super init]) {
        [self setupBtcFormatter];
        [self setupLocalCurrencyFormatter];

//        self.modalChain = [[NSMutableArray alloc] init];
//        app = self;
    }

    return self;
}

//- (void)transitionToIndex:(NSInteger)newIndex
//{
//    if (newIndex == TAB_SEND)
//    [self.tabControllerManager sendCoinsClicked:nil];
//    else if (newIndex == TAB_DASHBOARD)
//    [self.tabControllerManager dashBoardClicked:nil];
//    else if (newIndex == TAB_TRANSACTIONS)
//    [self.tabControllerManager transactionsClicked:nil];
//    else if (newIndex == TAB_RECEIVE)
//    [self.tabControllerManager receiveCoinClicked:nil];
//}

//- (void)swipeLeft
//{
//    TabViewcontroller *tabViewController = self.tabControllerManager.tabViewController;
//
//    if (tabViewController.selectedIndex < 2)
//    {
//        NSInteger newIndex = tabViewController.selectedIndex + 1;
//        [self transitionToIndex:newIndex];
//    }
//}
//
//- (void)swipeRight
//{
//    TabViewcontroller *tabViewController = self.tabControllerManager.tabViewController;
//
//    if (tabViewController.selectedIndex)
//    {
//        NSInteger newIndex = tabViewController.selectedIndex - 1;
//        [self transitionToIndex:newIndex];
//    }
//}

//- (CertificatePinner *)certificatePinner
//{
//#ifdef DISABLE_CERTIFICATE_PINNING
//    return nil;
//#else
//    if (!_certificatePinner) _certificatePinner = [[CertificatePinner alloc] init];
//    _certificatePinner.delegate = self;
//    return _certificatePinner;
//#endif
//}

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [Fabric with:@[[Crashlytics class]]];
//
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    app.window = appDelegate.window;
//
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//
//    [userDefaults registerDefaults:@{USER_DEFAULTS_KEY_ASSET_TYPE : [NSNumber numberWithInt:AssetTypeBitcoin]}];
//
//    [[NSUserDefaults standardUserDefaults] registerDefaults:@{USER_DEFAULTS_KEY_DEBUG_ENABLE_CERTIFICATE_PINNING : @YES}];
//    [[NSUserDefaults standardUserDefaults] registerDefaults:@{USER_DEFAULTS_KEY_SWIPE_TO_RECEIVE_ENABLED : @YES}];
//#ifndef DEBUG
//    [[NSUserDefaults standardUserDefaults] setObject:ENV_INDEX_PRODUCTION forKey:USER_DEFAULTS_KEY_ENV];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_DEBUG_ENABLE_CERTIFICATE_PINNING];
//
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_DEBUG_SECURITY_REMINDER_CUSTOM_TIMER];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_DEBUG_APP_REVIEW_PROMPT_CUSTOM_TIMER];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_ZERO_TICKER];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_SURGE];
//
//    [[NSUserDefaults standardUserDefaults] synchronize];

    // TODO: migrate all code below to RootServiceSwift

//    SharedSessionDelegate *sharedSessionDelegate = [[SharedSessionDelegate alloc] initWithCertificatePinner:self.certificatePinner];
//
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSString *userAgentString = [
//                                 NSString stringWithFormat:@"Blockchain-iOS/%@ (iOS/%@; %@)",
//                                 [self getVersionLabelString],
//                                 [[UIDevice currentDevice] systemVersion], [DeviceIdentifier deviceName]
//                                 ];
//    configuration.HTTPAdditionalHeaders = @{@"User-Agent" : userAgentString};
//
//    [SessionManager setupSharedSessionConfiguration:configuration delegate:sharedSessionDelegate queue:nil];
//
//    [self.certificatePinner pinCertificate];

//    [self checkForNewInstall];

//    [self persistServerSessionIDForNewUIWebViews];

//    [self disableUIWebViewCaching];

    // Allocate the global wallet
//    WalletManager.sharedInstance.wallet = WalletManager.sharedInstance.wallet;
//    WalletManager.sharedInstance.wallet.delegate = self;

    // Send email when exceptions are caught
#ifndef DEBUG
    NSSetUncaughtExceptionHandler(&HandleException);
#endif

//    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_KEY_LOADING_TEXT object:nil queue:nil usingBlock:^(NSNotification * notification) {
//        self.loadingText = [notification object];
//    }];

//    app.window.backgroundColor = [UIColor whiteColor];
//
//    [self setupSideMenu];
//
//    [app.window makeKeyAndVisible];
//
//    [self.tabControllerManager dashBoardClicked:nil];

    // Add busy view to root vc
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:busyView];
//    busyView.frame = app.window.frame;
//    busyView.alpha = 0.0f;

    // Load settings
//    symbolLocal = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_SYMBOL_LOCAL];

//    [self showWelcomeOrPinScreen];

//    [self requestAuthorizationForPushNotifications];

    // TODO: Set Montserrat font globally
    app.mainTitleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_TOP_BAR_TEXT];

    // TODO: Migrate elsewhere
    secondPasswordDescriptionLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    secondPasswordTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    secondPasswordButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];

    return YES;
}

- (void)showWelcomeScreen
{
//    [self checkForMaintenance];
//
//    BCWelcomeView *welcomeView = [[BCWelcomeView alloc] init];
//    [welcomeView.createWalletButton addTarget:self action:@selector(showCreateWallet:) forControlEvents:UIControlEventTouchUpInside];
//    [welcomeView.existingWalletButton addTarget:self action:@selector(showPairWallet:) forControlEvents:UIControlEventTouchUpInside];
//    [welcomeView.recoverWalletButton addTarget:self action:@selector(showRecoverWallet:) forControlEvents:UIControlEventTouchUpInside];

//    [app showModalWithContent:welcomeView closeType:ModalCloseTypeNone showHeader:NO headerText:nil onDismiss:nil onResume:nil];

//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

//- (void)showPinScreen
//{
//    BlockchainSettings.sharedAppInstance.hasSeenAllCards = YES;
//    BlockchainSettings.sharedAppInstance.shouldHideAllCards = YES;
//
//    if ([BlockchainSettings sharedAppInstance].isPinSet) {
//        [self showPinModalAsView:YES];
//        // [rootService authenticateWithBiometrics];
//    } else {
//        [self checkForMaintenance];
//        [self showPasswordModal];
//        [[AlertViewPresenter sharedInstance] checkAndWarnOnJailbrokenPhones];
//    }
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSideMenu) name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
//
//    [self migratePasswordAndPinFromNSUserDefaults];
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // TODO: call Swift instance method directly from AppDelegate after refactor
    // [rootService applicationWillResignActive:application];

    [self hideSendAndReceiveKeyboards];

    if (createWalletView) {
        [createWalletView hideKeyboard];
    }

//    if (manualPairView) {
//        [manualPairView hideKeyboard];
//    }

//    if ([mainPasswordTextField isFirstResponder]) {
//        [mainPasswordTextField resignFirstResponder];
//    }
//
//    if (!rootService.isPromptingForBiometricAuthentication) {
//        // Show the LaunchImage so the list of running apps does not show the user's information
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // Small delay so we don't change the view while it's zooming out
//
//            [self.window addSubview:curtainImageView];
//            [self.window bringSubviewToFront:curtainImageView];
//
//            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
//                curtainImageView.alpha = 1; // 0?
//            } completion:^(BOOL finished) {
//                // Dismiss any ViewControllers that are used modally, except for the MerchantViewController
//                if (self.tabControllerManager.tabViewController.presentedViewController == _bcWebViewController) {
//                    [_bcWebViewController dismissViewControllerAnimated:NO completion:nil];
//                }
//            }];
//        });
//    }

    if (self.pinEntryViewController.verifyOnly) {
        [self.pinEntryViewController reset];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // TODO: call Swift instance method directly from AppDelegate after refactor
    // [rootService applicationDidEnterBackground:application];
    if (BlockchainSettings.sharedAppInstance.swipeToReceiveEnabled &&
        [WalletManager.sharedInstance.wallet isInitialized] &&
        [WalletManager.sharedInstance.wallet didUpgradeToHd]) {

        NSString *etherAddress = [WalletManager.sharedInstance.wallet getEtherAddress];
        if (etherAddress) {
            [KeychainItemWrapper setSwipeEtherAddress:etherAddress];
        } else {
            [KeychainItemWrapper removeSwipeEtherAddress];
        }

        int numberOfBitcoinAddressesToDerive = SWIPE_TO_RECEIVE_ADDRESS_COUNT;
        NSArray *bitcoinSwipeAddresses = [KeychainItemWrapper getSwipeAddressesForAssetType:AssetTypeBitcoin];
        if (bitcoinSwipeAddresses) {
            numberOfBitcoinAddressesToDerive = SWIPE_TO_RECEIVE_ADDRESS_COUNT - (int)bitcoinSwipeAddresses.count;
        }

        [WalletManager.sharedInstance.wallet getSwipeAddresses:numberOfBitcoinAddressesToDerive assetType:AssetTypeBitcoin];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidEnterBackground" object:self];
    }

    [self.loginTimer invalidate];

    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];

    [self hideSendAndReceiveKeyboards];

    // Close all modals
    [app closeAllModals];

//    self.topViewControllerDelegate = nil;

    // Close screens that shouldn't be in the foreground when returning to the wallet
    if (_backupNavigationViewController) {
        [_backupNavigationViewController dismissViewControllerAnimated:NO completion:nil];
    }

    if (_settingsNavigationController) {
        [_settingsNavigationController dismissViewControllerAnimated:NO completion:nil];
    }

    self.tabControllerManager.transactionsBitcoinViewController.loadedAllTransactions = NO;
    self.tabControllerManager.transactionsBitcoinViewController.messageIdentifier = nil;
    WalletManager.sharedInstance.wallet.isFetchingTransactions = NO;
    WalletManager.sharedInstance.wallet.isFilteringTransactions = NO;
    WalletManager.sharedInstance.wallet.didReceiveMessageForLastTransaction = NO;

    [createWalletView showPassphraseTextField];

    [[AppCoordinator sharedInstance] closeSideMenu];

    // Close PIN Modal in case we are setting it (after login or when changing the PIN)
    if (self.pinEntryViewController.verifyOnly == NO || self.pinEntryViewController.inSettings == NO) {
        [AuthenticationCoordinator.shared closePinEntryViewWithAnimated:NO];
    }

    // Show pin modal before we close the app so the PIN verify modal gets shown in the list of running apps and immediately after we restart
    if ([BlockchainSettings sharedAppInstance].isPinSet) {
        [self showPinModalAsView:YES];
        [self.pinEntryViewController reset];
    }

    BOOL hasGuidAndSharedKey = [KeychainItemWrapper guid] && [KeychainItemWrapper sharedKey];

    if ([wallet isInitialized]) {

        if (hasGuidAndSharedKey) {
            BlockchainSettings.sharedAppInstance.hasEndedFirstSession = YES;
        }

        [self beginBackgroundUpdateTask];

        [AuthenticationCoordinator.sharedInstance logoutWithShowPasswordView:false];
    }

    if (BlockchainSettings.sharedAppInstance.hasSeenAllCards) {
        BlockchainSettings.sharedAppInstance.shouldHideAllCards = YES;
    }

    if (BlockchainSettings.sharedAppInstance.didFailTouchIDSetup &&
        !BlockchainSettings.sharedAppInstance.touchIDEnabled) {
        BlockchainSettings.sharedAppInstance.shouldShowTouchIDSetup = YES;
    }

    [WalletManager.sharedInstance.wallet setupBuySellWebview];

    [WalletManager.sharedInstance closeWebSocketsWithCloseCode:WebSocketCloseCodeBackgroundedApp];

    if (hasGuidAndSharedKey) {
        [[[NetworkManager sharedInstance] session] resetWithCompletionHandler:^{
            // completion handler must be non-null
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Cannot be refactored any further until more code is migrated to RootServiceSwift
    if ([BlockchainSettings sharedAppInstance].isPinSet) {
        // [rootService authenticateWithBiometrics];
        return;
    }

    if (![wallet isInitialized]) {
        [self showWelcomeScreen];

        if ([KeychainItemWrapper guid] && [KeychainItemWrapper sharedKey]) {
            [self showPasswordModal];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // TODO: call Swift instance method directly from AppDelegate after refactor
    // [rootService applicationDidBecomeActive:application];
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if (![BlockchainSettings sharedAppInstance].isPinSet) {
        if ([[url absoluteString] isEqualToString:[NSString stringWithFormat:@"%@%@", PREFIX_BLOCKCHAIN_WALLET_URI, @"loginAuthorized"]]) {
            [self manualPairClicked:nil];
            return YES;
        } else {
            return NO;
        }
    }

    NSString *absoluteURL = [url absoluteString];

    if ([absoluteURL hasPrefix:PREFIX_BLOCKCHAIN_WALLET_URI]) {
        // redirect from browser to app - do nothing.
        return YES;
    } else if ([absoluteURL hasPrefix:PREFIX_BLOCKCHAIN_URI]) {

        [app closeModalWithTransition:kCATransitionFade];
//
//        NSDictionary *dict = [self parseURI:absoluteURL prefix:PREFIX_BLOCKCHAIN_URI];
//        NSString *identifier = [dict objectForKey:DICTIONARY_KEY_ID];
//        NSString *name = [dict objectForKey:DICTIONARY_KEY_NAME];
//        showType = ShowTypeNewContact;
//        _contactsViewController = [[ContactsViewController alloc] initWithInvitation:identifier name:name];

        return YES;
    }

    [app closeModalWithTransition:kCATransitionFade];

    NSDictionary *dict = [self parseURI:absoluteURL prefix:PREFIX_BITCOIN_URI];
    NSString * addr = [dict objectForKey:DICTIONARY_KEY_ADDRESS];
    NSString * amount = [dict objectForKey:DICTIONARY_KEY_AMOUNT];

    showType = ShowTypeSendCoins;

    [self.tabControllerManager setupBitcoinPaymentFromURLHandlerWithAmountString:amount address:addr];

    return YES;
}

//- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
//{
//    pushNotificationPendingAction = notification;
//
//    [WalletManager.sharedInstance.wallet getMessages];
//}

//- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
//{
//    DLog(@"User received remote notification");
//    NSString *type = [response.notification.request.content.userInfo objectForKey:DICTIONARY_KEY_TYPE];
//    NSString *invitationSent = [response.notification.request.content.userInfo objectForKey:DICTIONARY_KEY_ID];
//
//    if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_CONTACT_REQUEST]) {
//        showType = ShowTypeNewContact;
//        _contactsViewController = [[ContactsViewController alloc] initWithAcceptedInvitation:invitationSent];
//    } else if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_PAYMENT]) {
//        showType = ShowTypeNewPayment;
//        [self.tabControllerManager setTransactionsViewControllerMessageIdentifier:invitationSent];
//    }
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }

    self.deviceToken = [token copy];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    DLog(@"didReceiveRemoteNotification");
    if (application.applicationState == UIApplicationStateInactive) {
        NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber + 1];
    }

    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    BlockchainSettings.sharedAppInstance.shouldHideAllCards = YES;
    BlockchainSettings.sharedAppInstance.hasSeenAllCards = YES;
    BlockchainSettings.sharedAppInstance.shouldHideBuySellCard = YES;
}

#pragma mark - Setup

- (TabControllerManager *)tabControllerManager
{
    return [AppCoordinator sharedInstance].tabControllerManager;
//    if (!_tabControllerManager) _tabControllerManager = [TabControllerManager new];
//    _tabControllerManager.delegate = self;
//    return _tabControllerManager;
}

//- (void)requestAuthorizationForPushNotifications
//{
//    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    } else {
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        center.delegate = self;
//        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//             if (!error) {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [[UIApplication sharedApplication] registerForRemoteNotifications];
//                 });
//                 DLog( @"Push registration success." );
//             } else {
//                 DLog( @"Push registration FAILED" );
//                 DLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
//                 DLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
//             }
//         }];
//    }
//}

- (void)registerDeviceForPushNotifications
{
    // TODO: test deregistering from the server

    NSString *preferredLanguage = [[NSLocale preferredLanguages] firstObject];
    const char *languageString = [preferredLanguage UTF8String];

    NSMutableURLRequest *notificationsRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:URL_PUSH_NOTIFICATIONS_SERVER_ARGUMENT_GUID_ARGUMENT_SHAREDKEY_ARGUMENT_TOKEN_ARGUMENT_LENGTH_ARGUMENT_LANGUAGE_ARGUMENT, [[BlockchainAPI sharedInstance] walletUrl], [WalletManager.sharedInstance.wallet guid], [WalletManager.sharedInstance.wallet sharedKey], self.deviceToken, (unsigned long)[self.deviceToken length], languageString]]];
    [notificationsRequest setHTTPMethod:@"POST"];

    NSURLSessionDataTask *dataTask = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:notificationsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            DLog(@"Error registering device with backend: %@", [error localizedDescription]);
        }
        NSError *jsonError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            DLog(@"Error parsing response from registering device with backend: %@", [error localizedDescription]);
        } else {
            DLog(@"Register notifications result: %@", result);
        }
    }];

    [dataTask resume];
}

- (void)setupBtcFormatter
{
    self.btcFormatter = [[NSNumberFormatter alloc] init];
    [_btcFormatter setMaximumFractionDigits:8];
    [_btcFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

- (void)setupLocalCurrencyFormatter
{
    self.localCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [_localCurrencyFormatter setMinimumFractionDigits:2];
    [_localCurrencyFormatter setMaximumFractionDigits:2];
    [_localCurrencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

//- (void)persistServerSessionIDForNewUIWebViews
//{
//    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
//}

//- (void)disableUIWebViewCaching
//{
//    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
//    [NSURLCache setSharedURLCache:sharedCache];
//}

//- (void)setupSideMenu
//{
//    _slidingViewController = [[ECSlidingViewController alloc] init];
//    _slidingViewController.topViewController = self.tabControllerManager.tabViewController;
//    sideMenuViewController = [[SideMenuViewController alloc] init];
//    _slidingViewController.underLeftViewController = sideMenuViewController;
//    _window.rootViewController = _slidingViewController;
//}

//- (void)showWelcomeOrPinScreen
//{
//    // Not paired yet
//    if (![KeychainItemWrapper guid] || ![KeychainItemWrapper sharedKey]) {
//        [self showWelcome];
//        [self checkAndWarnOnJailbrokenPhones];
//    }
//    // Paired
//    else {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_HAS_SEEN_ALL_CARDS];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_SHOULD_HIDE_ALL_CARDS];
//
//        // If the PIN is set show the pin modal
//        if ([self isPinSet]) {
//            [self showPinModalAsView:YES];
//            [rootService authenticateWithBiometrics];
//        } else {
//            // No PIN set we need to ask for the main password
//            [self checkForMaintenance];
//            [self showPasswordModal];
//            [self checkAndWarnOnJailbrokenPhones];
//        }
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSideMenu) name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
//
//        [self migratePasswordAndPinFromNSUserDefaults];
//    }
//}

- (void)migratePasswordAndPinFromNSUserDefaults
{
    NSString * password = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_PASSWORD];
    NSString * pin = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_PIN];

    if (password && pin) {
        WalletManager.sharedInstance.wallet.password = password;

        [self savePIN:pin];

        // TODO only remove these if savePIN is successful (required JS modifications) (and synchronize)
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_PASSWORD];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_PIN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//- (void)setupBuySellWebview
//{
//    [WalletManager.sharedInstance.wallet setupBuySellWebview];
//}

//- (void)initializeWebview
//{
//    self.buyBitcoinViewController = [[BuyBitcoinViewController alloc] init];
//}

#pragma mark - UI State
//
//- (void)reload
//{
//    [self.tabControllerManager reload];
//    [_settingsNavigationController reload];
//    [_accountsAndAddressesNavigationController reload];
//
//    [sideMenuViewController reload];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RELOAD_TO_DISMISS_VIEWS object:nil];
//    // Legacy code for generating new addresses
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_NEW_ADDRESS object:nil userInfo:nil];
//}
//
- (void)reloadAfterMultiAddressResponse
{
    if (WalletManager.sharedInstance.wallet.didReceiveMessageForLastTransaction) {
        WalletManager.sharedInstance.wallet.didReceiveMessageForLastTransaction = NO;
        Transaction *transaction = WalletManager.sharedInstance.latestMultiAddressResponse.transactions.firstObject;
        [self.tabControllerManager.receiveBitcoinViewController paymentReceived:ABS(transaction.amount) showBackupReminder:NO];
    }

    [self.tabControllerManager reloadAfterMultiAddressResponse];
    [_settingsNavigationController reloadAfterMultiAddressResponse];
    [_accountsAndAddressesNavigationController reload];

    [sideMenuViewController reload];

    [[NSNotificationCenter defaultCenter] postNotificationName:ConstantsObjcBridge.notificationKeyReloadToDismissViews object:nil];
    // Legacy code for generating new addresses
    [[NSNotificationCenter defaultCenter] postNotificationName:ConstantsObjcBridge.notificationKeyNewAddress object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_MULTIADDRESS_RESPONSE_RELOAD object:nil];
}

- (void)reloadSideMenu
{
    [sideMenuViewController reloadTableView];
}

- (void)toggleSymbol
{
//    symbolLocal = !symbolLocal;
//
//    // Save this setting here and load it on start
//    [[NSUserDefaults standardUserDefaults] setBool:symbolLocal forKey:USER_DEFAULTS_KEY_SYMBOL_LOCAL];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    [self reloadSymbols];
}

- (NSInteger)filterIndex
{
    return [self.tabControllerManager getFilterIndex];
}

- (void)filterTransactionsByAccount:(int)accountIndex assetType:(AssetType)assetType
{
    [self.tabControllerManager filterTransactionsByAccount:accountIndex filterLabel:[WalletManager.sharedInstance.wallet getLabelForAccount:accountIndex assetType:self.tabControllerManager.assetType] assetType:assetType];

    [WalletManager.sharedInstance.wallet reloadFilter];
}

- (void)filterTransactionsByImportedAddresses
{
    [self.tabControllerManager filterTransactionsByImportedAddresses];

    [WalletManager.sharedInstance.wallet reloadFilter];
}

- (void)removeTransactionsFilter
{
    [self.tabControllerManager removeTransactionsFilter];
    [WalletManager.sharedInstance.wallet reloadFilter];
}

- (void)reloadSymbols
{
//    [self.tabControllerManager reloadSymbols];
//
//    [_contactsViewController reloadSymbols];
//    [_accountsAndAddressesNavigationController reload];
//    [sideMenuViewController reload];
}

//- (void)showBusyViewWithLoadingText:(NSString *)text
//{
//    if (self.topViewControllerDelegate) {
//        if ([self.topViewControllerDelegate respondsToSelector:@selector(showBusyViewWithLoadingText:)]) {
//            [self.topViewControllerDelegate showBusyViewWithLoadingText:text];
//        }
//        return;
//    }
//
//    if (self.pinEntryViewController.inSettings &&
//        ![text isEqualToString:BC_STRING_LOADING_SYNCING_WALLET] &&
//        ![text isEqualToString:BC_STRING_LOADING_VERIFYING]) {
//        DLog(@"Verify optional PIN view is presented - will not update busy views unless verifying or syncing");
//        return;
//    }
//
//    if ([self.tabControllerManager isSending] && modalView) {
//        DLog(@"Send progress modal is presented - will not show busy view");
//        return;
//    }
//
//    [busyLabel setText:text];
//
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:busyView];
//
//    if (busyView.alpha < 1.0) {
//        [busyView fadeIn];
//    }
//}

//- (void)updateBusyViewLoadingText:(NSString *)text
//{
//    if (self.topViewControllerDelegate) {
//        if ([self.topViewControllerDelegate respondsToSelector:@selector(updateBusyViewLoadingText:)]) {
//            [self.topViewControllerDelegate updateBusyViewLoadingText:text];
//        }
//        return;
//    }
//
//    if (self.pinEntryViewController.inSettings &&
//        ![text isEqualToString:BC_STRING_LOADING_SYNCING_WALLET] &&
//        ![text isEqualToString:BC_STRING_LOADING_VERIFYING]) {
//        DLog(@"Verify optional PIN view is presented - will not update busy views unless verifying or syncing");
//        return;
//    }
//
//    if (busyView.alpha == 1.0) {
//        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
//            [busyLabel setText:text];
//        }];
//    }
//}
//
//- (void)showVerifyingBusyViewWithTimer:(NSInteger)timeInSeconds
//{
//    [self showBusyViewWithLoadingText:BC_STRING_LOADING_VERIFYING];
//    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:timeInSeconds target:self selector:@selector(showErrorLoading) userInfo:nil repeats:NO];
//}
//
//- (voiupdateBusyViewLoadingTextng
//{
//    [self.loginTimer invalidate];
//
//    if (!WalletManager.sharedInstance.wallet.guid && busyView.alpha == 1.0 && [busyLabel.text isEqualToString:BC_STRING_LOADING_VERIFYING]) {
//        [self.pinEntryViewController reset];
//        [LoadingViewPresenter.sharedInstance hideBusyView];
//        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_ERROR_LOADING_WALLET title:BC_STRING_ERROR handler: nil];
//    }
//}

//- (void)hideBusyView
//{
//    if (self.topViewControllerDelegate) {
//        if ([self.topViewControllerDelegate respondsToSelector:@selector(hideBusyView)]) {
//            [self.topViewControllerDelegate hideBusyView];
//        }
//    }
//
//    if (busyView.alpha == 1.0) {
//        [busyView fadeOut];
//    }
//}

- (void)hideSendAndReceiveKeyboards
{
    [self.tabControllerManager hideSendAndReceiveKeyboards];
}

//- (void)showMobileNotice
//{
//    NSString *message = [WalletManager.sharedInstance.wallet getMobileMessage];
//
//    if (message) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_INFORMATION message:message preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//
//        if (self.window.rootViewController.presentedViewController) {
//            [self.window.rootViewController.presentedViewController presentViewController:alert animated:YES completion:nil];
//        } else {
//            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//        }
//    }
//}

- (BOOL)checkIfWaitingOnEtherTransaction
{
    BOOL isWaiting = [WalletManager.sharedInstance.wallet isWaitingOnEtherTransaction];

    if (isWaiting) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:BC_STRING_WAITING_FOR_ETHER_PAYMENT_TO_FINISH_TITLE message:BC_STRING_WAITING_FOR_ETHER_PAYMENT_TO_FINISH_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
        [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];

        if (self.window.rootViewController.presentedViewController) {
            [self.window.rootViewController.presentedViewController presentViewController:errorAlert animated:YES completion:nil];
        } else {
            [self.window.rootViewController presentViewController:errorAlert animated:YES completion:nil];
        }
    }

    return isWaiting;
}

//#pragma mark - AlertView Helpers
//
//- (void)standardNotifyAutoDismissingController:(NSString *)message
//{
//    [self standardNotifyAutoDismissingController:message title:BC_STRING_ERROR];
//}
//
//- (void)standardNotifyAutoDismissingController:(NSString*)message title:(NSString*)title
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//
//    if (!self.pinEntryViewController) {
//        [[NSNotificationCenter defaultCenter] addObserver:alert selector:@selector(autoDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    }
//
//    if (self.topViewControllerDelegate) {
//        if (self.pinEntryViewController) {
//            [self.pinEntryViewController.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//        } else if ([self.topViewControllerDelegate respondsToSelector:@selector(presentAlertController:)]) {
//            [self.topViewControllerDelegate presentAlertController:alert];
//        }
//    } else if (self.pinEntryViewController) {
//        [self.pinEntryViewController.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//    } else if (self.tabControllerManager.tabViewController.presentedViewController) {
//        [self.tabControllerManager.tabViewController.presentedViewController presentViewController:alert animated:YES completion:nil];
//    } else {
//        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//    }
//}
//
//- (void)standardNotify:(NSString*)message
//{
//    [self standardNotifyAutoDismissingController:message];
//}
//
//- (void)standardNotify:(NSString*)message title:(NSString*)title
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
//            [self standardNotifyAutoDismissingController:message title:title];
//        }
//    });
//}

# pragma mark - Wallet.js callbacks

- (void)walletDidLoad
{
    // TODO move to WalletManager
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endBackgroundUpdateTask];
    });
}
- (void)walletFailedToLoad
{
    DLog(@"walletFailedToLoad");
    // When doing a manual pair the wallet fails to load the first time because the server needs to verify via email that the user grants access to this device. In that case we don't want to display any additional errors besides the server error telling the user to check his email.
    if ([manualPairView isDescendantOfView:_window.rootViewController.view]) {
        return;
    }

//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_FAILED_TO_LOAD_WALLET_TITLE message:[NSString stringWithFormat:BC_STRING_FAILED_TO_LOAD_WALLET_DETAIL] preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_FORGET_WALLET style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UIAlertController *forgetWalletAlert = [UIAlertController alertControllerWithTitle:BC_STRING_WARNING message:BC_STRING_FORGET_WALLET_DETAILS preferredStyle:UIAlertControllerStyleAlert];
//        [forgetWalletAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [self walletFailedToLoad];
//        }]];
//        [forgetWalletAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_FORGET_WALLET style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [WalletManager.sharedInstance forgetWallet];
//            [self showWelcomeScreen];
//        }]];
//        [_window.rootViewController presentViewController:forgetWalletAlert animated:YES completion:nil];
//    }]];
//
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CLOSE_APP style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        UIApplication *app = [UIApplication sharedApplication];
//
//        [app performSelector:@selector(suspend)];
//    }]];
//
//    [_window.rootViewController presentViewController:alert animated:YES completion:nil];
}
//
//- (void)walletDidDecrypt
//{
//    DLog(@"walletDidDecrypt");
//
//    if ([BlockchainSettings sharedAppInstance].isPinSet) {
//        [self forceHDUpgradeForLegacyWallets];
//    }
//
//    self.changedPassword = NO;
//
//    [self setAccountData:wallet.guid sharedKey:wallet.sharedKey];
//
//    //Becuase we are not storing the password on the device. We record the first few letters of the hashed password.
//    //With the hash prefix we can then figure out if the password changed
//    NSString * passwordPartHash = BlockchainSettings.sharedAppInstance.passwordPartHash;
//    if (![[[WalletManager.sharedInstance.wallet.password SHA256] substringToIndex:MIN([WalletManager.sharedInstance.wallet.password length], 5)] isEqualToString:passwordPartHash]) {
//        [self clearPin];
//    }
//}
//
- (void)walletDidFinishLoad
{
//    DLog(@"walletDidFinishLoad");

//    WalletManager.sharedInstance.wallet.btcSwipeAddressToSubscribe = nil;
//    WalletManager.sharedInstance.wallet.bchSwipeAddressToSubscribe = nil;
//
//    WalletManager.sharedInstance.wallet.twoFactorInput = nil;
//
//    [manualPairView clearTextFields];
//
//    [app closeAllModals];
//
//    if (![BlockchainSettings sharedAppInstance].isPinSet) {
//        if (WalletManager.sharedInstance.wallet.isNew) {
//            [self showNewWalletSetup];
//        } else {
//            [app showPinModalAsView:NO];
//        }
//    } else {
//        NSDate *dateOfLastReminder = BlockchainSettings.sharedAppInstance.reminderModalDate;
//
//        NSTimeInterval timeIntervalBetweenPrompts = TIME_INTERVAL_SECURITY_REMINDER_PROMPT;
//
//#ifdef DEBUG
//        id customTimeValue = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_DEBUG_SECURITY_REMINDER_CUSTOM_TIMER];
//        if (customTimeValue) {
//            timeIntervalBetweenPrompts = [customTimeValue doubleValue];
//        }
//#endif
//
//        if (dateOfLastReminder) {
//            if ([dateOfLastReminder timeIntervalSinceNow] < -timeIntervalBetweenPrompts) {
//                [self showSecurityReminder];
//            }
//        } else {
//            if (BlockchainSettings.sharedAppInstance.hasSeenEmailReminder) {
//                [self showSecurityReminder];
//            } else {
//                [self checkIfSettingsLoadedAndShowEmailReminder];
//            }
//        }
//    }
//
//    [self.tabControllerManager.sendBitcoinViewController reload];
//    [self.tabControllerManager.sendBitcoinCashViewController reload];
//
//    // Enabling touch ID and immediately backgrounding the app hides the status bar
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
//
//    [self registerDeviceForPushNotifications];
//
//    if (showType == ShowTypeSendCoins) {
//        [self showSendCoins];
//    } else if (showType == ShowTypeNewPayment) {
//        [self.tabControllerManager showTransactionsAnimated:YES];
//    } else if (showType == ShowTypeNewContact) {
//        [WalletManager.sharedInstance.wallet loadContacts];
//        [self showContacts];
//        return;
//    }
//
//    showType = ShowTypeNone;
//
//    if ([BlockchainSettings sharedAppInstance].isPinSet) {
//
//        UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
//        if (topViewController == self.settingsNavigationController && self.settingsNavigationController) return;
//
//        [self showMobileNotice];
//    }
//
//    [WalletManager.sharedInstance.wallet loadContactsThenGetMessages];
}

- (void)didGetMultiAddressResponse:(MultiAddressResponse*)response
{
    WalletManager.sharedInstance.latestMultiAddressResponse = response;

    [self.tabControllerManager updateTransactionsViewControllerData:response];

#ifdef ENABLE_TRANSACTION_FETCHING
    if (WalletManager.sharedInstance.wallet.isFetchingTransactions) {
        [_transactionsViewController reload];
        WalletManager.sharedInstance.wallet.isFetchingTransactions = NO;
    } else {
        [self reloadAfterMultiAddressResponse];
    }
#else
    if (WalletManager.sharedInstance.wallet.isFilteringTransactions) {
        WalletManager.sharedInstance.wallet.isFilteringTransactions = NO;
        [self updateSymbols];
        [self reloadAfterMultiAddressResponse];
    } else {
        [self getAccountInfo];
    }
#endif

    int newDefaultAccountLabeledAddressesCount = [WalletManager.sharedInstance.wallet getDefaultAccountLabelledAddressesCount];
    NSNumber *lastCount = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_DEFAULT_ACCOUNT_LABELLED_ADDRESSES_COUNT];
    if (lastCount && [lastCount intValue] != newDefaultAccountLabeledAddressesCount) {
        [KeychainItemWrapper removeAllSwipeAddressesForAssetType:AssetTypeBitcoin];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newDefaultAccountLabeledAddressesCount] forKey:USER_DEFAULTS_KEY_DEFAULT_ACCOUNT_LABELLED_ADDRESSES_COUNT];
}

- (void)didSetLatestBlock:(LatestBlock*)block
{
    [self.tabControllerManager didSetLatestBlock:block];
}

- (void)getAccountInfo
{
    // TODO: move this to WalletManager
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccountInfo) name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
    [WalletManager.sharedInstance.wallet getAccountInfo];
}

- (void)didGetAccountInfo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];

    if (showReminderType == ShowReminderTypeTwoFactor) {
        if (![WalletManager.sharedInstance.wallet hasEnabledTwoStep]) {
            [self showTwoFactorReminder];
        }
    } else if (showReminderType == ShowReminderTypeEmail) {
        if (![WalletManager.sharedInstance.wallet hasVerifiedEmail]) {
            [self showEmailVerificationReminder];
        }
    }

    showReminderType = ShowReminderTypeNone;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAfterGettingCurrencySymbols) name:NOTIFICATION_KEY_GET_ALL_CURRENCY_SYMBOLS_SUCCESS object:nil];
    [WalletManager.sharedInstance.wallet getAllCurrencySymbols];
}

- (void)reloadAfterGettingCurrencySymbols
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_GET_ALL_CURRENCY_SYMBOLS_SUCCESS object:nil];

    [self updateSymbols];

    [WalletManager.sharedInstance.wallet fetchBitcoinCashExchangeRates];
}

- (void)didGetBitcoinCashExchangeRates
{
    [WalletManager.sharedInstance.wallet getEthExchangeRate];
}

- (void)didFetchBitcoinCashHistory
{
    [LoadingViewPresenter.sharedInstance hideBusyView];

    [AppCoordinator.sharedInstance reload];
}

- (void)updateSymbols
{
    {
        NSString *fiatCode = WalletManager.sharedInstance.wallet.accountInfo[DICTIONARY_KEY_ACCOUNT_SETTINGS_CURRENCY_FIAT];
        NSMutableDictionary *symbolLocalDict = [[NSMutableDictionary alloc] initWithDictionary:[WalletManager.sharedInstance.wallet.currencySymbols objectForKey:fiatCode]];
        [symbolLocalDict setObject:fiatCode forKey:DICTIONARY_KEY_CODE];
        if (symbolLocalDict) {
            WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local = [CurrencySymbol symbolFromDict:symbolLocalDict];
        }
    }

    {
        NSString *btcCode = WalletManager.sharedInstance.wallet.accountInfo[DICTIONARY_KEY_ACCOUNT_SETTINGS_CURRENCY_BTC];
        if (btcCode) {
            WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc = [CurrencySymbol btcSymbolFromCode:btcCode];
        }
    }
}

- (void)walletFailedToDecrypt
{
    DLog(@"walletFailedToDecrypt");
    // In case we were on the manual pair screen, we want to go back there. The way to check for that is that the wallet has a guid, but it's not saved yet
    if (wallet.guid && ![KeychainItemWrapper guid]) {
        [self manualPairClicked:nil];

        return;
    }

    [self showPasswordModal];
}

- (void)showPasswordModal
{
//    mainPasswordLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
//
//    mainPasswordTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
//    mainPasswordTextField.text = @"";
//
//    mainPasswordButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
//
//    forgotPasswordButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
//    forgotPasswordButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    forgotPasswordButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
//    forgotPasswordButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [forgotPasswordButton setTitle:BC_STRING_FORGOT_PASSWORD forState:UIControlStateNormal];
//
//    forgetWalletLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
//
//    forgetWalletButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
//    forgetWalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    forgetWalletButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
//    forgetWalletButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:mainPasswordTextField action:@selector(resignFirstResponder)];
//
//    [mainPasswordView addGestureRecognizer:tapGesture];
//
//    [self showModalWithContent:mainPasswordView closeType:ModalCloseTypeNone headerText:BC_STRING_PASSWORD_REQUIRED];
}

- (void)beginBackgroundUpdateTask
{
    // We're using a background task to ensure we get enough time to sync. The bg task has to be ended before or when the timer expires, otherwise the app gets killed by the system.
    // Always kill the old handler before starting a new one. In case the system starts a bg task when the app goes into background, comes to foreground and goes to background before the first background task was ended. In that case the first background task is never killed and the system kills the app when the maximum time is up.
    [self endBackgroundUpdateTask];

    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    if (self.backgroundUpdateTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundUpdateTask];
        self.backgroundUpdateTask = UIBackgroundTaskInvalid;
    }
}

- (void)playBeepSound
{
    if (beepSoundID == 0) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"beep" ofType:SOUND_FORMAT]], &beepSoundID);
    }

    AudioServicesPlaySystemSound(beepSoundID);
}

- (void)playAlertSound
{
    if (alertSoundID == 0) {
        //Find the Alert Sound
        NSString * alert_sound = [[NSBundle mainBundle] pathForResource:@"alert-received" ofType:SOUND_FORMAT];

        //Create the system sound
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: alert_sound], &alertSoundID);
    }

    AudioServicesPlaySystemSound(alertSoundID);
}

//- (void)pushWebViewController:(NSString*)url title:(NSString *)title
//{
//    _bcWebViewController = [[BCWebViewController alloc] initWithTitle:title];
//    [_bcWebViewController loadURL:url];
//    _bcWebViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self.tabControllerManager.tabViewController presentViewController:_bcWebViewController animated:YES completion:nil];
//}

- (NSMutableDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] >= 2) {
            NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            [dict setObject:val forKey:key];
        }
    }
    return dict;
}

- (NSDictionary*)parseURI:(NSString*)urlString prefix:(NSString *)urlPrefix
{
    if (!urlString) {
        return nil;
    }

    if (![urlString hasPrefix:urlPrefix]) {
        return [NSDictionary dictionaryWithObject:urlString forKey:DICTIONARY_KEY_ADDRESS];
    }

    NSString * replaced = [[urlString stringByReplacingOccurrencesOfString:PREFIX_BITCOIN_URI withString:[NSString stringWithFormat:@"%@//", PREFIX_BITCOIN_URI]] stringByReplacingOccurrencesOfString:@"////" withString:@"//"];

    NSURL * url = [NSURL URLWithString:replaced];

    NSMutableDictionary *dict = [self parseQueryString:[url query]];

    if ([url host] != NULL)
    [dict setObject:[url host] forKey:DICTIONARY_KEY_ADDRESS];

    return dict;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == secondPasswordTextField) {
        if (validateSecondPassword) {
            [self secondPasswordClicked:textField];
        } else {
            [self privateKeyPasswordClicked];
        }
    }
//    else if (textField == mainPasswordTextField) {
//        [self mainPasswordClicked:textField];
//    }

    return YES;
}

- (void)getPrivateKeyPassword:(void (^)(NSString *))success error:(void (^)(NSString *))error
{
    validateSecondPassword = FALSE;

    secondPasswordDescriptionLabel.text = BC_STRING_PRIVATE_KEY_ENCRYPTED_DESCRIPTION;

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    if (topViewController) {
        BCModalViewController *bcModalViewController = [[BCModalViewController alloc] initWithCloseType:ModalCloseTypeClose showHeader:YES headerText:LocalizationConstantsObjcBridge.passwordRequired   view:secondPasswordView];

        addPrivateKeySuccess = success;

        [topViewController presentViewController:bcModalViewController animated:YES completion:^{
            UIButton *secondPasswordOverlayButton = [[UIButton alloc] initWithFrame:[secondPasswordView convertRect:secondPasswordButton.frame toView:bcModalViewController.view]];
            [bcModalViewController.view addSubview:secondPasswordOverlayButton];
            [secondPasswordOverlayButton addTarget:self action:@selector(privateKeyPasswordClicked) forControlEvents:UIControlEventTouchUpInside];
        }];

        [bcModalViewController.closeButton addTarget:self action:@selector(closeAllModals) forControlEvents:UIControlEventAllTouchEvents];
    } else {
        [app showModalWithContent:secondPasswordView closeType:ModalCloseTypeClose headerText:LocalizationConstantsObjcBridge.passwordRequired onDismiss:^() {
            NSString * password = secondPasswordTextField.text;

            if ([password length] == 0) {
                if (error) error(BC_STRING_NO_PASSWORD_ENTERED);
            } else {
                if (success) success(password);
            }

            secondPasswordTextField.text = nil;
        } onResume:nil];

        BCModalView *modalView = [ModalPresenter sharedInstance].modalView;
        [modalView.closeButton removeTarget:self action:@selector(closeModalClicked:) forControlEvents:UIControlEventAllTouchEvents];

        [modalView.closeButton addTarget:self action:@selector(closeAllModals) forControlEvents:UIControlEventAllTouchEvents];
    }

    [secondPasswordTextField becomeFirstResponder];
}

- (void)privateKeyPasswordClicked
{
    NSString * password = secondPasswordTextField.text;

    if ([password length] == 0) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_NO_PASSWORD_ENTERED title:BC_STRING_ERROR handler: nil];
    } else {
        if (self.tabControllerManager.tabViewController.presentedViewController) {
            [self.tabControllerManager.tabViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self closeModalWithTransition:kCATransitionFade];
        }
        if (addPrivateKeySuccess) addPrivateKeySuccess(password);
    }

    secondPasswordTextField.text = nil;
}

- (IBAction)secondPasswordClicked:(id)sender
{
    NSString *password = secondPasswordTextField.text;

    if ([password length] == 0) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_NO_PASSWORD_ENTERED title:BC_STRING_ERROR handler: nil];
    } else if(validateSecondPassword && ![wallet validateSecondPassword:password]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_SECOND_PASSWORD_INCORRECT title:BC_STRING_ERROR handler: nil];
    } else {
        if (secondPasswordSuccess) {
            // It takes ANIMATION_DURATION to dismiss the second password view, then a little extra to make sure any wait spinners start spinning before we execute the success function.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5*ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (secondPasswordSuccess) {
                    secondPasswordSuccess(password);
                    secondPasswordSuccess = nil;
                }
            });
        }
        [app closeModalWithTransition:kCATransitionFade];
    }

    secondPasswordTextField.text = nil;
}

- (void)getSecondPassword:(void (^)(NSString *))success error:(void (^)(NSString *))error helperText:(NSString *)helperText
{
    secondPasswordDescriptionLabel.text = helperText ? : BC_STRING_ACTION_REQUIRES_SECOND_PASSWORD;

    validateSecondPassword = TRUE;

    secondPasswordSuccess = success;

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    if (topViewController) {
        BCModalViewController *bcModalViewController = [[BCModalViewController alloc] initWithCloseType:ModalCloseTypeClose showHeader:YES headerText:BC_STRING_SECOND_PASSWORD_REQUIRED view:secondPasswordView];

        [topViewController presentViewController:bcModalViewController animated:YES completion:^{
            UIButton *secondPasswordOverlayButton = [[UIButton alloc] initWithFrame:[secondPasswordView convertRect:secondPasswordButton.frame toView:bcModalViewController.view]];
            [bcModalViewController.view addSubview:secondPasswordOverlayButton];
            [secondPasswordOverlayButton addTarget:self action:@selector(secondPasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
        }];

        [bcModalViewController.closeButton addTarget:self action:@selector(closeAllModals) forControlEvents:UIControlEventAllTouchEvents];
    } else {
        [app showModalWithContent:secondPasswordView closeType:ModalCloseTypeClose headerText:BC_STRING_SECOND_PASSWORD_REQUIRED onDismiss:^() {
            secondPasswordTextField.text = nil;
            [self.tabControllerManager enableSendPaymentButtons];
        } onResume:nil];

        BCModalView *modalView = [ModalPresenter sharedInstance].modalView;
        [modalView.closeButton removeTarget:self action:@selector(closeModalClicked:) forControlEvents:UIControlEventAllTouchEvents];

        [modalView.closeButton addTarget:self action:@selector(closeAllModals) forControlEvents:UIControlEventAllTouchEvents];

        [modalView.closeButton addTarget:self action:@selector(forceHDUpgradeForLegacyWallets) forControlEvents:UIControlEventAllTouchEvents];

        if ([self.tabControllerManager isSendViewControllerTransferringAll]) {
            [modalView.closeButton addTarget:self.tabControllerManager action:@selector(reloadSendController) forControlEvents:UIControlEventAllTouchEvents];
        }
    }

    [secondPasswordTextField becomeFirstResponder];
}

- (void)closeAllModals
{
//    [LoadingViewPresenter.sharedInstance hideBusyView];
//
//    secondPasswordSuccess = nil;
//    secondPasswordTextField.text = nil;
//
//    WalletManager.sharedInstance.wallet.isSyncing = NO;
//
//    [modalView endEditing:YES];
//
//    [modalView removeFromSuperview];
//
//    CATransition *animation = [CATransition animation];
//    [animation setDuration:ANIMATION_DURATION];
//    [animation setType:kCATransitionFade];
//
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//
//    [[[UIApplication sharedApplication].keyWindow layer] addAnimation:animation forKey:ANIMATION_KEY_HIDE_MODAL];
//
//    if (self.modalView.onDismiss) {
//        self.modalView.onDismiss();
//        self.modalView.onDismiss = nil;
//    }
//
//    self.modalView = nil;
//
//    for (BCModalView *modalChainView in self.modalChain) {
//
//        for (UIView *subView in [modalChainView.myHolderView subviews]) {
//            [subView removeFromSuperview];
//        }
//
//        [modalChainView.myHolderView removeFromSuperview];
//
//        if (modalChainView.onDismiss) {
//            modalChainView.onDismiss();
//        }
//    }
//
//    [self.modalChain removeAllObjects];
}

- (void)closeModalWithTransition:(NSString *)transition
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_MODAL_VIEW_DISMISSED object:nil];
//
//    [modalView removeFromSuperview];
//
//    CATransition *animation = [CATransition animation];
//    // There are two types of transitions: movement based and fade in/out. The movement based ones can have a subType to set which direction the movement is in. In case the transition parameter is a direction, we use the MoveIn transition and the transition parameter as the direction, otherwise we use the transition parameter as the transition type.
//    [animation setDuration:ANIMATION_DURATION];
//    if (transition != kCATransitionFade) {
//        [animation setType:kCATransitionMoveIn];
//        [animation setSubtype:transition];
//    }
//    else {
//        [animation setType:transition];
//    }
//
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//    [[[UIApplication sharedApplication].keyWindow layer] addAnimation:animation forKey:ANIMATION_KEY_HIDE_MODAL];
//
//    if (self.modalView.onDismiss) {
//        self.modalView.onDismiss();
//        self.modalView.onDismiss = nil;
//    }
//
//    if ([self.modalChain count] > 0) {
//        BCModalView * previousModalView = [self.modalChain objectAtIndex:[self.modalChain count]-1];
//
//        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:previousModalView];
//
//        [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:busyView];
//
//        [[UIApplication sharedApplication].keyWindow.rootViewController.view endEditing:TRUE];
//
//        if (self.modalView.onResume) {
//            self.modalView.onResume();
//        }
//
//        self.modalView = previousModalView;
//
//        [self.modalChain removeObjectAtIndex:[self.modalChain count]-1];
//    }
//    else {
//        self.modalView = nil;
//    }
}

- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType headerText:(NSString *)headerText
{
    [self showModalWithContent:(BCModalContentView *)contentView closeType:closeType showHeader:YES headerText:headerText onDismiss:nil onResume:nil];
}

- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType headerText:(NSString *)headerText onDismiss:(void (^)())onDismiss onResume:(void (^)())onResume
{
    [self showModalWithContent:(BCModalContentView *)contentView closeType:closeType showHeader:YES headerText:headerText onDismiss:onDismiss onResume:onResume];
}

- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText onDismiss:(void (^)())onDismiss onResume:(void (^)())onResume
{
//    // Remove the modal if we have one
//    if (modalView) {
//        [modalView removeFromSuperview];
//
//        if (modalView.closeType != ModalCloseTypeNone) {
//            if (modalView.onDismiss) {
//                modalView.onDismiss();
//                modalView.onDismiss = nil;
//            }
//        } else {
//            [self.modalChain addObject:modalView];
//        }
//
//        self.modalView = nil;
//    }
//
//    // Show modal
//    modalView = [[BCModalView alloc] initWithCloseType:closeType showHeader:showHeader headerText:headerText];
//    self.modalView.onDismiss = onDismiss;
//    self.modalView.onResume = onResume;
//    if (onResume) {
//        onResume();
//    }
//
//    if ([contentView respondsToSelector:@selector(prepareForModalPresentation)]) {
//        [(BCModalContentView *)contentView prepareForModalPresentation];
//    }
//
//    [modalView.myHolderView addSubview:contentView];
//
//    contentView.frame = CGRectMake(0, 0, modalView.myHolderView.frame.size.width, modalView.myHolderView.frame.size.height);
//
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:modalView];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view endEditing:TRUE];
//
//    @try {
//        CATransition *animation = [CATransition animation];
//        [animation setDuration:ANIMATION_DURATION];
//
//        if (closeType == ModalCloseTypeBack) {
//            [animation setType:kCATransitionMoveIn];
//            [animation setSubtype:kCATransitionFromRight];
//        }
//        else {
//            [animation setType:kCATransitionFade];
//        }
//
//        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//        [[[UIApplication sharedApplication].keyWindow.rootViewController.view layer] addAnimation:animation forKey:ANIMATION_KEY_SHOW_MODAL];
//    } @catch (NSException * e) {
//        DLog(@"Animation Exception %@", e);
//    }
//
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didFailBackupWallet
{
    // Refresh the wallet and history
    [WalletManager.sharedInstance.wallet getWalletAndHistory];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_SYNC_ERROR object:nil];
}

- (void)didBackupWallet
{
    [AppCoordinator.sharedInstance reload];
}

//- (void)setAccountData:(NSString*)guid sharedKey:(NSString*)sharedKey
//{
//    if ([guid length] != 36) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:BC_STRING_INTERRUPTED_DECRYPTION_PLEASE_CLOSE_THE_APP_AND_TRY_AGAIN preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CLOSE_APP style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            // Close App
//            UIApplication *app = [UIApplication sharedApplication];
//            [app performSelector:@selector(suspend)];
//        }]];
//        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//        return;
//    }
//
//    if ([sharedKey length] != 36) {
//        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_INVALID_SHARED_KEY title:BC_STRING_ERROR handler: nil];
//        return;
//    }
//
//    [KeychainItemWrapper setGuidInKeychain:guid];
//    [KeychainItemWrapper setSharedKeyInKeychain:sharedKey];
//}

- (IBAction)scanAccountQRCodeclicked:(id)sender
{
    if (![self getCaptureDeviceInput:nil]) {
        return;
    }

    PairingCodeParser * pairingCodeParser = [[PairingCodeParser alloc] initWithSuccess:^(NSDictionary*code) {
        DLog(@"scanAndParse success");

        [WalletManager.sharedInstance forgetWallet];

        [app clearPin];

        [WalletManager.sharedInstance.wallet loadWalletWithGuid:[code objectForKey:QR_CODE_KEY_GUID] sharedKey:[code objectForKey:QR_CODE_KEY_SHARED_KEY] password:[code objectForKey:QR_CODE_KEY_PASSWORD]];

        WalletManager.sharedInstance.wallet.delegate = self;

        wallet.didPairAutomatically = YES;

    } error:^(NSString*error) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR handler: nil];
    }];

    ECSlidingViewController *slidingViewController = [AppCoordinator sharedInstance].slidingViewController;
    [slidingViewController presentViewController:pairingCodeParser animated:YES completion:nil];
}

- (void)scanPrivateKeyForWatchOnlyAddress:(NSString *)address
{
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    if (![app getCaptureDeviceInput:nil]) {
        return;
    }

    PrivateKeyReader *reader = [[PrivateKeyReader alloc] initWithAssetType:self.tabControllerManager.assetType success:^(NSString* privateKeyString) {
        [WalletManager.sharedInstance.wallet addKey:privateKeyString toWatchOnlyAddress:address];
    } error:nil acceptPublicKeys:NO busyViewText:BC_STRING_LOADING_IMPORT_KEY];

    [[NSNotificationCenter defaultCenter] addObserver:reader selector:@selector(autoDismiss) name:ConstantsObjcBridge.notificationKeyReloadToDismissViews object:nil];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:reader animated:YES completion:nil];

    WalletManager.sharedInstance.wallet.lastScannedWatchOnlyAddress = address;
}

- (void)askUserToAddWatchOnlyAddress:(NSString *)address success:(void (^)(NSString *))success
{
    UIAlertController *alertToWarnAboutWatchOnly = [UIAlertController alertControllerWithTitle:BC_STRING_WARNING_TITLE message:[NSString stringWithFormat:@"%@\n\n%@", BC_STRING_ADD_WATCH_ONLY_ADDRESS_WARNING_ONE, BC_STRING_ADD_WATCH_ONLY_ADDRESS_WARNING_TWO] preferredStyle:UIAlertControllerStyleAlert];
    [alertToWarnAboutWatchOnly addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (success) {
            success(address);
        }
    }]];
    [alertToWarnAboutWatchOnly addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:alertToWarnAboutWatchOnly animated:YES completion:nil];
}

- (void)logout
{
//    [self.loginTimer invalidate];
//
//    [WalletManager.sharedInstance.wallet resetSyncStatus];
//
//    [WalletManager.sharedInstance.wallet loadBlankWallet];
//
//    WalletManager.sharedInstance.wallet.hasLoadedAccountInfo = NO;
//
//    WalletManager.sharedInstance.latestMultiAddressResponse = nil;
//
//    [self.tabControllerManager logout];
//
//    _settingsNavigationController = nil;
//
//    [AppCoordinator.sharedInstance reload];
//
//    [WalletManager.sharedInstance.wallet.ethSocket closeWithCode:WEBSOCKET_CODE_LOGGED_OUT reason:WEBSOCKET_CLOSE_REASON_LOGGED_OUT];
//    [WalletManager.sharedInstance.wallet.btcSocket closeWithCode:WEBSOCKET_CODE_LOGGED_OUT reason:WEBSOCKET_CLOSE_REASON_LOGGED_OUT];
//    [WalletManager.sharedInstance.wallet.bchSocket closeWithCode:WEBSOCKET_CODE_LOGGED_OUT reason:WEBSOCKET_CLOSE_REASON_LOGGED_OUT];
}

//- (void)buyBitcoinClicked:(id)sender
//{
//    NSDictionary *loginData = [[WalletManager.sharedInstance.wallet executeJSSynchronous:@"MyWalletPhone.getWebViewLoginData()"] toDictionary];
//    NSString *walletJson = loginData[@"walletJson"];
//    NSString *externalJson = [loginData[@"externalJson"] isEqual:[NSNull null]] ? @"" : loginData[@"externalJson"];
//    NSString *magicHash = [loginData[@"magicHash"] isEqual:[NSNull null]] ? @"" : loginData[@"magicHash"];
//    [self.buyBitcoinViewController loginWithJson:walletJson externalJson:externalJson magicHash:magicHash password:WalletManager.sharedInstance.wallet.password];
//    self.buyBitcoinViewController.delegate = WalletManager.sharedInstance.wallet;
//    BuyBitcoinNavigationController *navigationController = [[BuyBitcoinNavigationController alloc] initWithRootViewController:self.buyBitcoinViewController title:BC_STRING_BUY_AND_SELL_BITCOIN];
//    [self.tabControllerManager.tabViewController presentViewController:navigationController animated:YES completion:nil];
//}

//- (void)exchangeClicked:(id)sender
//{
//    [self.tabControllerManager exchangeClicked];
//}

//- (void)forgetWallet
//{
//    [self clearPin];
//
//    // Clear all cookies (important one is the server session id SID)
//    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *each in cookieStorage.cookies) {
//        [cookieStorage deleteCookie:each];
//    }
//
//    WalletManager.sharedInstance.wallet.sessionToken = nil;
//
//    [KeychainItemWrapper removeAllSwipeAddresses];
//
//    self.isVerifyingMobileNumber = NO;
//
//    [KeychainItemWrapper removeGuidFromKeychain];
//    [KeychainItemWrapper removeSharedKeyFromKeychain];
//
//    [WalletManager.sharedInstance.wallet loadBlankWallet];
//
//    self.latestResponse = nil;
//
//    [self.tabControllerManager forgetWallet];
//
//    [self reload];
//
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_DEFAULTS_KEY_CONTACTS_LAST_NAME_USED];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USER_DEFAULTS_KEY_TOUCH_ID_ENABLED];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    [[AppCoordinator sharedInstance].tabControllerManager transitionToIndex:TAB_DASHBOARD];
//
//    [self setupBuySellWebview];
//}

- (void)didImportKey:(NSString *)address
{
    [LoadingViewPresenter.sharedInstance showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];

    WalletManager.sharedInstance.wallet.lastImportedAddress = address;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertUserOfImportedKey) name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
}

- (void)alertUserOfImportedKey
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];

    NSString *messageWithArgument = [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:WalletManager.sharedInstance.wallet.lastImportedAddress] ? BC_STRING_IMPORTED_WATCH_ONLY_ADDRESS_ARGUMENT : BC_STRING_IMPORTED_PRIVATE_KEY_ARGUMENT;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_SUCCESS message:[NSString stringWithFormat:messageWithArgument, WalletManager.sharedInstance.wallet.lastImportedAddress] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:alert selector:@selector(autoDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:alert animated:YES completion:nil];
}

- (void)didImportIncorrectPrivateKey:(NSString *)address
{
    [LoadingViewPresenter.sharedInstance showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertUserOfImportedIncorrectPrivateKey) name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
}

- (void)alertUserOfImportedIncorrectPrivateKey
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];

    NSString *message = [NSString stringWithFormat:@"%@\n\n%@", BC_STRING_INCORRECT_PRIVATE_KEY_IMPORTED_MESSAGE_ONE, BC_STRING_INCORRECT_PRIVATE_KEY_IMPORTED_MESSAGE_TWO];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_SUCCESS message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:alert selector:@selector(autoDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:alert animated:YES completion:nil];
}

- (void)didImportPrivateKeyToLegacyAddress
{
    [LoadingViewPresenter.sharedInstance showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertUserOfImportedPrivateKeyIntoLegacyAddress) name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
}

- (void)alertUserOfImportedPrivateKeyIntoLegacyAddress
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_SUCCESS message:BC_STRING_IMPORTED_PRIVATE_KEY_SUCCESS preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:alert selector:@selector(autoDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:alert animated:YES completion:nil];
}

- (void)didFailToImportPrivateKey:(NSString *)error
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.tabControllerManager.receiveBitcoinViewController name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];

    [LoadingViewPresenter.sharedInstance hideBusyView];
    WalletManager.sharedInstance.wallet.isSyncing = NO;

    if ([error containsString:ERROR_PRESENT_IN_WALLET]) {
        error = BC_STRING_KEY_ALREADY_IMPORTED;
    } else if ([error containsString:ERROR_NEEDS_BIP38]) {
        error = BC_STRING_NEEDS_BIP38_PASSWORD;
    } else if ([error containsString:ERROR_WRONG_BIP_PASSWORD]) {
        error = BC_STRING_WRONG_BIP38_PASSWORD;
    } else {
        error = BC_STRING_UNKNOWN_ERROR_PRIVATE_KEY;
    }

    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:error preferredStyle:UIAlertControllerStyleAlert];
    [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:errorAlert selector:@selector(autoDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:errorAlert animated:YES completion:nil];
}

- (void)didFailToImportPrivateKeyForWatchOnlyAddress:(NSString *)error
{
    [LoadingViewPresenter.sharedInstance hideBusyView];
    WalletManager.sharedInstance.wallet.isSyncing = NO;
    NSString *alertTitle = BC_STRING_ERROR;
    if ([error containsString:ERROR_NOT_PRESENT_IN_WALLET]) {
        error = BC_STRING_ADDRESS_NOT_PRESENT_IN_WALLET;
    } else if ([error containsString:ERROR_ADDRESS_NOT_WATCH_ONLY]) {
        error = BC_STRING_ADDRESS_NOT_WATCH_ONLY;
    } else if ([error containsString:ERROR_WRONG_BIP_PASSWORD]) {
        error = BC_STRING_WRONG_BIP38_PASSWORD;
    } else if ([error containsString:ERROR_PRIVATE_KEY_OF_ANOTHER_WATCH_ONLY_ADDRESS]) {
        error = BC_STRING_KEY_BELONGS_TO_OTHER_ADDRESS_NOT_WATCH_ONLY;
    }

    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:alertTitle message:error preferredStyle:UIAlertControllerStyleAlert];
    [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [errorAlert addAction:[UIAlertAction actionWithTitle:[LocalizationConstantsObjcBridge tryAgain] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self scanPrivateKeyForWatchOnlyAddress:WalletManager.sharedInstance.wallet.lastScannedWatchOnlyAddress];
    }]];

    [[NSNotificationCenter defaultCenter] addObserver:errorAlert selector:@selector(autoDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:errorAlert animated:YES completion:nil];
}

- (void)didFailRecovery
{
    [createWalletView showPassphraseTextField];
}

- (void)didRecoverWallet
{
    [createWalletView didRecoverWallet];
}

- (void)didFailGetHistory:(NSString *)error
{
    NSString *errorMessage = [error length] == 0 ? BC_STRING_SEND_ERROR_NO_INTERNET_CONNECTION : error;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];

    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)didGenerateNewAddress
{
    [app.accountsAndAddressesNavigationController didGenerateNewAddress];
}

- (void)returnToAddressesScreen
{
    if (self.accountsAndAddressesNavigationController) {
        [self.accountsAndAddressesNavigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)alertUserOfInvalidAccountName
{
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_NAME_ALREADY_IN_USE title:BC_STRING_ERROR handler: nil];

    [LoadingViewPresenter.sharedInstance hideBusyView];
}

- (void)alertUserOfInvalidPrivateKey
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_INCORRECT_PRIVATE_KEY title:BC_STRING_ERROR handler: nil];
    });
}

- (void)sendFromWatchOnlyAddress
{
    [self.tabControllerManager sendFromWatchOnlyAddress];
}

- (void)didCheckForOverSpending:(NSNumber *)amount fee:(NSNumber *)fee
{
    [self.tabControllerManager didCheckForOverSpending:amount fee:fee];
}

- (void)didGetMaxFee:(NSNumber *)fee amount:(NSNumber *)amount dust:(NSNumber *)dust willConfirm:(BOOL)willConfirm
{
    [self.tabControllerManager didGetMaxFee:fee amount:amount dust:dust willConfirm:willConfirm];
}

- (void)didUpdateTotalAvailable:(NSNumber *)sweepAmount finalFee:(NSNumber *)finalFee
{
    [self.tabControllerManager didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
}

- (void)didGetFee:(NSNumber *)fee dust:(NSNumber *)dust txSize:(NSNumber *)txSize
{
    [self.tabControllerManager didGetFee:fee dust:dust txSize:txSize];
}

- (void)didChangeSatoshiPerByte:(NSNumber *)sweepAmount fee:(NSNumber *)fee dust:(NSNumber *)dust updateType:(FeeUpdateType)updateType
{
    [self.tabControllerManager didChangeSatoshiPerByte:sweepAmount fee:fee dust:dust updateType:updateType];
}

- (void)enableSendPaymentButtons
{
    [self.tabControllerManager enableSendPaymentButtons];
}

- (void)updateSendBalance:(NSNumber *)balance fees:(NSDictionary *)fees
{
    [self.tabControllerManager updateSendBalance:balance fees:fees];
}

- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed
{
    if (self.transferAllFundsModalController) {
        [self.transferAllFundsModalController updateTransferAllAmount:amount fee:fee addressesUsed:addressesUsed];
        [LoadingViewPresenter.sharedInstance hideBusyView];
    } else {
        [self.tabControllerManager updateTransferAllAmount:amount fee:fee addressesUsed:addressesUsed];
    }
}

- (void)showSummaryForTransferAll
{
    if (self.transferAllFundsModalController) {
        [self.transferAllFundsModalController showSummaryForTransferAll];
        [LoadingViewPresenter.sharedInstance hideBusyView];
    } else {
        [self.tabControllerManager showSummaryForTransferAll];
    }
}

- (void)sendDuringTransferAll:(NSString *)secondPassword
{
    if (self.transferAllFundsModalController) {
        [self.transferAllFundsModalController sendDuringTransferAll:secondPassword];
    } else {
        [self.tabControllerManager sendDuringTransferAll:secondPassword];
    }
}

- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *)secondPassword
{
    [self.tabControllerManager didErrorDuringTransferAll:error secondPassword:secondPassword];
}

- (void)updateLoadedAllTransactions:(NSNumber *)loadedAll
{
    [self.tabControllerManager updateLoadedAllTransactions:loadedAll];
}

- (void)didReceivePaymentNotice:(NSString *)notice
{
    if (self.tabControllerManager.tabViewController.selectedIndex == TAB_SEND && LoadingViewPresenter.sharedInstance.busyView.alpha == 0 && !self.pinEntryViewController && !self.tabControllerManager.tabViewController.presentedViewController) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:notice title:[LocalizationConstantsObjcBridge information] handler: nil];
    }
}

- (void)didGetFiatAtTime:(NSNumber *)fiatAmount currencyCode:(NSString *)currencyCode assetType:(AssetType)assetType
{
    BOOL didFindTransaction = NO;

    NSArray *transactions;
    NSString *targetHash;

    if (assetType == AssetTypeBitcoin) {
        transactions = WalletManager.sharedInstance.latestMultiAddressResponse.transactions;
        targetHash = self.tabControllerManager.transactionsBitcoinViewController.detailViewController.transactionModel.myHash;
    } else if (assetType == AssetTypeEther) {
        transactions = WalletManager.sharedInstance.wallet.etherTransactions;
        targetHash = self.tabControllerManager.transactionsEtherViewController.detailViewController.transactionModel.myHash;
    } else if (assetType == AssetTypeBitcoinCash) {
        transactions = WalletManager.sharedInstance.wallet.bitcoinCashTransactions;
        targetHash = self.tabControllerManager.transactionsBitcoinCashViewController.detailViewController.transactionModel.myHash;
    }

    for (Transaction *transaction in transactions) {
        if ([transaction.myHash isEqualToString:targetHash]) {
            [transaction.fiatAmountsAtTime setObject:[app.localCurrencyFormatter stringFromNumber:fiatAmount] forKey:currencyCode];
            didFindTransaction = YES;
            break;
        }
    }

    if (!didFindTransaction) {
        DLog(@"didGetFiatAtTime: will not set fiat amount because the detail controller's transaction hash cannot be found.");
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_GET_FIAT_AT_TIME object:nil];
}

- (void)didErrorWhenGettingFiatAtTime:(NSString *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:BC_STRING_ERROR_GETTING_FIAT_AT_TIME preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];

    [self.tabControllerManager.tabViewController.presentedViewController presentViewController:alert animated:YES completion:nil];
}

- (void)didSetDefaultAccount
{
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:AssetTypeBitcoin];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:AssetTypeBitcoinCash];
    [self.tabControllerManager didSetDefaultAccount];
}

- (void)didChangeLocalCurrency
{
    [self.tabControllerManager didChangeLocalCurrency];
}

//- (void)didCreateInvitation:(NSDictionary *)invitation
//{
//    [self.contactsViewController didCreateInvitation:invitation];
//}
//
//- (void)didReadInvitation:(NSDictionary *)invitation identifier:(NSString *)identifier;
//{
//    [self.contactsViewController didReadInvitation:invitation identifier:identifier];
//}
//
//- (void)didCompleteRelation
//{
//    [self.contactsViewController didCompleteRelation];
//}
//
//- (void)didFailCompleteRelation
//{
//    [self.contactsViewController didFailCompleteRelation];
//}
//
//- (void)didFailAcceptRelation:(NSString *)name
//{
//    [self.contactsViewController didFailAcceptRelation:name];
//}
//
//- (void)didAcceptRelation:(NSString *)invitation name:(NSString *)name
//{
//    [self.contactsViewController didAcceptRelation:invitation name:name];
//}
//
//- (void)didFetchExtendedPublicKey
//{
//    [self.contactsViewController didFetchExtendedPublicKey];
//}

//- (void)didGetMessagesOnFirstLoad
//{
//    [self.tabControllerManager didGetMessagesOnFirstLoad];
//
//    [self reloadMessageViews];
//}

//- (void)didGetNewMessages:(NSArray *)newMessages
//{
//    UNNotification *pushNotificationPendingAction = PushNotificationManager.sharedInstace.presentingPushNotification;
//    if (pushNotificationPendingAction) {
//
//        NSString *type = [pushNotificationPendingAction.request.content.userInfo objectForKey:DICTIONARY_KEY_TYPE];
//
//        NSString *identifier;
//
//        if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_PAYMENT]) {
//            identifier = [[[newMessages firstObject] objectForKey:DICTIONARY_KEY_PAYLOAD] objectForKey:DICTIONARY_KEY_ID];
//        }
//        else if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_CONTACT_REQUEST]) {
//            identifier = [pushNotificationPendingAction.request.content.userInfo objectForKey:DICTIONARY_KEY_ID];
//        }
//
//        DLog(@"User received remote notification %@ of type %@", identifier, type);
//
//        NSDictionary *alert = [[pushNotificationPendingAction.request.content.userInfo objectForKey:DICTIONARY_KEY_APS] objectForKey:DICTIONARY_KEY_ALERT];
//        NSString *title = [alert objectForKey:DICTIONARY_KEY_TITLE];
//        NSString *message = [alert objectForKey:DICTIONARY_KEY_BODY];
//
//        if ([WalletManager.sharedInstance.wallet isInitialized]) {
//
//            UIAlertController *alert;
//
//            UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController.topMostViewController;
//            if ([topViewController conformsToProtocol:@protocol(TopViewController)]) {
//                if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_CONTACT_REQUEST]) {
//                    alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_GO_TO_CONTACTS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        [self.tabControllerManager.tabViewController dismissViewControllerAnimated:YES completion:^{
//                            [[AppCoordinator sharedInstance] closeSideMenu];
//                            [app closeAllModals];
//                        }];
//                    }]];
//                } else
//                if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_PAYMENT]) {
//                    alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_GO_TO_TRANSACTIONS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        [self.tabControllerManager.tabViewController dismissViewControllerAnimated:YES completion:^{
//                            [[AppCoordinator sharedInstance] closeSideMenu];
//                            [app closeAllModals];
//                            [self showTransactions];
//                            [self.tabControllerManager selectPayment:identifier];
//                        }];
//                    }]];
//                }
//                if (alert) {
//                    [topViewController presentViewController:alert animated:YES completion:nil];
//                }
//
//            } else if (self.pinEntryViewController) {
//                // On PIN screen
//                if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_CONTACT_REQUEST]) {
//                    alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//                } else if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_PAYMENT]) {
//                    alert = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"%@\n%@", message, BC_STRING_GO_TO_TRANSACTIONS_TO_ACCEPT] preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//                }
//                [self.pinEntryViewController.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//            } else {
//
//                // Not on PIN screen, no top view controller
//                if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_CONTACT_REQUEST]) {
//                    alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_GO_TO_CONTACTS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        [app closeAllModals];
//                        [[AppCoordinator sharedInstance] closeSideMenu];
////                        _contactsViewController = [[ContactsViewController alloc] initWithAcceptedInvitation:identifier];
////                        [self showContacts];
//                    }]];
//                } else
//                if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_PAYMENT]) {
//                    alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
//
//                    if (self.tabControllerManager.tabViewController.activeViewController == self.tabControllerManager.transactionsBitcoinViewController) {
//                        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_GO_TO_REQUEST style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                            [app closeAllModals];
//                            [[AppCoordinator sharedInstance] closeSideMenu];
//                            [self.tabControllerManager selectPayment:identifier];
//                        }]];
//                    } else {
//                        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_GO_TO_TRANSACTIONS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                            [app closeAllModals];
//                            [[AppCoordinator sharedInstance] closeSideMenu];
//                            [self showTransactions];
//                            [self.tabControllerManager selectPayment:identifier];
//                        }]];
//                    }
//                }
//                [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//            }
//        } else if ([KeychainItemWrapper guid] && [KeychainItemWrapper sharedKey]) {
//
//            // Logged out
//            UIAlertController *alert;
//            if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_CONTACT_REQUEST]) {
//                alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
//                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//            } else if ([type isEqualToString:PUSH_NOTIFICATION_TYPE_PAYMENT]) {
//                alert = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"%@\n%@", message, BC_STRING_GO_TO_TRANSACTIONS_TO_ACCEPT] preferredStyle:UIAlertControllerStyleAlert];
//                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//            }
//
//            if (self.pinEntryViewController) {
//                [self.pinEntryViewController.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
//            } else {
//                // Use should be on logged out/enter password modal
//                [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//            }
//        } else {
//            DLog(@"Got messages while unpaired - possibly received push notification while unpaired");
//        }
//    }
//
//    PushNotificationManager.sharedInstace.presentingPushNotification = nil;
//
//    [self reloadMessageViews];
//}

//- (void)reloadMessageViews
//{
//    [self.tabControllerManager reloadMessageViews];
//
//    [sideMenuViewController reloadTableView];
//
//    NSInteger badgeNumber = 0;
//
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
//
//    [self.tabControllerManager updateBadgeNumber:badgeNumber forSelectedIndex:TAB_TRANSACTIONS];
//}

- (void)didCompleteTrade:(NSDictionary *)trade
{
    NSString *date = [trade objectForKey:DICTIONARY_KEY_TRADE_DATE_CREATED];
    NSString *hash = [trade objectForKey:DICTIONARY_KEY_TRADE_HASH];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_TRADE_COMPLETED message:[NSString stringWithFormat:BC_STRING_THE_TRADE_YOU_CREATED_ON_DATE_ARGUMENT_HAS_BEEN_COMPLETED, date] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_VIEW_DETAILS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tabControllerManager showTransactionDetailForHash:hash];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;
        [topViewController presentViewController:alert animated:YES completion:nil];
    });
}

- (void)showCompletedTrade:(NSString *)txHash
{
    [[AppCoordinator sharedInstance] closeSideMenu];

    [self showTransactions];

    [self.tabControllerManager showTransactionDetailForHash:txHash];
}

- (void)didPushTransaction
{
    DestinationAddressSource source = [self.tabControllerManager getSendAddressSource];
    NSString *eventName;

    if (source == DestinationAddressSourceQR) {
        eventName = WALLET_EVENT_TX_FROM_QR;
    } else if (source == DestinationAddressSourcePaste) {
        eventName = WALLET_EVENT_TX_FROM_PASTE;
    } else if (source == DestinationAddressSourceURI) {
        eventName = WALLET_EVENT_TX_FROM_URI;
    } else if (source == DestinationAddressSourceDropDown) {
        eventName = WALLET_EVENT_TX_FROM_DROPDOWN;
    } else if (source == DestinationAddressSourceContact) {
        eventName = WALLET_EVENT_TX_FROM_CONTACTS;
    } else if (source == DestinationAddressSourceNone) {
        DLog(@"Destination address source none");
        return;
    } else {
        DLog(@"Unknown destination address source %d", source);
        return;
    }

    NSURL *URL = [NSURL URLWithString:[[[BlockchainAPI sharedInstance] walletUrl] stringByAppendingFormat:URL_SUFFIX_EVENT_NAME_ARGUMENT, eventName]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"POST";

    NSURLSessionDataTask *dataTask = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            DLog(@"Error saving address input: %@", [error localizedDescription]);
        }
    }];

    [dataTask resume];
}

//- (void)didSendPaymentRequest:(NSDictionary *)info amount:(uint64_t)amount name:(NSString *)name requestId:(NSString *)requestId
//{
//    if (!requestId) {
//        [LoadingViewPresenter.sharedInstance hideBusyView];
//        [self.tabControllerManager clearReceiveAmounts];
//
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"success_large"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//        imageView.tintColor = COLOR_BLOCKCHAIN_GREEN;
//        imageView.frame = CGRectMake(0, 0, 70, 70);
//
//        BCEmptyPageView *confirmationView = [[BCEmptyPageView alloc] initWithFrame:CGRectMake(self.window.frame.origin.x, self.window.frame.origin.y - DEFAULT_HEADER_HEIGHT, self.window.frame.size.width, self.window.frame.size.height)
//                                                                             title:BC_STRING_REQUEST_SENT_TITLE
//                                                                        titleColor:COLOR_BLOCKCHAIN_GREEN
//                                                                          subtitle:[NSString stringWithFormat:BC_STRING_REQUEST_SENT_SUBTITLE_AMOUNT_ARGUMENT_CONTACT_NAME_ARGUMENT, [NSNumberFormatter formatMoney:amount localCurrency:NO], name]
//                                                                         imageView:imageView];
//
//        [app showModalWithContent:confirmationView closeType:ModalCloseTypeDone headerText:BC_STRING_CONFIRMATION onDismiss:^{
//            [self showTransactions];
//        } onResume:nil];
//    }
//}

//- (void)didRequestPaymentRequest:(NSDictionary *)info name:(NSString *)name
//{
//    [LoadingViewPresenter.sharedInstance hideBusyView];
//
//    [self.tabControllerManager reloadSendController];
//
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"success_large"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//    imageView.tintColor = COLOR_BLOCKCHAIN_GREEN;
//    imageView.frame = CGRectMake(0, 0, 70, 70);
//
//    BCEmptyPageView *confirmationView = [[BCEmptyPageView alloc] initWithFrame:CGRectMake(self.window.frame.origin.x, self.window.frame.origin.y - DEFAULT_HEADER_HEIGHT, self.window.frame.size.width, self.window.frame.size.height)
//                                                                         title:BC_STRING_TRANSACTION_STARTED_TITLE
//                                                                    titleColor:COLOR_BLOCKCHAIN_GREEN
//                                                                      subtitle:[NSString stringWithFormat:BC_STRING_TRANSACTION_STARTED_SUBTITLE_CONTACT_NAME_ARGUMENT, name]
//                                                                     imageView:imageView];
//
//    UITextView *noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, confirmationView.frame.size.width - 24, 0)];
//    noteTextView.layer.cornerRadius = 2.0;
//    noteTextView.text = [NSString stringWithFormat:@"%@\n%@", [BC_STRING_IMPORTANT_NOTE uppercaseString], BC_STRING_RPR_INFO];
//    noteTextView.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
//    noteTextView.backgroundColor = COLOR_NOTE_LIGHT_BLUE;
//    noteTextView.textColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
//    CGFloat margin = 12;
//    noteTextView.textContainerInset = UIEdgeInsetsMake(margin, margin, margin, margin);
//    noteTextView.editable = NO;
//    noteTextView.scrollEnabled = NO;
//    noteTextView.selectable = NO;
//    [noteTextView sizeToFit];
//    noteTextView.frame = CGRectMake(0, confirmationView.frame.size.height - noteTextView.frame.size.height - 8 - DEFAULT_HEADER_HEIGHT, noteTextView.frame.size.width, noteTextView.frame.size.height);
//    noteTextView.center = CGPointMake(confirmationView.center.x, noteTextView.center.y);
//    noteTextView.layer.borderColor = [COLOR_BLOCKCHAIN_LIGHT_BLUE CGColor];
//    noteTextView.layer.borderWidth = 1.0;
//    [confirmationView addSubview:noteTextView];
//
//    [app showModalWithContent:confirmationView closeType:ModalCloseTypeDone headerText:BC_STRING_CONFIRMATION onDismiss:^{
//        [self showTransactions];
//    } onResume:nil];
//}

//- (void)didSendPaymentRequestResponse
//{
//    [WalletManager.sharedInstance.wallet getHistoryWithoutBusyView];
//}

//- (void)didChangeContactName:(NSDictionary *)info
//{
//    [self.contactsViewController didChangeContactName];
//}
//
//- (void)didDeleteContact:(NSDictionary *)info
//{
//    if ([self.contactsViewController.navigationController.viewControllers count] == 1) {
//        [WalletManager.sharedInstance.wallet getMessages];
//    } else {
//        [self.contactsViewController.navigationController popToRootViewControllerAnimated:YES];
//    }
//}
//
//- (void)didDeleteContactAfterStoringInfo:(NSDictionary *)info
//{
//    [self.contactsViewController didDeleteContactAfterStoringInfo];
//}
//
//- (void)didRejectContactTransaction
//{
//    [self.tabControllerManager didRejectContactTransaction];
//
//    [WalletManager.sharedInstance.wallet getMessages];
//}

- (void)didGetSwipeAddresses:(NSArray *)newSwipeAddresses assetType:(AssetType)assetType
{
    if (!newSwipeAddresses) {
        DLog(@"Error: no new swipe addresses found!");
        return;
    }

    for (NSString *swipeAddress in newSwipeAddresses) {
        [KeychainItemWrapper addSwipeAddress:swipeAddress assetType:assetType];
    }

    if (assetType == AssetTypeBitcoin) {

        int numberOfBitcoinCashAddressesToDerive = SWIPE_TO_RECEIVE_ADDRESS_COUNT;
        NSArray *bitcoinCashSwipeAddresses = [KeychainItemWrapper getSwipeAddressesForAssetType:AssetTypeBitcoinCash];
        if (bitcoinCashSwipeAddresses) {
            numberOfBitcoinCashAddressesToDerive = SWIPE_TO_RECEIVE_ADDRESS_COUNT - (int)bitcoinCashSwipeAddresses.count;
        }

        [WalletManager.sharedInstance.wallet getSwipeAddresses:numberOfBitcoinCashAddressesToDerive assetType:AssetTypeBitcoinCash];
    } else {
        [self.pinEntryViewController setupQRCode];
    }
}

- (void)didFetchEthHistory
{
    [LoadingViewPresenter.sharedInstance hideBusyView];

    [AppCoordinator.sharedInstance reload];
}

- (void)didUpdateEthPayment:(NSDictionary *)ethPayment
{
    [self.tabControllerManager didUpdateEthPayment:ethPayment];
}

- (void)didFetchEthExchangeRate:(NSNumber *)rate
{
    [self reloadAfterMultiAddressResponse];

    [self.tabControllerManager didFetchEthExchangeRate:rate];
}

- (void)didSendEther
{
    [self.tabControllerManager didSendEther];
}

- (void)didErrorDuringEtherSend:(NSString *)error
{
    [self.tabControllerManager didErrorDuringEtherSend:error];
}

- (void)didCreateEthAccountForExchange
{
    [self.tabControllerManager didCreateEthAccountForExchange];
}

- (void)didGetEtherAddressWithSecondPassword
{
    [self.tabControllerManager didGetEtherAddressWithSecondPassword];
}

- (void)didGetExchangeTrades:(NSArray *)trades
{
    [self.tabControllerManager didGetExchangeTrades:trades];
}

- (void)didGetExchangeRate:(NSDictionary *)result
{
    [self.tabControllerManager didGetExchangeRate:result];
}

- (void)didGetAvailableBtcBalance:(NSDictionary *)result
{
    [self.tabControllerManager didGetAvailableBtcBalance:result];
}

- (void)didGetAvailableEthBalance:(NSDictionary *)result
{
    [self.tabControllerManager didGetAvailableEthBalance:result];
}

- (void)didBuildExchangeTrade:(NSDictionary *)tradeInfo
{
    [self.tabControllerManager didBuildExchangeTrade:tradeInfo];
}

- (void)didShiftPayment:(NSDictionary *)info
{
    [self.tabControllerManager didShiftPayment:info];
}

- (void)showGetAssetsAlert
{
    [self.tabControllerManager showGetAssetsAlert];
}

//- (void)checkForMaintenance
//{
//    [self checkForMaintenanceWithPinKey:nil pin:nil];
//}

//- (void)checkForMaintenanceWithPinKey:(NSString *)pinKey pin:(NSString *)pin
//{
//    NSURL *url = [NSURL URLWithString:[[[BlockchainAPI sharedInstance] walletUrl] stringByAppendingString:URL_SUFFIX_WALLET_OPTIONS]];
//    // session.sessionDescription = url.host;
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//    NSURLSessionDataTask *task = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (error) {
//                DLog(@"Error checking for maintenance in wallet options: %@", [error localizedDescription]);
//                [self hideBusyView];
//                [self.pinEntryViewController reset];
//                [self showMaintenanceAlertWithTitle:BC_STRING_ERROR message:BC_STRING_REQUEST_FAILED_PLEASE_CHECK_INTERNET_CONNECTION];
//            }
//            NSError *jsonError;
//            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
//            if (jsonError) {
//                DLog(@"Error parsing response from checking for maintenance in wallet options: %@", [error localizedDescription]);
//                [self hideBusyView];
//                [self.pinEntryViewController reset];
//                [self showMaintenanceAlertWithTitle:BC_STRING_ERROR message:BC_STRING_REQUEST_FAILED_PLEASE_CHECK_INTERNET_CONNECTION];
//            } else {
//                if ([[result objectForKey:DICTIONARY_KEY_MAINTENANCE] boolValue]) {
//                    NSDictionary *mobileInfo = [result objectForKey:DICTIONARY_KEY_MOBILE_INFO];
//                    NSString *message = [mobileInfo objectForKey:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]] ? : [mobileInfo objectForKey:@"en"];
//                    [self hideBusyView];
//                    [self.pinEntryViewController reset];
//                    [self showMaintenanceAlertWithTitle:BC_STRING_INFORMATION message:message];
//                } else {
//                    if (pinKey && pin) {
//                        [WalletManager.sharedInstance.wallet apiGetPINValue:pinKey pin:pin];
//                    }
//                }
//            }
//        });
//    }];
//    [task resume];
//}

//- (void)showMaintenanceAlertWithTitle:(NSString *)title message:(NSString *)message
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        UIApplication *app = [UIApplication sharedApplication];
//        [app performSelector:@selector(suspend)];
//    }]];
//
//    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController) {
//        [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController presentViewController:alert animated:YES completion:nil];
//    } else {
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//    }
//}

#pragma mark - Show Screens

//- (void)showContacts
//{
//    if (!_contactsViewController) {
//        _contactsViewController = [ContactsViewController new];
//    }
//
//    BCNavigationController *navigationController = [[BCNavigationController alloc] initWithRootViewController:self.contactsViewController title:BC_STRING_CONTACTS];
//
////    self.topViewControllerDelegate = navigationController;
//    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//
//    [self.tabControllerManager.tabViewController presentViewController:navigationController animated:YES completion:nil];
//}
//
//- (void)showAccountsAndAddresses
//{
//    if (!_accountsAndAddressesNavigationController) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME_ACCOUNTS_AND_ADDRESSES bundle:nil];
//        self.accountsAndAddressesNavigationController = [storyboard instantiateViewControllerWithIdentifier:NAVIGATION_CONTROLLER_NAME_ACCOUNTS_AND_ADDRESSES];
//    }
//
////    self.topViewControllerDelegate = self.accountsAndAddressesNavigationController;
//    self.accountsAndAddressesNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//
//    [self.tabControllerManager.tabViewController presentViewController:self.accountsAndAddressesNavigationController animated:YES completion:^{
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_HIDE_TRANSFER_ALL_FUNDS_ALERT] &&
//            self.accountsAndAddressesNavigationController.viewControllers.count == 1 &&
//            [WalletManager.sharedInstance.wallet didUpgradeToHd] &&
//            [WalletManager.sharedInstance.wallet getTotalBalanceForSpendableActiveLegacyAddresses] >= [WalletManager.sharedInstance.wallet dust] &&
//            self.accountsAndAddressesNavigationController.assetSelectorView.selectedAsset == AssetTypeBitcoin) {
//            [self.accountsAndAddressesNavigationController alertUserToTransferAllFunds:NO];
//        }
//    }];
//}

- (void)showSettings
{
    [self showSettings:nil];
}

- (void)showSettings:(void (^)())completionBlock
{
//    if (!_settingsNavigationController) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME_SETTINGS bundle: nil];
//        self.settingsNavigationController = [storyboard instantiateViewControllerWithIdentifier:NAVIGATION_CONTROLLER_NAME_SETTINGS];
//    }

//    self.topViewControllerDelegate = self.settingsNavigationController;
//    [self.settingsNavigationController showSettings];
//
//    self.settingsNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self.tabControllerManager.tabViewController presentViewController:self.settingsNavigationController animated:YES completion:completionBlock];
//
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//- (void)showSupport
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:BC_STRING_OPEN_ARGUMENT, URL_SUPPORT] message:BC_STRING_LEAVE_APP preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_SUPPORT]];
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
//    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//}

- (void)showTransactions
{
    [self.tabControllerManager showTransactionsAnimated:YES];
}

- (void)showSendCoins
{
    [self.tabControllerManager showSendCoinsAnimated:YES];
}

//- (void)showDebugMenu:(int)presenter
//{
//    DebugTableViewController *debugViewController = [[DebugTableViewController alloc] init];
//    debugViewController.presenter = presenter;
//
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:debugViewController];
//
//    [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
//}

- (void)showPinModalAsView:(BOOL)asView
{
//    BOOL walletIsNew = WalletManager.sharedInstance.wallet.isNew;
//    BOOL didAutoPair = WalletManager.sharedInstance.wallet.didPairAutomatically;
//
//    if (WalletManager.sharedInstance.didChangePassword) {
//        [self showPasswordModal];
//        return;
//    }
//
//    // Backgrounding from resetting PIN screen hides the status bar
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
//
//    // Don't show a new one if we already show it
//    if ([self.pinEntryViewController.view isDescendantOfView:[UIApplication sharedApplication].keyWindow.rootViewController.view] ||
//        (self.tabControllerManager.tabViewController.presentedViewController != nil && self.tabControllerManager.tabViewController.presentedViewController == self.pinEntryViewController && !_pinEntryViewController.isBeingDismissed)) {
//        return;
//    }
//
//    // if pin exists - verify
//    if ([BlockchainSettings sharedAppInstance].isPinSet) {
//        self.pinEntryViewController = [PEPinEntryController pinVerifyController];
//    }
//    // no pin - create
//    else {
//        self.pinEntryViewController = [PEPinEntryController pinCreateController];
//    }
//
//    self.pinEntryViewController.navigationBarHidden = YES;
//    self.pinEntryViewController.pinDelegate = self;
//
//    // asView inserts the modal's view into the rootViewController as a view - this is only used in didFinishLaunching so there is no delay when showing the PIN on start
//    if (asView) {
//        if ([_settingsNavigationController isBeingPresented]) {
//            // Immediately after enabling touch ID, backgrounding the app while the Settings scren is still being presented results in failure to add the PIN screen back. Using a delay to allow animation to complete fixes this
//            [[UIApplication sharedApplication].keyWindow.rootViewController.view performSelector:@selector(addSubview:) withObject:self.pinEntryViewController.view afterDelay:DELAY_KEYBOARD_DISMISSAL];
//            [self performSelector:@selector(showStatusBar) withObject:nil afterDelay:DELAY_KEYBOARD_DISMISSAL];
//        } else {
//            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.pinEntryViewController.view];
//        }
//    }
//    else {
//        if (walletIsNew) {
//            [self.tabControllerManager.tabViewController.presentedViewController presentViewController:self.pinEntryViewController animated:YES completion:^{
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_DID_CREATE_NEW_WALLET_TITLE message:BC_STRING_DID_CREATE_NEW_WALLET_DETAIL preferredStyle:UIAlertControllerStyleAlert];
//                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//                [self.pinEntryViewController presentViewController:alert animated:YES completion:nil];
//            }];
//        } else {
//            [self.tabControllerManager.tabViewController presentViewController:self.pinEntryViewController animated:YES completion:^{
//                if (didAutoPair) {
//                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_WALLET_PAIRED_SUCCESSFULLY_TITLE message:BC_STRING_WALLET_PAIRED_SUCCESSFULLY_DETAIL preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//                    [self.pinEntryViewController presentViewController:alert animated:YES completion:nil];
//                }
//            }];
//        }
//    }
//
//    WalletManager.sharedInstance.wallet.didPairAutomatically = NO;
//
//    [LoadingViewPresenter.sharedInstance hideBusyView];
//
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
//
//- (void)showStatusBar
//{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
//}

//- (void)toggleSideMenu
//{
//    // If the sideMenu is not shown, show it
//    if (_slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
//        [_slidingViewController anchorTopViewToRightAnimated:YES];
//    }
//    // If the sideMenu is shown, dismiss it
//    else {
//        [_slidingViewController resetTopViewAnimated:YES];
//    }
//
//    WalletManager.sharedInstance.wallet.isFetchingTransactions = NO;
//}
//
//- (void)closeSideMenu
//{
//    // If the sideMenu is shown, dismiss it
//    if (_slidingViewController.currentTopViewPosition != ECSlidingViewControllerTopViewPositionCentered) {
//        [_slidingViewController resetTopViewAnimated:YES];
//    }
//}

- (void)showSecurityReminder
{
    BlockchainSettings.sharedAppInstance.reminderModalDate = [NSDate date];

    if ([WalletManager.sharedInstance.wallet getTotalActiveBalance] > 0) {
        if (![WalletManager.sharedInstance.wallet isRecoveryPhraseVerified]) {
            [self showBackupReminder:NO];
        } else {
            [self checkIfSettingsLoadedAndShowTwoFactorReminder];
        }
    } else {
        [self checkIfSettingsLoadedAndShowTwoFactorReminder];
    }
}

- (void)checkIfSettingsLoadedAndShowTwoFactorReminder
{
    if (WalletManager.sharedInstance.wallet.hasLoadedAccountInfo) {
        if (![WalletManager.sharedInstance.wallet hasEnabledTwoStep]) {
            [self showTwoFactorReminder];
        }
    } else {
        showReminderType = ShowReminderTypeTwoFactor;
    }
}

- (void)checkIfSettingsLoadedAndShowEmailReminder
{
    if (WalletManager.sharedInstance.wallet.hasLoadedAccountInfo) {
        if (![WalletManager.sharedInstance.wallet hasVerifiedEmail]) {
            [self showEmailVerificationReminder];
        } else {
            [self showSecurityReminder];
        }
    } else {
        showReminderType = ShowReminderTypeEmail;
    }
}

- (void)showEmailVerificationReminder
{
    BlockchainSettings.sharedAppInstance.hasSeenEmailReminder = YES;

    WalletSetupViewController *setupViewController = [[WalletSetupViewController alloc] initWithSetupDelegate:self];

    BOOL shouldShowTouchID = BlockchainSettings.sharedAppInstance.shouldShowTouchIDSetup;
    setupViewController.emailOnly = !shouldShowTouchID;
    BlockchainSettings.sharedAppInstance.shouldShowTouchIDSetup = NO;
    BlockchainSettings.sharedAppInstance.didFailTouchIDSetup = NO;

    setupViewController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self.window.rootViewController presentViewController:setupViewController animated:NO completion:nil];
}

- (void)showBackupReminder:(BOOL)firstReceive
{
    ReminderType reminderType = firstReceive ? ReminderTypeBackupJustReceivedBitcoin : ReminderTypeBackupHasBitcoin;

    ReminderModalViewController *backupController = [[ReminderModalViewController alloc] initWithReminderType:reminderType];
    backupController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:backupController];
    navigationController.navigationBarHidden = YES;
    [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)showTwoFactorReminder
{
    ReminderModalViewController *twoFactorController = [[ReminderModalViewController alloc] initWithReminderType:ReminderTypeTwoFactor];
    twoFactorController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:twoFactorController];
    navigationController.navigationBarHidden = YES;
    [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)forceHDUpgradeForLegacyWallets
{
//    if (![WalletManager.sharedInstance.wallet didUpgradeToHd]) {
//        [self showHdUpgrade];
//    }
}
//
//- (void)showHdUpgrade
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME_UPGRADE bundle: nil];
//    UpgradeViewController *upgradeViewController = [storyboard instantiateViewControllerWithIdentifier:VIEW_CONTROLLER_NAME_UPGRADE];
//    upgradeViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    app.topViewControllerDelegate = upgradeViewController;
//    [self.tabControllerManager.tabViewController presentViewController:upgradeViewController animated:YES completion:nil];
//}
//
//- (void)showCreateWallet:(id)sender
//{
//    [app showModalWithContent:createWalletView closeType:ModalCloseTypeBack headerText:BC_STRING_CREATE_NEW_WALLET];
//    createWalletView.isRecoveringWallet = NO;
//}

//- (void)showPairWallet:(id)sender
//{
//    manualPairStepOneTextView.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
//    manualPairStepTwoTextView.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
//    manualPairStepThreeTextView.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
//
//    [app showModalWithContent:pairingInstructionsView closeType:ModalCloseTypeBack headerText:BC_STRING_AUTOMATIC_PAIRING];
//    scanPairingCodeButton.titleEdgeInsets = WELCOME_VIEW_BUTTON_EDGE_INSETS;
//    scanPairingCodeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    scanPairingCodeButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
//
//    manualPairButton.titleEdgeInsets = WELCOME_VIEW_BUTTON_EDGE_INSETS;
//    manualPairButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    manualPairButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
//}
//
//- (void)showRecoverWallet:(id)sender
//{
//    UIAlertController *recoveryWarningAlert = [UIAlertController alertControllerWithTitle:BC_STRING_RECOVER_FUNDS message:BC_STRING_RECOVER_FUNDS_ONLY_IF_FORGOT_CREDENTIALS preferredStyle:UIAlertControllerStyleAlert];
//    [recoveryWarningAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [app showModalWithContent:createWalletView closeType:ModalCloseTypeBack headerText:BC_STRING_RECOVER_FUNDS];
//        createWalletView.isRecoveringWallet = YES;
//    }]];
//    [recoveryWarningAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
//    [self.window.rootViewController presentViewController:recoveryWarningAlert animated:YES completion:nil];
//}
//
- (IBAction)manualPairClicked:(id)sender
{
//    [self showModalWithContent:manualPairView closeType:ModalCloseTypeBack headerText:BC_STRING_MANUAL_PAIRING];
//    WalletManager.sharedInstance.wallet.twoFactorInput = nil;
//    [manualPairView clearPasswordTextField];
}
//
//- (void)showNewWalletSetup
//{
//    WalletSetupViewController *setupViewController = [[WalletSetupViewController alloc] initWithSetupDelegate:self];
//    [self.tabControllerManager.tabViewController presentViewController:setupViewController animated:NO completion:^{
//        [app showPinModalAsView:NO];
//    }];
//}
//
#pragma mark - Actions

//- (IBAction)accountsAndAddressesClicked:(id)sender
//{
//    if (!self.tabControllerManager.tabViewController.presentedViewController) {
//        [app showAccountsAndAddresses];
//    }
//}

//- (IBAction)contactsClicked:(id)sender
//{
//    if (!self.tabControllerManager.tabViewController.presentedViewController) {
//        [app showContacts];
//    }
//}

//- (IBAction)accountSettingsClicked:(id)sender
//{
//    if (!self.tabControllerManager.tabViewController.presentedViewController) {
//        [self showSettings];
//    }
//}

//- (IBAction)backupFundsClicked:(id)sender
//{
//    if (!self.tabControllerManager.tabViewController.presentedViewController) {
//        [self showBackup];
//    }
//}
//
//- (IBAction)supportClicked:(id)sender
//{
//    if (!self.tabControllerManager.tabViewController.presentedViewController) {
//        [self showSupport];
//    }
//}

- (void)validatePINOptionally
{
    PEPinEntryController *pinVerifyPINOptionalController = [PEPinEntryController pinVerifyControllerClosable];
    pinVerifyPINOptionalController.pinDelegate = self;
    pinVerifyPINOptionalController.navigationBarHidden = YES;

    PEViewController *peViewController = (PEViewController *)[[pinVerifyPINOptionalController viewControllers] objectAtIndex:0];
    peViewController.cancelButton.hidden = NO;
    [peViewController.cancelButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];

    self.pinEntryViewController = pinVerifyPINOptionalController;

    peViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self.tabControllerManager.tabViewController dismissViewControllerAnimated:YES completion:nil];

    if (WalletManager.sharedInstance.wallet.isSyncing) {
        [LoadingViewPresenter.sharedInstance showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];
    }

    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.pinEntryViewController.view];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)changePIN
{
    PEPinEntryController *pinChangeController = [PEPinEntryController pinChangeController];
    pinChangeController.pinDelegate = self;
    pinChangeController.navigationBarHidden = YES;

    PEViewController *peViewController = (PEViewController *)[[pinChangeController viewControllers] objectAtIndex:0];
    peViewController.cancelButton.hidden = NO;
    [peViewController.cancelButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];

    self.pinEntryViewController = pinChangeController;

    peViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.tabControllerManager.tabViewController dismissViewControllerAnimated:YES completion:nil];

    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.pinEntryViewController.view];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
//
//- (void)clearPin
//{
//    App *settings = [BlockchainSettings sharedAppInstance];
//    settings.encryptedPinPassword = nil;
//    settings.pinKey = nil;
//    settings.passwordPartHash = nil;
//
//    self.lastEnteredPIN = 0000;
//}
//
//- (void)closePINModal:(BOOL)animated
//{
//    // There are two different ways the pinModal is displayed: as a subview of tabViewController (on start) and as a viewController. This checks which one it is and dismisses accordingly
//    if ([self.pinEntryViewController.view isDescendantOfView:[UIApplication sharedApplication].keyWindow.rootViewController.view]) {
//
//        [self.pinEntryViewController.view removeFromSuperview];
//
//    } else {
//        if (WalletManager.sharedInstance.wallet.isNew) {
//            [self.tabControllerManager.tabViewController.presentedViewController dismissViewControllerAnimated:animated completion:nil];
//        } else {
//            [self.tabControllerManager.tabViewController dismissViewControllerAnimated:animated completion:nil];
//        }
//    }
//
//    self.pinEntryViewController = nil;
//
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//}

//- (IBAction)logoutClicked:(id)sender
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_LOGOUT message:BC_STRING_REALLY_LOGOUT preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self clearPin];
//        [self.tabControllerManager clearSendToAddressAndAmountFields];
//        [self logout];
//        [[AppCoordinator sharedInstance] closeSideMenu];
//        [self showPasswordModal];
//    }]];
//
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
//
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//}

//- (void)logoutAndShowPasswordModal
//{
//    [self clearPin];
//    [self.tabControllerManager clearSendToAddressAndAmountFields];
//    [AuthenticationCoordinator.sharedInstance logout];
//    [[AppCoordinator sharedInstance] closeSideMenu];
//    [self showPasswordModal];
//}

- (IBAction)forgotPasswordClicked:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:BC_STRING_OPEN_ARGUMENT, URL_SUPPORT] message:BC_STRING_LEAVE_APP preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_SUPPORT_FORGOT_PASSWORD]];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)forgetWalletClicked:(id)sender
{
    UIAlertController *forgetWalletAlert = [UIAlertController alertControllerWithTitle:BC_STRING_WARNING message:BC_STRING_FORGET_WALLET_DETAILS preferredStyle:UIAlertControllerStyleAlert];
    [forgetWalletAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [forgetWalletAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_FORGET_WALLET style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DLog(@"forgetting wallet");
        [app closeModalWithTransition:kCATransitionFade];
        [WalletManager.sharedInstance forgetWallet];
        [self showWelcomeScreen];
    }]];

    if ([mainPasswordTextField isFirstResponder]) {
        [mainPasswordTextField resignFirstResponder];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:forgetWalletAlert animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:forgetWalletAlert animated:YES completion:nil];
    }
}

//- (IBAction)mainPasswordClicked:(id)sender
//{
//    [self showBusyViewWithLoadingText:BC_STRING_LOADING_DOWNLOADING_WALLET];
//    [mainPasswordTextField resignFirstResponder];
//    [self performSelector:@selector(loginMainPassword) withObject:nil afterDelay:DELAY_KEYBOARD_DISMISSAL];
//}

//- (void)presentViewControllerAnimated:(UIViewController *)viewController
//{
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
//}

//- (IBAction)webLoginClicked:(id)sender
//{
//    WebLoginViewController *webLoginViewController = [[WebLoginViewController alloc] init];
//    BCNavigationController *navigationController = [[BCNavigationController alloc] initWithRootViewController:webLoginViewController title:BC_STRING_LOG_IN_TO_WEB_WALLET];
//    [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
//}


- (void)setupTransferAllFunds
{
    self.transferAllFundsModalController = nil;
//    app.topViewControllerDelegate = nil;

    [self.tabControllerManager setupTransferAllFunds];
}

//- (void)loginMainPassword
//{
//    NSString *password = [mainPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//    if (password.length == 0) {
//        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_NO_PASSWORD_ENTERED title:BC_STRING_ERROR handler: nil];
//        [LoadingViewPresenter.sharedInstance hideBusyView];
//        return;
//    }
//
//    if (!Reachability.hasInternetConnection) {
//        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
//        [LoadingViewPresenter.sharedInstance hideBusyView];
//        return;
//    }
//
//    NSString *guid = [KeychainItemWrapper guid];
//    NSString *sharedKey = [KeychainItemWrapper sharedKey];
//
//    if (guid && sharedKey && password) {
//        [WalletManager.sharedInstance.wallet loadWalletWithGuid:guid sharedKey:sharedKey password:password];
//
//        WalletManager.sharedInstance.wallet.delegate = self;
//    } else {
//
//        if (!guid) {
//            DLog(@"failed to retrieve GUID from Keychain");
//        }
//
//        if (!sharedKey) {
//            DLog(@"failed to retrieve sharedKey from Keychain");
//        }
//
//        if (guid && !sharedKey) {
//            DLog(@"!!! Failed to retrieve sharedKey from Keychain but was able to retreive GUID ???");
//        }
//
//        [self failedToObtainValuesFromKeychain];
//
//        [LoadingViewPresenter.sharedInstance hideBusyView];
//    }
//
//    mainPasswordTextField.text = nil;
//}

- (NSString *)checkForTouchIDAvailablility
{
    LAContext *context = [[LAContext alloc] init];

    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        return nil;
    } else {
        if (error.code == LAErrorTouchIDNotAvailable) {
            return BC_STRING_TOUCH_ID_ERROR_NOT_AVAILABLE;
        } else if (error.code == LAErrorTouchIDNotEnrolled) {
            return BC_STRING_TOUCH_ID_ERROR_MUST_ENABLE;
        } else if (error.code == LAErrorTouchIDLockout) {
            return BC_STRING_TOUCH_ID_ERROR_LOCKED;
        }

        return BC_STRING_TOUCH_ID_ERROR_NOT_AVAILABLE;
        DLog(@"%@", [NSString stringWithFormat:BC_STRING_TOUCH_ID_ERROR_UNKNOWN_ARGUMENT, (long)error.code]);
    }
}

- (void)disabledTouchID
{
    [KeychainItemWrapper removePinFromKeychain];
}

- (void)verifyTwoFactorSMS
{
    [manualPairView verifyTwoFactorSMS];
}
//
//- (void)verifyTwoFactorGoogle
//{
//    [manualPairView verifyTwoFactorGoogle];
//}
//
//- (void)verifyTwoFactorYubiKey
//{
//    [manualPairView verifyTwoFactorYubiKey];
//}

-(void)rateApp {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[APP_STORE_LINK_PREFIX stringByAppendingString:APP_STORE_ID]]];
}

- (void)paymentReceived:(uint64_t)amount showBackupReminder:(BOOL)showBackupReminder
{
    if (self.tabControllerManager.tabViewController.selectedIndex == TAB_RECEIVE && ![self.tabControllerManager isSending]) {
        [self.tabControllerManager paymentReceived:amount showBackupReminder:showBackupReminder];
    } else {
        if (showBackupReminder) {
            [self showBackupReminder:YES];
        }
    }
}

- (void)paymentReceivedOnPINScreen:(NSString *)amount assetType:(AssetType)assetType
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_PAYMENT_RECEIVED message:amount preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        [self.pinEntryViewController paymentReceived:assetType];
    });
}

- (void)receivedTransactionMessage
{
    [self playBeepSound];

    [self.tabControllerManager receivedTransactionMessage];
}

//- (void)authorizationRequired
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_MANUAL_PAIRING_AUTHORIZATION_REQUIRED_TITLE message:BC_STRING_MANUAL_PAIRING_AUTHORIZATION_REQUIRED_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OPEN_MAIL_APP style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [UIApplication.sharedApplication openMailApplication];
//    }]];
//    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//}

//- (void)checkForUnusedAddress:(NSString *)address success:(void (^)(NSString *, BOOL))successBlock error:(void (^)())errorBlock assetType:(AssetType)assetType
//{
//    NSString *URLString;
//
//    if (assetType == AssetTypeBitcoin) {
//        URLString = [[[BlockchainAPI sharedInstance] walletUrl] stringByAppendingString:[NSString stringWithFormat:ADDRESS_URL_SUFFIX_HASH_ARGUMENT_ADDRESS_ARGUMENT, address]];
//    } else if (assetType == AssetTypeBitcoinCash) {
//        NSString *addressToCheck = [app.wallet fromBitcoinCash:address];
//        URLString = [[[BlockchainAPI sharedInstance] apiUrl] stringByAppendingString:[NSString stringWithFormat:ADDRESS_URL_SUFFIX_BCH_ADDRESS_ARGUMENT, addressToCheck]];
//    } else {
//        DLog(@"checking for unused address: unsupported asset type!");
//    }
//
//    NSURL *URL = [NSURL URLWithString:URLString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    NSURL *url = [NSURL URLWithString:[[BlockchainAPI sharedInstance] walletUrl]];
//    // session.sessionDescription = url.host;
//    NSURLSessionDataTask *task = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                DLog(@"Error checking for receive address %@: %@", address, error);
//                if (errorBlock) errorBlock();
//            });
//            return;
//        }
//
//        NSDictionary *addressInfo = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingAllowFragments error: &error];
//        NSArray *transactions = addressInfo[@"txs"];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            BOOL isUnused = transactions.count == 0;
//            return successBlock(address, isUnused);
//        });
//
//    }];
//
//    [task resume];
//}

//- (void)openMail
//{
//    NSURL *mailURL = [NSURL URLWithString:PREFIX_MAIL_URI];
//    if ([[UIApplication sharedApplication] canOpenURL:mailURL]) {
//        [[UIApplication sharedApplication] openURL:mailURL];
//    } else {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:[NSString stringWithFormat:BC_STRING_CANNOT_OPEN_MAIL_APP_URL_ARGUMENT, PREFIX_MAIL_URI] preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
//
//        if (self.tabControllerManager.tabViewController.presentedViewController) {
//            [self.tabControllerManager.tabViewController.presentedViewController presentViewController:alert animated:YES completion:nil];
//        } else {
//            [self.tabControllerManager.tabViewController presentViewController:alert animated:YES completion:nil];
//        }
//    }
//}
//
//- (void)showBackup
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME_BACKUP bundle: nil];
//    BackupViewController *backupController = [storyboard instantiateViewControllerWithIdentifier:NAVIGATION_CONTROLLER_NAME_BACKUP];
//
//    backupController.wallet = WalletManager.sharedInstance.wallet;
//    backupController.app = app;
//
//    backupController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self.tabControllerManager.tabViewController presentViewController:backupController animated:YES completion:nil];
//}

- (void)showTwoStep
{
    void (^showBackupBlock)() = ^() {
        [self.settingsNavigationController showTwoStep];
    };

    [self showSettings:showBackupBlock];
}

//- (void)checkIfPaymentRequestFulfilled:(Transaction *)transaction
//{
//    if (self.pendingPaymentRequestTransaction) {
//
//        uint64_t transactionAmount = llabs(transaction.amount) - llabs(transaction.fee);
//        BOOL amountsMatch = self.pendingPaymentRequestTransaction.intendedAmount == transactionAmount;
//        BOOL destinationAddressesMatch = NO;
//
//        for (NSDictionary *destination in transaction.to) {
//            if ([[destination objectForKey:DICTIONARY_KEY_ADDRESS] isEqualToString:self.pendingPaymentRequestTransaction.address]) {
//                destinationAddressesMatch = YES;
//                break;
//            }
//        }
//
//        if (amountsMatch && destinationAddressesMatch) {
//            [WalletManager.sharedInstance.wallet sendPaymentRequestResponse:self.pendingPaymentRequestTransaction.contactIdentifier transactionHash:transaction.myHash transactionIdentifier:self.pendingPaymentRequestTransaction.identifier];
//        } else {
//            if (!amountsMatch) {
//                DLog(@"Error: pending amount %lld does not match transaction amount %lld", self.pendingPaymentRequestTransaction.intendedAmount, transactionAmount);
//            }
//            if (!destinationAddressesMatch) {
//                DLog(@"Error: pending address %@ does not match any transaction addresses %@", self.pendingPaymentRequestTransaction.address, transaction.to);
//            }
//        }
//        self.pendingPaymentRequestTransaction = nil;
//    }
//}

- (void)setupSendToAddress:(NSString *)address
{
    [self.tabControllerManager setupSendToAddress:address];
}

//#pragma mark - Pin Entry Delegates

//- (void)pinEntryController:(PEPinEntryController *)c shouldAcceptPin:(NSUInteger)_pin callback:(void(^)(BOOL))callback
//{
//    self.lastEnteredPIN = _pin;
//
//    // TODO does this ever happen?
//    if (!WalletManager.sharedInstance.wallet) {
//        assert(1 == 2);
//        [self askIfUserWantsToResetPIN];
//        return;
//    }
//
//    NSString * pinKey = [BlockchainSettings sharedAppInstance].pinKey;
//    NSString * pin = [NSString stringWithFormat:@"%lu", (unsigned long)_pin];
//
//    [self showVerifyingBusyViewWithTimer:30.0];
//
//    // Check if we have an internet connection
//    // This only checks if a network interface is up. All other errors (including timeouts) are handled by JavaScript callbacks in Wallet.m
//    if (!Reachability.hasInternetConnection) {
//        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
//        return;
//    }
//
    // TODO: handle touch ID
//#ifdef ENABLE_TOUCH_ID
//    if (self.pinEntryViewController.verifyOptional) {
//        [KeychainItemWrapper setPINInKeychain:pin];
//    }
//#endif
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self checkForMaintenanceWithPinKey:pinKey pin:pin];
//    });
//
//    self.pinViewControllerCallback = callback;
//}

//- (void)showPinErrorWithMessage:(NSString *)message
//{
//    DLog(@"Pin error: %@", message);
//
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        // Reset the pin entry field
//        [LoadingViewPresenter.sharedInstance hideBusyView];
//        [self.pinEntryViewController reset];
//    }]];
//
//    UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;
//    [topViewController presentViewController:alert animated:YES completion:nil];
//}
//
//- (void)askIfUserWantsToResetPIN
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_PIN_VALIDATION_ERROR message:BC_STRING_PIN_VALIDATION_ERROR_DETAIL preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_ENTER_PASSWORD style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [AuthenticationCoordinator.shared closePinEntryViewWithAnimated:YES];
//        [self showPasswordModal];
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:RETRY_VALIDATION style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self pinEntryController:self.pinEntryViewController shouldAcceptPin:self.lastEnteredPIN callback:self.pinViewControllerCallback];
//    }]];
//
//    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//}
//
//- (void)didFailGetPinTimeout
//{
//    [self showPinErrorWithMessage:BC_STRING_TIMED_OUT];
//}
//
//- (void)didFailGetPinNoResponse
//{
//    [self showPinErrorWithMessage:BC_STRING_INCORRECT_PIN_RETRY];
//}
//
//- (void)didFailGetPinInvalidResponse
//{
//    [self showPinErrorWithMessage:BC_STRING_INVALID_RESPONSE];
//}
//
//- (void)didGetPinResponse:(NSDictionary*)dictionary
//{
//    [LoadingViewPresenter.sharedInstance hideBusyView];
//
//    NSNumber * code = [dictionary objectForKey:DICTIONARY_KEY_CODE]; //This is a status code from the server
//    NSString * error = [dictionary objectForKey:DICTIONARY_KEY_ERROR]; //This is an error string from the server or nil
//    NSString * success = [dictionary objectForKey:DICTIONARY_KEY_SUCCESS]; //The PIN decryption value from the server
//    NSString * encryptedPINPassword = [BlockchainSettings sharedAppInstance].encryptedPinPassword;
//
//    BOOL pinSuccess = FALSE;
//
//    // Incorrect pin
//    if (code == nil) {
//        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:LocalizationConstantsObjcBridge.incorrectPin title:BC_STRING_ERROR handler: nil];
//    }
//    // Pin retry limit exceeded
//    else if ([code intValue] == PIN_API_STATUS_CODE_DELETED) {
//
//        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PIN_VALIDATION_CANNOT_BE_COMPLETED title:BC_STRING_ERROR handler: nil];
//
//        [self clearPin];
//
//        [self logout];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showPasswordModal];
//            [AuthenticationCoordinator.shared closePinEntryViewWithAnimated:YES];
//        });
//
//    }
//    // Incorrect pin
//    else if ([code integerValue] == PIN_API_STATUS_PIN_INCORRECT) {
//
//        if (error == nil) {
//            error = @"PIN Code Incorrect. Unknown Error Message.";
//        }
//
//        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR handler: nil];
//    }
//    // Pin was accepted
//    else if ([code intValue] == PIN_API_STATUS_OK) {
//
//#ifdef ENABLE_TOUCH_ID
//        if (self.pinEntryViewController.verifyOptional) {
//            BlockchainSettings.sharedAppInstance.touchIDEnabled = YES;
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            [AuthenticationCoordinator.shared closePinEntryViewWithAnimated:YES];
//            [self showSettings];
//            return;
//        }
//#endif
//        // This is for change PIN - verify the password first, then show the enter screens
//        if (self.pinEntryViewController.verifyOnly == NO) {
//            if (self.pinViewControllerCallback) {
//                self.pinViewControllerCallback(YES);
//                self.pinViewControllerCallback = nil;
//            }
//
//            return;
//        }
//
//        // Initial PIN setup ?
//        if ([success length] == 0) {
//            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PIN_RESPONSE_OBJECT_SUCCESS_LENGTH_0 title:BC_STRING_ERROR handler: nil];
//            [self askIfUserWantsToResetPIN];
//            return;
//        }
//
//        NSString *decrypted = [WalletManager.sharedInstance.wallet decrypt:encryptedPINPassword password:success pbkdf2_iterations:PIN_PBKDF2_ITERATIONS];
//
//        if ([decrypted length] == 0) {
//            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_DECRYPTED_PIN_PASSWORD_LENGTH_0 title:BC_STRING_ERROR handler: nil];
//            [self askIfUserWantsToResetPIN];
//            return;
//        }
//
//        NSString *guid = [KeychainItemWrapper guid];
//        NSString *sharedKey = [KeychainItemWrapper sharedKey];
//
//        if (guid && sharedKey) {
//            [WalletManager.sharedInstance.wallet loadWalletWithGuid:guid sharedKey:sharedKey password:decrypted];
//        } else {
//
//            if (!guid) {
//                DLog(@"failed to retrieve GUID from Keychain");
//            }
//
//            if (!sharedKey) {
//                DLog(@"failed to retrieve sharedKey from Keychain");
//            }
//
//            if (guid && !sharedKey) {
//                DLog(@"!!! Failed to retrieve sharedKey from Keychain but was able to retreive GUID ???");
//            }
//
//            [AlertViewPresenter.sharedInstance showKeychainReadError];
//        }
//
//        [AuthenticationCoordinator.shared closePinEntryViewWithAnimated:YES];
//
//        pinSuccess = TRUE;
//
//    }
//    // Unknown error
//    else {
//        [self askIfUserWantsToResetPIN];
//    }
//
//    if (self.pinViewControllerCallback) {
//        self.pinViewControllerCallback(pinSuccess);
//        self.pinViewControllerCallback = nil;
//    }
//
//#ifdef ENABLE_TOUCH_ID
//    if (!pinSuccess && self.pinEntryViewController.verifyOptional) {
//        [KeychainItemWrapper removePinFromKeychain];
//    }
//#endif
//}
//
//- (void)didFailPutPin:(NSString*)value
//{
//    [LoadingViewPresenter.sharedInstance hideBusyView];
//
//    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:value title:BC_STRING_ERROR handler: nil];
//
//    [self reopenChangePIN];
//}

//- (void)reopenChangePIN
//{
//    [AuthenticationCoordinator.shared closePinEntryModalWithAnimated:NO];
//
//    // Show the pin modal to enter a pin again
//    self.pinEntryViewController = [PEPinEntryController pinCreateController];
//    self.pinEntryViewController.navigationBarHidden = YES;
//    self.pinEntryViewController.pinDelegate = self;
//
//    if ([BlockchainSettings sharedAppInstance].isPinSet) {
//        self.pinEntryViewController.inSettings = YES;
//    }
//
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.pinEntryViewController.view];
//}
//
//- (void)didPutPinSuccess:(NSDictionary*)dictionary
//{
//    [LoadingViewPresenter.sharedInstance hideBusyView];
//
//    if (!WalletManager.sharedInstance.wallet.password) {
//        [self didFailPutPin:BC_STRING_CANNOT_SAVE_PIN_CODE_WHILE];
//        return;
//    }
//
//    NSNumber * code = [dictionary objectForKey:DICTIONARY_KEY_CODE]; //This is a status code from the server
//    NSString * error = [dictionary objectForKey:DICTIONARY_KEY_ERROR]; //This is an error string from the server or nil
//    NSString * key = [dictionary objectForKey:DICTIONARY_KEY_KEY]; //This is our pin code lookup key
//    NSString * value = [dictionary objectForKey:DICTIONARY_KEY_VALUE]; //This is our encryption string
//
//    if (error != nil) {
//        [self didFailPutPin:error];
//    } else if (code == nil || [code intValue] != PIN_API_STATUS_OK) {
//        [self didFailPutPin:[NSString stringWithFormat:BC_STRING_INVALID_STATUS_CODE_RETURNED, code]];
//    } else if ([key length] == 0 || [value length] == 0) {
//        [self didFailPutPin:BC_STRING_PIN_RESPONSE_OBJECT_KEY_OR_VALUE_LENGTH_0];
//    } else {
//
//        BOOL inSettings = self.pinEntryViewController.inSettings;
//
//        if (inSettings) {
//            [self showSettings];
//        }
//        //Encrypt the wallet password with the random value
//        NSString * encrypted = [WalletManager.sharedInstance.wallet encrypt:WalletManager.sharedInstance.wallet.password password:value pbkdf2_iterations:PIN_PBKDF2_ITERATIONS];
//
//        //Store the encrypted result and discard the value
//        value = nil;
//
//        if (!encrypted) {
//            [self didFailPutPin:BC_STRING_PIN_ENCRYPTED_STRING_IS_NIL];
//            return;
//        }
//
//        App *appSettings = [BlockchainSettings sharedAppInstance];
//        appSettings.encryptedPinPassword = encrypted;
//        appSettings.pinKey = key;
//        appSettings.passwordPartHash = [[WalletManager.sharedInstance.wallet.password SHA256] substringToIndex:MIN([WalletManager.sharedInstance.wallet.password length], 5)];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        // Update your info to new pin code
//        [AuthenticationCoordinator.shared closePinEntryViewWithAnimated:YES];
//
//        if ([WalletManager.sharedInstance.wallet isInitialized] && !inSettings) [self showMobileNotice];
//
//        if (!WalletManager.sharedInstance.wallet.didUpgradeToHd) {
//            [self forceHDUpgradeForLegacyWallets];
//        }
//    }
//
//    WalletManager.sharedInstance.wallet.isNew = NO;
//}

//- (void)pinEntryController:(PEPinEntryController *)c willChangeToNewPin:(NSUInteger)_pin
//{
//    if (_pin == self.lastEnteredPIN && self.lastEnteredPIN != 0000) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:BC_STRING_NEW_PIN_MUST_BE_DIFFERENT preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [self reopenChangePIN];
//        }]];
//        [c presentViewController:alert animated:YES completion:nil];
//    } else if (_pin == PIN_COMMON_CODE_1 ||
//               _pin == PIN_COMMON_CODE_2 ||
//               _pin == PIN_COMMON_CODE_3 ||
//               _pin == PIN_COMMON_CODE_4 ||
//               _pin == PIN_COMMON_CODE_5) {
//
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_WARNING_TITLE message:BC_STRING_PIN_COMMON_CODE_WARNING_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:nil]];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_TRY_AGAIN style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [self reopenChangePIN];
//        }]];
//        [c presentViewController:alert animated:YES completion:nil];
//    } else if (_pin == PIN_INVALID_CODE) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:BC_STRING_PLEASE_CHOOSE_ANOTHER_PIN preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [self reopenChangePIN];
//        }]];
//        [c presentViewController:alert animated:YES completion:nil];
//    }
//}

//- (void)pinEntryController:(PEPinEntryController *)c changedPin:(NSUInteger)_pin
//{
//    self.lastEnteredPIN = _pin;
//
//    if (![WalletManager.sharedInstance.wallet isInitialized] || !WalletManager.sharedInstance.wallet.password) {
//        [self didFailPutPin:BC_STRING_CANNOT_SAVE_PIN_CODE_WHILE];
//        return;
//    }
//
//    NSString * pin = [NSString stringWithFormat:@"%lu", (unsigned long)_pin];
//
//    [self showBusyViewWithLoadingText:BC_STRING_LOADING_VERIFYING];
//
//    [self savePIN:pin];
//}

- (void)savePIN:(NSString*)pin {
//    uint8_t data[32];
//    int err = 0;
//
//    //32 Random bytes for key
//    err = SecRandomCopyBytes(kSecRandomDefault, 32, data);
//    if(err != noErr)
//    @throw [NSException exceptionWithName:@"..." reason:@"..." userInfo:nil];
//
//    NSString * key = [[[NSData alloc] initWithBytes:data length:32] hexadecimalString];
//
//    //32 random bytes for value
//    err = SecRandomCopyBytes(kSecRandomDefault, 32, data);
//    if(err != noErr)
//    @throw [NSException exceptionWithName:@"..." reason:@"..." userInfo:nil];
//
//    NSString * value = [[[NSData alloc] initWithBytes:data length:32] hexadecimalString];
//
//    [WalletManager.sharedInstance.wallet pinServerPutKeyOnPinServerServer:key value:value pin:pin];
//
//#ifdef ENABLE_TOUCH_ID
//    if (BlockchainSettings.sharedAppInstance.touchIDEnabled) {
//        [KeychainItemWrapper setPINInKeychain:pin];
//    }
//#endif
}

//- (void)pinEntryControllerDidCancel:(PEPinEntryController *)c
//{
//    DLog(@"Pin change cancelled!");
//    [self closePINModal:YES];
//}
//
//- (void)failedToObtainValuesFromKeychain
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_FAILED_TO_LOAD_WALLET_TITLE message:BC_STRING_ERROR_LOADING_WALLET_IDENTIFIER_FROM_KEYCHAIN preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CLOSE_APP style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        // Close App
//        UIApplication *app = [UIApplication sharedApplication];
//        [app performSelector:@selector(suspend)];
//    }]];
//
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//}

#pragma mark - Setup Delegate

//- (CGRect)getFrame
//{
//    return self.window.frame;
//}

- (BOOL)enableTouchIDClicked
{
    NSString *errorString = [app checkForTouchIDAvailablility];
    if (!errorString) {
        BlockchainSettings.sharedAppInstance.touchIDEnabled = YES;
        NSString * pin = [NSString stringWithFormat:@"%lu", (unsigned long)self.lastEnteredPIN];
        [KeychainItemWrapper setPINInKeychain:pin];
        return YES;
    } else {
        UIAlertController *alertTouchIDError = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:errorString preferredStyle:UIAlertControllerStyleAlert];
        [alertTouchIDError addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
        [self.tabControllerManager.tabViewController.presentedViewController presentViewController:alertTouchIDError animated:YES completion:nil];

        BlockchainSettings.sharedAppInstance.didFailTouchIDSetup = YES;

        return NO;
    }
}

//- (void)openMailClicked
//{
//    [self openMail];
//}

//- (NSString *)getEmail
//{
//    return [WalletManager.sharedInstance.wallet getEmail];
//}

#pragma mark - State Checks

//- (void)checkForNewInstall
//{
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_FIRST_RUN]) {
//
//        if ([KeychainItemWrapper guid] && [KeychainItemWrapper sharedKey] && ![BlockchainSettings sharedAppInstance].isPinSet) {
//            [self alertUserAskingToUseOldKeychain];
//        }
//
//        [[NSUserDefaults standardUserDefaults] setBool:true forKey:USER_DEFAULTS_KEY_FIRST_RUN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_HAS_SEEN_UPGRADE_TO_HD_SCREEN]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_HAS_SEEN_UPGRADE_TO_HD_SCREEN];
//    }
//}

//- (void)alertUserAskingToUseOldKeychain
//{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
//
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ASK_TO_USE_OLD_WALLET_TITLE message:BC_STRING_ASK_TO_USE_OLD_WALLET_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CREATE_NEW_WALLET style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [self forgetWalletClicked:nil];
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_LOGIN_EXISTING_WALLET style:UIAlertActionStyleDefault handler:nil]];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//    });
//}

//- (void)alertUserOfCompromisedSecurity
//{
//    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_UNSAFE_DEVICE_MESSAGE title:BC_STRING_UNSAFE_DEVICE_TITLE];
//}

//- (void)checkAndWarnOnJailbrokenPhones
//{
//    if ([RootService isUnsafe]) {
//        [self alertUserOfCompromisedSecurity];
//    }
//}

+ (BOOL)isUnsafe
{
#if !(TARGET_IPHONE_SIMULATOR)

    if ([[NSFileManager defaultManager] fileExistsAtPath:UNSAFE_CHECK_PATH_CYDIA]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:UNSAFE_CHECK_PATH_MOBILE_SUBSTRATE]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:UNSAFE_CHECK_PATH_BIN_BASH]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:UNSAFE_CHECK_PATH_USR_SBIN_SSHD]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:UNSAFE_CHECK_PATH_ETC_APT]){
        return YES;
    }

    NSError *error;
    NSString *stringToBeWritten = @"TEST";
    [stringToBeWritten writeToFile:UNSAFE_CHECK_PATH_WRITE_TEST atomically:YES
                          encoding:NSUTF8StringEncoding error:&error];
    if(error == nil){
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:UNSAFE_CHECK_PATH_WRITE_TEST error:nil];
    }

    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UNSAFE_CHECK_CYDIA_URL]]){
        return YES;
    }
#endif

    return NO;
}

//- (BOOL)checkInternetConnection
//{
//    Reachability *reachability = [Reachability reachabilityForInternetConnection];
//    if ([reachability currentReachabilityStatus] == NotReachable) {
//        DLog(@"No Internet connection");
//        [self showPinErrorWithMessage:BC_STRING_NO_INTERNET_CONNECTION];
//        return NO;
//    }
//    return YES;
//}

- (AVCaptureDeviceInput *)getCaptureDeviceInput:(UIViewController *)viewController
{
    NSError *error;

    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        // This should never happen - all devices we support (iOS 7+) have cameras
        DLog(@"QR code scanner problem: %@", [error localizedDescription]);

        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] ==  AVAuthorizationStatusAuthorized) {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[error localizedDescription] title:BC_STRING_ERROR handler: nil];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ENABLE_CAMERA_PERMISSIONS_ALERT_TITLE message:BC_STRING_ENABLE_CAMERA_PERMISSIONS_ALERT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_GO_TO_SETTINGS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:settingsURL];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];

            if (viewController) {
                [viewController presentViewController:alert animated:YES completion:nil];
            } else {
                [UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    return input;
}

//#pragma mark - Certificate Pinner Delegate
//
//- (void)failedToValidateCertificate:(NSString *)hostName
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_FAILED_VALIDATION_CERTIFICATE_TITLE message:[NSString stringWithFormat:@"%@\n\n%@\n\n%@", hostName, BC_STRING_FAILED_VALIDATION_CERTIFICATE_MESSAGE, [NSString stringWithFormat:BC_STRING_FAILED_VALIDATION_CERTIFICATE_MESSAGE_CONTACT_SUPPORT_ARGUMENT, URL_SUPPORT]] preferredStyle:UIAlertControllerStyleAlert];
//    alert.view.tag = TAG_CERTIFICATE_VALIDATION_FAILURE_ALERT;
//    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        // Close App
//        UIApplication *app = [UIApplication sharedApplication];
//        [app performSelector:@selector(suspend)];
//    }]];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.window.rootViewController.presentedViewController) {
//            if (self.window.rootViewController.presentedViewController.view.tag != TAG_CERTIFICATE_VALIDATION_FAILURE_ALERT) {
//                [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
//                    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//                }];
//            }
//        } else {
//            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
//        }
//    });
//
//}

@end
