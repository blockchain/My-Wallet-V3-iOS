//
//  SendEtherViewController.m
//  Blockchain
//
//  Created by kevinwu on 8/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SendEtherViewController.h"
#import "BCLine.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"
#import "BCAmountInputView.h"
#import "BCConfirmPaymentView.h"
#import "BCConfirmPaymentViewModel.h"
#import "ContinueButtonInputAccessoryView.h"
#import "Blockchain-Swift.h"
#import "NSNumberFormatter+Currencies.h"

@interface QRCodeScannerSendViewController ()
- (void)stopReadingQRCode;
@end

@interface EtherAmountInputViewController () <ContinueButtonInputAccessoryViewDelegate>
@property (nonatomic) NSString *toAddress;
@property (nonatomic) NSDecimalNumber *latestExchangeRate;
@property (nonatomic) BCAmountInputView *amountInputView;
@property (nonatomic) UITextField *toField;
@property (nonatomic) NSDecimalNumber *ethAmount;
@property (nonatomic) NSDecimalNumber *ethAvailable;
@property (nonatomic) BOOL displayingLocalSymbolSend;
@property (nonatomic, readwrite) DestinationAddressSource addressSource;

- (void)doCurrencyConversion;
@end

@interface SendEtherViewController () <ConfirmPaymentViewDelegate>
@property (nonatomic) NSDecimalNumber *ethFee;
@property (nonatomic) UILabel *feeAmountLabel;
@property (nonatomic) UIButton *fundsAvailableButton;
@property (nonatomic) UIButton *continuePaymentButton;
@property (nonatomic) NSString *noteToSet;
@property (nonatomic) ContinueButtonInputAccessoryView *continuePaymentAccessoryView;
@property (nonatomic) BCConfirmPaymentView *confirmPaymentView;
@property (nonatomic) BOOL shouldKeepCurrentPayment;

@end

#define ROW_HEIGHT_SEND_SMALL 45
#define ROW_HEIGHT_SEND_LARGE 51

