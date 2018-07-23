//
//  SettingsTableViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 7/13/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsSelectorTableViewController.h"
#import "SettingsWebViewController.h"
#import "SettingsTwoStepViewController.h"
#import "Blockchain-Swift.h"
#import "KeychainItemWrapper+SwipeAddresses.h"
#import "BCVerifyEmailViewController.h"
#import "BCVerifyMobileNumberViewController.h"
#import "WebLoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

const int textFieldTagChangePasswordHint = 8;
const int textFieldTagVerifyMobileNumber = 7;
const int textFieldTagChangeMobileNumber = 6;

const int sectionProfile = 0;
const int profileWalletIdentifier = 0;
const int profileEmail = 1;
const int profileMobileNumber = 2;
const int profileWebLogin = 3;

const int sectionPreferences = 1;
const int preferencesEmailNotifications = 0;
const int preferencesLocalCurrency = 1;

const int sectionSecurity = 2;
const int securityTwoStep = 0;
const int securityPasswordChange = 1;
const int securityWalletRecoveryPhrase = 2;
const int PINChangePIN = 3;

const int aboutSection = 3;
const int aboutUs = 0;
const int aboutTermsOfService = 1;
const int aboutPrivacyPolicy = 2;
const int aboutCookiePolicy = 3;

@interface SettingsTableViewController () <UITextFieldDelegate, EmailDelegate, MobileNumberDelegate>

@property (nonatomic, copy) NSDictionary *availableCurrenciesDictionary;
@property (nonatomic, copy) NSDictionary *allCurrencySymbolsDictionary;

@property (nonatomic, copy) NSString *enteredEmailString;
@property (nonatomic, copy) NSString *emailString;

@property (nonatomic, copy) NSString *enteredMobileNumberString;
@property (nonatomic, copy) NSString *mobileNumberString;

@property (nonatomic) UITextField *changeFeeTextField;
@property (nonatomic) float currentFeePerKb;

@property (nonatomic) BOOL isVerifyingMobileNumber;
@property (nonatomic) BOOL isEnablingTwoStepSMS;
@property (nonatomic) BackupNavigationViewController *backupController;

@property (readonly, nonatomic) int PINBiometry;
@property (readonly, nonatomic) int PINSwipeToReceive;

@end

@implementation SettingsTableViewController

// Note: - There should not be a toggle for this setting, instead just assume the user wants to use it during pin setup.
// SeeAlso: - https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/authentication
- (int)PINBiometry
{
    //: Don't show the option to enable biometric authentication if the user is not enrolled
    if (![self biometryTypeDescription]) {
        return -1;
    }
    //: As long as the user is enrolled in biometric authentication, the row index will be 4
    return 4;
}

- (int)PINSwipeToReceive
{
    AppFeatureConfiguration *swipeToReceive = [AppFeatureConfigurator.sharedInstance configurationFor:AppFeatureSwipeToReceive];
    if (!swipeToReceive.isEnabled) {
        return -1;
    }
    //: If the user is enrolled in biometric authentication, account for the additional row
    if ([self biometryTypeDescription]) {
        return 5;
    }
    //: Otherwise it will be the forth item
    return 4;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = UIColor.lightGray;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:USER_DEFAULTS_KEY_LOADED_SETTINGS];
    [self updateEmailAndMobileStrings];
    [self reload];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_KEY_RELOAD_SETTINGS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAfterMultiAddressResponse) name:NOTIFICATION_KEY_RELOAD_SETTINGS_AFTER_MULTIADDRESS object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.isEnablingTwoStepSMS = NO;

    SettingsNavigationController *navigationController = (SettingsNavigationController *)self.navigationController;
    navigationController.headerLabel.text = BC_STRING_SETTINGS;

    BOOL loadedSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_LOADED_SETTINGS] boolValue];
    if (!loadedSettings) {
        [self reload];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)reload
{
    DLog(@"Reloading settings");

    [self.backupController reload];

    [self getAccountInfo];
    [self getAllCurrencySymbols];
}

- (void)reloadAfterMultiAddressResponse
{
    [self.backupController reload];

    [self updateAccountInfo];
    [self updateCurrencySymbols];
}

- (void)getAllCurrencySymbols
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCurrencySymbols) name:NOTIFICATION_KEY_GET_ALL_CURRENCY_SYMBOLS_SUCCESS object:nil];

    [WalletManager.sharedInstance.wallet getBtcExchangeRates];
}

- (void)didGetCurrencySymbols
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_GET_ALL_CURRENCY_SYMBOLS_SUCCESS object:nil];
    [self updateCurrencySymbols];
}

- (void)updateCurrencySymbols
{
    self.allCurrencySymbolsDictionary = WalletManager.sharedInstance.wallet.btcRates;

    [self reloadTableView];
}

- (void)getAccountInfo
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccountInfo) name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];

    [WalletManager.sharedInstance.wallet getAccountInfo];
}

- (void)didGetAccountInfo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
    [self updateAccountInfo];
}

- (void)updateAccountInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:USER_DEFAULTS_KEY_LOADED_SETTINGS];

    DLog(@"SettingsTableViewController: gotAccountInfo");

    if ([WalletManager.sharedInstance.wallet getFiatCurrencies] != nil) {
        self.availableCurrenciesDictionary = [WalletManager.sharedInstance.wallet getFiatCurrencies];
    }

    [self updateEmailAndMobileStrings];

    if ([self.alertTargetViewController isMemberOfClass:[SettingsTwoStepViewController class]]) {
        SettingsTwoStepViewController *twoStepViewController = (SettingsTwoStepViewController *)self.alertTargetViewController;
        [twoStepViewController updateUI];
    }

    [self reloadTableView];
}

