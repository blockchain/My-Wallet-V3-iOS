//
//  ReceiveCoinsViewControllerViewController.m
//  Blockchain
//
//  Created by Ben Reeves on 17/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ReceiveBitcoinViewController.h"
#import "ReceiveTableCell.h"
#import "Address.h"
#import "UIViewController+AutoDismiss.h"
#import "QRCodeGenerator.h"
#import "BCAddressSelectionView.h"
#import "BCLine.h"
#import "Blockchain-Swift.h"
#import "UIView+ChangeFrameAttribute.h"
#import "BCTotalAmountView.h"
#import "BCDescriptionView.h"
#import "BCAmountInputView.h"
#import "UILabel+Animations.h"
#import "NSNumberFormatter+Currencies.h"

#define BOTTOM_CONTAINER_HEIGHT_PARTIAL 101
#define BOTTOM_CONTAINER_HEIGHT_FULL 201
#define BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_DEFAULT 226
#define BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_4S 224
#define ESTIMATED_KEYBOARD_PLUS_ACCESSORY_VIEW_HEIGHT 205.5

@interface ReceiveBitcoinViewController() <UIActivityItemSource, AddressSelectionDelegate>
@property (nonatomic) UITextField *lastSelectedField;
@property (nonatomic) QRCodeGenerator *qrCodeGenerator;
@property (nonatomic) uint64_t lastRequestedAmount;
@property (nonatomic) BOOL firstLoading;
@property (nonatomic) BCLine *lineBelowFromField;
@property (nonatomic) BCSecureTextField *descriptionField;
@property (nonatomic) UIView *descriptionContainerView;
@property (nonatomic) BCAmountInputView *amountInputView;
@property (nonatomic) BCDescriptionView *view;

@property (nonatomic) Boolean didClickAccount;
@property (nonatomic) int clickedAccount;

@property (nonatomic) UILabel *mainAddressLabel;

@property (nonatomic) NSString *mainAddress;
@property (nonatomic) NSString *mainLabel;

@property (nonatomic) NSString *detailAddress;
@property (nonatomic) NSString *detailLabel;
@property (nonatomic) CGFloat safeAreaInsetTop;
@end

@implementation ReceiveBitcoinViewController

@synthesize activeKeys;
@dynamic view;

#pragma mark - Lifecycle

- (void)loadView
{
    self.view = [[BCDescriptionView alloc] init];
    if (IS_USING_SCREEN_SIZE_LARGER_THAN_5S) self.view.descriptionCellHeight = BOTTOM_CONTAINER_HEIGHT_FULL - 2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _safeAreaInsetTop = [UIView rootViewSafeAreaInsets].top;
    CGRect frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:YES assetSelector:YES];
    CGFloat offsetY = [ConstantsObjcBridge defaultNavigationBarHeight];
    self.view.frame = CGRectOffset(frame, 0, offsetY);
    
    self.firstLoading = YES;

    [self setupAmountInputAccessoryView];
    [self setupTotalAmountView];
    [self setupBottomViews];
    [self selectDefaultDestination];
    
    CGFloat imageWidth = IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 200 : IS_USING_SCREEN_SIZE_4S ? 120 : 150;
    if (IS_USING_SCREEN_SIZE_4S && self.assetType == LegacyAssetTypeBitcoin) {
        imageWidth = 100;
    }
    
    qrCodeMainImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - imageWidth) / 2, 35, imageWidth, imageWidth)];
    qrCodeMainImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self setupTapGestureForMainQR];
    
    [self reload];
    
    [self setupHeaderView];
    
    self.firstLoading = NO;
    
    [self updateUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self clearAmounts];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideKeyboard];
}

- (QRCodeGenerator *)qrCodeGenerator
{
    if (!_qrCodeGenerator) {
        _qrCodeGenerator = [[QRCodeGenerator alloc] init];
    }
    return _qrCodeGenerator;
}

- (void)setupTotalAmountView
{
    self.view.topView = [[BCTotalAmountView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOTAL_AMOUNT_VIEW_HEIGHT) color:COLOR_BLOCKCHAIN_AQUA amount:0];
    self.view.topView.hidden = YES;
    [self.view addSubview:self.view.topView];
}

- (void)setupAmountInputAccessoryView
{
    amountKeyboardAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, BUTTON_HEIGHT)];
    amountKeyboardAccessoryView.backgroundColor = [UIColor whiteColor];;
    
    BCLine *topLine = [[BCLine alloc] initWithYPosition:0];
    [amountKeyboardAccessoryView addSubview:topLine];
    
    BCLine *bottomLine = [[BCLine alloc] initWithYPosition:BUTTON_HEIGHT - 1];
    [amountKeyboardAccessoryView addSubview:bottomLine];
    
    doneButton = [[UIButton alloc] initWithFrame:CGRectMake(amountKeyboardAccessoryView.frame.size.width - 68, 0, 60, BUTTON_HEIGHT)];
    doneButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:13.0];
    [doneButton setTitleColor:COLOR_BLOCKCHAIN_LIGHT_BLUE forState:UIControlStateNormal];
    [doneButton setTitle:BC_STRING_DONE forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [amountKeyboardAccessoryView addSubview:doneButton];
}

