//
//  RootService.h
//  Blockchain
//
//  Created by Kevin Wu on 8/15/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "Wallet.h"
#import "RootService.h"
#import "MultiAddressResponse.h"
#import "TabViewController.h"
#import "PEPinEntryController.h"
#import "BCModalView.h"
#import "BCModalViewController.h"
#import "ECSlidingViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "UpgradeViewController.h"
#import "SettingsNavigationController.h"
#import <AVFoundation/AVFoundation.h>
#import "AccountsAndAddressesNavigationController.h"
#import "TransferAllFundsViewController.h"
#import "NSNumberFormatter+Currencies.h"
#import "CertificatePinner.h"
#import <UserNotifications/UserNotifications.h>
#import "ReminderModalViewController.h"
#import "WalletSetupViewController.h"
#import "TabControllerManager.h"
#import <WebKit/WebKit.h>

@protocol TopViewController;

@class TransactionsBitcoinViewController, BCFadeView, ReceiveCoinsViewController, SendBitcoinViewController, BCCreateWalletView, BCManualPairView, MultiAddressResponse, PairingCodeParser, MerchantMapViewController, BCWebViewController, BackupNavigationViewController, ContactsViewController, ContactTransaction, BuyBitcoinViewController;

@interface RootService : NSObject <UIApplicationDelegate, WalletDelegate, PEPinEntryControllerDelegate, MFMailComposeViewControllerDelegate, CertificatePinnerDelegate, UNUserNotificationCenterDelegate, ReminderModalDelegate, SetupDelegate, TabControllerDelegate> {

    Wallet *wallet;
    
    SystemSoundID alertSoundID;
    SystemSoundID beepSoundID;
    SystemSoundID dingSoundID;
    
    IBOutlet BCFadeView *busyView;
    IBOutlet UILabel *busyLabel;
    
    IBOutlet BCCreateWalletView *createWalletView;
    IBOutlet BCModalContentView *pairingInstructionsView;
    IBOutlet BCManualPairView *manualPairView;
    
    IBOutlet UIButton *scanPairingCodeButton;
    IBOutlet UIButton *manualPairButton;
    IBOutlet UITextView *manualPairStepOneTextView;
    IBOutlet UITextView *manualPairStepTwoTextView;
    IBOutlet UITextView *manualPairStepThreeTextView;
    
    BOOL validateSecondPassword;
    IBOutlet UILabel *secondPasswordDescriptionLabel;
    IBOutlet UIView *secondPasswordView;
    IBOutlet UITextField *secondPasswordTextField;
    IBOutlet UIButton *secondPasswordButton;
    
    IBOutlet UIView *mainPasswordView;
    IBOutlet UILabel *mainPasswordLabel;
    IBOutlet UIButton *mainPasswordButton;
    IBOutlet UILabel *forgetWalletLabel;
    IBOutlet UIButton *forgotPasswordButton;
    IBOutlet UITextField *mainPasswordTextField;
    IBOutlet UIButton *forgetWalletButton;
    
@public
    
    BOOL symbolLocal;
}

@property (nonatomic, weak) UIViewController <TopViewController> *topViewControllerDelegate;

@property (strong, nonatomic) IBOutlet ECSlidingViewController *slidingViewController;
@property (nonatomic) TabControllerManager *tabControllerManager;
@property (strong, nonatomic) IBOutlet MerchantMapViewController *merchantViewController;
@property (strong, nonatomic) IBOutlet BCWebViewController *bcWebViewController;
@property (strong, nonatomic) IBOutlet BackupNavigationViewController *backupNavigationViewController;
@property (strong, nonatomic) SettingsNavigationController *settingsNavigationController;
@property (strong, nonatomic) AccountsAndAddressesNavigationController *accountsAndAddressesNavigationController;
@property (strong, nonatomic) ContactsViewController *contactsViewController;

@property (strong, nonatomic) IBOutlet UILabel *mainTitleLabel;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundUpdateTask;

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) Wallet *wallet;
@property (strong, nonatomic) MultiAddressResponse *latestResponse;
@property (nonatomic, strong) NSString *loadingText;

@property (strong, nonatomic) IBOutlet BCModalView *modalView;
@property (strong, nonatomic) NSMutableArray *modalChain;

@property (strong, nonatomic) TransferAllFundsViewController *transferAllFundsModalController;

@property(nonatomic) NSString *deviceToken;
@property (nonatomic) BuyBitcoinViewController *buyBitcoinViewController;

// PIN Entry
@property (nonatomic, strong) PEPinEntryController *pinEntryViewController;
@property (nonatomic, copy) void (^pinViewControllerCallback)(BOOL);
@property (nonatomic, assign) NSUInteger lastEnteredPIN;
@property (nonatomic) NSTimer *loginTimer;

@property(nonatomic, strong) NSNumberFormatter *btcFormatter;
@property(nonatomic, strong) NSNumberFormatter *ethFormatter;
@property(nonatomic, strong) NSNumberFormatter *localCurrencyFormatter;

@property (nonatomic) BOOL changedPassword;
@property (nonatomic) BOOL isVerifyingMobileNumber;