- (void)updateEmailAndMobileStrings
{
    NSString *emailString = [WalletManager.sharedInstance.wallet getEmail];

    if (emailString != nil) {
        self.emailString = emailString;
    }

    NSString *mobileNumberString = [WalletManager.sharedInstance.wallet getSMSNumber];

    if (mobileNumberString != nil) {
        self.mobileNumberString = mobileNumberString;
    }
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

+ (UIFont *)fontForCell
{
    return [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM];
}

+ (UIFont *)fontForCellSubtitle
{
    return [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];
}

- (UITableViewCell *)adjustFontForCell:(UITableViewCell *)cell
{
    UILabel *cellTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    cellTextLabel.text = cell.textLabel.text;
    [cellTextLabel sizeToFit];
    if (cellTextLabel.frame.size.width > cell.contentView.frame.size.width * 2/3) {
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NUEUE size:FONT_SIZE_EXTRA_SMALL];
        cell.detailTextLabel.font = [UIFont fontWithName:FONT_HELVETICA_NUEUE size:FONT_SIZE_EXTRA_SMALL];
    }

    if (cellTextLabel.frame.size.width > cell.contentView.frame.size.width * 4/5) {
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NUEUE size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
        cell.detailTextLabel.font = [UIFont fontWithName:FONT_HELVETICA_NUEUE size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
    }

    return cell;
}

- (CurrencySymbol *)getLocalSymbolFromLatestResponse
{
    return WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local;
}

- (CurrencySymbol *)getBtcSymbolFromLatestResponse
{
    return WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc;
}

- (void)alertUserOfErrorLoadingSettings
{
    UIAlertController *alertForErrorLoading = [UIAlertController alertControllerWithTitle:BC_STRING_SETTINGS_ERROR_LOADING_TITLE message:BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    [alertForErrorLoading addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertForErrorLoading animated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:USER_DEFAULTS_KEY_LOADED_SETTINGS];
}

- (void)alertUserOfSuccess:(NSString *)successMessage
{
    UIAlertController *alertForSuccess = [UIAlertController alertControllerWithTitle:[LocalizationConstantsObjcBridge success] message:successMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertForSuccess addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    if (self.alertTargetViewController) {
        [self.alertTargetViewController presentViewController:alertForSuccess animated:YES completion:nil];
    } else {
        [self.navigationController presentViewController:alertForSuccess animated:YES completion:nil];
    }

    [self reload];
}

- (void)alertUserOfError:(NSString *)errorMessage
{
    UIAlertController *alertForError = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertForError addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    if (self.alertTargetViewController) {
        [self.alertTargetViewController presentViewController:alertForError animated:YES completion:nil];
    } else {
        [self.navigationController presentViewController:alertForError animated:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)walletIdentifierClicked
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_SETTINGS_COPY_GUID message:BC_STRING_SETTINGS_COPY_GUID_WARNING preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:BC_STRING_COPY_TO_CLIPBOARD style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        DLog("User confirmed copying GUID");
        [UIPasteboard generalPasteboard].string = WalletManager.sharedInstance.wallet.guid;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [alert addAction:copyAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)emailClicked
{
    BCVerifyEmailViewController *verifyEmailController = [[BCVerifyEmailViewController alloc] initWithEmailDelegate:self];
    [self.navigationController pushViewController:verifyEmailController animated:YES];
}

#pragma mark - Email Delegate

- (BOOL)isEmailVerified
{
    return [WalletManager.sharedInstance.wallet hasVerifiedEmail];
}

- (NSString *)getEmail
{
    return [WalletManager.sharedInstance.wallet getEmail];
}

- (void)changeEmail:(NSString *)emailString
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEmailSuccess) name:NOTIFICATION_KEY_CHANGE_EMAIL_SUCCESS object:nil];

    self.enteredEmailString = emailString;

    [WalletManager.sharedInstance.wallet changeEmail:emailString];
}

#pragma mark - Mobile Delegate

- (BOOL)isMobileVerified
{
    return [WalletManager.sharedInstance.wallet hasVerifiedMobileNumber];
}

- (NSString *)getMobileNumber
{
    return [WalletManager.sharedInstance.wallet getSMSNumber];
}

- (void)changeMobileNumber:(NSString *)newNumber
{
    self.enteredMobileNumberString = newNumber;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMobileNumberSuccess) name:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMobileNumberError) name:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_ERROR object:nil];
    
    [WalletManager.sharedInstance.wallet changeMobileNumber:newNumber];
}

- (BOOL)showVerifyAlertIfNeeded
{
    BOOL shouldShowVerifyAlert = self.isVerifyingMobileNumber;

    if (shouldShowVerifyAlert) {
        [self alertUserToVerifyMobileNumber];
        self.isVerifyingMobileNumber = NO;
    }

    return shouldShowVerifyAlert;
}

- (void)mobileNumberClicked
{
    if ([WalletManager.sharedInstance.wallet getTwoStepType] == TWO_STEP_AUTH_TYPE_SMS) {
        UIAlertController *alertToDisableTwoFactorSMS = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED_ARGUMENT, BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_SMS] message:[NSString stringWithFormat:BC_STRING_SETTINGS_SECURITY_MUST_DISABLE_TWO_FACTOR_SMS_ARGUMENT, self.mobileNumberString] preferredStyle:UIAlertControllerStyleAlert];
        [alertToDisableTwoFactorSMS addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
        if (self.alertTargetViewController) {
            [self.alertTargetViewController presentViewController:alertToDisableTwoFactorSMS animated:YES completion:nil];
        } else {
            [self presentViewController:alertToDisableTwoFactorSMS animated:YES completion:nil];
        }
        return;
    }

    BCVerifyMobileNumberViewController *verifyMobileNumberController = [[BCVerifyMobileNumberViewController alloc] initWithMobileDelegate:self];
    [self.navigationController pushViewController:verifyMobileNumberController animated:YES];
}

- (void)aboutUsClicked
{
    [AboutUsViewController presentIn:self];
}