- (UIView *)getTextViewInputAccessoryView
{
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, BUTTON_HEIGHT)];
    inputAccessoryView.backgroundColor = [UIColor whiteColor];;
    
    BCLine *topLine = [[BCLine alloc] initWithYPosition:0];
    [inputAccessoryView addSubview:topLine];
    
    BCLine *bottomLine = [[BCLine alloc] initWithYPosition:BUTTON_HEIGHT];
    [inputAccessoryView addSubview:bottomLine];
    
    UIButton *doneDescriptionButton = [[UIButton alloc] initWithFrame:CGRectMake(inputAccessoryView.frame.size.width - 68, 0, 60, BUTTON_HEIGHT)];
    doneDescriptionButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:13.0];
    [doneDescriptionButton setTitleColor:COLOR_BLOCKCHAIN_LIGHT_BLUE forState:UIControlStateNormal];
    [doneDescriptionButton setTitle:BC_STRING_DONE forState:UIControlStateNormal];
    [doneDescriptionButton addTarget:self action:@selector(endEditingDescription) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:doneDescriptionButton];
    
    return inputAccessoryView;
}

- (void)setupBottomViews
{
    CGFloat containerHeightPlusButtonSpace = IS_USING_SCREEN_SIZE_4S ? BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_4S : BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_DEFAULT;
    
    self.bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.origin.y + self.view.frame.size.height - containerHeightPlusButtonSpace, self.view.frame.size.width, BOTTOM_CONTAINER_HEIGHT_PARTIAL)];
    self.bottomContainerView.clipsToBounds = YES;
    
    CGFloat leftPadding = 0;
    if (self.assetType == LegacyAssetTypeBitcoin) {
        leftPadding = 15;
        BCLine *lineAboveAmounts = [[BCLine alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        lineAboveAmounts.backgroundColor = [ConstantsObjcBridge grayLineColor];
        [self.bottomContainerView addSubview:lineAboveAmounts];
    }

    BCLine *lineBelowAmounts = [[BCLine alloc] initWithFrame:CGRectMake(leftPadding, 50, self.view.frame.size.width - leftPadding, 1)];
    lineBelowAmounts.backgroundColor = [ConstantsObjcBridge grayLineColor];
    [self.bottomContainerView addSubview:lineBelowAmounts];
    
    BCLine *lineBelowToField = [[BCLine alloc] initWithFrame:CGRectMake(0, lineBelowAmounts.frame.origin.y + 50, self.view.frame.size.width, 1)];
    lineBelowToField.backgroundColor = [ConstantsObjcBridge grayLineColor];
    [self.bottomContainerView addSubview:lineBelowToField];
    
    self.lineBelowFromField = [[BCLine alloc] initWithFrame:CGRectMake(0, lineBelowToField.frame.origin.y + 50, self.view.frame.size.width, 1)];
    self.lineBelowFromField.backgroundColor = [ConstantsObjcBridge grayLineColor];
    [self.bottomContainerView addSubview:self.lineBelowFromField];
    
    BCLine *lineBelowDescripton = [[BCLine alloc] initWithFrame:CGRectMake(0, self.lineBelowFromField.frame.origin.y + 50, self.view.frame.size.width, 1)];
    lineBelowDescripton.backgroundColor = [ConstantsObjcBridge grayLineColor];
    [self.bottomContainerView addSubview:lineBelowDescripton];
    
    if (self.assetType == LegacyAssetTypeBitcoin) {
        BCAmountInputView *amountView = [[BCAmountInputView alloc] init];
        amountView.btcLabel.text = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.symbol;
        amountView.btcField.inputAccessoryView = amountKeyboardAccessoryView;
        amountView.btcField.delegate = self;
        amountView.fiatField.inputAccessoryView = amountKeyboardAccessoryView;
        amountView.fiatField.delegate = self;
        [self.bottomContainerView addSubview:amountView];
        self.amountInputView = amountView;
    }

    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 50, 21)];
    toLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    toLabel.textColor = COLOR_TEXT_DARK_GRAY;
    toLabel.text = BC_STRING_TO;
    toLabel.adjustsFontSizeToFitWidth = YES;
    [self.bottomContainerView addSubview:toLabel];
    
    UIButton *selectDestinationButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 35, 60, 35, 30)];
    selectDestinationButton.adjustsImageWhenHighlighted = NO;
    [selectDestinationButton setImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
    [selectDestinationButton addTarget:self action:@selector(selectDestination) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomContainerView addSubview:selectDestinationButton];
    
    self.receiveToLabel = [[UILabel alloc] initWithFrame:CGRectMake(toLabel.frame.origin.x + toLabel.frame.size.width + 16, 65, selectDestinationButton.frame.origin.x - (toLabel.frame.origin.x + toLabel.frame.size.width + 16), 21)];
    self.receiveToLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.receiveToLabel.textColor = COLOR_TEXT_DARK_GRAY;
    [self.bottomContainerView addSubview:self.receiveToLabel];
    UITapGestureRecognizer *tapGestureReceiveTo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectDestination)];
    [self.receiveToLabel addGestureRecognizer:tapGestureReceiveTo];
    self.receiveToLabel.userInteractionEnabled = YES;
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(lineBelowToField.frame.origin.x, lineBelowToField.frame.origin.y + 15, 50, 21)];
    fromLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    fromLabel.textColor = COLOR_TEXT_DARK_GRAY;
    fromLabel.text = BC_STRING_FROM;
    fromLabel.adjustsFontSizeToFitWidth = YES;
    [self.bottomContainerView addSubview:fromLabel];
    
    self.descriptionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.lineBelowFromField.frame.origin.y + self.lineBelowFromField.frame.size.height, self.view.frame.size.width, 49)];
    self.descriptionContainerView.backgroundColor = [UIColor whiteColor];
    self.descriptionContainerView.clipsToBounds = YES;
    self.view.descriptionTextView = [self.view configureTextViewWithFrame:CGRectMake(self.view.frame.size.width/2 + 8, 15, self.view.frame.size.width/2 - 16, self.view.descriptionCellHeight - 30)];
    self.view.descriptionTextView.hidden = YES;
    [self.descriptionContainerView addSubview:self.view.descriptionTextView];
    [self.bottomContainerView addSubview:self.descriptionContainerView];
    
    self.view.descriptionTextView.inputAccessoryView = [self getTextViewInputAccessoryView];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width/2 - 15, 21)];
    descriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    descriptionLabel.textColor = COLOR_TEXT_DARK_GRAY;
    descriptionLabel.text = BC_STRING_DESCRIPTION;
    [self.descriptionContainerView addSubview:descriptionLabel];
    
    self.descriptionField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + 16, 15, self.view.frame.size.width/2 - 16 - 15, 20)];
    self.descriptionField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.descriptionField.textColor = COLOR_TEXT_DARK_GRAY;
    self.descriptionField.textAlignment = NSTextAlignmentRight;
    self.descriptionField.returnKeyType = UIReturnKeyDone;
    self.descriptionField.delegate = self;
    [self.descriptionContainerView addSubview:self.descriptionField];

    CGFloat requestButtonOriginY = self.view.frame.size.height - BUTTON_HEIGHT - 20;
    UIButton *requestButton = [[UIButton alloc] initWithFrame:CGRectMake(0, requestButtonOriginY, self.view.frame.size.width - 40, BUTTON_HEIGHT)];
    requestButton.center = CGPointMake(self.bottomContainerView.center.x, requestButton.center.y);
    [requestButton setTitle:BC_STRING_REQUEST_PAYMENT forState:UIControlStateNormal];
    requestButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    requestButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    requestButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    [requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestButton addTarget:self action:@selector(requestButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestButton];
    
    [doneButton setTitle:BC_STRING_DONE forState:UIControlStateNormal];
    doneButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGesture];

    [self.view addSubview:self.bottomContainerView];
}

