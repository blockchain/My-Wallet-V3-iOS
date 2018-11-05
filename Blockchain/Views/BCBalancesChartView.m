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
@property (nonatomic) BalanceChartViewModel *stellar;

@property (nonatomic) PieChartView *chartView;
@property (nonatomic) BCBalanceChartLegendKeyView *bitcoinLegendKey;
@property (nonatomic) BCBalanceChartLegendKeyView *etherLegendKey;
@property (nonatomic) BCBalanceChartLegendKeyView *bitcoinCashLegendKey;
@property (nonatomic) BCBalanceChartLegendKeyView *stellarLegendKey;
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
        [self setupEmptyChartState];
        self.defaultHeight = self.bounds.size.height;
    }
    
    return self;
}

- (void)setupChartViewWithFrame:(CGRect)frame
{
    self.chartView = [[PieChartView alloc] initWithFrame:CGRectMake(0, 16, frame.size.width, 200)];
    self.chartView.drawCenterTextEnabled = YES;
    self.chartView.drawHoleEnabled = YES;
    self.chartView.holeColor = [UIColor clearColor];
    self.chartView.holeRadiusPercent = 0.8;
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
                             textColor: UIColor.gray4
                             insets: UIEdgeInsetsMake(10, 10, 10, 10)];
    marker.chartView = self.chartView;
    self.chartView.marker = marker;
    [self addSubview:self.chartView];
}

- (void)setupEmptyChartState
{
    PieChartDataSet *dataSet;
    ChartDataEntry *emptyValue = [[PieChartDataEntry alloc] initWithValue:1];
    dataSet = [[PieChartDataSet alloc] initWithValues:@[emptyValue] label:[LocalizationConstantsObjcBridge balances]];
    dataSet.colors = @[UIColor.emptyChart];
    dataSet.selectionShift = 5;
    self.chartView.highlightPerTapEnabled = NO;

    dataSet.drawValuesEnabled = NO;

    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    [data setValueTextColor:UIColor.whiteColor];
    self.chartView.data = data;

    [self.bitcoinLegendKey changeBalance:[@"0" stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeBitcoin]]];
    [self.bitcoinLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:@"0"]];

    [self.etherLegendKey changeBalance:[@"0" stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeEther]]];
    [self.etherLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:@"0"]];

    [self.bitcoinCashLegendKey changeBalance:[@"0" stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeBitcoinCash]]];
    [self.bitcoinCashLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:@"0"]];

    [self.stellarLegendKey changeBalance:[@"0" stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeStellar]]];
    [self.stellarLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:@"0"]];
}

- (void)setupLegendWithFrame:(CGRect)frame
{
    CGFloat bottomPadding = CHART_VIEW_BOTTOM_PADDING;
    CGFloat containerViewHorizontalPadding = CONTAINER_VIEW_HORIZONTAL_PADDING;

    CGFloat legendKeySpacing = 16;
    CGFloat legendKeyHeight = 80;
    CGFloat legendKeyContainerHeight = (legendKeyHeight * 2) + legendKeySpacing;
    CGFloat legendKeyContainerWidth = frame.size.width - (containerViewHorizontalPadding * 2);
    CGFloat legendKeyWidth = (legendKeyContainerWidth - legendKeySpacing * 2) / 2;
    CGFloat legendKeyContainerPosY = self.chartView.frame.origin.y + self.chartView.frame.size.height + bottomPadding;

    UIView *legendKeyContainerView = [[UIView alloc] initWithFrame:CGRectMake(containerViewHorizontalPadding, legendKeyContainerPosY, legendKeyContainerWidth, legendKeyContainerHeight)];
    [self addSubview:legendKeyContainerView];
    
    self.bitcoinLegendKey = [[BCBalanceChartLegendKeyView alloc] initWithFrame:CGRectMake(0, 0, legendKeyWidth, legendKeyHeight) assetColor:[AssetTypeLegacyHelper colorFor:LegacyAssetTypeBitcoin] assetName:[AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin]];
    UITapGestureRecognizer *tapGestureBitcoin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bitcoinLegendTapped)];
    [self.bitcoinLegendKey addGestureRecognizer:tapGestureBitcoin];
    [legendKeyContainerView addSubview:self.bitcoinLegendKey];
    
     self.etherLegendKey = [[BCBalanceChartLegendKeyView alloc] initWithFrame:CGRectMake(legendKeyWidth + (legendKeySpacing * 2), 0, legendKeyWidth, legendKeyHeight) assetColor:[AssetTypeLegacyHelper colorFor:LegacyAssetTypeEther] assetName:[AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum]];
    UITapGestureRecognizer *tapGestureEther = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(etherLegendTapped)];
    [self.etherLegendKey addGestureRecognizer:tapGestureEther];
     [legendKeyContainerView addSubview:self.etherLegendKey];

    self.bitcoinCashLegendKey = [[BCBalanceChartLegendKeyView alloc] initWithFrame:CGRectMake(0, (legendKeyHeight + legendKeySpacing), legendKeyWidth, legendKeyHeight) assetColor:[AssetTypeLegacyHelper colorFor:LegacyAssetTypeBitcoinCash] assetName:[AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash]];
    UITapGestureRecognizer *tapGestureBitcoinCash = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bitcoinCashLegendTapped)];
    [self.bitcoinCashLegendKey addGestureRecognizer:tapGestureBitcoinCash];
    [legendKeyContainerView addSubview:self.bitcoinCashLegendKey];

    self.stellarLegendKey = [[BCBalanceChartLegendKeyView alloc] initWithFrame:CGRectMake(legendKeyWidth + (legendKeySpacing * 2), (legendKeyHeight + legendKeySpacing), legendKeyWidth, legendKeyHeight) assetColor:[AssetTypeLegacyHelper colorFor:LegacyAssetTypeStellar] assetName:[AssetTypeLegacyHelper descriptionFor:AssetTypeStellar]];
    UITapGestureRecognizer *tapGestureStellar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stellarLegendTapped)];
    [self.stellarLegendKey addGestureRecognizer:tapGestureStellar];
    [legendKeyContainerView addSubview:self.stellarLegendKey];

    self.legendKeyContainerView = legendKeyContainerView;
}

