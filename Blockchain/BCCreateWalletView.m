//
//  BCCreateWalletView
//  Blockchain
//
//  Created by Ben Reeves on 18/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCCreateWalletView.h"
#import "BuyBitcoinViewController.h"
#import "Blockchain-Swift.h"
#import "BCWebViewController.h"

@implementation BCCreateWalletView

+ (BCCreateWalletView *)instanceFromNib
{
    UINib *nib = [UINib nibWithNibName:@"MainWindow" bundle:[NSBundle mainBundle]];
    NSArray *objs = [nib instantiateWithOwner:nil options:nil];
    for (id object in objs) {
        if ([object isKindOfClass:[BCCreateWalletView class]]) {
            return (BCCreateWalletView *) object;
        }
    }
    return (BCCreateWalletView *) [objs objectAtIndex:0];
}

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createButton.frame = CGRectMake(0, 0, self.window.frame.size.width, 46);
    createButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
    self.createButton = createButton;
    
    emailTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    passwordTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    password2TextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    
    emailTextField.inputAccessoryView = createButton;
    passwordTextField.inputAccessoryView = createButton;
    password2TextField.inputAccessoryView = createButton;
    
    passwordTextField.textColor = [UIColor grayColor];
    password2TextField.textColor = [UIColor grayColor];
    
    passwordFeedbackLabel.adjustsFontSizeToFitWidth = YES;
    
    termsOfServiceLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_EXTRA_EXTRA_SMALL];
    termsOfServiceButton.titleLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_EXTRA_EXTRA_SMALL];
}

- (void)createBlankWallet
{
    [WalletManager.sharedInstance.wallet loadBlankWallet];
}

// Make sure keyboard comes back if use is returning from TOS
- (void)didMoveToWindow
{
    [emailTextField becomeFirstResponder];
}

- (void)setIsRecoveringWallet:(BOOL)isRecoveringWallet
{
    _isRecoveringWallet = isRecoveringWallet;
    
    if (_isRecoveringWallet) {
        [self.createButton removeTarget:self action:@selector(createAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.createButton addTarget:self action:@selector(showRecoveryPhraseView:) forControlEvents:UIControlEventTouchUpInside];
        [self.createButton setTitle:BC_STRING_CONTINUE forState:UIControlStateNormal];
    } else {
        [self.createButton removeTarget:self action:@selector(showRecoveryPhraseView:) forControlEvents:UIControlEventTouchUpInside];
        [self.createButton addTarget:self action:@selector(createAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.createButton setTitle:BC_STRING_CREATE_WALLET forState:UIControlStateNormal];
    }
}

#pragma mark - BCModalContentView Lifecyle methods

- (void)prepareForModalPresentation
{
    emailTextField.delegate = self;
    passwordTextField.delegate = self;
    password2TextField.delegate = self;
    
    [self clearSensitiveTextFields];

#ifdef DEBUG
    emailTextField.text = @"test@doesnotexist.tld";
    passwordTextField.text = @"testpassword!";
    password2TextField.text = @"testpassword!";
    [self checkPasswordStrength];
#endif
    
    _recoveryPhraseView.recoveryPassphraseTextField.delegate = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Scroll up to fit all entry fields on small screens
        if (!IS_568_SCREEN) {
            CGRect frame = self.frame;
            
            frame.origin.y = -SCROLL_HEIGHT_SMALL_SCREEN;
            
            self.frame = frame;
        }
        
        [emailTextField becomeFirstResponder];
    });
}

- (void)prepareForModalDismissal
{
    emailTextField.delegate = nil;
}

#pragma mark - Actions