- (void)selectDefaultDestination
{
    if ([WalletManager.sharedInstance.wallet didUpgradeToHd]) {
        [self didSelectToAccount:[WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType]];
    } else {
        [self didSelectToAddress:[[WalletManager.sharedInstance.wallet allLegacyAddresses:self.assetType] firstObject]];
    }
}

- (void)setupTapGestureForMainLabel
{
    UITapGestureRecognizer *tapGestureForMainLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainQRClicked:)];
    [self.mainAddressLabel addGestureRecognizer:tapGestureForMainLabel];
    self.mainAddressLabel.userInteractionEnabled = YES;
}

- (void)setupTapGestureForMainQR
{
    UITapGestureRecognizer *tapMainQRGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainQRClicked:)];
    [qrCodeMainImageView addGestureRecognizer:tapMainQRGestureRecognizer];
    qrCodeMainImageView.userInteractionEnabled = YES;
}

- (void)reload
{
    [self reloadAddresses];
    [self reloadLocalAndBtcSymbolsFromLatestResponse];
    
    if (!self.mainAddress) {
        [self reloadMainAddress];
    } else if (self.didClickAccount) {
        [self didSelectFromAccount:self.clickedAccount];
    } else {
        [self updateUI];
    }
}

- (void)reloadAddresses
{
    self.activeKeys = [WalletManager.sharedInstance.wallet activeLegacyAddresses:self.assetType];
}

- (void)reloadLocalAndBtcSymbolsFromLatestResponse
{
    if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc) {
        self.amountInputView.fiatLabel.text = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.code;
        self.amountInputView.btcLabel.text = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.symbol;
    }
}