@implementation SendEtherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat safeAreaInsetTop = 20;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
    }

    if (@available(iOS 11.0, *)) {
        self.view.frame = window.rootViewController.view.safeAreaLayoutGuide.layoutFrame;
    } else {
        CGFloat assetSelectorHeight = 36;
        CGFloat tabBarHeight = 49;
        CGFloat height = window.frame.size.height - safeAreaInsetTop - [ConstantsObjcBridge defaultNavigationBarHeight] - assetSelectorHeight - tabBarHeight;
        self.view.frame = CGRectMake(0, 0, window.frame.size.width, height);
    }
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 40, 21)];
    fromLabel.adjustsFontSizeToFitWidth = YES;
    fromLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    fromLabel.textColor = COLOR_TEXT_DARK_GRAY;
    fromLabel.text = BC_STRING_FROM;
    [self.view addSubview:fromLabel];
    
    CGFloat fromPlaceholderLabelOriginX = fromLabel.frame.origin.x + fromLabel.frame.size.width + 13;
    UILabel *fromPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(fromPlaceholderLabelOriginX, 8, self.view.frame.size.width - fromPlaceholderLabelOriginX, 30)];
    fromPlaceholderLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    fromPlaceholderLabel.textColor = COLOR_TEXT_DARK_GRAY;
    fromPlaceholderLabel.text = BC_STRING_MY_ETHER_WALLET;
    [self.view addSubview:fromPlaceholderLabel];
    
    BCLine *lineAboveToField = [self offsetLineWithYPosition:ROW_HEIGHT_SEND_SMALL];
    [self.view addSubview:lineAboveToField];
    
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, ROW_HEIGHT_SEND_SMALL + 16, 40, 21)];
    toLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    toLabel.textColor = COLOR_TEXT_DARK_GRAY;
    toLabel.text = BC_STRING_TO;
    [self.view addSubview:toLabel];
    
    CGFloat toFieldOriginX = toLabel.frame.origin.x + toLabel.frame.size.width + 13;
    BCSecureTextField *toField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(toFieldOriginX, ROW_HEIGHT_SEND_SMALL + 12, self.view.frame.size.width - 8 - toFieldOriginX, 30)];
    toField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    toField.placeholder = BC_STRING_ENTER_ETHER_ADDRESS;
    toField.delegate = self;
    toField.textColor = COLOR_TEXT_DARK_GRAY;
    toField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:toField];
    self.toField = toField;
    
    BCLine *lineBelowToField = [self offsetLineWithYPosition:ROW_HEIGHT_SEND_SMALL + ROW_HEIGHT_SEND_LARGE];
    [self.view addSubview:lineBelowToField];

    BCAmountInputView *amountInputView = [[BCAmountInputView alloc] init];
    amountInputView.btcLabel.text = CURRENCY_SYMBOL_ETH;
    [amountInputView changeYPosition:ROW_HEIGHT_SEND_SMALL + ROW_HEIGHT_SEND_LARGE];
    [amountInputView changeHeight:amountInputView.btcLabel.frame.origin.y + amountInputView.btcLabel.frame.size.height];
    [self.view addSubview:amountInputView];
    ContinueButtonInputAccessoryView *inputAccessoryView = [[ContinueButtonInputAccessoryView alloc] init];
    inputAccessoryView.delegate = self;
    toField.inputAccessoryView = inputAccessoryView;
    self.continuePaymentAccessoryView = inputAccessoryView;
    amountInputView.btcField.inputAccessoryView = inputAccessoryView;
    amountInputView.fiatField.inputAccessoryView = inputAccessoryView;
    amountInputView.btcField.delegate = self;
    amountInputView.fiatField.delegate = self;
    self.amountInputView = amountInputView;
    
    CGFloat useAllButtonOriginY = amountInputView.frame.origin.y + amountInputView.frame.size.height;
    UIButton *fundsAvailableButton = [[UIButton alloc] initWithFrame:CGRectMake(15, useAllButtonOriginY, self.view.frame.size.width - 15 - 8, 112 + ROW_HEIGHT_SEND_LARGE -useAllButtonOriginY)];
    fundsAvailableButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [fundsAvailableButton setTitleColor:COLOR_BLOCKCHAIN_LIGHT_BLUE forState:UIControlStateNormal];
    fundsAvailableButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
    fundsAvailableButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [fundsAvailableButton addTarget:self action:@selector(useAllClicked) forControlEvents:UIControlEventTouchUpInside];
    self.fundsAvailableButton = fundsAvailableButton;
    
    [self.view addSubview:fundsAvailableButton];

    BCLine *lineBelowAmounts = [self offsetLineWithYPosition:112 + ROW_HEIGHT_SEND_LARGE];
    [self.view addSubview:lineBelowAmounts];
    
    UILabel *feeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 112 + ROW_HEIGHT_SEND_LARGE + 15, 40, 21)];
    feeLabel.textColor = COLOR_TEXT_DARK_GRAY;
    feeLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    feeLabel.text = BC_STRING_FEE;
    [self.view addSubview:feeLabel];
    
    UILabel *feeAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(feeLabel.frame.origin.x + feeLabel.frame.size.width + 8, 112 + ROW_HEIGHT_SEND_LARGE + 6, 222, 39)];
    feeAmountLabel.textColor = COLOR_TEXT_DARK_GRAY;
    feeAmountLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    [self.view addSubview:feeAmountLabel];
    self.feeAmountLabel = feeAmountLabel;

    BCLine *lineBelowFee = [self offsetLineWithYPosition:163+ROW_HEIGHT_SEND_LARGE];
    [self.view addSubview:lineBelowFee];
    
    CGFloat sendButtonOriginY = self.view.frame.size.height - BUTTON_HEIGHT - 20;
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(0, sendButtonOriginY, self.view.frame.size.width - 40, BUTTON_HEIGHT)];
    continueButton.center = CGPointMake(self.view.center.x, continueButton.center.y);
    [continueButton setTitle:BC_STRING_CONTINUE forState:UIControlStateNormal];
    continueButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    continueButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    continueButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    self.continuePaymentButton = continueButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getHistory];
}

- (void)keepCurrentPayment
{
    self.shouldKeepCurrentPayment = YES;
}