- (void)setupLineSeparator
{
    BCLine *line = [[BCLine alloc] initWithFrame:CGRectMake(self.legendKeyContainerView.frame.origin.x, self.legendKeyContainerView.frame.origin.y + self.legendKeyContainerView.frame.size.height + 8, self.legendKeyContainerView.frame.size.width, 1)];
    line.backgroundColor = UIColor.grayLine;
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

    self.watchOnlyBalanceView.hidden = NO;
    self.lineSeparator.hidden = NO;
}

- (void)hideWatchOnlyView
{
    [self changeHeight:self.defaultHeight];
    self.watchOnlyBalanceView.hidden = YES;
    self.lineSeparator.hidden = YES;
}

- (void)updateWatchOnlyViewBalance
{
    NSString *watchOnlyBalance = BlockchainSettings.sharedAppInstance.symbolLocal ?
    [self.fiatSymbol stringByAppendingString: [NSNumberFormatter fiatStringFromDouble:self.bitcoin.watchOnly.fiatBalance]] :
    [self.bitcoin.watchOnly.balance stringByAppendingFormat:@" %@", CURRENCY_SYMBOL_BTC];
    [self.watchOnlyBalanceView updateTextWithBalance:watchOnlyBalance];
}

- (BalanceChartViewModel *)bitcoin
{
    if (!_bitcoin) {
        _bitcoin = [[BalanceChartViewModel alloc] init];
    }
    return _bitcoin;
}

- (BalanceChartViewModel *)ether
{
    if (!_ether) {
        _ether = [[BalanceChartViewModel alloc] init];
    }
    return _ether;
}

- (BalanceChartViewModel *)bitcoinCash
{
    if (!_bitcoinCash) {
        _bitcoinCash = [[BalanceChartViewModel alloc] init];
    }
    return _bitcoinCash;
}

- (BalanceChartViewModel *)stellar
{
    if (!_stellar) {
        _stellar = [[BalanceChartViewModel alloc] init];
    }
    return _stellar;
}

- (void)hideChartMarker
{
    [self.chartView highlightValue:nil callDelegate:NO];
}

- (void)updateFiatSymbol:(NSString *)fiatSymbol
{
    self.fiatSymbol = fiatSymbol;
}

- (void)updateTotalFiatBalance:(NSString *)fiatBalance
{
    self.chartView.centerAttributedText = fiatBalance ? [self balanceAttributedStringWithText:fiatBalance] : nil;
}

// Bitcoin