- (void)reloadMainAddress
{
    // Get an address: the first empty receive address for the default HD account
    // Or the first active legacy address if there are no HD accounts
    if ([WalletManager.sharedInstance.wallet getActiveAccountsCount:self.assetType] > 0) {
        [self didSelectFromAccount:[WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType]];
    }
    else if (activeKeys.count > 0) {
        for (NSString *address in activeKeys) {
            if (![WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:address]) {
                [self didSelectFromAddress:address];
                break;
            }
        }
    }
}

- (void)setupHeaderView
{
    CGFloat headerTopOffset = 10;
    if (_safeAreaInsetTop == 44) {
        headerTopOffset = 60;
    }
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, headerTopOffset, self.view.frame.size.width, self.bottomContainerView.frame.origin.y - headerTopOffset)];
    UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 42)];
    instructionsLabel.textAlignment = NSTextAlignmentCenter;
    instructionsLabel.textColor = COLOR_TEXT_DARK_GRAY;
    instructionsLabel.numberOfLines = 0;
    instructionsLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_SMALL];
    instructionsLabel.text = (IS_USING_SCREEN_SIZE_4S && self.assetType == LegacyAssetTypeBitcoin) ? nil : BC_STRING_RECEIVE_SCREEN_INSTRUCTIONS;
    [instructionsLabel sizeToFit];
    if (instructionsLabel.frame.size.height > 40) [instructionsLabel changeHeight:40];
    instructionsLabel.center = CGPointMake(self.view.frame.size.width/2, instructionsLabel.center.y);
    [self.headerView addSubview:instructionsLabel];
    
    [self.view addSubview:self.headerView];
    
    if ([WalletManager.sharedInstance.wallet getActiveAccountsCount:self.assetType] > 0 || activeKeys.count > 0) {
        
        BOOL isUsing4SScreenSize = IS_USING_SCREEN_SIZE_4S;
        BOOL isUsing5SScreenSize = IS_USING_SCREEN_SIZE_5S;

        qrCodeMainImageView.image = [self.qrCodeGenerator qrImageFromAddress:self.mainAddress];
        
        if (!isUsing4SScreenSize) {
            if (isUsing5SScreenSize) {
                [qrCodeMainImageView changeYPosition:42];
            } else {
                [qrCodeMainImageView changeYPosition:57];
            }
            instructionsLabel.center = CGPointMake(self.headerView.center.x, qrCodeMainImageView.frame.origin.y/2);
        } else {
            [qrCodeMainImageView changeYPosition:instructionsLabel.frame.origin.y + instructionsLabel.frame.size.height + 5];
        }
        
        [self.headerView addSubview:qrCodeMainImageView];
        
        CGFloat yOffset = isUsing4SScreenSize ? 4 : isUsing5SScreenSize ? 8 : 16;
        self.mainAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, qrCodeMainImageView.frame.origin.y + qrCodeMainImageView.frame.size.height + yOffset, self.view.frame.size.width - 40, 20)];
        
        self.mainAddressLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
        self.mainAddressLabel.textAlignment = NSTextAlignmentCenter;
        self.mainAddressLabel.textColor = COLOR_TEXT_DARK_GRAY;;
        [self.mainAddressLabel setMinimumScaleFactor:.5f];
        [self.mainAddressLabel setAdjustsFontSizeToFitWidth:YES];
        [self.headerView addSubview:self.mainAddressLabel];
        
        [self setupTapGestureForMainLabel];
    }
}

#pragma mark - Helpers

- (NSString *)getAddress:(NSIndexPath*)indexPath
{
    NSString *addr = nil;
    
    if ([indexPath section] == 1)
        addr = [activeKeys objectAtIndex:[indexPath row]];
    
    return addr;
}

- (NSString *)uriURL
{
    if (self.assetType == LegacyAssetTypeBitcoinCash) {
        return self.clickedAddress;
    }

    double amount = (double)[self getInputAmountInSatoshi] / SATOSHI;

    NSString *amountString = [[NSNumberFormatter assetFormatterWithUSLocale] stringFromNumber:[NSNumber numberWithDouble:amount]];

    return [NSString stringWithFormat:@"bitcoin://%@?amount=%@", self.clickedAddress, amountString];
}

- (uint64_t)getInputAmountInSatoshi
{
    if ([self shouldUseBtcField]) {
        return [WalletManager.sharedInstance.wallet parseBitcoinValueFromTextField:self.amountInputView.btcField];
    } else {
        NSString *language = self.amountInputView.fiatField.textInputMode.primaryLanguage;
        NSLocale *locale = [language isEqualToString:LOCALE_IDENTIFIER_AR] ? [NSLocale localeWithLocaleIdentifier:language] : [NSLocale currentLocale];
        NSString *requestedAmountString = [self.amountInputView.fiatField.text stringByReplacingOccurrencesOfString:[locale objectForKey:NSLocaleDecimalSeparator] withString:@"."];
        if (![requestedAmountString containsString:@"."]) {
            requestedAmountString = [requestedAmountString stringByReplacingOccurrencesOfString:@"," withString:@"."];
        }
        if (![requestedAmountString containsString:@"."]) {
            requestedAmountString = [requestedAmountString stringByReplacingOccurrencesOfString:@"٫" withString:@"."];
        }
        return WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion * [requestedAmountString doubleValue];
    }
    
    return 0;
}