- (IBAction)showRecoveryPhraseView:(id)sender
{
    if (![self isReadyToSubmitForm]) {
        return;
    };
    
    [self hideKeyboard];

    [[ModalPresenter sharedInstance] showModalWithContent:self.recoveryPhraseView closeType:ModalCloseTypeBack showHeader:true headerText:[LocalizationConstantsObjcBridge onboardingRecoverFunds] onDismiss:^{
        [self.createButton removeTarget:self action:@selector(recoverWalletClicked:) forControlEvents:UIControlEventTouchUpInside];
    } onResume:^{
        [self.recoveryPhraseView.recoveryPassphraseTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3f];
    }];
    
    [self.createButton removeTarget:self action:@selector(showRecoveryPhraseView:) forControlEvents:UIControlEventTouchUpInside];
    [self.createButton addTarget:self action:@selector(recoverWalletClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.recoveryPhraseView.recoveryPassphraseTextField.inputAccessoryView = self.createButton;
}

- (IBAction)recoverWalletClicked:(id)sender
{
    if (self.isRecoveringWallet) {
        NSString *recoveryPhrase = [[NSMutableString alloc] initWithString:self.recoveryPhraseView.recoveryPassphraseTextField.text];
        
        NSString *trimmedRecoveryPhrase = [recoveryPhrase stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        
        [LoadingViewPresenter.sharedInstance showBusyViewWithLoadingText:BC_STRING_LOADING_RECOVERING_WALLET];
        [self.recoveryPhraseView.recoveryPassphraseTextField resignFirstResponder];
        self.recoveryPhraseView.recoveryPassphraseTextField.hidden = YES;

        [WalletManager.sharedInstance.wallet recoverWithEmail:emailTextField.text password:passwordTextField.text passphrase:trimmedRecoveryPhrase];
        
        WalletManager.sharedInstance.wallet.delegate = WalletManager.sharedInstance;
    }
}


// Get here from New Account and also when manually pairing
- (IBAction)createAccountClicked:(id)sender
{
    if (![self isReadyToSubmitForm]) {
        return;
    };
    
    [self hideKeyboard];
        
    // Get callback when wallet is done loading
    // Continue in walletJSReady callback
    WalletManager.sharedInstance.wallet.delegate = self;

    [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_WALLET];
 
    // Load the JS without a wallet
    [WalletManager.sharedInstance.wallet performSelector:@selector(loadBlankWallet) withObject:nil afterDelay:DELAY_KEYBOARD_DISMISSAL];
}

- (IBAction)termsOfServiceClicked:(id)sender
{
    BCWebViewController *webViewController = [[BCWebViewController alloc] initWithTitle:BC_STRING_TERMS_OF_SERVICE];
    webViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [webViewController loadURL:[ConstantsObjcBridge termsOfServiceURLString]];
    [UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController presentViewController:webViewController animated:true completion:nil];
}

#pragma mark - Wallet Delegate method

- (void)walletJSReady
{
    // JS is loaded - now create the wallet
    [WalletManager.sharedInstance.wallet newAccount:self.tmpPassword email:emailTextField.text];
}

- (void)didCreateNewAccount:(NSString*)guid sharedKey:(NSString*)sharedKey password:(NSString*)password
{
    emailTextField.text = nil;
    passwordTextField.text = nil;
    password2TextField.text = nil;

    WalletManager.sharedInstance.wallet.delegate = WalletManager.sharedInstance;

    // Reset wallet
    [WalletManager.sharedInstance forgetWallet];
        
    // Load the newly created wallet
    [WalletManager.sharedInstance.wallet loadWalletWithGuid:guid sharedKey:sharedKey password:password];
    
    WalletManager.sharedInstance.wallet.isNew = YES;
    BuySellCoordinator.sharedInstance.buyBitcoinViewController.isNew = YES;
    
    BlockchainSettings.sharedAppInstance.hasSeenAllCards = NO;
    BlockchainSettings.sharedAppInstance.shouldHideAllCards = NO;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_LAST_CARD_OFFSET];

    BlockchainSettings.sharedAppInstance.hasSeenEmailReminder = NO;
    BlockchainSettings.sharedAppInstance.hasEndedFirstSession = NO;
    BlockchainSettings.sharedAppInstance.reminderModalDate = NULL;
    
    BlockchainSettings.sharedAppInstance.shouldHideBuySellCard = YES;
}

- (void)errorCreatingNewAccount:(NSString*)message
{
    if ([message isEqualToString:@""]) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
    } else if ([message isEqualToString:ERROR_TIMEOUT_REQUEST]){
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:LocalizationConstantsObjcBridge.timedOut title:BC_STRING_ERROR handler: nil];
    } else if ([message isEqualToString:ERROR_FAILED_NETWORK_REQUEST] || [message containsString:ERROR_TIMEOUT_ERROR] || [[message stringByReplacingOccurrencesOfString:@" " withString:@""] containsString:ERROR_STATUS_ZERO]){
        dispatch_after(DELAY_KEYBOARD_DISMISSAL, dispatch_get_main_queue(), ^{
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[LocalizationConstantsObjcBridge requestFailedCheckConnection] title:BC_STRING_ERROR handler: nil];
        });
    } else {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:message title:BC_STRING_ERROR handler: nil];
    }
}

#pragma mark - Textfield Delegates


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == emailTextField) {
        [passwordTextField becomeFirstResponder];
    }
    else if (textField == passwordTextField) {
        [password2TextField becomeFirstResponder];
    }
    else if (textField == password2TextField) {
        if (self.isRecoveringWallet) {
            [self.createButton setTitle:[LocalizationConstantsObjcBridge onboardingRecoverFunds] forState:UIControlStateNormal];
            [self showRecoveryPhraseView:nil];
        } else {
            [self createAccountClicked:textField];
        }
    }
    else if (textField == self.recoveryPhraseView.recoveryPassphraseTextField) {
        [self recoverWalletClicked:textField];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == passwordTextField) {
        [self performSelector:@selector(checkPasswordStrength) withObject:nil afterDelay:0.01];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (passwordTextField.text.length == 0) {
        passwordFeedbackLabel.hidden = YES;
        passwordStrengthMeter.hidden = YES;
    }
}

