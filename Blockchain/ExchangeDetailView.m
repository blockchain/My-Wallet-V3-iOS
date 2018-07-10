//
//  ExchangeDetailView.m
//  Blockchain
//
//  Created by Maurice A. on 11/20/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeDetailView.h"
#import "ExchangeTrade.h"
#import "BCLine.h"
#import "UIView+ChangeFrameAttribute.h"
#import "NSDateFormatter+VerboseString.h"
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

#define MARGIN_HORIZONTAL 20
#define NUMBER_OF_ROWS_FETCHED_TRADE 6
#define NUMBER_OF_ROWS_BUILT_TRADE 6

@interface ExchangeDetailView ()
@property (nonatomic) NSString *orderID;
@end
@implementation ExchangeDetailView

- (instancetype)initWithFrame:(CGRect)frame fetchedTrade:(ExchangeTrade *)trade
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self changeHeight:NUMBER_OF_ROWS_FETCHED_TRADE * [ExchangeDetailView rowHeight]];
        [self setupPseudoTableWithFetchedTrade:trade];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame builtTrade:(ExchangeTrade *)trade
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self changeHeight:NUMBER_OF_ROWS_BUILT_TRADE * [ExchangeDetailView rowHeight]];
        [self setupPseudoTableWithBuiltTrade:trade];
    }
    return self;
}

- (void)setupPseudoTableWithFetchedTrade:(ExchangeTrade *)trade
{
    // Rendering Logic
    NSString *depositCurrencySymbol = [[trade depositCurrency] uppercaseString];
    NSString *withdrawalCurrencySymbol = [[trade withdrawalCurrency] uppercaseString];
    NSString *depositCurrency = [ExchangeDetailView stringFromSymbol:depositCurrencySymbol];
    NSString *receiveCurrency = [ExchangeDetailView stringFromSymbol:withdrawalCurrencySymbol];
    NSString *depositAmount = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[trade.depositAmount stringValue]], depositCurrencySymbol];
    NSString *withdrawAmount = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[trade.withdrawalAmount stringValue]], withdrawalCurrencySymbol];
    NSString *minerFee = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[trade.minerFee stringValue]], withdrawalCurrencySymbol];

    UIView *rowDeposit = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_DEPOSIT, depositCurrency] accessoryText:depositAmount yPosition:0 accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowDeposit];

    UIView *rowReceive = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_BE_RECEIVED, receiveCurrency] accessoryText:withdrawAmount yPosition:rowDeposit.frame.origin.y + rowDeposit.frame.size.height accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowReceive];

    UIView *rowExchangeRate = [self rowViewWithText:BC_STRING_EXCHANGE_RATE accessoryText:trade.exchangeRateString yPosition:rowReceive.frame.origin.y + rowReceive.frame.size.height accessoryLabelWidthHasPriority:YES];
    [self addSubview:rowExchangeRate];

    UIView *rowTransactionFee = [self rowViewWithText:BC_STRING_TRANSACTION_FEE accessoryText:minerFee yPosition:rowExchangeRate.frame.origin.y + rowExchangeRate.frame.size.height accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowTransactionFee];

    UIView *rowOrderID = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_EXCHANGE_ORDER_ID, @""] accessoryText:trade.orderID yPosition:rowTransactionFee.frame.origin.y + rowTransactionFee.frame.size.height accessoryLabelWidthHasPriority:NO];
    self.orderID = trade.orderID;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(orderIDTapped)];
    [rowOrderID addGestureRecognizer:tapGestureRecognizer];
    rowOrderID.userInteractionEnabled = YES;
    [self addSubview:rowOrderID];
    
    UIView *rowDate = [self rowViewWithText:BC_STRING_DATE accessoryText:[NSDateFormatter verboseStringFromDate:trade.date] yPosition:rowOrderID.frame.origin.y + rowOrderID.frame.size.height accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowDate];

    BCLine *bottomLine = [[BCLine alloc] initWithYPosition:rowDate.frame.origin.y + rowDate.frame.size.height];
    [self addSubview:bottomLine];
}