- (void)reload
{
    if (self.shouldKeepCurrentPayment) {
        self.shouldKeepCurrentPayment = NO;
        [WalletManager.sharedInstance.wallet getEthExchangeRate];
        return;
    }
    
    self.ethAmount = 0;
    self.ethFee = 0;
    self.ethAvailable = 0;
    
    if (![WalletManager.sharedInstance.wallet hasEthAccount]) {
        [self disablePaymentButtons];
        self.amountInputView.userInteractionEnabled = NO;
    } else {
        [self enablePaymentButtons];
        self.amountInputView.userInteractionEnabled = YES;
    }

    [WalletManager.sharedInstance.wallet createNewPayment:LegacyAssetTypeEther];

    if (self.addressToSet) {
        [self selectToAddress:self.addressToSet];
        self.addressToSet = nil;
    } else {
        self.toAddress = nil;
        self.toField.text = nil;
    }
    
    [self.amountInputView clearFields];
    
    [WalletManager.sharedInstance.wallet getEthExchangeRate];
}

- (void)reloadAfterMultiAddressResponse
{
    if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local) {
        self.amountInputView.fiatLabel.text = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.code;
    }
    
    self.displayingLocalSymbolSend = (BlockchainSettings.sharedAppInstance.symbolLocal && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion > 0);
}

- (void)setAddress:(NSString *)address
{
    [self selectToAddress:address];
}

- (void)getHistory
{
    [WalletManager.sharedInstance.wallet getEthHistory];
}

- (void)updateExchangeRate:(NSDecimalNumber *)rate
{
    self.latestExchangeRate = rate;
    
    [self doCurrencyConversion];
    [self updateFeeLabel];
}

- (void)updateFeeLabel
{
    self.feeAmountLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", self.ethFee ? : @0, CURRENCY_SYMBOL_ETH,
                                [NSNumberFormatter formatEthToFiatWithSymbol:[self.ethFee stringValue] exchangeRate:self.latestExchangeRate]];
}

- (void)doCurrencyConversion
{
    [super doCurrencyConversion];
    
    [WalletManager.sharedInstance.wallet changePaymentAmount:self.ethAmount assetType:LegacyAssetTypeEther];
}

- (void)didUpdatePayment:(NSDictionary *)payment;
{
    id dictAmount = payment[DICTIONARY_KEY_AMOUNT];
    id dictAvailable = payment[DICTIONARY_KEY_AVAILABLE];
    id dictFee = payment[DICTIONARY_KEY_FEE];
    BOOL dictSweep = [payment[DICTIONARY_KEY_SWEEP] boolValue];
    
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[dictAmount decimalValue]];
    DLog(@"Amount is %@", amount);
    self.ethAmount = amount;
    
    NSDecimalNumber *available = [NSDecimalNumber decimalNumberWithDecimal:[dictAvailable decimalValue]];
    NSDecimalNumber *fee = [NSDecimalNumber decimalNumberWithDecimal:[dictFee decimalValue]];
    
    if (dictSweep) {
        self.amountInputView.btcField.text = [amount compare:@0] == NSOrderedSame ? nil : [amount stringValue];
        self.amountInputView.fiatField.text = [NSNumberFormatter formatEthToFiat:[amount stringValue] exchangeRate:self.latestExchangeRate localCurrencyFormatter:[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator]];
    }
    
    self.ethAvailable = available;
    
    self.ethFee = fee;
    [self updateFeeLabel];

    if ([WalletManager.sharedInstance.wallet isWaitingOnEtherTransaction]) {
        [self.fundsAvailableButton setTitle:BC_STRING_WAITING_FOR_ETHER_PAYMENT_TO_FINISH_MESSAGE forState:UIControlStateNormal];
        [self.fundsAvailableButton setTitleColor:COLOR_WARNING_RED forState:UIControlStateNormal];
        self.toField.userInteractionEnabled = NO;
        self.fundsAvailableButton.userInteractionEnabled = NO;
        self.amountInputView.userInteractionEnabled = NO;
        [self disablePaymentButtons];
        return;
    } else {
        [self updateFundsAvailable];
        [self.fundsAvailableButton setTitleColor:COLOR_BLOCKCHAIN_LIGHT_BLUE forState:UIControlStateNormal];
        self.toField.userInteractionEnabled = YES;
        self.fundsAvailableButton.userInteractionEnabled = YES;
        self.amountInputView.userInteractionEnabled = YES;
    }
    
    NSComparisonResult result = [available compare:amount];
    
    if (result == NSOrderedDescending || result == NSOrderedSame) {
        [self enablePaymentButtons];
        [self.amountInputView removeHighlightFromAmounts];
    } else {
        [self disablePaymentButtons];
        [self.amountInputView highlightInvalidAmounts];
    }
}