- (BOOL)shouldUseBtcField
{
    BOOL shouldUseBtcField = YES;
    
    if ([self.amountInputView.btcField isFirstResponder]) {
        shouldUseBtcField = YES;
    } else if ([self.amountInputView.fiatField isFirstResponder]) {
        shouldUseBtcField = NO;
        
    } else if (self.lastSelectedField == self.amountInputView.btcField) {
        shouldUseBtcField = YES;
    } else if (self.lastSelectedField == self.amountInputView.fiatField) {
        shouldUseBtcField = NO;
    }
    
    return shouldUseBtcField;
}

- (void)doCurrencyConversion
{
    [self doCurrencyConversionWithAmount:[self getInputAmountInSatoshi]];
}

- (void)doCurrencyConversionWithAmount:(uint64_t)amount
{
    if ([self shouldUseBtcField]) {
        self.amountInputView.fiatField.text = [NSNumberFormatter formatAmount:amount localCurrency:YES];
    } else {
        self.amountInputView.btcField.text = [NSNumberFormatter formatAmount:amount localCurrency:NO];
    }
}

- (NSString *)getKey:(NSIndexPath*)indexPath
{
    NSString *key;
    
    if ([indexPath section] == 0)
        key = [activeKeys objectAtIndex:[indexPath row]];
    
    return key;
}

- (void)updateAmounts
{
    [self setQRPayment];
    [self setTotalAmountViewAmount];
}

- (void)setQRPayment
{
    uint64_t amount = [self getInputAmountInSatoshi];
    double amountAsDouble = (double)amount / SATOSHI;
        
    UIImage *image;
    if (self.assetType == LegacyAssetTypeBitcoin) {
        image = [self.qrCodeGenerator qrImageFromAddress:self.clickedAddress amount:amountAsDouble];
    } else {
        image = [self.qrCodeGenerator createQRImageFromString:self.clickedAddress];
    }
        
    qrCodeMainImageView.image = image;
    qrCodeMainImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self doCurrencyConversionWithAmount:amount];
}

- (void)setTotalAmountViewAmount
{
    BCTotalAmountView *totalAmountView = (BCTotalAmountView *)self.view.topView;
    [totalAmountView updateLabelsWithAmount:[self getInputAmountInSatoshi]];
}

- (void)changeTopView:(BOOL)shouldShowQR
{
    UIView *viewToHide = shouldShowQR ? self.view.topView : self.headerView;
    UIView *viewToShow = shouldShowQR ? self.headerView : self.view.topView;
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    CGFloat newContainerYPosition = shouldShowQR ? self.view.frame.origin.y + self.view.frame.size.height - (IS_USING_SCREEN_SIZE_4S ? BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_4S : BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_DEFAULT) - tabControllerManager.tabViewController.assetControlContainer.frame.size.height : self.view.topView.frame.size.height;
    
    viewToShow.alpha = 0;
    viewToShow.hidden = NO;
    
    viewToHide.alpha = 1;
    viewToHide.hidden = NO;
    
    CGFloat newContainerHeight = shouldShowQR ? BOTTOM_CONTAINER_HEIGHT_PARTIAL : BOTTOM_CONTAINER_HEIGHT_FULL;
    CGFloat newLineXPosition = shouldShowQR ? 0 : 15;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        viewToHide.alpha = 0;
        [self.bottomContainerView changeYPosition:newContainerYPosition];
        [self.bottomContainerView changeHeight:newContainerHeight];
        [self.lineBelowFromField changeXPosition:newLineXPosition];
    } completion:^(BOOL finished) {
        
        viewToHide.hidden = YES;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            viewToShow.alpha = 1;
        }];
    }];
}

#pragma mark - Asset Agnostic Methods



#pragma mark - Actions

- (IBAction)doneButtonClicked:(UIButton *)sender
{
    [self hideKeyboard];
}

- (IBAction)labelSaveClicked:(id)sender
{
    NSString *label = [labelTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![WalletManager.sharedInstance.wallet didUpgradeToHd]) {
        NSMutableCharacterSet *allowedCharSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [allowedCharSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([label rangeOfCharacterFromSet:[allowedCharSet invertedSet]].location != NSNotFound) {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_LABEL_MUST_BE_ALPHANUMERIC title:BC_STRING_ERROR in:self handler: nil];
            return;
        }
    }

    NSString *addr = self.clickedAddress;
    
    [WalletManager.sharedInstance.wallet setLabel:label forLegacyAddress:addr];
    
    [self reload];
    
    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
    
    if (WalletManager.sharedInstance.wallet.isSyncing) {
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:[LocalizationConstantsObjcBridge syncingWallet]];
    }
}

