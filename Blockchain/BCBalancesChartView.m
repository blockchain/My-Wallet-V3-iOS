//
//  BCBalancesChartView.m
//  Blockchain
//
//  Created by kevinwu on 2/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCBalancesChartView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "BCBalanceChartLegendKeyView.h"
#import "Blockchain-Swift.h"
#import "NSNumberFormatter+Currencies.h"
#import "BCLine.h"

#define CHART_VIEW_BOTTOM_PADDING 16
#define CONTAINER_VIEW_HORIZONTAL_PADDING 20

@import Charts;

@interface BCBalancesChartView ()
@property (nonatomic) NSString *fiatSymbol;
@property (nonatomic) BalanceChartViewModel *bitcoin;
@property (nonatomic) BalanceChartViewModel *ether;
@property (nonatomic) BalanceChartViewModel *bitcoinCash;

@property (nonatomic) PieChartView *chartView;
@property (nonatomic) BCBalanceChartLegendKeyView *bitcoinLegendKey;
@property (nonatomic) BCBalanceChartLegendKeyView *etherLegendKey;
@property (nonatomic) BCBalanceChartLegendKeyView *bitcoinCashLegendKey;
@property (nonatomic) UIView *legendKeyContainerView;
@property (nonatomic) BCLine *lineSeparator;
@property (nonatomic) WatchOnlyBalanceView *watchOnlyBalanceView;

@property (nonatomic) CGFloat defaultHeight;
@end

@implementation BCBalancesChartView

- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChartViewWithFrame:frame];
        [self setupLegendWithFrame:frame];
        [self setupLineSeparator];
        self.defaultHeight = self.bounds.size.height;
    }
    
    return self;
}

- (void)setupChartViewWithFrame:(CGRect)frame
{
    self.chartView = [[PieChartView alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 210)];
    self.chartView.drawCenterTextEnabled = YES;
    self.chartView.drawHoleEnabled = YES;
    self.chartView.holeColor = [UIColor clearColor];
    self.chartView.holeRadiusPercent = 0.7;
    [self.chartView animateWithYAxisDuration:0.5];
    self.chartView.rotationEnabled = NO;
    self.chartView.legend.enabled = NO;
    self.chartView.chartDescription.enabled = NO;
    self.chartView.highlightPerTapEnabled = NO;
    self.chartView.transparentCircleColor = [UIColor whiteColor];
    self.chartView.drawMarkers = YES;
    BCPriceMarker *marker = [[BCPriceMarker alloc]
                             initWithColor: [UIColor whiteColor]
                             font: [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:14]
                             textColor: COLOR_PRICE_PREVIEW_CHART_MARKER
                             insets: UIEdgeInsetsMake(10, 10, 10, 10)];
    marker.chartView = self.chartView;
    self.chartView.marker = marker;
    [self addSubview:self.chartView];
}

- (void)setupLegendWithFrame:(CGRect)frame
{
    CGFloat bottomPadding = CHART_VIEW_BOTTOM_PADDING;
    CGFloat containerViewHorizontalPadding = CONTAINER_VIEW_HORIZONTAL_PADDING;
    UIView *legendKeyContainerView = [[UIView alloc] initWithFrame:CGRectMake(containerViewHorizontalPadding, self.chartView.frame.origin.y + self.chartView.frame.size.height + bottomPadding, frame.size.width - containerViewHorizontalPadding*2, (frame.size.height - bottomPadding)/5)];
    [self addSubview:legendKeyContainerView];
    
    CGFloat legendKeySpacing = 12;
    CGFloat legendKeyWidth = (legendKeyContainerView.frame.size.width - legendKeySpacing*2)/3;
    CGFloat legendKeyHeight = legendKeyContainerView.frame.size.height;
    
    self.bitcoinLegendKey = [[BCBalanceChartLegendKeyView alloc] initWithFrame:CGRectMake(0, 0, legendKeyWidth, legendKeyHeight) assetColor:COLOR_BLOCKCHAIN_BLUE assetName:[AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin]];
    UITapGestureRecognizer *tapGestureBitcoin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bitcoinLegendTapped)];
    [self.bitcoinLegendKey addGestureRecognizer:tapGestureBitcoin];
    [legendKeyContainerView addSubview:self.bitcoinLegendKey];
    
     self.etherLegendKey = [[BCBalanceChartLegendKeyView alloc] initWithFrame:CGRectMake(legendKeyWidth + legendKeySpacing, 0, legendKeyWidth, legendKeyHeight) assetColor:COLOR_BLOCKCHAIN_LIGHT_BLUE assetName:[AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum]];
    UITapGestureRecognizer *tapGestureEther = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(etherLegendTapped)];
    [self.etherLegendKey addGestureRecognizer:tapGestureEther];
     [legendKeyContainerView addSubview:self.etherLegendKey];

    self.bitcoinCashLegendKey = [[BCBalanceChartLegendKeyView alloc] initWithFrame:CGRectMake((legendKeyWidth + legendKeySpacing)*2, 0, legendKeyWidth, legendKeyHeight) assetColor:COLOR_BLOCKCHAIN_LIGHTER_BLUE assetName:[AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash]];
    UITapGestureRecognizer *tapGestureBitcoinCash = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bitcoinCashLegendTapped)];
    [self.bitcoinCashLegendKey addGestureRecognizer:tapGestureBitcoinCash];
    [legendKeyContainerView addSubview:self.bitcoinCashLegendKey];

    self.legendKeyContainerView = legendKeyContainerView;
}

