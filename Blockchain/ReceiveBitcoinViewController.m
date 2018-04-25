//
//  ReceiveCoinsViewControllerViewController.m
//  Blockchain
//
//  Created by Ben Reeves on 17/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ReceiveBitcoinViewController.h"
#import "RootService.h"
#import "ReceiveTableCell.h"
#import "Address.h"
#import "PrivateKeyReader.h"
#import "UIViewController+AutoDismiss.h"
#import "QRCodeGenerator.h"
#import "BCAddressSelectionView.h"
#import "BCLine.h"
#import "Blockchain-Swift.h"
#import "BCContactRequestView.h"
#import "Contact.h"
#import "UIView+ChangeFrameAttribute.h"
#import "BCTotalAmountView.h"
#import "BCDescriptionView.h"
#import "BCAmountInputView.h"
#import "UILabel+Animations.h"
#import "Blockchain-Swift.h"

#ifdef ENABLE_CONTACTS
#define BOTTOM_CONTAINER_HEIGHT_PARTIAL 151
#else
#define BOTTOM_CONTAINER_HEIGHT_PARTIAL 101
#endif
#define BOTTOM_CONTAINER_HEIGHT_FULL 201
#define BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_DEFAULT 220
#define BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_4S 210
#define ESTIMATED_KEYBOARD_PLUS_ACCESSORY_VIEW_HEIGHT 205.5