- (IBAction)mainQRClicked:(id)sender
{
    if ([self.mainAddress isKindOfClass:[NSString class]]) {
        [UIPasteboard generalPasteboard].string = self.mainAddressLabel.text;
        [self.mainAddressLabel animateFromText:[[self.mainAddress componentsSeparatedByString:@":"] lastObject] toIntermediateText:BC_STRING_COPIED_TO_CLIPBOARD speed:1 gestureReceiver:qrCodeMainImageView];
    } else {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_ERROR_COPYING_TO_CLIPBOARD title:BC_STRING_ERROR in:self handler: nil];
    }
}

- (NSString*)formatPaymentRequestWithAmount:(NSString *)amount url:(NSString*)url
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        return [NSString stringWithFormat:BC_STRING_PAYMENT_REQUEST_BITCOIN_ARGUMENT_ARGUMENT, amount, url];
    }
    return [NSString stringWithFormat:BC_STRING_PAYMENT_REQUEST_BITCOIN_CASH_ARGUMENT, url];
}

- (NSString*)formatPaymentRequestHTML:(NSString*)url
{
    return [NSString stringWithFormat:BC_STRING_PAYMENT_REQUEST_HTML, url];
}

- (IBAction)archiveAddressClicked:(id)sender
{
    NSString *addr = self.clickedAddress;
    Boolean isArchived = [WalletManager.sharedInstance.wallet isAddressArchived:addr];
    
    if (isArchived) {
        [WalletManager.sharedInstance.wallet toggleArchiveLegacyAddress:addr];
    }
    else {
        // Need at least one active address
        if (activeKeys.count == 1 && ![WalletManager.sharedInstance.wallet hasAccount]) {
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];

            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_AT_LEAST_ONE_ACTIVE_ADDRESS title:BC_STRING_ERROR in:self handler: nil];
            
            return;
        }
        
        [WalletManager.sharedInstance.wallet toggleArchiveLegacyAddress:addr];
    }
    
    [self reload];
    
    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
}

- (void)hideKeyboardForced
{
    // When backgrounding the app quickly, the input accessory view can remain visible without a first responder, so force the keyboard to appear before dismissing it
    [self.amountInputView.fiatField becomeFirstResponder];
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    [labelTextField resignFirstResponder];
    [self.descriptionField resignFirstResponder];
    [self.amountInputView hideKeyboard];
    
    self.view.scrollEnabled = NO;
    [self.view scrollRectToVisible:CGRectZero animated:YES];
    self.view.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

- (void)alertUserOfPaymentWithMessage:(NSString *)messageString showBackupReminder:(BOOL)showBackupReminder;
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_PAYMENT_RECEIVED message:messageString preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        if (showBackupReminder) {
            [ReminderPresenter.sharedInstance showBackupReminderWithFirstReceive:YES];
        } else if ([self.amountInputView.btcField isFirstResponder] || [self.amountInputView.fiatField isFirstResponder]) {
            [self.lastSelectedField becomeFirstResponder];
        }
        
    }]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)alertUserOfWatchOnlyAddress:(NSString *)address
{
    UIAlertController *alertForWatchOnly = [UIAlertController alertControllerWithTitle:BC_STRING_WARNING_TITLE message:BC_STRING_WATCH_ONLY_RECEIVE_WARNING preferredStyle:UIAlertControllerStyleAlert];
    [alertForWatchOnly addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self didSelectFromAddress:address];
        [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFromLeft];
    }]];
    [alertForWatchOnly addAction:[UIAlertAction actionWithTitle:[LocalizationConstantsObjcBridge dontShowAgain] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_HIDE_WATCH_ONLY_RECEIVE_WARNING];
        [self didSelectFromAddress:address];
        [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFromLeft];
    }]];
    [alertForWatchOnly addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:alertForWatchOnly selector:@selector(autoDismiss) name:ConstantsObjcBridge.notificationKeyReloadToDismissViews object:nil];

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:alertForWatchOnly animated:YES completion:nil];
}

- (void)storeRequestedAmount
{
    self.lastRequestedAmount = [WalletManager.sharedInstance.wallet parseBitcoinValueFromTextField:self.amountInputView.btcField];
}

- (void)updateUI
{
    if (self.firstLoading) return; // UI will be updated when viewDidLoad finishes
    
    if (self.bottomContainerView.frame.origin.y == 0) {
        [self.bottomContainerView changeYPosition:self.view.frame.size.height - BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_4S];
    }

    self.receiveToLabel.text = self.mainLabel;
    self.mainAddressLabel.text = [[self.mainAddress componentsSeparatedByString:@":"] lastObject];
    
    [self updateAmounts];
}