#pragma mark - Helpers

- (void)didRecoverWallet
{
    [self clearSensitiveTextFields];
    self.recoveryPhraseView.recoveryPassphraseTextField.hidden = NO;
}

- (void)showPassphraseTextField
{
    self.recoveryPhraseView.recoveryPassphraseTextField.hidden = NO;
}

- (void)hideKeyboard
{
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [password2TextField resignFirstResponder];
    
    [self.recoveryPhraseView.recoveryPassphraseTextField resignFirstResponder];
}

- (void)clearSensitiveTextFields
{
    passwordTextField.text = nil;
    password2TextField.text = nil;
    passwordStrengthMeter.progress = 0;
    self.passwordStrength = 0;
    
    passwordTextField.layer.borderColor = COLOR_TEXT_FIELD_BORDER_GRAY.CGColor;
    passwordFeedbackLabel.textColor = [UIColor darkGrayColor];
    
    self.recoveryPhraseView.recoveryPassphraseTextField.text = @"";
}

- (void)checkPasswordStrength
{
    passwordFeedbackLabel.hidden = NO;
    passwordStrengthMeter.hidden = NO;
    
    NSString *password = passwordTextField.text;
    
    UIColor *color;
    NSString *description;
    
    float passwordStrength = [WalletManager.sharedInstance.wallet getStrengthForPassword:password];

    if (passwordStrength < 25) {
        color = COLOR_PASSWORD_STRENGTH_WEAK;
        description = BC_STRING_PASSWORD_STRENGTH_WEAK;
    }
    else if (passwordStrength < 50) {
        color = COLOR_PASSWORD_STRENGTH_REGULAR;
        description = BC_STRING_PASSWORD_STRENGTH_REGULAR;
    }
    else if (passwordStrength < 75) {
        color = COLOR_PASSWORD_STRENGTH_NORMAL;
        description = BC_STRING_PASSWORD_STRENGTH_NORMAL;
    }
    else {
        color = COLOR_PASSWORD_STRENGTH_STRONG;
        description = BC_STRING_PASSWORD_STRENGTH_STRONG;
    }
    
    self.passwordStrength = passwordStrength;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        passwordFeedbackLabel.text = description;
        passwordFeedbackLabel.textColor = color;
        passwordStrengthMeter.progress = passwordStrength/100;
        passwordStrengthMeter.progressTintColor = color;
        passwordTextField.layer.borderColor = color.CGColor;
    }];
}

- (BOOL)isReadyToSubmitForm
{
    if ([emailTextField.text length] == 0) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PLEASE_PROVIDE_AN_EMAIL_ADDRESS title:BC_STRING_ERROR handler: nil];
        [emailTextField becomeFirstResponder];
        return NO;
    }
    
    if ([emailTextField.text hasPrefix:@"@"] ||
        [emailTextField.text hasSuffix:@"@"] ||
        [[emailTextField.text componentsSeparatedByString:@"@"] count] != 2) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_INVALID_EMAIL_ADDRESS title:BC_STRING_ERROR handler: nil];
        [emailTextField becomeFirstResponder];
        return NO;
    }
    
    self.tmpPassword = passwordTextField.text;
    
    if (!self.tmpPassword || [self.tmpPassword length] == 0) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:LocalizationConstantsObjcBridge.noPasswordEntered title:BC_STRING_ERROR handler: nil];
        [passwordTextField becomeFirstResponder];
        return NO;
    }
    
    if ([self.tmpPassword isEqualToString:emailTextField.text]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PASSWORD_MUST_BE_DIFFERENT_FROM_YOUR_EMAIL title:BC_STRING_ERROR handler: nil];
        [passwordTextField becomeFirstResponder];
        return NO;
    }
    
    if (self.passwordStrength < 25) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PASSWORD_NOT_STRONG_ENOUGH title:BC_STRING_ERROR handler: nil];
        [passwordTextField becomeFirstResponder];
        return NO;
    }
    
    if ([self.tmpPassword length] > 255) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PASSWORD_MUST_BE_LESS_THAN_OR_EQUAL_TO_255_CHARACTERS title:BC_STRING_ERROR handler: nil];
        [passwordTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self.tmpPassword isEqualToString:[password2TextField text]]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PASSWORDS_DO_NOT_MATCH title:BC_STRING_ERROR handler: nil];
        [password2TextField becomeFirstResponder];
        return NO;
    }
    
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return NO;
    }
    
    return YES;
}

@end