- (void)termsOfServiceClicked
{
    SettingsWebViewController *aboutViewController = [[SettingsWebViewController alloc] init];
    aboutViewController.urlTargetString = [ConstantsObjcBridge termsOfServiceURLString];
    BCNavigationController *navigationController = [[BCNavigationController alloc] initWithRootViewController:aboutViewController title:BC_STRING_SETTINGS_TERMS_OF_SERVICE];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showPrivacyPolicy
{
    SettingsWebViewController *aboutViewController = [[SettingsWebViewController alloc] init];
    aboutViewController.urlTargetString = [ConstantsObjcBridge privacyPolicyURLString];
    BCNavigationController *navigationController = [[BCNavigationController alloc] initWithRootViewController:aboutViewController title:BC_STRING_SETTINGS_PRIVACY_POLICY];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showCookiePolicy
{
    SettingsWebViewController *aboutViewController = [[SettingsWebViewController alloc] init];
    aboutViewController.urlTargetString = [ConstantsObjcBridge cookiePolicyURLString];
    BCNavigationController *navigationController = [[BCNavigationController alloc] initWithRootViewController:aboutViewController title:[LocalizationConstantsObjcBridge cookiePolicy]];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Change Fee per KB

- (NSString *)convertFloatToString:(float)floatNumber forDisplay:(BOOL)isForDisplay
{
    NSNumberFormatter *feePerKbFormatter = [[NSNumberFormatter alloc] init];
    feePerKbFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    feePerKbFormatter.maximumFractionDigits = 8;
    NSNumber *amountNumber = [NSNumber numberWithFloat:floatNumber];
    NSString *displayString = [feePerKbFormatter stringFromNumber:amountNumber];
    if (isForDisplay) {
        return displayString;
    } else {
        NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
        NSString *numbersWithDecimalSeparatorString = [[NSString alloc] initWithFormat:@"%@%@", NUMBER_KEYPAD_CHARACTER_SET_STRING, decimalSeparator];
        NSCharacterSet *characterSetFromString = [NSCharacterSet characterSetWithCharactersInString:displayString];
        NSCharacterSet *numbersAndDecimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:numbersWithDecimalSeparatorString];

        if (![numbersAndDecimalCharacterSet isSupersetOfSet:characterSetFromString]) {
            // Current keypad will not support this character set; return string with known decimal separators "," and "."
            feePerKbFormatter.locale = [NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US];

            if ([decimalSeparator isEqualToString:@"."]) {
                return [feePerKbFormatter stringFromNumber:amountNumber];;
            } else {
                [feePerKbFormatter setDecimalSeparator:decimalSeparator];
                return [feePerKbFormatter stringFromNumber:amountNumber];
            }
        }

        return displayString;
    }
}

#pragma mark - Change Mobile Number

- (void)changeMobileNumberSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_ERROR object:nil];

    self.mobileNumberString = self.enteredMobileNumberString;

    [self getAccountInfo];

    [self alertUserToVerifyMobileNumber];
}

- (void)changeMobileNumberError
{
    self.isEnablingTwoStepSMS = NO;
    [self alertUserOfError:BC_STRING_SETTINGS_ERROR_INVALID_MOBILE_NUMBER];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_ERROR object:nil];
}

- (void)alertUserToVerifyMobileNumber
{
    self.isVerifyingMobileNumber = YES;

    UIAlertController *alertForVerifyingMobileNumber = [UIAlertController alertControllerWithTitle:BC_STRING_SETTINGS_VERIFY_ENTER_CODE message:[[NSString alloc] initWithFormat:BC_STRING_SETTINGS_SENT_TO_ARGUMENT, self.mobileNumberString] preferredStyle:UIAlertControllerStyleAlert];
    [alertForVerifyingMobileNumber addAction:[UIAlertAction actionWithTitle:BC_STRING_SETTINGS_VERIFY_MOBILE_RESEND style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self changeMobileNumber:self.mobileNumberString];
    }]];
    [alertForVerifyingMobileNumber addAction:[UIAlertAction actionWithTitle:BC_STRING_SETTINGS_VERIFY style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self verifyMobileNumber:[[alertForVerifyingMobileNumber textFields] firstObject].text];
    }]];
    [alertForVerifyingMobileNumber addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // If the user cancels right after adding a legitimate number, update accountInfo
        self.isEnablingTwoStepSMS = NO;
        [self getAccountInfo];
    }]];
    [alertForVerifyingMobileNumber addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        BCSecureTextField *secureTextField = (BCSecureTextField *)textField;
        secureTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        secureTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        secureTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        secureTextField.tag = TAG_TEXTFIELD_VERIFY_MOBILE_NUMBER;
        secureTextField.delegate = self;
        secureTextField.returnKeyType = UIReturnKeyDone;
        secureTextField.placeholder = BC_STRING_ENTER_VERIFICATION_CODE;
    }];
    if (self.alertTargetViewController) {
        [self.alertTargetViewController presentViewController:alertForVerifyingMobileNumber animated:YES completion:nil];
    } else {
        [self.navigationController presentViewController:alertForVerifyingMobileNumber animated:YES completion:nil];
    }}

- (void)verifyMobileNumber:(NSString *)code
{
    [WalletManager.sharedInstance.wallet verifyMobileNumber:code];
    [self addObserversForVerifyingMobileNumber];
    // Mobile number error appears through sendEvent
}

- (void)addObserversForVerifyingMobileNumber
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifyMobileNumberSuccess) name:NOTIFICATION_KEY_VERIFY_MOBILE_NUMBER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifyMobileNumberError) name:NOTIFICATION_KEY_VERIFY_MOBILE_NUMBER_ERROR object:nil];
}

- (void)verifyMobileNumberSuccess
{
    self.isVerifyingMobileNumber = NO;

    [self removeObserversForVerifyingMobileNumber];

    if (self.isEnablingTwoStepSMS) {
        [self enableTwoStepForSMS];
        return;
    }

    [self alertUserOfSuccess:BC_STRING_SETTINGS_MOBILE_NUMBER_VERIFIED];
}

- (void)verifyMobileNumberError
{
    [self removeObserversForVerifyingMobileNumber];
    self.isEnablingTwoStepSMS = NO;
}

- (void)removeObserversForVerifyingMobileNumber
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_VERIFY_MOBILE_NUMBER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_VERIFY_MOBILE_NUMBER_ERROR object:nil];
}