@interface ReceiveBitcoinViewController() <UIActivityItemSource, AddressSelectionDelegate>
@property (nonatomic) UITextField *lastSelectedField;
@property (nonatomic) QRCodeGenerator *qrCodeGenerator;
@property (nonatomic) uint64_t lastRequestedAmount;
@property (nonatomic) BOOL firstLoading;
@property (nonatomic) BCNavigationController *contactRequestNavigationController;
@property (nonatomic) Contact *fromContact;
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
    
    self.firstLoading = YES;
    
    self.view.frame = CGRectMake(0,
                                 DEFAULT_HEADER_HEIGHT_OFFSET,
                                 [UIScreen mainScreen].bounds.size.width,
                                 [UIScreen mainScreen].bounds.size.height - DEFAULT_HEADER_HEIGHT - DEFAULT_HEADER_HEIGHT_OFFSET - DEFAULT_FOOTER_HEIGHT);
    
    [self setupAmountInputAccessoryView];
    [self setupTotalAmountView];
    [self setupBottomViews];
    [self selectDefaultDestination];
    
    CGFloat imageWidth = IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 200 : IS_USING_SCREEN_SIZE_4S ? 120 : 150;
    
    qrCodeMainImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - imageWidth) / 2, 35, imageWidth, imageWidth)];
    qrCodeMainImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self setupTapGestureForMainQR];
    
    [self reload];
    
    [self setupHeaderView];
    
    self.firstLoading = NO;
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    app.mainTitleLabel.text = BC_STRING_REQUEST;
    
    self.view.frame = CGRectMake(0,
                                 DEFAULT_HEADER_HEIGHT_OFFSET,
                                 [UIScreen mainScreen].bounds.size.width,
                                 [UIScreen mainScreen].bounds.size.height - DEFAULT_HEADER_HEIGHT - DEFAULT_HEADER_HEIGHT_OFFSET - DEFAULT_FOOTER_HEIGHT);
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
    [self.view addSubview:self.bottomContainerView];
    
    CGFloat leftPadding = 0;
    if (self.assetType == AssetTypeBitcoin) {
        leftPadding = 15;
        BCLine *lineAboveAmounts = [[BCLine alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        lineAboveAmounts.backgroundColor = COLOR_LINE_GRAY;
        [self.bottomContainerView addSubview:lineAboveAmounts];
    }

    BCLine *lineBelowAmounts = [[BCLine alloc] initWithFrame:CGRectMake(leftPadding, 50, self.view.frame.size.width - leftPadding, 1)];
    lineBelowAmounts.backgroundColor = COLOR_LINE_GRAY;
    [self.bottomContainerView addSubview:lineBelowAmounts];
    
    BCLine *lineBelowToField = [[BCLine alloc] initWithFrame:CGRectMake(0, lineBelowAmounts.frame.origin.y + 50, self.view.frame.size.width, 1)];
    lineBelowToField.backgroundColor = COLOR_LINE_GRAY;
    [self.bottomContainerView addSubview:lineBelowToField];
    
    self.lineBelowFromField = [[BCLine alloc] initWithFrame:CGRectMake(0, lineBelowToField.frame.origin.y + 50, self.view.frame.size.width, 1)];
    self.lineBelowFromField.backgroundColor = COLOR_LINE_GRAY;
    [self.bottomContainerView addSubview:self.lineBelowFromField];
    
    BCLine *lineBelowDescripton = [[BCLine alloc] initWithFrame:CGRectMake(0, self.lineBelowFromField.frame.origin.y + 50, self.view.frame.size.width, 1)];
    lineBelowDescripton.backgroundColor = COLOR_LINE_GRAY;
    [self.bottomContainerView addSubview:lineBelowDescripton];
    
    if (self.assetType == AssetTypeBitcoin) {
        BCAmountInputView *amountView = [[BCAmountInputView alloc] init];
        amountView.btcLabel.text = app.latestResponse.symbol_btc.symbol;
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
    
    self.receiveFromLabel = [[UILabel alloc] initWithFrame:CGRectMake(fromLabel.frame.origin.x + fromLabel.frame.size.width + 16, lineBelowToField.frame.origin.y + 15, selectDestinationButton.frame.origin.x - (fromLabel.frame.origin.x + fromLabel.frame.size.width + 16), 21)];
    self.receiveFromLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.receiveFromLabel.textColor = COLOR_LIGHT_GRAY;
    self.receiveFromLabel.text = BC_STRING_SELECT_CONTACT;
    [self.bottomContainerView addSubview:self.receiveFromLabel];
    UITapGestureRecognizer *tapGestureReceiveFrom = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectFromClicked)];
    [self.receiveFromLabel addGestureRecognizer:tapGestureReceiveFrom];
    self.receiveFromLabel.userInteractionEnabled = YES;
    
    self.selectFromButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 35,  lineBelowToField.frame.origin.y + 10, 35, 30)];
    self.selectFromButton.adjustsImageWhenHighlighted = NO;
    [self.selectFromButton setImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
    [self.selectFromButton addTarget:self action:@selector(selectFromClicked) forControlEvents:UIControlEventTouchUpInside];
    self.selectFromButton.hidden = YES;
    [self.bottomContainerView addSubview:self.selectFromButton];
    
    CGFloat whatsThisButtonWidth = IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 120 : 100;
    self.whatsThisButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - whatsThisButtonWidth, lineBelowToField.frame.origin.y + 15, whatsThisButtonWidth, 21)];
    self.whatsThisButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    [self.whatsThisButton setTitleColor:COLOR_BLOCKCHAIN_LIGHT_BLUE forState:UIControlStateNormal];
    [self.whatsThisButton setTitle:BC_STRING_WHATS_THIS forState:UIControlStateNormal];
    [self.whatsThisButton addTarget:self action:@selector(whatsThisButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomContainerView addSubview:self.whatsThisButton];
    
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
    
    CGFloat spacing = 12;
    CGFloat requestButtonOriginY = self.view.frame.size.height - BUTTON_HEIGHT - spacing;
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
}