- (void)setupLineSeparator
{
    BCLine *line = [[BCLine alloc] initWithFrame:CGRectMake(self.legendKeyContainerView.frame.origin.x, self.legendKeyContainerView.frame.origin.y + self.legendKeyContainerView.frame.size.height + 8, self.legendKeyContainerView.frame.size.width, 1)];
    line.backgroundColor = [ConstantsObjcBridge grayLineColor];
    [self addSubview:line];
    self.lineSeparator = line;

    self.lineSeparator.hidden = YES;
}

- (CGFloat)watchOnlyViewHeight
{
    return 50;
}

- (void)showWatchOnlyView
{
    [self changeHeight:self.defaultHeight + [self watchOnlyViewHeight]];

    if (!self.watchOnlyBalanceView) {
        CGFloat containerViewHorizonalPadding = CONTAINER_VIEW_HORIZONTAL_PADDING;
        self.watchOnlyBalanceView = [[WatchOnlyBalanceView alloc] initWithFrame:CGRectMake(containerViewHorizonalPadding, self.lineSeparator.frame.origin.y + self.lineSeparator.frame.size.height + 8, self.legendKeyContainerView.frame.size.width, 40)];
        [self addSubview:self.watchOnlyBalanceView];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(watchOnlyViewTapped)];
        tapGesture.numberOfTapsRequired = 1;
        [self.watchOnlyBalanceView addGestureRecognizer:tapGesture];
        self.watchOnlyBalanceView.userInteractionEnabled = YES;
    }

    [self updateWatchOnlyViewBalance];

    self.lineSeparator.hidden = NO;
}

- (void)hideWatchOnlyView
{
    [self changeHeight:self.defaultHeight];
    self.lineSeparator.hidden = YES;
}

- (void)updateWatchOnlyViewBalance
{
    NSString *watchOnlyBalance;
    if (BlockchainSettings.sharedAppInstance.symbolLocal) {
        watchOnlyBalance = [self.fiatSymbol stringByAppendingString: [NSNumberFormatter fiatStringFromDouble:self.bitcoin.watchOnly.fiatBalance]];
    } else {
        NSString *balance = self.bitcoin.watchOnly.balance ? : @"0";
        watchOnlyBalance = [balance stringByAppendingFormat:@" %@", CURRENCY_SYMBOL_BTC];
    }
    [self.watchOnlyBalanceView updateTextWithBalance:watchOnlyBalance];
}

// Lazy initializers
- (BalanceChartViewModel *)bitcoin
{
    if (!_bitcoin) _bitcoin = [[BalanceChartViewModel alloc] init];
    return _bitcoin;
}

- (BalanceChartViewModel *)ether
{
    if (!_ether) _ether = [[BalanceChartViewModel alloc] init];
    return _ether;
}

- (BalanceChartViewModel *)bitcoinCash
{
    if (!_bitcoinCash) _bitcoinCash = [[BalanceChartViewModel alloc] init];
    return _bitcoinCash;
}

- (void)hideChartMarker
{
    [self.chartView highlightValue:nil callDelegate:NO];
}

- (void)updateFiatSymbol:(NSString *)fiatSymbol
{
    self.fiatSymbol = fiatSymbol;
}

- (void)updateBitcoinFiatBalance:(double)fiatBalance
{
    self.bitcoin.fiatBalance = fiatBalance;
}

- (void)updateBitcoinWatchOnlyBalance:(NSString *)watchOnlyBalance;
{
    self.bitcoin.watchOnly.balance = watchOnlyBalance;
}

- (void)updateBitcoinWatchOnlyFiatBalance:(double)watchOnlyFiatBalance
{
    self.bitcoin.watchOnly.fiatBalance = watchOnlyFiatBalance;
}

// Ethereum

- (void)updateEtherFiatBalance:(double)fiatBalance
{
    self.ether.fiatBalance = fiatBalance;
}

// Bitcoin Cash

- (void)updateBitcoinCashFiatBalance:(double)fiatBalance
{
    self.bitcoinCash.fiatBalance = fiatBalance;
}