#pragma mark - Web login

- (void)webLoginClicked
{
    WebLoginViewController *webLoginViewController = [[WebLoginViewController alloc] init];
    [self.navigationController pushViewController:webLoginViewController animated:YES];
}

#pragma mark - Change Swipe to Receive

- (void)switchSwipeToReceiveTapped
{
    BOOL swipeToReceiveEnabled = BlockchainSettings.sharedAppInstance.swipeToReceiveEnabled;

    if (!swipeToReceiveEnabled) {
        UIAlertController *swipeToReceiveAlert = [UIAlertController alertControllerWithTitle:BC_STRING_SETTINGS_PIN_SWIPE_TO_RECEIVE message:BC_STRING_SETTINGS_SWIPE_TO_RECEIVE_IN_FIVES_FOOTER preferredStyle:UIAlertControllerStyleAlert];
        [swipeToReceiveAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_ENABLE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BlockchainSettings.sharedAppInstance.swipeToReceiveEnabled = !swipeToReceiveEnabled;
            // Clear all swipe addresses in case default account has changed
            if (!swipeToReceiveEnabled) {
                [AssetAddressRepository.sharedInstance removeAllSwipeAddresses];
            }
        }]];
        [swipeToReceiveAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.PINSwipeToReceive inSection:sectionSecurity];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [self presentViewController:swipeToReceiveAlert animated:YES completion:nil];
    } else {
        BlockchainSettings.sharedAppInstance.swipeToReceiveEnabled = !swipeToReceiveEnabled;
        // Clear all swipe addresses in case default account has changed
        if (!swipeToReceiveEnabled) {
            [AssetAddressRepository.sharedInstance removeAllSwipeAddresses];
        }
    }
}

#pragma mark - Biometrics

/**
 Gets the biometric type description depending on whether the device supports Face ID, Touch ID or neither.
 @return The biometric type description of the authentication method.
 */
- (NSString *)biometryTypeDescription
{
    BiometricType *type = UIDevice.currentDevice.supportedBiometricType;
    if (!type) { return nil; }
    return [NSString stringWithFormat:[LocalizationConstantsObjcBridge useBiometricsAsPin], type.title];
}

- (void)biometrySwitchTapped
{
    [AuthenticationManager.sharedInstance canAuthenticateUsingBiometryWithAndReply:^(BOOL success, NSString * _Nullable errorMessage) {
        if (success) {
            [self toggleBiometry];
        } else {
            BlockchainSettings.sharedAppInstance.biometryEnabled = NO;
            UIAlertController *alertBiometryError = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            [alertBiometryError addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.PINBiometry inSection:sectionSecurity];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }]];
            [self presentViewController:alertBiometryError animated:YES completion:nil];
        }
    }];
}

- (void)toggleBiometry
{
    BOOL biometryEnabled = BlockchainSettings.sharedAppInstance.biometryEnabled;
    if (!(biometryEnabled == YES)) {
        NSString *biometryWarning = [NSString stringWithFormat:[LocalizationConstantsObjcBridge biometryWarning], [self biometryTypeDescription]];
        UIAlertController *alertForTogglingBiometry = [UIAlertController alertControllerWithTitle:[self biometryTypeDescription] message:biometryWarning preferredStyle:UIAlertControllerStyleAlert];
        [alertForTogglingBiometry addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.PINBiometry inSection:sectionSecurity];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [alertForTogglingBiometry addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [AuthenticationCoordinator.sharedInstance validatePin];
        }]];
        [self presentViewController:alertForTogglingBiometry animated:YES completion:nil];
    } else {
        BlockchainSettings.sharedAppInstance.pin = nil;
        BlockchainSettings.sharedAppInstance.biometryEnabled = !biometryEnabled;
    }
}

#pragma mark - Change notifications

- (BOOL)emailNotificationsEnabled
{
    return [WalletManager.sharedInstance.wallet emailNotificationsEnabled];
}

- (void)toggleEmailNotifications
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:preferencesEmailNotifications inSection:sectionPreferences];

    if (Reachability.hasInternetConnection) {
        if ([self emailNotificationsEnabled]) {
            [WalletManager.sharedInstance.wallet disableEmailNotifications];
        } else {
            if ([WalletManager.sharedInstance.wallet getEmailVerifiedStatus] == YES) {
                [WalletManager.sharedInstance.wallet enableEmailNotifications];
            } else {
                [self alertUserOfError:BC_STRING_PLEASE_VERIFY_EMAIL_ADDRESS_FIRST];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                return;
            }
        }

        UITableViewCell *changeEmailNotificationsCell = [self.tableView cellForRowAtIndexPath:indexPath];
        changeEmailNotificationsCell.userInteractionEnabled = NO;
        [self addObserversForChangingNotifications];
    } else {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)addObserversForChangingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNotificationsSuccess) name:NOTIFICATION_KEY_CHANGE_NOTIFICATIONS_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNotificationsError) name:NOTIFICATION_KEY_CHANGE_NOTIFICATIONS_ERROR object:nil];
}

- (void)removeObserversForChangingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_NOTIFICATIONS_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_NOTIFICATIONS_ERROR object:nil];
}

- (void)changeNotificationsSuccess
{
    [self removeObserversForChangingNotifications];

    SettingsNavigationController *navigationController = (SettingsNavigationController *)self.navigationController;
    [navigationController.busyView fadeIn];

    UITableViewCell *changeEmailNotificationsCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:preferencesEmailNotifications inSection:sectionPreferences]];
    changeEmailNotificationsCell.userInteractionEnabled = YES;
}

- (void)changeNotificationsError
{
    [self removeObserversForChangingNotifications];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:preferencesEmailNotifications inSection:sectionPreferences];

    UITableViewCell *changeEmailNotificationsCell = [self.tableView cellForRowAtIndexPath:indexPath];
    changeEmailNotificationsCell.userInteractionEnabled = YES;

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Change Two Step

- (void)showTwoStep
{
    [self performSingleSegueWithIdentifier:SEGUE_IDENTIFIER_TWO_STEP sender:nil];
}