- (void)selectDefaultDestination
{
    if ([app.wallet didUpgradeToHd]) {
        [self didSelectToAccount:[app.wallet getDefaultAccountIndexForAssetType:self.assetType]];
    } else {
        [self didSelectToAddress:[[app.wallet allLegacyAddresses:self.assetType] firstObject]];
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
#ifdef ENABLE_CONTACTS
    [self resetContactInfo];
#endif
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
    self.activeKeys = [app.wallet activeLegacyAddresses:self.assetType];
}

- (void)resetContactInfo
{
    [self didSelectContact:nil];
    
    self.view.note = nil;
    self.descriptionField.text = nil;
}

- (void)reloadLocalAndBtcSymbolsFromLatestResponse
{
    if (app.latestResponse.symbol_local && app.latestResponse.symbol_btc) {
        self.amountInputView.fiatLabel.text = app.latestResponse.symbol_local.code;
        self.amountInputView.btcLabel.text = app.latestResponse.symbol_btc.symbol;
    }
}

- (void)reloadMainAddress
{
    // Get an address: the first empty receive address for the default HD account
    // Or the first active legacy address if there are no HD accounts
    if ([app.wallet getActiveAccountsCount:self.assetType] > 0) {
        [self didSelectFromAccount:[app.wallet getDefaultAccountIndexForAssetType:self.assetType]];
    }
    else if (activeKeys.count > 0) {
        for (NSString *address in activeKeys) {
            if (![app.wallet isWatchOnlyLegacyAddress:address]) {
                [self didSelectFromAddress:address];
                break;
            }
        }
    }
}

- (void)setupHeaderView
{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.bottomContainerView.frame.origin.y)];
    
    if (!(IS_USING_SCREEN_SIZE_4S) && self.assetType == AssetTypeBitcoinCash) {
        self.headerView.center = CGPointMake(self.headerView.center.x, (self.bottomContainerView.frame.origin.y + AMOUNT_INPUT_VIEW_HEIGHT)/2);
    }
    
    UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 42)];
    instructionsLabel.textAlignment = NSTextAlignmentCenter;
    instructionsLabel.textColor = COLOR_TEXT_DARK_GRAY;
    instructionsLabel.numberOfLines = 0;
    instructionsLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_SMALL];
    instructionsLabel.text = IS_USING_SCREEN_SIZE_4S ? nil : BC_STRING_RECEIVE_SCREEN_INSTRUCTIONS;
    [instructionsLabel sizeToFit];
    if (instructionsLabel.frame.size.height > 40) [instructionsLabel changeHeight:40];
    instructionsLabel.center = CGPointMake(self.view.frame.size.width/2, instructionsLabel.center.y);
    [self.headerView addSubview:instructionsLabel];
    
    [self.view addSubview:self.headerView];
    
    if ([app.wallet getActiveAccountsCount:self.assetType] > 0 || activeKeys.count > 0) {
        
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
            [qrCodeMainImageView changeYPosition:0];
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
    if (self.assetType == AssetTypeBitcoinCash) {
        return self.clickedAddress;
    }

    double amount = (double)[self getInputAmountInSatoshi] / SATOSHI;
    
    app.btcFormatter.usesGroupingSeparator = NO;
    NSLocale *currentLocale = app.btcFormatter.locale;
    app.btcFormatter.locale = [NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US];
    NSString *amountString = [app.btcFormatter stringFromNumber:[NSNumber numberWithDouble:amount]];
    app.btcFormatter.locale = currentLocale;
    app.btcFormatter.usesGroupingSeparator = YES;
    
    return [NSString stringWithFormat:@"bitcoin://%@?amount=%@", self.clickedAddress, amountString];
}

- (uint64_t)getInputAmountInSatoshi
{
    if ([self shouldUseBtcField]) {
        return [app.wallet parseBitcoinValueFromTextField:self.amountInputView.btcField];
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
        return app.latestResponse.symbol_local.conversion * [requestedAmountString doubleValue];
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
    if (self.assetType == AssetTypeBitcoin) {
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
    
    if (![app.wallet didUpgradeToHd]) {
        NSMutableCharacterSet *allowedCharSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [allowedCharSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([label rangeOfCharacterFromSet:[allowedCharSet invertedSet]].location != NSNotFound) {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_LABEL_MUST_BE_ALPHANUMERIC title:BC_STRING_ERROR];
            return;
        }
    }

    NSString *addr = self.clickedAddress;
    
    [app.wallet setLabel:label forLegacyAddress:addr];
    
    [self reload];
    
    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
    
    if (app.wallet.isSyncing) {
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];
    }
}

- (IBAction)mainQRClicked:(id)sender
{
    if ([self.mainAddress isKindOfClass:[NSString class]]) {
        [UIPasteboard generalPasteboard].string = self.mainAddressLabel.text;
        [self.mainAddressLabel animateFromText:[[self.mainAddress componentsSeparatedByString:@":"] lastObject] toIntermediateText:BC_STRING_COPIED_TO_CLIPBOARD speed:1 gestureReceiver:qrCodeMainImageView];
    } else {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_ERROR_COPYING_TO_CLIPBOARD title:BC_STRING_ERROR];
    }
}