- (void)updateBitcoinBalance:(NSString *)balance
{
    self.bitcoin.balance = balance;
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

- (void)updateEtherBalance:(NSString *)balance
{
    self.ether.balance = balance;
}

- (void)updateEtherFiatBalance:(double)fiatBalance
{
    self.ether.fiatBalance = fiatBalance;
}

// Bitcoin Cash

- (void)updateBitcoinCashBalance:(NSString *)balance
{
    self.bitcoinCash.balance = balance;
}

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

// Stellar

- (void)updateStellarBalance:(NSString *)balance
{
    self.stellar.balance = balance;
}

- (void)updateStellarFiatBalance:(double)fiatBalance
{
    self.stellar.fiatBalance = fiatBalance;
}

- (void)updateChart
{
    [self hideChartMarker];
    
    BOOL hasZeroBalances = !self.bitcoin.fiatBalance && !self.ether.fiatBalance && !self.bitcoinCash.fiatBalance && !self.stellar.fiatBalance;

    PieChartDataSet *dataSet;

    if (hasZeroBalances) {
        ChartDataEntry *emptyValue = [[PieChartDataEntry alloc] initWithValue:1];
        dataSet = [[PieChartDataSet alloc] initWithValues:@[emptyValue] label:[LocalizationConstantsObjcBridge balances]];
        dataSet.colors = @[UIColor.emptyChart];
        dataSet.selectionShift = 5;
        self.chartView.highlightPerTapEnabled = NO;
    } else {
        NSString *fiatSymbol = self.fiatSymbol ? : @"";
        NSDictionary *btcChartEntryData = @{@"currency": [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin], @"symbol": fiatSymbol};
        NSDictionary *ethChartEntryData = @{@"currency": [AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum], @"symbol": fiatSymbol};
        NSDictionary *bchChartEntryData = @{@"currency": [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash], @"symbol": fiatSymbol};
        NSDictionary *xlmChartEntryData = @{@"currency": [AssetTypeLegacyHelper descriptionFor:AssetTypeStellar], @"symbol": fiatSymbol};
        ChartDataEntry *bitcoinValue = [[PieChartDataEntry alloc] initWithValue:self.bitcoin.fiatBalance data:btcChartEntryData];
        ChartDataEntry *etherValue = [[PieChartDataEntry alloc] initWithValue:self.ether.fiatBalance data:ethChartEntryData];
        ChartDataEntry *bitcoinCashValue = [[PieChartDataEntry alloc] initWithValue:self.bitcoinCash.fiatBalance data:bchChartEntryData];
        ChartDataEntry *stellarValue = [[PieChartDataEntry alloc] initWithValue:self.stellar.fiatBalance data:xlmChartEntryData];
        dataSet = [[PieChartDataSet alloc] initWithValues:@[bitcoinValue, etherValue, bitcoinCashValue, stellarValue] label:[LocalizationConstantsObjcBridge balances]];
        dataSet.colors = @[
                           [AssetTypeLegacyHelper colorFor:LegacyAssetTypeBitcoin],
                           [AssetTypeLegacyHelper colorFor:LegacyAssetTypeEther],
                           [AssetTypeLegacyHelper colorFor:LegacyAssetTypeBitcoinCash],
                           [AssetTypeLegacyHelper colorFor:LegacyAssetTypeStellar]
                           ];
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

    [self.bitcoinLegendKey changeBalance:[self.bitcoin.balance stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeBitcoin]]];
    [self.bitcoinLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:[NSNumberFormatter fiatStringFromDouble:self.bitcoin.fiatBalance]]];

    [self.etherLegendKey changeBalance:[self.ether.balance stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeEther]]];
    [self.etherLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:[NSNumberFormatter fiatStringFromDouble:self.ether.fiatBalance]]];

    [self.bitcoinCashLegendKey changeBalance:[self.bitcoinCash.balance stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeBitcoinCash]]];
    [self.bitcoinCashLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:[NSNumberFormatter fiatStringFromDouble:self.bitcoinCash.fiatBalance]]];

    [self.stellarLegendKey changeBalance:[self.stellar.balance stringByAppendingFormat:@" %@", [AssetTypeLegacyHelper symbolFor:LegacyAssetTypeStellar]]];
    [self.stellarLegendKey changeFiatBalance:[self.fiatSymbol stringByAppendingString:[NSNumberFormatter fiatStringFromDouble:self.stellar.fiatBalance]]];
}

- (void)clearLegendKeyBalances
{
    [self.bitcoinLegendKey changeBalance:nil];
    [self.bitcoinLegendKey changeFiatBalance:nil];

    [self.etherLegendKey changeBalance:nil];
    [self.etherLegendKey changeFiatBalance:nil];

    [self.bitcoinCashLegendKey changeBalance:nil];
    [self.bitcoinCashLegendKey changeFiatBalance:nil];

    [self.stellarLegendKey changeBalance:nil];
    [self.stellarLegendKey changeFiatBalance:nil];
}

- (NSAttributedString *)balanceAttributedStringWithText:(NSString *)text
{
    UIFont *font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjects:@[UIColor.blackColor, font] forKeys:@[NSForegroundColorAttributeName, NSFontAttributeName]];
    
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

- (void)stellarLegendTapped
{
    [self.delegate stellarLegendTapped];
}

- (void)watchOnlyViewTapped
{
    [self.delegate watchOnlyViewTapped];
}

@end