- (void)alertUserToChangeTwoStepVerification
{
    NSString *alertTitle;
    BOOL isTwoStepEnabled = YES;
    int twoStepType = [WalletManager.sharedInstance.wallet getTwoStepType];
    if (twoStepType == TWO_STEP_AUTH_TYPE_SMS) {
        alertTitle = [NSString stringWithFormat:BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED_ARGUMENT, BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_SMS];
    } else if (twoStepType == TWO_STEP_AUTH_TYPE_GOOGLE) {
        alertTitle = [NSString stringWithFormat:BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED_ARGUMENT, BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_GOOGLE];
    } else if (twoStepType == TWO_STEP_AUTH_TYPE_YUBI_KEY){
        alertTitle = [NSString stringWithFormat:BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED_ARGUMENT, BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_YUBI_KEY];
    } else if (twoStepType == TWO_STEP_AUTH_TYPE_NONE) {
        alertTitle = BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_DISABLED;
        isTwoStepEnabled = NO;
    } else {
        alertTitle = BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED;
    }

    UIAlertController *alertForChangingTwoStep = [UIAlertController alertControllerWithTitle:alertTitle message:BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_MESSAGE_SMS_ONLY preferredStyle:UIAlertControllerStyleAlert];
    [alertForChangingTwoStep addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler: nil]];
    [alertForChangingTwoStep addAction:[UIAlertAction actionWithTitle:isTwoStepEnabled ? BC_STRING_DISABLE : BC_STRING_ENABLE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self changeTwoStepVerification];
    }]];

    if (self.alertTargetViewController) {
        [self.alertTargetViewController presentViewController:alertForChangingTwoStep animated:YES completion:nil];
    } else {
        [self presentViewController:alertForChangingTwoStep animated:YES completion:nil];
    }
}

- (void)changeTwoStepVerification
{
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    if ([WalletManager.sharedInstance.wallet getTwoStepType] == TWO_STEP_AUTH_TYPE_NONE) {
        self.isEnablingTwoStepSMS = YES;
        if ([WalletManager.sharedInstance.wallet getSMSVerifiedStatus] == YES) {
            [self enableTwoStepForSMS];
        } else {
            [self mobileNumberClicked];
        }
    } else {
        [self disableTwoStep];
    }
}

- (void)enableTwoStepForSMS
{
    [self prepareForForChangingTwoStep];
    [WalletManager.sharedInstance.wallet enableTwoStepVerificationForSMS];
}

- (void)disableTwoStep
{
    [self prepareForForChangingTwoStep];
    [WalletManager.sharedInstance.wallet disableTwoStepVerification];
}

- (void)prepareForForChangingTwoStep
{
    UITableViewCell *enableTwoStepCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:securityTwoStep inSection:sectionSecurity]];
    enableTwoStepCell.userInteractionEnabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTwoStepSuccess) name:NOTIFICATION_KEY_CHANGE_TWO_STEP_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTwoStepError) name:NOTIFICATION_KEY_CHANGE_TWO_STEP_ERROR object:nil];
}

- (void)doneChangingTwoStep
{
    UITableViewCell *enableTwoStepCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:securityTwoStep inSection:sectionSecurity]];
    enableTwoStepCell.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_TWO_STEP_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_TWO_STEP_ERROR object:nil];
}

- (void)changeTwoStepSuccess
{
    if (self.isEnablingTwoStepSMS) {
        [self alertUserOfSuccess:BC_STRING_TWO_STEP_ENABLED_SUCCESS];
    } else {
        [self alertUserOfSuccess:BC_STRING_TWO_STEP_DISABLED_SUCCESS];
    }
    self.isEnablingTwoStepSMS = NO;

    [self doneChangingTwoStep];
}

- (void)changeTwoStepError
{
    self.isEnablingTwoStepSMS = NO;
    [self alertUserOfError:BC_STRING_TWO_STEP_ERROR];
    [self doneChangingTwoStep];
    [self getAccountInfo];
}

#pragma mark - Change Email

- (BOOL)hasAddedEmail
{
    return [WalletManager.sharedInstance.wallet getEmail] ? YES : NO;
}

- (NSString *)getUserEmail
{
    return [WalletManager.sharedInstance.wallet getEmail];
}

- (void)alertUserToChangeEmail:(BOOL)hasAddedEmail
{
    NSString *alertViewTitle = hasAddedEmail ? BC_STRING_SETTINGS_CHANGE_EMAIL :BC_STRING_ADD_EMAIL;

    UIAlertController *alertForChangingEmail = [UIAlertController alertControllerWithTitle:alertViewTitle message:BC_STRING_PLEASE_PROVIDE_AN_EMAIL_ADDRESS preferredStyle:UIAlertControllerStyleAlert];
    [alertForChangingEmail addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // If the user cancels right after adding a legitimate email address, update accountInfo
        UITableViewCell *emailCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:profileEmail inSection:sectionProfile]];
        if (([emailCell.detailTextLabel.text isEqualToString:BC_STRING_SETTINGS_UNVERIFIED] && [alertForChangingEmail.title isEqualToString:BC_STRING_SETTINGS_CHANGE_EMAIL]) || ![[self getUserEmail] isEqualToString:self.emailString]) {
            [self getAccountInfo];
        }
    }]];
    [alertForChangingEmail addAction:[UIAlertAction actionWithTitle:BC_STRING_SETTINGS_VERIFY style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        NSString *newEmail = [[alertForChangingEmail textFields] firstObject].text;

        if ([[[newEmail lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:[[[self getUserEmail] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
            [self alertUserOfError:BC_STRING_SETTINGS_NEW_EMAIL_MUST_BE_DIFFERENT];
            return;
        }

        if ([WalletManager.sharedInstance.wallet emailNotificationsEnabled]) {
            [self alertUserAboutDisablingEmailNotifications:newEmail];
        } else {
            [self changeEmail:newEmail];
        }

    }]];
    [alertForChangingEmail addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        BCSecureTextField *secureTextField = (BCSecureTextField *)textField;
        secureTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        secureTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        secureTextField.returnKeyType = UIReturnKeyDone;
        secureTextField.text = hasAddedEmail ? [self getUserEmail] : @"";
    }];

    if (self.alertTargetViewController) {
        [self.alertTargetViewController presentViewController:alertForChangingEmail animated:YES completion:nil];
    } else {
        [self presentViewController:alertForChangingEmail animated:YES completion:nil];
    }
}

- (void)alertUserAboutDisablingEmailNotifications:(NSString *)newEmail
{
    self.enteredEmailString = newEmail;

    UIAlertController *alertForChangingEmail = [UIAlertController alertControllerWithTitle:BC_STRING_SETTINGS_NEW_EMAIL_ADDRESS message:BC_STRING_SETTINGS_NEW_EMAIL_ADDRESS_WARNING_DISABLE_NOTIFICATIONS preferredStyle:UIAlertControllerStyleAlert];
    [alertForChangingEmail addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [alertForChangingEmail addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self disableNotificationsThenChangeEmail:newEmail];
    }]];

    if (self.alertTargetViewController) {
        [self.alertTargetViewController presentViewController:alertForChangingEmail animated:YES completion:nil];
    } else {
        [self presentViewController:alertForChangingEmail animated:YES completion:nil];
    }
}