- (NSString*)formatPaymentRequestWithAmount:(NSString *)amount url:(NSString*)url
{
    if (self.assetType == AssetTypeBitcoin) {
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
    Boolean isArchived = [app.wallet isAddressArchived:addr];
    
    if (isArchived) {
        [app.wallet toggleArchiveLegacyAddress:addr];
    }
    else {
        // Need at least one active address
        if (activeKeys.count == 1 && ![app.wallet hasAccount]) {
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];

            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_AT_LEAST_ONE_ACTIVE_ADDRESS title:BC_STRING_ERROR];
            
            return;
        }
        
        [app.wallet toggleArchiveLegacyAddress:addr];
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
            [app showBackupReminder:YES];
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
    [alertForWatchOnly addAction:[UIAlertAction actionWithTitle:BC_STRING_DONT_SHOW_AGAIN style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_HIDE_WATCH_ONLY_RECEIVE_WARNING];
        [self didSelectFromAddress:address];
        [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFromLeft];
    }]];
    [alertForWatchOnly addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:alertForWatchOnly selector:@selector(autoDismiss) name:NOTIFICATION_KEY_RELOAD_TO_DISMISS_VIEWS object:nil];

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:alertForWatchOnly animated:YES completion:nil];
}

- (void)storeRequestedAmount
{
    self.lastRequestedAmount = [app.wallet parseBitcoinValueFromTextField:self.amountInputView.btcField];
}

- (void)updateUI
{
    if (self.firstLoading) return; // UI will be updated when viewDidLoad finishes
    
    if (self.bottomContainerView.frame.origin.y == 0) {
        [self.bottomContainerView changeYPosition:self.view.frame.size.height - BOTTOM_CONTAINER_HEIGHT_PLUS_BUTTON_SPACE_4S];
    }
    
    if (app.wallet.contacts.count > 0) {
        self.selectFromButton.hidden = NO;
        self.whatsThisButton.hidden = YES;
    } else {
        self.selectFromButton.hidden = YES;
        self.whatsThisButton.hidden = NO;
    }
    
    self.receiveToLabel.text = self.mainLabel;
    self.mainAddressLabel.text = [[self.mainAddress componentsSeparatedByString:@":"] lastObject];
    
    [self updateAmounts];
}

- (void)paymentReceived:(uint64_t)amountReceived showBackupReminder:(BOOL)showBackupReminder
{
    NSString *btcAmountString = self.assetType == AssetTypeBitcoin ? [NSNumberFormatter formatMoney:amountReceived localCurrency:NO] : [NSNumberFormatter formatBchWithSymbol:amountReceived localCurrency:NO];
    NSString *localCurrencyAmountString = self.assetType == AssetTypeBitcoin ? [NSNumberFormatter formatMoney:amountReceived localCurrency:YES] : [NSNumberFormatter formatBchWithSymbol:amountReceived localCurrency:YES];
    [self alertUserOfPaymentWithMessage:[[NSString alloc] initWithFormat:@"%@\n%@", btcAmountString, localCurrencyAmountString] showBackupReminder:showBackupReminder];
}

- (void)selectDestination
{
    if (![app.wallet isInitialized]) {
        DLog(@"Tried to access select to screen when not initialized!");
        return;
    }
    
    [self hideKeyboard];
    
    SelectMode selectMode = self.fromContact ? SelectModeReceiveFromContact : SelectModeReceiveTo;
    
    BCAddressSelectionView *addressSelectionView = [[BCAddressSelectionView alloc] initWithWallet:app.wallet selectMode:selectMode delegate:self];

    [[ModalPresenter sharedInstance] showModalWithContent:addressSelectionView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_RECEIVE_TO onDismiss:nil onResume:nil];
}