- (void)updateBitcoinCashWatchOnlyBalance:(NSString *)balance
{
    self.bitcoinCash.watchOnly.balance = balance;
}

- (void)updateBitcoinCashWatchOnlyFiatBalance:(double)watchOnlyFiatBalance
{
    self.bitcoinCash.watchOnly.fiatBalance = watchOnlyFiatBalance;
}

- (void)updateTotalFiatBalance:(NSString *)fiatBalance
{
    self.chartView.centerAttributedText = fiatBalance ? [self balanceAttributedStringWithText:fiatBalance] : nil;
}

- (void)updateBitcoinBalance:(NSString *)balance
{
    self.bitcoin.balance = balance;
}

- (void)updateEtherBalance:(NSString *)balance
{
    self.ether.balance = balance;
}

- (void)updateBitcoinCashBalance:(NSString *)balance
{
    self.bitcoinCash.balance = balance;
}

- (void)updateChart
{
    [self hideChartMarker];
    
    BOOL hasZeroBalances = !self.bitcoin.fiatBalance && !self.ether.fiatBalance && !self.bitcoinCash.fiatBalance;

    PieChartDataSet *dataSet;

    if (hasZeroBalances) {
        ChartDataEntry *emptyValue = [[PieChartDataEntry alloc] initWithValue:1];
        dataSet = [[PieChartDataSet alloc] initWithValues:@[emptyValue] label:BC_STRING_BALANCES];
        dataSet.colors = @[COLOR_EMPTY_CHART_GRAY];
        dataSet.selectionShift = 5;
        self.chartView.highlightPerTapEnabled = NO;
    } else {
        NSString *fiatSymbol = self.fiatSymbol ? : @"";
        NSDictionary *btcChartEntryData = @{@"currency": [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin], @"symbol": fiatSymbol};
        NSDictionary *ethChartEntryData = @{@"currency": [AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum], @"symbol": fiatSymbol};
        NSDictionary *bchChartEntryData = @{@"currency": [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash], @"symbol": fiatSymbol};
        ChartDataEntry *bitcoinValue = [[PieChartDataEntry alloc] initWithValue:self.bitcoin.fiatBalance data:btcChartEntryData];
        ChartDataEntry *etherValue = [[PieChartDataEntry alloc] initWithValue:self.ether.fiatBalance data:ethChartEntryData];
        ChartDataEntry *bitcoinCashValue = [[PieChartDataEntry alloc] initWithValue:self.bitcoinCash.fiatBalance data:bchChartEntryData];
        dataSet = [[PieChartDataSet alloc] initWithValues:@[bitcoinValue, etherValue, bitcoinCashValue] label:BC_STRING_BALANCES];
        dataSet.colors = @[COLOR_BLOCKCHAIN_BLUE, COLOR_BLOCKCHAIN_LIGHT_BLUE, COLOR_BLOCKCHAIN_LIGHTER_BLUE];
        dataSet.selectionShift = 5;
        self.chartView.highlightPerTapEnabled = YES;
    }

    dataSet.drawValuesEnabled = NO;
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    [data setValueTextColor:UIColor.whiteColor];
    self.chartView.data = data;
    if (!hasZeroBalances) {
        [self.chartView animateWithYAxisDuration:1.0];
    }

    [self.bitcoinLegendKey changeBalance:[self.bitcoin.balance stringByAppendingFormat:@" %@", CURRENCY_SYMBOL_BTC]];
    [self.bitcoinLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:[NSNumberFormatter fiatStringFromDouble:self.bitcoin.fiatBalance]]];

    [self.etherLegendKey changeBalance:[self.ether.balance stringByAppendingFormat:@" %@", CURRENCY_SYMBOL_ETH]];
    [self.etherLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:[NSNumberFormatter fiatStringFromDouble:self.ether.fiatBalance]]];

    [self.bitcoinCashLegendKey changeBalance:[self.bitcoinCash.balance stringByAppendingFormat:@" %@", CURRENCY_SYMBOL_BCH]];
    [self.bitcoinCashLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:[NSNumberFormatter fiatStringFromDouble:self.bitcoinCash.fiatBalance]]];
}

- (NSAttributedString *)balanceAttributedStringWithText:(NSString *)text
{
    UIFont *font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjects:@[COLOR_TEXT_DARK_GRAY, font] forKeys:@[NSForegroundColorAttributeName, NSFontAttributeName]];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributesDictionary];
    
    return attributedString;
}

- (void)bitcoinLegendTapped
{
    [self.delegate bitcoinLegendTapped];
}

- (void)etherLegendTapped
{
    [self.delegate etherLegendTapped];
}

- (void)bitcoinCashLegendTapped
{
    [self.delegate bitcoinCashLegendTapped];
}

- (void)watchOnlyViewTapped
{
    [self.delegate watchOnlyViewTapped];
}

@end