- (void)disableNotificationsThenChangeEmail:(NSString *)newEmail
{
    SettingsNavigationController *navigationController = (SettingsNavigationController *)self.navigationController;
    [navigationController.busyView fadeIn];

    [WalletManager.sharedInstance.wallet disableEmailNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEmailAfterDisablingNotifications) name:[ConstantsObjcBridge notificationKeyBackupSuccess] object:nil];
}

- (void)changeEmailAfterDisablingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConstantsObjcBridge notificationKeyBackupSuccess] object:nil];
    [self changeEmail:self.enteredEmailString];
}

- (void)alertUserToVerifyEmail
{
    UIAlertController *alertForVerifyingEmail = [UIAlertController alertControllerWithTitle:[[NSString alloc] initWithFormat:BC_STRING_VERIFICATION_EMAIL_SENT_TO_ARGUMENT, self.emailString] message:BC_STRING_PLEASE_CHECK_AND_CLICK_EMAIL_VERIFICATION_LINK preferredStyle:UIAlertControllerStyleAlert];
    [alertForVerifyingEmail addAction:[UIAlertAction actionWithTitle:BC_STRING_SETTINGS_VERIFY_EMAIL_RESEND style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resendVerificationEmail];
    }]];
    [alertForVerifyingEmail addAction:[UIAlertAction actionWithTitle:BC_STRING_OPEN_MAIL_APP style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIApplication.sharedApplication openMailApplication];
    }]];
    [alertForVerifyingEmail addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self getAccountInfo];
    }]];

    if (self.alertTargetViewController) {
        [self.alertTargetViewController presentViewController:alertForVerifyingEmail animated:YES completion:nil];
    } else {
        [self.navigationController presentViewController:alertForVerifyingEmail animated:YES completion:nil];
    }}

- (void)resendVerificationEmail
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resendVerificationEmailSuccess) name:NOTIFICATION_KEY_RESEND_VERIFICATION_EMAIL_SUCCESS object:nil];

    [WalletManager.sharedInstance.wallet resendVerificationEmail:self.emailString];
}

- (void)resendVerificationEmailSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_RESEND_VERIFICATION_EMAIL_SUCCESS object:nil];

    [self alertUserToVerifyEmail];
}

- (void)changeEmailSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHANGE_EMAIL_SUCCESS object:nil];

    self.emailString = self.enteredEmailString;

    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC);
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self alertUserToVerifyEmail];
    });
}

#pragma mark - Wallet Recovery Phrase

- (void)showBackup
{
    if (!self.backupController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME_BACKUP bundle: nil];
        self.backupController = [storyboard instantiateViewControllerWithIdentifier:NAVIGATION_CONTROLLER_NAME_BACKUP];
    }

    self.backupController.wallet = WalletManager.sharedInstance.wallet;

    self.backupController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:self.backupController animated:YES completion:nil];
}

#pragma mark - Change Password

- (void)changePassword
{
    [self performSingleSegueWithIdentifier:SEGUE_IDENTIFIER_CHANGE_PASSWORD sender:nil];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    __weak SettingsTableViewController *weakSelf = self;

    if (self.alertTargetViewController) {
        [self.alertTargetViewController dismissViewControllerAnimated:YES completion:^{
            if (textField.tag == TAG_TEXTFIELD_VERIFY_MOBILE_NUMBER) {
                [weakSelf verifyMobileNumber:textField.text];

            } else if (textField.tag == TAG_TEXTFIELD_CHANGE_MOBILE_NUMBER) {
                [weakSelf changeMobileNumber:textField.text];
            }
        }];
        return YES;
    }

    [self dismissViewControllerAnimated:YES completion:^{
        if (textField.tag == TAG_TEXTFIELD_VERIFY_MOBILE_NUMBER) {
            [weakSelf verifyMobileNumber:textField.text];

        } else if (textField.tag == TAG_TEXTFIELD_CHANGE_MOBILE_NUMBER) {
            [weakSelf changeMobileNumber:textField.text];
        }
    }];

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.changeFeeTextField) {

        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray  *points = [newString componentsSeparatedByString:@"."];
        NSArray  *commas = [newString componentsSeparatedByString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];

        // Only one comma or point in input field allowed
        if ([points count] > 2 || [commas count] > 2)
            return NO;

        // Only 1 leading zero
        if (points.count == 1 || commas.count == 1) {
            if (range.location == 1 && ![string isEqualToString:@"."] && ![string isEqualToString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]] && [textField.text isEqualToString:@"0"]) {
                return NO;
            }
        }

        NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
        NSString *numbersWithDecimalSeparatorString = [[NSString alloc] initWithFormat:@"%@%@", NUMBER_KEYPAD_CHARACTER_SET_STRING, decimalSeparator];
        NSCharacterSet *characterSetFromString = [NSCharacterSet characterSetWithCharactersInString:newString];
        NSCharacterSet *numbersAndDecimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:numbersWithDecimalSeparatorString];

        // Only accept numbers and decimal representations
        if (![numbersAndDecimalCharacterSet isSupersetOfSet:characterSetFromString]) {
            return NO;
        }
    }

    return YES;
}