- (void)setupPseudoTableWithBuiltTrade:(ExchangeTrade *)trade
{
    // Rendering Logic
    NSString *depositCurrencySymbol = [[trade depositCurrency] uppercaseString];
    NSString *withdrawalCurrencySymbol = [[trade withdrawalCurrency] uppercaseString];
    NSString *depositCurrency = [ExchangeDetailView stringFromSymbol:depositCurrencySymbol];
    NSString *receiveCurrency = [ExchangeDetailView stringFromSymbol:withdrawalCurrencySymbol];
    NSString *depositAmount = [NSString stringWithFormat:@"%@ %@",  [NSNumberFormatter localFormattedString:[trade.depositAmount stringValue]], depositCurrencySymbol];
    NSString *withdrawAmount = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[trade.withdrawalAmount stringValue]], withdrawalCurrencySymbol];
    NSString *transactionFee = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[trade.transactionFee stringValue]], depositCurrencySymbol];
    NSString *minerFee = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[trade.minerFee stringValue]], withdrawalCurrencySymbol];
    NSString *totalSpent = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[[trade.depositAmount decimalNumberByAdding:trade.transactionFee] stringValue]], depositCurrencySymbol];
    
    UIView *rowDeposit = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_DEPOSIT, depositCurrency] accessoryText:depositAmount yPosition:0 accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowDeposit];

    UIView *rowTransactionFee = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_TRANSACTION_FEE, depositCurrency] accessoryText:transactionFee yPosition:rowDeposit.frame.origin.y + rowDeposit.frame.size.height accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowTransactionFee];
    
    UIView *rowTotalSpent = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_TOTAL_ARGUMENT_SPENT, depositCurrency] accessoryText:totalSpent yPosition:rowTransactionFee.frame.origin.y + rowTransactionFee.frame.size.height accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowTotalSpent];
    
    UIView *rowExchangeRate = [self rowViewWithText:BC_STRING_EXCHANGE_RATE accessoryText:trade.exchangeRateString yPosition:rowTotalSpent.frame.origin.y + rowTotalSpent.frame.size.height accessoryLabelWidthHasPriority:YES];
    [self addSubview:rowExchangeRate];
    
    UIView *rowNetworkTransactionFee = [self rowViewWithText:BC_STRING_NETWORK_TRANSACTION_FEE accessoryText:minerFee yPosition:rowExchangeRate.frame.origin.y + rowExchangeRate.frame.size.height accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowNetworkTransactionFee];
    
    UIView *rowReceive = [self rowViewWithText:[NSString stringWithFormat:BC_STRING_ARGUMENT_TO_BE_RECEIVED, receiveCurrency] accessoryText:withdrawAmount yPosition:rowNetworkTransactionFee.frame.origin.y + rowNetworkTransactionFee.frame.size.height accessoryLabelWidthHasPriority:NO];
    [self addSubview:rowReceive];
    
    BCLine *bottomLine = [[BCLine alloc] initWithYPosition:rowReceive.frame.origin.y + rowReceive.frame.size.height];
    [self addSubview:bottomLine];
}

- (UIView *)rowViewWithText:(NSString *)text accessoryText:(NSString *)accessoryText yPosition:(CGFloat)posY accessoryLabelWidthHasPriority:(BOOL)accessoryLabelWidthHasPriority
{
    CGFloat horizontalMargin = MARGIN_HORIZONTAL;
    CGFloat rowWidth = UIApplication.sharedApplication.keyWindow.rootViewController.view.frame.size.width;
    CGFloat rowHeight = [ExchangeDetailView rowHeight];
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, posY, rowWidth, rowHeight)];

    CGFloat maxLabelWidth = rowWidth/2 - horizontalMargin;
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, 0, 0, 0)];
    mainLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    mainLabel.textColor = UIColor.gray5;
    mainLabel.text = text;
    [mainLabel sizeToFit];
    [mainLabel changeHeight:rowHeight];
    [rowView addSubview:mainLabel];

    CGFloat labelWidthLeeWay = rowWidth/10;
    if (accessoryLabelWidthHasPriority) {
        
        UILabel *testAccessoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        testAccessoryLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
        testAccessoryLabel.numberOfLines = 0;
        testAccessoryLabel.text = accessoryText;
        [testAccessoryLabel sizeToFit];
        
        if (testAccessoryLabel.frame.size.width > maxLabelWidth + labelWidthLeeWay){
            [mainLabel changeWidth:maxLabelWidth - labelWidthLeeWay];
        } else if (testAccessoryLabel.frame.size.width < maxLabelWidth - labelWidthLeeWay) {
            [mainLabel changeWidth:maxLabelWidth + labelWidthLeeWay];
        } else {
            [mainLabel changeWidth:rowWidth - testAccessoryLabel.frame.size.width - horizontalMargin*2];
        }
    } else {
        if (mainLabel.frame.size.width > maxLabelWidth + labelWidthLeeWay){
            [mainLabel changeWidth:maxLabelWidth + labelWidthLeeWay];
        } else if (mainLabel.frame.size.width < maxLabelWidth - labelWidthLeeWay) {
            [mainLabel changeWidth:maxLabelWidth - labelWidthLeeWay];
        }
    }
    
    CGFloat accessoryLabelOriginX = mainLabel.frame.origin.x + mainLabel.frame.size.width;

    UILabel *accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(accessoryLabelOriginX, 0, self.frame.size.width - accessoryLabelOriginX - horizontalMargin, rowHeight)];
    accessoryLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    accessoryLabel.text = accessoryText;
    accessoryLabel.textColor = UIColor.gray5;
    accessoryLabel.textAlignment = NSTextAlignmentRight;
    accessoryLabel.numberOfLines = 0;
    [rowView addSubview:accessoryLabel];

    BCLine *topLine = [[BCLine alloc] initWithYPosition:posY];
    [self addSubview:topLine];

    return rowView;
}

+ (CGFloat)rowHeight
{
    BOOL isUsingLargeScreenSize = IS_USING_SCREEN_SIZE_LARGER_THAN_5S;
    BOOL isUsing4S = IS_USING_SCREEN_SIZE_4S;
    CGFloat rowHeight = isUsingLargeScreenSize ? 60 : isUsing4S ? 44 : 50;
    return rowHeight;
}

- (void)orderIDTapped
{
    if (self.orderID) {
        [self.delegate orderIDTapped:self.orderID];
    }
}

+ (NSString *)stringFromSymbol:(NSString *)symbol
{
    if ([symbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        return [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin];
    } else if ([symbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        return [AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum];
    } else if ([symbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        return [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash];
    }
    DLog(@"ExchangeDetailView: unsupported symbol!");
    return nil;
}

@end