- (void)disablePaymentButtons
{
    self.continuePaymentButton.enabled = NO;
    [self.continuePaymentButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.continuePaymentButton setBackgroundColor:COLOR_BUTTON_KEYPAD_GRAY];
    
    [self.continuePaymentAccessoryView disableContinueButton];
}

- (void)enablePaymentButtons
{
    self.continuePaymentButton.enabled = YES;
    [self.continuePaymentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continuePaymentButton setBackgroundColor:COLOR_BLOCKCHAIN_LIGHT_BLUE];
    
    [self.continuePaymentAccessoryView enableContinueButton];
}

- (void)useAllClicked
{
    [WalletManager.sharedInstance.wallet sweepEtherPayment];
}

- (void)clearFundsAvailable
{
    self.ethAvailable = 0;
    [self updateFundsAvailable];
}

#pragma mark - View Helpers

- (BCLine *)offsetLineWithYPosition:(CGFloat)yPosition
{
    BCLine *line = [[BCLine alloc] initWithYPosition:yPosition];
    [line changeXPosition:15];
    return line;
}

#pragma mark - Continue Button Accessory View Delegate

- (void)continueButtonClicked
{
    self.toAddress = self.toField.text;
    
    if (self.toAddress == nil || self.toAddress.length == 0) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_YOU_MUST_ENTER_DESTINATION_ADDRESS title:BC_STRING_ERROR handler: nil];
        return;
    } else if (![self isEtherAddress:self.toAddress]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[NSString stringWithFormat:BC_STRING_INVALID_ETHER_ADDRESS_ARGUMENT, self.toAddress] title:BC_STRING_ERROR handler: nil];
        return;
    }
    
    if ([self.ethAmount isEqualToNumber:@0]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_INVALID_SEND_VALUE title:BC_STRING_ERROR handler: nil];
        return;
    }
    
    [self checkIfEtherContractAddress:self.toAddress successHandler:^(NSString *nonContractAddress) {
        
        [WalletManager.sharedInstance.wallet changePaymentToAddress:nonContractAddress assetType:LegacyAssetTypeEther];

        NSDecimalNumber *totalDecimalNumber = [self.ethAmount decimalNumberByAdding:self.ethFee];
        
        BCConfirmPaymentViewModel *confirmPaymentViewModel = [[BCConfirmPaymentViewModel alloc]
                                                              initWithTo:self.toAddress
                                                              ethAmount:[NSNumberFormatter formatEth:self.ethAmount]
                                                              ethFee:[NSNumberFormatter formatEth:self.ethFee]
                                                              ethTotal:[NSNumberFormatter formatEth:[NSNumberFormatter truncatedEthAmount:totalDecimalNumber locale:nil]]
                                                              fiatAmount:[NSNumberFormatter appendStringToFiatSymbol:self.amountInputView.fiatField.text]
                                                              fiatFee:[NSNumberFormatter formatEthToFiatWithSymbol:[self.ethFee stringValue] exchangeRate:self.latestExchangeRate]
                                                              fiatTotal:[NSNumberFormatter formatEthToFiatWithSymbol:[NSString stringWithFormat:@"%@", totalDecimalNumber] exchangeRate:self.latestExchangeRate]];
        
        self.confirmPaymentView = [[BCConfirmPaymentView alloc] initWithWindow:self.view.window viewModel:confirmPaymentViewModel sendButtonFrame:self.continuePaymentButton.frame];
        self.confirmPaymentView.confirmDelegate = self;
        
        [self.confirmPaymentView.reallyDoPaymentButton addTarget:self action:@selector(reallyDoPayment) forControlEvents:UIControlEventTouchUpInside];
        [[ModalPresenter sharedInstance] showModalWithContent:self.confirmPaymentView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_CONFIRM_PAYMENT onDismiss:nil onResume:nil];
    }];
}