@property (nonatomic) ContactTransaction *pendingPaymentRequestTransaction;

// Certificate Pinning
@property (nonatomic) CertificatePinner *certificatePinner;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

- (void)setAccountData:(NSString*)guid sharedKey:(NSString*)sharedKey;

- (void)playBeepSound;
- (void)playAlertSound;


- (void)showWelcome;
- (void)logout;
- (void)forgetWallet;
- (void)showPasswordModal;

- (void)toggleSideMenu;
- (void)closeSideMenu;

- (void)swipeLeft;
- (void)swipeRight;

// BC Modal
- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType headerText:(NSString *)headerText;
- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType headerText:(NSString *)headerText onDismiss:(void (^)())onDismiss onResume:(void (^)())onResume;
- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText onDismiss:(void (^)())onDismiss onResume:(void (^)())onResume;
- (void)closeModalWithTransition:(NSString *)transition;
- (void)closeAllModals;

- (NSDictionary*)parseURI:(NSString*)urlString prefix:(NSString *)urlPrefix;

// Wallet Delegate
- (void)didSetLatestBlock:(LatestBlock*)block;
- (void)walletFailedToDecrypt;

// Display a message
- (void)standardNotifyAutoDismissingController:(NSString *)message;
- (void)standardNotifyAutoDismissingController:(NSString *)message title:(NSString *)title;
- (void)standardNotify:(NSString*)message;
- (void)standardNotify:(NSString*)message title:(NSString*)title;

// Busy view with loading text
- (void)showBusyViewWithLoadingText:(NSString *)text;
- (void)updateBusyViewLoadingText:(NSString *)text;
- (void)hideBusyView;

// Request Second Password From User
- (void)getSecondPassword:(void (^)(NSString *))success error:(void (^)(NSString *))error helperText:(NSString *)helperText;
- (void)getPrivateKeyPassword:(void (^)(NSString *))success error:(void (^)(NSString *))error;

- (void)reload;
- (void)reloadAfterMultiAddressResponse;
- (void)toggleSymbol;

- (void)logoutAndShowPasswordModal;

- (NSInteger)filterIndex;
- (void)filterTransactionsByAccount:(int)accountIndex;
- (void)filterTransactionsByImportedAddresses;
- (void)removeTransactionsFilter;

- (void)initializeWebview;

- (void)pushWebViewController:(NSString*)url title:(NSString *)title;

- (void)showSendCoins;
- (void)showAccountsAndAddresses;
- (void)showDebugMenu:(int)presenter;
- (void)showHdUpgrade;
- (void)showBackupReminder:(BOOL)firstReceive;

- (IBAction)webLoginClicked:(id)sender;
- (IBAction)merchantClicked:(UIButton *)sender;
- (IBAction)forgetWalletClicked:(id)sender;
- (IBAction)scanAccountQRCodeclicked:(id)sender;
- (IBAction)secondPasswordClicked:(id)sender;
- (IBAction)mainPasswordClicked:(id)sender;
- (IBAction)manualPairClicked:(id)sender;

- (IBAction)accountsAndAddressesClicked:(id)sender;
- (IBAction)contactsClicked:(id)sender;
- (IBAction)accountSettingsClicked:(id)sender;
- (IBAction)backupFundsClicked:(id)sender;
- (IBAction)supportClicked:(id)sender;
- (IBAction)logoutClicked:(id)sender;
- (IBAction)buyBitcoinClicked:(id)sender;
- (IBAction)exchangeClicked:(id)sender;

- (void)setupTransferAllFunds;
- (void)setupPaymentRequest:(ContactTransaction *)transaction;
- (void)setupSendToAddress:(NSString *)address;

- (void)paymentReceived:(NSDecimalNumber *)amount showBackupReminder:(BOOL)showBackupReminder;
- (void)checkIfPaymentRequestFulfilled:(Transaction *)transaction;

- (void)clearPin;
- (void)showPinModalAsView:(BOOL)asView;
- (BOOL)isPinSet;
- (void)validatePINOptionally;
- (void)changePIN;

- (BOOL)checkInternetConnection;

- (NSString *)checkForTouchIDAvailablility;
- (void)disabledTouchID;

- (AVCaptureDeviceInput *)getCaptureDeviceInput:(UIViewController *)viewController;

- (void)scanPrivateKeyForWatchOnlyAddress:(NSString *)address;
- (void)askUserToAddWatchOnlyAddress:(NSString *)address success:(void (^)(NSString *))success;

- (void)verifyTwoFactorSMS;
- (void)verifyTwoFactorGoogle;
- (void)verifyTwoFactorYubiKey;

- (void)rateApp;
- (void)authorizationRequired;

- (void)endBackgroundUpdateTask;

- (NSString *)getVersionLabelString;
- (void)checkForUnusedAddress:(NSString *)address success:(void (^)(NSString *, BOOL))successBlock error:(void (^)())errorBlock;

- (BOOL)checkIfWaitingOnEtherTransaction;

- (void)showGetAssetsAlert;
@end

extern RootService *app;