- (void)whatsThisButtonClicked
{
    UIView *introducingContactsView = [[UIView alloc] initWithFrame:self.view.frame];
    introducingContactsView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_LARGE];
    titleLabel.textColor = COLOR_BLOCKCHAIN_MEDIUM_BLUE;
    titleLabel.text = BC_STRING_INTRODUCING_CONTACTS_TITLE;
    [titleLabel sizeToFit];
    titleLabel.center = introducingContactsView.center;
    [introducingContactsView addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, titleLabel.frame.origin.y - 100, introducingContactsView.frame.size.width - 50, 100)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"contacts_splash"];
    [introducingContactsView addSubview:imageView];
    
    float onePixelHeight = 1.0/[UIScreen mainScreen].scale;
    UIView *onePixelLine = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 16, introducingContactsView.frame.size.width - 50, onePixelHeight)];
    onePixelLine.center = CGPointMake(introducingContactsView.center.x, onePixelLine.center.y);
    onePixelLine.backgroundColor = COLOR_LINE_GRAY;
    [introducingContactsView addSubview:onePixelLine];
    
    UILabel *descriptionLabelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, onePixelLine.frame.origin.y + 16, self.view.frame.size.width - 30, 0)];
    descriptionLabelTop.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    descriptionLabelTop.textColor = COLOR_TEXT_GRAY;
    descriptionLabelTop.textAlignment = NSTextAlignmentCenter;
    descriptionLabelTop.numberOfLines = 0;
    descriptionLabelTop.textColor = COLOR_LIGHT_GRAY;
    descriptionLabelTop.text = BC_STRING_INTRODUCING_CONTACTS_DESCRIPTION_TOP;
    [descriptionLabelTop sizeToFit];
    descriptionLabelTop.center = CGPointMake(introducingContactsView.center.x, descriptionLabelTop.center.y);
    [introducingContactsView addSubview:descriptionLabelTop];
    
    UILabel *descriptionLabelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, descriptionLabelTop.frame.origin.y + descriptionLabelTop.frame.size.height + 8, 0, 0)];
    descriptionLabelBottom.font = descriptionLabelTop.font;
    descriptionLabelBottom.textColor = COLOR_DARK_GRAY;
    descriptionLabelBottom.text = BC_STRING_INTRODUCING_CONTACTS_DESCRIPTION_BOTTOM;
    [descriptionLabelBottom sizeToFit];
    descriptionLabelBottom.center = CGPointMake(introducingContactsView.center.x, descriptionLabelBottom.center.y);
    [introducingContactsView addSubview:descriptionLabelBottom];

    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(15, [UIApplication sharedApplication].keyWindow.frame.size.height - BUTTON_HEIGHT - 16, introducingContactsView.frame.size.width - 30, BUTTON_HEIGHT)];
    [dismissButton setTitle:BC_STRING_ILL_DO_THIS_LATER forState:UIControlStateNormal];
    [dismissButton setTitleColor:COLOR_MEDIUM_GRAY forState:UIControlStateNormal];
    dismissButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    dismissButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [introducingContactsView addSubview:dismissButton];
    
    UIButton *getStartedButton = [[UIButton alloc] initWithFrame:CGRectMake(15, dismissButton.frame.origin.y - dismissButton.frame.size.height - 8, introducingContactsView.frame.size.width - 30, BUTTON_HEIGHT)];
    getStartedButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    [getStartedButton setTitle:BC_STRING_GET_STARTED forState:UIControlStateNormal];
    getStartedButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    getStartedButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [getStartedButton addTarget:self action:@selector(showContacts) forControlEvents:UIControlEventTouchUpInside];
    [introducingContactsView addSubview:getStartedButton];
    
    BCModalViewController *modalViewController = [BCModalViewController new];
    modalViewController.view = introducingContactsView;
    
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleDefault;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:modalViewController animated:YES completion:nil];
}

- (void)selectFromClicked
{
    if (![app.wallet isInitialized]) {
        DLog(@"Tried to access request button when not initialized!");
        return;
    }
    
    BCAddressSelectionView *addressSelectionView = [[BCAddressSelectionView alloc] initWithWallet:app.wallet selectMode:SelectModeContact delegate:self];
    addressSelectionView.previouslySelectedContact = self.fromContact;
    [addressSelectionView reloadTableView];

    [[ModalPresenter sharedInstance] showModalWithContent:addressSelectionView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_REQUEST_FROM onDismiss:nil onResume:nil];
}