- (void)closeButtonClicked
{
    [self.toField resignFirstResponder];
    [self.amountInputView.fiatField resignFirstResponder];
    [self.amountInputView.btcField resignFirstResponder];
}

#pragma mark - Actions

- (void)setupNoteForTransaction:(NSString *)note
{
    self.noteToSet = note;
}

- (void)feeInformationButtonClicked
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_FEE_INFORMATION_TITLE message:BC_STRING_FEE_INFORMATION_MESSAGE_ETHER preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:alert animated:YES completion:nil];
}

- (void)reallyDoPayment
{
    if ([[WalletManager sharedInstance].wallet isWaitingOnEtherTransaction]) {
        [[AlertViewPresenter sharedInstance] showWaitingForEtherPaymentAlert];
        return;
    }
    
    UIView *sendView = [[UIView alloc] initWithFrame:self.view.frame];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 60, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    spinner.center = CGPointMake(self.view.center.x, spinner.center.y);
    [spinner startAnimating];
    [sendView addSubview:spinner];
    
    UILabel *sendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 240, 120)];
    sendLabel.textAlignment = NSTextAlignmentCenter;
    sendLabel.center = CGPointMake(self.view.center.x, sendLabel.center.y);
    sendLabel.textColor = COLOR_TEXT_DARK_GRAY;
    sendLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    sendLabel.text = BC_STRING_SENDING;
    [sendView addSubview:sendLabel];
    
    [[ModalPresenter sharedInstance] showModalWithContent:sendView closeType:ModalCloseTypeNone showHeader:true headerText:BC_STRING_SENDING_TRANSACTION onDismiss:nil onResume:nil];

    [WalletManager.sharedInstance.wallet sendEtherPaymentWithNote:self.noteToSet];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
    
    [self updateFundsAvailable];
}

- (void)updateFundsAvailable
{
    NSString *availableAmount;

    if (self.displayingLocalSymbolSend) {
        availableAmount = [NSNumberFormatter formatEthToFiatWithSymbol:[self.ethAvailable stringValue] exchangeRate:self.latestExchangeRate];
    } else {
        availableAmount = [NSNumberFormatter formatEth:self.ethAvailable];
    }
    
    [self.fundsAvailableButton setTitle:[NSString stringWithFormat:BC_STRING_USE_TOTAL_AVAILABLE_MINUS_FEE_ARGUMENT, availableAmount] forState:UIControlStateNormal];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopReadingQRCode) withObject:nil waitUntilDone:NO];
            
            // do something useful with results
            dispatch_sync(dispatch_get_main_queue(), ^{

                NSString *address = [metadataObj stringValue];
                
                if ([address hasPrefix:[ConstantsObjcBridge ethereumUriPrefix]]) address = [address stringByReplacingOccurrencesOfString:[ConstantsObjcBridge ethereumUriPrefix] withString:@""];
                
                [self selectToAddress:address];
                DLog(@"toAddress: %@", address);
                
                self.addressSource = DestinationAddressSourceQR;
            });
        }
    }
}

#pragma mark - Overrides

- (BOOL)isEtherAddress:(NSString *)address
{
    return [WalletManager.sharedInstance.wallet isValidAddress:address assetType:LegacyAssetTypeEther];
}

- (void)selectToAddress:(NSString *)address
{
    if (address == nil || ![self isEtherAddress:address]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[NSString stringWithFormat:BC_STRING_INVALID_ETHER_ADDRESS_ARGUMENT, address] title:BC_STRING_ERROR handler: nil];
        return;
    }
    
    self.toField.text = address;
    self.toAddress = address;
    
    [self checkIfEtherContractAddress:address successHandler:nil];
}

- (void)checkIfEtherContractAddress:(NSString *)address successHandler:(void (^ _Nullable)(NSString *))success
{
    [WalletManager.sharedInstance.wallet isEtherContractAddress:address completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        BOOL isContract = [[[jsonResponse allValues] firstObject] boolValue];
        if (isContract) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_CONTRACT_ADDRESSES_NOT_SUPPORTED_TITLE message:BC_STRING_CONTRACT_ADDRESSES_NOT_SUPPORTED_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction: [UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
            TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
            [tabControllerManager.tabViewController presentViewController:alert animated:YES completion:nil];
        } else {
            if (success) success(address);
        }
    }];
}

@end