#pragma mark - Segue

- (void)performSingleSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([[self navigationController] topViewController] == self) {
        [self performSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_CURRENCY]) {
        SettingsSelectorTableViewController *settingsSelectorTableViewController = segue.destinationViewController;
        settingsSelectorTableViewController.itemsDictionary = self.availableCurrenciesDictionary;
    } else if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_TWO_STEP]) {
        SettingsTwoStepViewController *twoStepViewController = (SettingsTwoStepViewController *)segue.destinationViewController;
        twoStepViewController.settingsController = self;
        self.alertTargetViewController = twoStepViewController;
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    switch (indexPath.section) {
        case sectionProfile: {
            switch (indexPath.row) {
                case profileWalletIdentifier: {
                    [self walletIdentifierClicked];
                    return;
                }
                case profileEmail: {
                    [self emailClicked];
                    return;
                }
                case profileMobileNumber: {
                    [self mobileNumberClicked];
                    return;
                }
                case profileWebLogin: {
                    [self webLoginClicked];
                    return;
                }
            }
            return;
        }
        case sectionPreferences: {
            switch (indexPath.row) {
                case preferencesLocalCurrency: {
                    [self performSingleSegueWithIdentifier:SEGUE_IDENTIFIER_CURRENCY sender:nil];
                    return;
                }
            }
            return;
        }
        case sectionSecurity: {
            if (indexPath.row == securityTwoStep) {
                [self showTwoStep];
                return;
            } else if (indexPath.row == securityPasswordChange) {
                [self changePassword];
                return;
            } else if (indexPath.row == securityWalletRecoveryPhrase) {
                [self showBackup];
                return;
            } else if (indexPath.row == PINChangePIN) {
                [AuthenticationCoordinator.sharedInstance changePin];
                return;
            }
            return;
        }
        case aboutSection: {
            switch (indexPath.row) {
                case aboutUs: {
                    [self aboutUsClicked];
                    return;
                }
                case aboutTermsOfService: {
                    [self termsOfServiceClicked];
                    return;
                }
                case aboutPrivacyPolicy: {
                    [self showPrivacyPolicy];
                    return;
                }
                case aboutCookiePolicy: {
                    [self showCookiePolicy];
                    return;
                }
            }
            return;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case sectionProfile: return 4;
        case sectionPreferences: return 2;
        case sectionSecurity: {
            NSInteger numberOfRows = 6;
            if (self.PINBiometry == -1) {
                numberOfRows--;
            }
            if (self.PINSwipeToReceive == -1) {
                numberOfRows--;
            }
            if (![WalletManager.sharedInstance.wallet didUpgradeToHd]) {
                numberOfRows--;
            }
            return numberOfRows;
        }
        case aboutSection: return 4;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"s%li-r%li", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        if (indexPath.section == sectionProfile && indexPath.row == profileWalletIdentifier) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.textLabel.textColor = UIColor.gray5;
            cell.textLabel.font = [SettingsTableViewController fontForCell];
            cell.detailTextLabel.font = [SettingsTableViewController fontForCell];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        }
    }

    switch (indexPath.section) {
        case sectionProfile: {
            switch (indexPath.row) {
                case profileWalletIdentifier: {
                    cell.textLabel.font = [SettingsTableViewController fontForCell];
                    cell.textLabel.textColor = UIColor.gray5;
                    cell.textLabel.text = BC_STRING_SETTINGS_WALLET_ID;
                    cell.detailTextLabel.text = WalletManager.sharedInstance.wallet.guid;
                    cell.detailTextLabel.font = [SettingsTableViewController fontForCellSubtitle];
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
                    return cell;
                }
                case profileEmail: {
                    cell.textLabel.text = BC_STRING_SETTINGS_EMAIL;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    if ([self getUserEmail] != nil && [WalletManager.sharedInstance.wallet getEmailVerifiedStatus] == YES) {
                        cell.detailTextLabel.text = BC_STRING_SETTINGS_VERIFIED;
                        cell.detailTextLabel.textColor = UIColor.green;
                    } else {
                        cell.detailTextLabel.text = BC_STRING_SETTINGS_UNVERIFIED;
                        cell.detailTextLabel.textColor = UIColor.error;
                    }
                    return [self adjustFontForCell:cell];
                }
                case profileMobileNumber: {
                    cell.textLabel.text = BC_STRING_SETTINGS_MOBILE_NUMBER;
                    if ([WalletManager.sharedInstance.wallet hasVerifiedMobileNumber]) {
                        cell.detailTextLabel.text = BC_STRING_SETTINGS_VERIFIED;
                        cell.detailTextLabel.textColor = UIColor.green;
                    } else {
                        cell.detailTextLabel.text = BC_STRING_SETTINGS_UNVERIFIED;
                        cell.detailTextLabel.textColor = UIColor.error;
                    }
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return [self adjustFontForCell:cell];
                }
                case profileWebLogin: {
                    cell.textLabel.text = BC_STRING_LOG_IN_TO_WEB_WALLET;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return [self adjustFontForCell:cell];
                }
            }
        }
        case sectionPreferences: {
            switch (indexPath.row) {
                case preferencesEmailNotifications: {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.text = BC_STRING_SETTINGS_EMAIL_NOTIFICATIONS;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UISwitch *switchForEmailNotifications = [[UISwitch alloc] init];
                    switchForEmailNotifications.on = [self emailNotificationsEnabled];
                    [switchForEmailNotifications addTarget:self action:@selector(toggleEmailNotifications) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = switchForEmailNotifications;
                    return cell;
                }
                case preferencesLocalCurrency: {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    NSString *selectedCurrencyCode = [self getLocalSymbolFromLatestResponse].code;
                    NSString *currencyName = self.availableCurrenciesDictionary[selectedCurrencyCode];
                    cell.textLabel.text = BC_STRING_SETTINGS_LOCAL_CURRENCY;
                    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@ (%@)", currencyName, self.allCurrencySymbolsDictionary[selectedCurrencyCode][@"symbol"]];
                    if (currencyName == nil || self.allCurrencySymbolsDictionary[selectedCurrencyCode][@"symbol"] == nil) {
                        cell.detailTextLabel.text = @"";
                    }
                    return cell;
                }
            }
        }
        case sectionSecurity: {
            if (indexPath.row == securityTwoStep) {
                cell.textLabel.text = BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                int authType = [WalletManager.sharedInstance.wallet getTwoStepType];
                cell.detailTextLabel.textColor = UIColor.green;
                if (authType == TWO_STEP_AUTH_TYPE_SMS) {
                    cell.detailTextLabel.text = BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_SMS;
                } else if (authType == TWO_STEP_AUTH_TYPE_GOOGLE) {
                    cell.detailTextLabel.text = BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_GOOGLE;
                } else if (authType == TWO_STEP_AUTH_TYPE_YUBI_KEY) {
                    cell.detailTextLabel.text = BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_YUBI_KEY;
                } else if (authType == TWO_STEP_AUTH_TYPE_NONE) {
                    cell.detailTextLabel.text = BC_STRING_DISABLED;
                    cell.detailTextLabel.textColor = UIColor.error;
                } else {
                    cell.detailTextLabel.text = BC_STRING_UNKNOWN;
                }
                return [self adjustFontForCell:cell];
            }
            else if (indexPath.row == securityPasswordChange) {
                cell.textLabel.text = BC_STRING_SETTINGS_SECURITY_CHANGE_PASSWORD;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return [self adjustFontForCell:cell];
            }
            else if (indexPath.row == securityWalletRecoveryPhrase) {
                cell.textLabel.font = [SettingsTableViewController fontForCell];
                cell.textLabel.text = BC_STRING_WALLET_RECOVERY_PHRASE;
                if (WalletManager.sharedInstance.wallet.isRecoveryPhraseVerified) {
                    cell.detailTextLabel.text = BC_STRING_SETTINGS_VERIFIED;
                    cell.detailTextLabel.textColor = UIColor.green;
                } else {
                    cell.detailTextLabel.text = BC_STRING_SETTINGS_UNCONFIRMED;
                    cell.detailTextLabel.textColor = UIColor.error;
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return [self adjustFontForCell:cell];
            } else if (indexPath.row == PINChangePIN) {
                cell.textLabel.text = BC_STRING_CHANGE_PIN;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            } else if (indexPath.row == self.PINBiometry) {
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [SettingsTableViewController fontForCell];
                cell.textLabel.text = [self biometryTypeDescription];
                UISwitch *biometrySwitch = [[UISwitch alloc] init];
                BOOL biometryEnabled = BlockchainSettings.sharedAppInstance.biometryEnabled;
                biometrySwitch.on = biometryEnabled;
                [biometrySwitch addTarget:self action:@selector(biometrySwitchTapped) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = biometrySwitch;
                return cell;
            } else if (indexPath.row == self.PINSwipeToReceive) {
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [SettingsTableViewController fontForCell];
                cell.textLabel.text = BC_STRING_SETTINGS_PIN_SWIPE_TO_RECEIVE;
                UISwitch *switchForSwipeToReceive = [[UISwitch alloc] init];
                BOOL swipeToReceiveEnabled = BlockchainSettings.sharedAppInstance.swipeToReceiveEnabled;
                switchForSwipeToReceive.on = swipeToReceiveEnabled;
                [switchForSwipeToReceive addTarget:self action:@selector(switchSwipeToReceiveTapped) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = switchForSwipeToReceive;
                return cell;
            }
        }
        case aboutSection: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case aboutUs: {
                    cell.textLabel.text = BC_STRING_SETTINGS_ABOUT_US;
                    return cell;
                }
                case aboutTermsOfService: {
                    cell.textLabel.text = BC_STRING_SETTINGS_TERMS_OF_SERVICE;
                    return cell;
                }
                case aboutPrivacyPolicy: {
                    cell.textLabel.text = BC_STRING_SETTINGS_PRIVACY_POLICY;
                    return cell;
                }
                case aboutCookiePolicy: {
                    cell.textLabel.text = [LocalizationConstantsObjcBridge cookiePolicy];
                    return cell;
                }
            }
        }
        default: return nil;
    }

    return cell;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    view.backgroundColor = UIColor.lightGray;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width, 14)];
    label.textColor = UIColor.brandPrimary;
    label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];

    NSString *labelString = [self titleForHeaderInSection:section];
    label.text = labelString;
    [label sizeToFit];

    [view addSubview:label];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == sectionProfile && indexPath.row == profileWalletIdentifier) {
        return indexPath;
    }

    BOOL hasLoadedAccountInfoDictionary = WalletManager.sharedInstance.wallet.hasLoadedAccountInfo ? YES : NO;

    if (!hasLoadedAccountInfoDictionary || [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_LOADED_SETTINGS] boolValue] == NO) {
        [self alertUserOfErrorLoadingSettings];
        return nil;
    } else {
        return indexPath;
    }
}

#pragma mark - Table View Helpers

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case sectionProfile: return BC_STRING_SETTINGS_PROFILE;
        case sectionPreferences: return BC_STRING_SETTINGS_PREFERENCES;
        case sectionSecurity: return BC_STRING_SETTINGS_SECURITY;
        case aboutSection: return BC_STRING_SETTINGS_ABOUT;
        default: return nil;
    }
}

#pragma mark Security Center Helpers

- (void)verifyEmailTapped
{
    [self emailClicked];
}

- (void)changeTwoStepTapped
{
    [self alertUserToChangeTwoStepVerification];
}

@end