- (void)requestButtonClicked
{
    if (self.fromContact) {
        
        uint64_t amount = [self getInputAmountInSatoshi];
        
        if (amount == 0) {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_INVALID_SEND_VALUE title:BC_STRING_ERROR];
            return;
        }
        
        id accountOrAddress;
        if (self.didClickAccount) {
            accountOrAddress = [NSNumber numberWithInt:self.clickedAccount];
        } else {
            accountOrAddress = self.clickedAddress;

        }

        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_REQUEST];
        [app.wallet sendPaymentRequest:self.fromContact.identifier amount:amount requestId:nil note:self.view.note initiatorSource:accountOrAddress];
    } else {
        [self share];
    }
}

- (void)share
{
    if (![app.wallet isInitialized]) {
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

    [activityViewController setValue:BC_STRING_PAYMENT_REQUEST_BITCOIN_SUBJECT forKey:@"subject"];
    
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

- (void)showContacts
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
        [app contactsClicked:nil];
    }];
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
    if (![app.wallet isInitialized]) {
        DLog(@"Tried to access Receive textField when not initialized!");
        return NO;
    }
    
    if ([AppCoordinator sharedInstance].slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        return NO;
    }
    
    if (textField == self.amountInputView.fiatField || textField == self.amountInputView.btcField) {
        self.lastSelectedField = textField;
        
        self.view.scrollEnabled = YES;
        self.view.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + (self.view.frame.size.height - self.bottomContainerView.frame.origin.y + 50));
        [self.view scrollRectToVisible:CGRectMake(0, self.bottomContainerView.frame.origin.y + self.amountInputView.frame.size.height + ESTIMATED_KEYBOARD_PLUS_ACCESSORY_VIEW_HEIGHT, 1, 1) animated:YES];
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
            NSUInteger maxlength = [@(SATOSHI) stringValue].length - [@(SATOSHI / app.latestResponse.symbol_btc.conversion) stringValue].length;
            
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
            amountInSatoshi = app.latestResponse.symbol_local.conversion * [amountString doubleValue];
        }
        else {
            amountInSatoshi = [app.wallet parseBitcoinValueFromString:newString];
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

- (AssetType)getAssetType
{
    return self.assetType;
}

- (void)didSelectFromAddress:(NSString*)address
{
    self.mainAddress = address;
    NSString *addr = self.mainAddress;
    NSString *label = [app.wallet labelForLegacyAddress:addr assetType:self.assetType];
    
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

- (void)didSelectFromAccount:(int)account assetType:(AssetType)asset
{
    [self didSelectFromAccount:account];
}

- (void)didSelectFromAccount:(int)account
{
    self.mainAddress = [app.wallet getReceiveAddressForAccount:account assetType:self.assetType];
    self.clickedAddress = self.mainAddress;
    self.clickedAccount = account;
    self.didClickAccount = YES;
    
    self.mainLabel = [app.wallet getLabelForAccount:account assetType:self.assetType];
    
    [self updateUI];
}

- (void)didSelectToAccount:(int)account assetType:(AssetType)asset
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

- (void)didSelectContact:(Contact *)contact
{
    if (contact && !contact.mdid) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:BC_STRING_CONTACT_ARGUMENT_HAS_NOT_ACCEPTED_INVITATION_YET, contact.name] message:[NSString stringWithFormat:BC_STRING_CONTACT_ARGUMENT_MUST_ACCEPT_INVITATION, contact.name] preferredStyle:UIAlertControllerStyleAlert];
        [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
        TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
        [tabControllerManager.tabViewController presentViewController:errorAlert animated:YES completion:nil];
    } else if (contact == self.fromContact || contact == nil) {
        self.fromContact = nil;
        self.receiveFromLabel.text = BC_STRING_SELECT_CONTACT_OPTIONAL;
        self.receiveFromLabel.textColor = COLOR_LIGHT_GRAY;

        [self changeTopView:YES];
        
    } else {
        [[ModalPresenter sharedInstance] closeAllModals];
        
        self.descriptionField.placeholder = [NSString stringWithFormat:BC_STRING_SHARED_WITH_CONTACT_NAME_ARGUMENT, contact.name];
        self.fromContact = contact;
        self.receiveFromLabel.text = contact.name;
        self.receiveFromLabel.textColor = COLOR_TEXT_DARK_GRAY;
        
        if (self.view.topView.hidden) {
            [self changeTopView:NO];
        }
    }
    
    [self resetDescriptionContainerView];
}

@end