- (void)paymentReceived:(uint64_t)amountReceived showBackupReminder:(BOOL)showBackupReminder
{
    NSString *btcAmountString = self.assetType == LegacyAssetTypeBitcoin ? [NSNumberFormatter formatMoney:amountReceived localCurrency:NO] : [NSNumberFormatter formatBchWithSymbol:amountReceived localCurrency:NO];
    NSString *localCurrencyAmountString = self.assetType == LegacyAssetTypeBitcoin ? [NSNumberFormatter formatMoney:amountReceived localCurrency:YES] : [NSNumberFormatter formatBchWithSymbol:amountReceived localCurrency:YES];

    NSString *paymentMessage;
    if (![localCurrencyAmountString isEqualToString:btcAmountString]) {
        paymentMessage = [NSString stringWithFormat:@"%@\n%@", btcAmountString, localCurrencyAmountString];
    } else {
        paymentMessage = btcAmountString;
    }
    [self alertUserOfPaymentWithMessage:paymentMessage showBackupReminder:showBackupReminder];
}

- (void)selectDestination
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access select to screen when not initialized!");
        return;
    }
    
    [self hideKeyboard];
    
    SelectMode selectMode = SelectModeReceiveTo;
    
    BCAddressSelectionView *addressSelectionView = [[BCAddressSelectionView alloc] initWithWallet:WalletManager.sharedInstance.wallet selectMode:selectMode delegate:self];

    [[ModalPresenter sharedInstance] showModalWithContent:addressSelectionView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_RECEIVE_TO onDismiss:nil onResume:nil];
}

- (void)selectFromClicked
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access request button when not initialized!");
        return;
    }
    
//    BCAddressSelectionView *addressSelectionView = [[BCAddressSelectionView alloc] initWithWallet:WalletManager.sharedInstance.wallet selectMode:SelectModeContact delegate:self];
//    [addressSelectionView reloadTableView];

//    [[ModalPresenter sharedInstance] showModalWithContent:addressSelectionView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_REQUEST_FROM onDismiss:nil onResume:nil];
}

- (void)requestButtonClicked
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access share button when not initialized!");
        return;
    }

    uint64_t amount = [self getInputAmountInSatoshi];
    NSString *amountString = amount > 0 ? [NSNumberFormatter formatMoney:[self getInputAmountInSatoshi] localCurrency:NO] : [BC_STRING_AMOUNT lowercaseString];
    NSString *message = [self formatPaymentRequestWithAmount:amountString url:@""];

    NSURL *url = [NSURL URLWithString:[self uriURL]];

    NSArray *activityItems = @[message, self, url];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];

    activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeOpenInIBooks, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo];

    NSString *assetTitle = (self.assetType == LegacyAssetTypeBitcoin) ? @"Bitcoin" : @"Bitcoin Cash";
    NSString *subject = [NSString stringWithFormat:LocalizationConstantsObjcBridge.xPaymentRequest, assetTitle];
    [activityViewController setValue:subject forKey:@"subject"];

    [self.amountInputView.btcField resignFirstResponder];
    [self.amountInputView.fiatField resignFirstResponder];

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:activityViewController animated:YES completion:nil];
}

- (void)clearAmounts
{
    self.amountInputView.btcField.text = nil;
    self.amountInputView.fiatField.text = nil;
}

- (void)dismiss
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)endEditingDescription
{
    [self.view endEditingDescription];
    
    self.descriptionField.hidden = NO;
    self.view.descriptionTextView.hidden = YES;

    self.descriptionField.text = self.view.note;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self resetDescriptionContainerView];
    }];
}

- (void)resetDescriptionContainerView
{
    [self.descriptionContainerView changeYPosition:self.lineBelowFromField.frame.origin.y + self.lineBelowFromField.frame.size.height];
    [self.descriptionContainerView changeHeight:49];
}

# pragma mark - UITextField delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access Receive textField when not initialized!");
        return NO;
    }
    
    if ([AppCoordinator sharedInstance].slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        return NO;
    }
    
    if (textField == self.amountInputView.fiatField || textField == self.amountInputView.btcField) {
        self.lastSelectedField = textField;
        
        CGFloat additionalSpaceForiPhoneX = (_safeAreaInsetTop == 44) ? 41 : 0;
        self.view.scrollEnabled = YES;
        self.view.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + (self.view.frame.size.height - self.bottomContainerView.frame.origin.y + 50));
        [self.view scrollRectToVisible:CGRectMake(0, self.bottomContainerView.frame.origin.y + self.amountInputView.frame.size.height + ESTIMATED_KEYBOARD_PLUS_ACCESSORY_VIEW_HEIGHT + additionalSpaceForiPhoneX, 1, 1) animated:YES];
    }
    
    if (textField == self.descriptionField) {
        
        [self.view beginEditingDescription];
        [self.view.descriptionTextView becomeFirstResponder];
        self.view.descriptionTextView.hidden = NO;
        self.descriptionField.hidden = YES;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self.descriptionContainerView changeYPosition:1];
            [self.descriptionContainerView changeHeight:self.view.descriptionCellHeight];
        }];

        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == labelTextField) {
        [self labelSaveClicked:nil];
        return YES;
    }

    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.amountInputView.btcField || textField == self.amountInputView.fiatField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray  *points = [newString componentsSeparatedByString:@"."];
        NSLocale *locale = [textField.textInputMode.primaryLanguage isEqualToString:LOCALE_IDENTIFIER_AR] ? [NSLocale localeWithLocaleIdentifier:textField.textInputMode.primaryLanguage] : [NSLocale currentLocale];
        NSArray  *commas = [newString componentsSeparatedByString:[locale objectForKey:NSLocaleDecimalSeparator]];
        
        // Only one comma or point in input field allowed
        if ([points count] > 2 || [commas count] > 2)
            return NO;
        
        // Only 1 leading zero
        if (points.count == 1 || commas.count == 1) {
            if (range.location == 1 && ![string isEqualToString:@"."] && ![string isEqualToString:[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]] && [textField.text isEqualToString:@"0"]) {
                return NO;
            }
        }
        
        // When entering amount in BTC, max 8 decimal places
        if ([self.amountInputView.btcField isFirstResponder]) {
            // Max number of decimal places depends on bitcoin unit
            NSUInteger maxlength = [@(SATOSHI) stringValue].length - [@(SATOSHI / WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion) stringValue].length;
            
            if (points.count == 2) {
                NSString *decimalString = points[1];
                if (decimalString.length > maxlength) {
                    return NO;
                }
            }
            else if (commas.count == 2) {
                NSString *decimalString = commas[1];
                if (decimalString.length > maxlength) {
                    return NO;
                }
            }
        }
        
        // Fiat currencies have a max of 3 decimal places, most of them actually only 2. For now we will use 2.
        else if ([self.amountInputView.fiatField isFirstResponder]) {
            if (points.count == 2) {
                NSString *decimalString = points[1];
                if (decimalString.length > 2) {
                    return NO;
                }
            }
            else if (commas.count == 2) {
                NSString *decimalString = commas[1];
                if (decimalString.length > 2) {
                    return NO;
                }
            }
        }
        
        uint64_t amountInSatoshi = 0;

        if (textField == self.amountInputView.fiatField) {
            // Convert input amount to internal value
            NSString *amountString = [newString stringByReplacingOccurrencesOfString:@"," withString:@"."];
            if (![amountString containsString:@"."]) {
                amountString = [newString stringByReplacingOccurrencesOfString:@"٫" withString:@"."];
            }
            amountInSatoshi = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion * [amountString doubleValue];
        }
        else {
            amountInSatoshi = [WalletManager.sharedInstance.wallet parseBitcoinValueFromString:newString];
        }
        
        if (amountInSatoshi > BTC_LIMIT_IN_SATOSHI) {
            return NO;
        } else {
            [self performSelector:@selector(updateAmounts) withObject:nil afterDelay:0.1f];
            return YES;
        }
    } else {
        return YES;
    }
}

#pragma mark - UIActivityItemSource Delegate

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if (activityType == UIActivityTypePostToTwitter) {
        return nil;
    } else {
        return qrCodeMainImageView.image;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

#pragma mark - BCAddressSelectionView Delegate

- (LegacyAssetType)getAssetType
{
    return self.assetType;
}

- (void)didSelectFromAddress:(NSString*)address
{
    self.mainAddress = address;
    NSString *addr = self.mainAddress;
    NSString *label = [WalletManager.sharedInstance.wallet labelForLegacyAddress:addr assetType:self.assetType];
    
    self.clickedAddress = addr;
    self.didClickAccount = NO;
    
    if (label.length > 0) {
        self.mainLabel = label;
    } else {
        self.mainLabel = addr;
    }
    
    [self updateUI];
}

- (void)didSelectToAddress:(NSString*)address
{
    [self didSelectFromAddress:address];
}

- (void)didSelectFromAccount:(int)account assetType:(LegacyAssetType)asset
{
    [self didSelectFromAccount:account];
}

- (void)didSelectFromAccount:(int)account
{
    self.mainAddress = [WalletManager.sharedInstance.wallet getReceiveAddressForAccount:account assetType:self.assetType];
    self.clickedAddress = self.mainAddress;
    self.clickedAccount = account;
    self.didClickAccount = YES;
    
    self.mainLabel = [WalletManager.sharedInstance.wallet getLabelForAccount:account assetType:self.assetType];
    
    [self updateUI];
}

- (void)didSelectToAccount:(int)account assetType:(LegacyAssetType)asset
{
    [self didSelectToAccount:account];
}

- (void)didSelectToAccount:(int)account
{
    [self didSelectFromAccount:account];
}

- (void)didSelectWatchOnlyAddress:(NSString *)address
{
    [self alertUserOfWatchOnlyAddress:address];
}

@end
