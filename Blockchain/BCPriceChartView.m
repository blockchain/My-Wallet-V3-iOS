//
//  BCPriceChartView.m
//  Blockchain
//
//  Created by kevinwu on 1/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCPriceChartView.h"
#import "Assets.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"
#import "GraphTimeFrame.h"
#import "NSNumberFormatter+Currencies.h"

#define X_INSET_GRAPH_CONTAINER 16

@import Charts;

@interface BCPriceChartView () <ChartViewDelegate>

@property (nonatomic) id <IChartAxisValueFormatter, BCPriceChartViewDelegate> delegate;

@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic) LineChartView *chartView;
@property (nonatomic) UIView *graphContainerView;
@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) UIView *priceContainerView;
@property (nonatomic) UILabel *priceLabel;
@property (nonatomic) UILabel *percentageChangeLabel;
@property (nonatomic) UIImageView *arrowImageView;

@property (nonatomic) UIButton *allTimeButton;
@property (nonatomic) UIButton *yearButton;
@property (nonatomic) UIButton *monthButton;
@property (nonatomic) UIButton *weekButton;
@property (nonatomic) UIButton *dayButton;
@property (nonatomic) NSDecimalNumber *lastEthExchangeRate;

@property (nonatomic) NSArray *lastUpdatedValues;

@property (nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation BCPriceChartView

- (id)initWithFrame:(CGRect)frame assetType:(LegacyAssetType)assetType dataPoints:(NSArray *)dataPoints delegate:(id<IChartAxisValueFormatter, ChartViewDelegate, BCPriceChartViewDelegate>)delegate
{
    if (self == [super initWithFrame:frame]) {
        self.assetType = assetType;
        self.delegate = delegate;

        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 2;
        
        UIView *titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, self.frame.size.width, 60)];
        titleContainerView.backgroundColor = [UIColor clearColor];
        titleContainerView.center = CGPointMake(self.bounds.size.width/2, titleContainerView.center.y);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        titleLabel.textColor = UIColor.brandPrimary;
        titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_EXTRALIGHT size:FONT_SIZE_EXTRA_SMALL];
        [titleContainerView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        self.priceContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.priceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_LARGE];
        self.priceLabel.textColor = UIColor.brandPrimary;
        [self.priceContainerView addSubview:self.priceLabel];
        
        self.percentageChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.percentageChangeLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
        self.percentageChangeLabel.textColor = UIColor.brandPrimary;
        [self.priceContainerView addSubview:self.percentageChangeLabel];
        
        self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 15)];
        self.arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.priceContainerView addSubview:self.arrowImageView];
        
        [titleContainerView addSubview:self.priceContainerView];
        
        [self addSubview:titleContainerView];
        
        UIView *graphContainerView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, X_INSET_GRAPH_CONTAINER, titleContainerView.frame.origin.y + 44)];
        [graphContainerView changeWidth:self.frame.size.width - graphContainerView.frame.origin.x - 30];
        [graphContainerView changeHeight:self.frame.size.height - 120];
        
        CGFloat verticalSpacing = 0;
        CGFloat horizontalSpacing = 0;
        
        LineChartView *chartView = [[LineChartView alloc] initWithFrame:CGRectMake(horizontalSpacing, verticalSpacing, graphContainerView.bounds.size.width - horizontalSpacing*2, graphContainerView.bounds.size.height - verticalSpacing*2)];
        chartView.delegate = self;
        chartView.drawGridBackgroundEnabled = NO;
        chartView.drawBordersEnabled = NO;
        chartView.scaleXEnabled = NO;
        chartView.scaleYEnabled = NO;
        chartView.pinchZoomEnabled = NO;
        chartView.doubleTapToZoomEnabled = NO;
        chartView.chartDescription.enabled = NO;
        chartView.legend.enabled = NO;
        
        BCChartMarkerView *marker = [[BCChartMarkerView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        marker.chartView = chartView;
        chartView.marker = marker;
        
        chartView.leftAxis.drawGridLinesEnabled = NO;
        chartView.leftAxis.labelTextColor = UIColor.gray3;
        chartView.leftAxis.labelFont = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
        chartView.leftAxis.labelCount = 4;
        
        chartView.rightAxis.enabled = NO;
        
        chartView.xAxis.labelFont = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
        chartView.xAxis.drawGridLinesEnabled = NO;
        chartView.xAxis.labelTextColor = UIColor.gray3;
        chartView.xAxis.labelPosition = XAxisLabelPositionBottom;
        chartView.xAxis.granularityEnabled = YES;
        chartView.xAxis.labelCount = 4;
        [chartView setExtraOffsetsWithLeft:8.0 top:0 right:0 bottom:10.0];
        chartView.noDataFont = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
        chartView.noDataTextColor = UIColor.gray3;
        
        chartView.xAxis.valueFormatter = delegate;
        chartView.leftAxis.valueFormatter = delegate;
        
        self.chartView = chartView;
        [graphContainerView addSubview:self.chartView];
        
        [self addSubview:graphContainerView];
        self.graphContainerView = graphContainerView;
        
        [self setupTimeSpanButtons];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_GRAPH_TIME_FRAME];
        GraphTimeFrame *timeFrame = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        UIButton *selectedButton;
        
        [self.weekButton setSelected:NO];
        [self.monthButton setSelected:NO];
        [self.yearButton setSelected:NO];
        [self.allTimeButton setSelected:NO];
        
        if (!timeFrame || timeFrame.timeFrame == TimeFrameWeek) {
            selectedButton = self.weekButton;
        } else if (timeFrame.timeFrame == TimeFrameMonth) {
            selectedButton = self.monthButton;
        } else if (timeFrame.timeFrame == TimeFrameYear) {
            selectedButton = self.yearButton;
        } else if (timeFrame.timeFrame == TimeFrameAll) {
            selectedButton = self.allTimeButton;
        } else if (timeFrame.timeFrame == TimeFrameDay) {
            selectedButton = self.dayButton;
        }
        
        [selectedButton setSelected:YES];
    }
    
    return self;
}

- (void)setupTimeSpanButtons
{
    CGFloat buttonContainerViewWidth = 280;
    UIView *buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.graphContainerView.frame.origin.y + self.graphContainerView.frame.size.height + 16, buttonContainerViewWidth, 30)];
    
    CGFloat buttonWidth = buttonContainerViewWidth/5;
    
    self.allTimeButton = [self timeSpanButtonWithFrame:CGRectMake(0, 0, buttonWidth, 30) title:BC_STRING_ALL];
    [buttonContainerView addSubview:self.allTimeButton];
    
    self.yearButton = [self timeSpanButtonWithFrame:CGRectMake(self.allTimeButton.frame.origin.x + self.allTimeButton.frame.size.width, 0, buttonWidth, 30) title:BC_STRING_YEAR];
    [buttonContainerView addSubview:self.yearButton];
    
    self.monthButton = [self timeSpanButtonWithFrame:CGRectMake(self.yearButton.frame.origin.x + self.yearButton.frame.size.width, 0, buttonWidth, 30) title:BC_STRING_MONTH];
    [buttonContainerView addSubview:self.monthButton];
    
    self.weekButton = [self timeSpanButtonWithFrame:CGRectMake(self.monthButton.frame.origin.x + self.monthButton.frame.size.width, 0, buttonWidth, 30) title:BC_STRING_WEEK];
    [buttonContainerView addSubview:self.weekButton];
    
    self.dayButton = [self timeSpanButtonWithFrame:CGRectMake(self.weekButton.frame.origin.x + self.weekButton.frame.size.width, 0, buttonWidth, 30) title:BC_STRING_DAY];
    [buttonContainerView addSubview:self.dayButton];
    
    [self addSubview:buttonContainerView];
    buttonContainerView.center = CGPointMake(self.graphContainerView.center.x + 20, buttonContainerView.center.y);
}

- (void)timeSpanButtonTapped:(UIButton *)button
{
    [self.weekButton setSelected:NO];
    [self.monthButton setSelected:NO];
    [self.yearButton setSelected:NO];
    [self.dayButton setSelected:NO];
    [self.allTimeButton setSelected:NO];
    
    [button setSelected:YES];
    
    GraphTimeFrame *timeFrame;
    
    if (button == self.dayButton) {
        timeFrame = [GraphTimeFrame timeFrameDay];
    } else if (button == self.weekButton) {
        timeFrame = [GraphTimeFrame timeFrameWeek];
    } else if (button == self.monthButton) {
        timeFrame = [GraphTimeFrame timeFrameMonth];
    } else if (button == self.yearButton) {
        timeFrame = [GraphTimeFrame timeFrameYear];
    } else {
        timeFrame = [GraphTimeFrame timeFrameAll:self.assetType];
    }
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:timeFrame];
    [currentDefaults setObject:data forKey:USER_DEFAULTS_KEY_GRAPH_TIME_FRAME];
    
    self.isLoading = YES;
    
    [self.delegate reloadPriceChartView:self.assetType];
}

- (ChartAxisBase *)leftAxis
{
    return self.chartView.leftAxis;
}

- (ChartAxisBase *)xAxis
{
    return self.chartView.xAxis;
}

- (void)clear
{
    [self.chartView clear];
}

- (void)updateEthExchangeRate:(NSDecimalNumber *)rate
{
    self.lastEthExchangeRate = rate;
}

- (void)updateWithValues:(NSArray *)values
{
    [self updateTitleContainer:values];
    [self setChartValues:values];
}

- (void)updateTitleContainer
{
    [self updateTitleContainer:self.lastUpdatedValues];
}

- (void)updateTitleContainer:(NSArray *)values
{
    self.lastUpdatedValues = values;
    
    self.titleLabel.text = [self getChartTitleText];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake([self.titleLabel superview].bounds.size.width/2, self.titleLabel.center.y);
    
    self.priceLabel.text = [self getPriceLabelText];
    [self.priceLabel sizeToFit];
    
    double firstPrice = [[[values firstObject] objectForKey:DICTIONARY_KEY_PRICE] doubleValue];
    double lastPrice = [[[values lastObject] objectForKey:DICTIONARY_KEY_PRICE] doubleValue];
    double difference = lastPrice - firstPrice;
    double percentChange = (difference / firstPrice) * 100;
    
    self.arrowImageView.hidden = NO;
    self.arrowImageView.tintColor = UIColor.green;
    [self.arrowImageView changeXPosition:self.priceLabel.frame.size.width + 8];
    [self.arrowImageView changeYPosition:self.priceLabel.frame.size.height - self.arrowImageView.frame.size.height - 3.5];
    
    UIImage *arrowImage = [UIImage imageNamed:@"down_triangle"];
    
    if (percentChange > 0) {
        self.arrowImageView.image = [[UIImage imageWithCGImage:arrowImage.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.arrowImageView.tintColor = UIColor.green;
    } else {
        self.arrowImageView.image = [arrowImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.arrowImageView.tintColor = UIColor.red;
    }
    
    self.percentageChangeLabel.hidden = NO;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:1];
    [numberFormatter setMinimumFractionDigits:1];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSLocale *currentLocale = numberFormatter.locale;
    numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US];
    NSNumber *number = [numberFormatter numberFromString:[NSString stringWithFormat:@"%.1f", percentChange]];
    numberFormatter.locale = currentLocale;
    
    self.percentageChangeLabel.text = [[numberFormatter stringFromNumber:number] stringByAppendingString:@"%"];
    [self.percentageChangeLabel sizeToFit];
    [self.percentageChangeLabel changeYPosition:self.priceLabel.frame.size.height - self.percentageChangeLabel.frame.size.height - 1.5];
    [self.percentageChangeLabel changeXPosition:self.priceLabel.frame.origin.x + self.priceLabel.frame.size.width + 8 + self.arrowImageView.frame.size.width];
    
    self.priceContainerView.frame = CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, self.priceLabel.frame.size.width + 8 + self.arrowImageView.frame.size.width + self.percentageChangeLabel.frame.size.width, 30);
    self.priceContainerView.center = CGPointMake(self.bounds.size.width/2, self.priceContainerView.center.y);
}

- (void)updateTitleContainerWithChartDataEntry:(ChartDataEntry *)dataEntry
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MMM d, yyyy";
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dataEntry.x]];
    dateFormatter.dateFormat = @"h:mm a";
    NSString *timeString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dataEntry.x]];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ %@", dateString, BC_STRING_AT, timeString];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake([self.titleLabel superview].frame.size.width/2, self.titleLabel.center.y);
    
    NSString *formattedString = [NSNumberFormatter localFormattedString:[NSString stringWithFormat:@"%.2f", dataEntry.y]];
    self.priceLabel.text = [NSString stringWithFormat:@"%@%@", WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol, formattedString];
    [self.priceLabel sizeToFit];
    
    self.percentageChangeLabel.hidden = YES;
    self.arrowImageView.hidden = YES;
    
    self.priceContainerView.frame = CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, self.priceLabel.frame.size.width, 30);
    self.priceContainerView.center = CGPointMake(self.bounds.size.width/2, self.priceContainerView.center.y);
}

- (void)setChartValues:(NSArray *)values
{
    BOOL shouldAnimate = self.chartView.data == nil;
    
    NSMutableArray *finalValues = [NSMutableArray new];
    
    for (NSDictionary *dict in values) {
        double x = [[dict objectForKey:DICTIONARY_KEY_TIMESTAMP] doubleValue];
        double y = [[dict objectForKey:DICTIONARY_KEY_PRICE] doubleValue];
        ChartDataEntry *value = [[ChartDataEntry alloc] initWithX:x y:y];
        [finalValues addObject:value];
    }
    
    LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithValues:finalValues label:nil];
    dataSet.lineWidth = 1.5f;
    dataSet.colors = @[UIColor.brandPrimary];
    dataSet.mode = LineChartModeLinear;
    dataSet.drawValuesEnabled = NO;
    dataSet.circleRadius = 1.0f;
    dataSet.drawCircleHoleEnabled = NO;
    dataSet.circleColors = @[UIColor.brandPrimary];
    dataSet.drawFilledEnabled = NO;
    dataSet.drawVerticalHighlightIndicatorEnabled = NO;
    dataSet.drawHorizontalHighlightIndicatorEnabled = NO;
    self.chartView.data = [[LineChartData alloc] initWithDataSet:dataSet];
    if (shouldAnimate) [self.chartView animateWithXAxisDuration:1.0];

    self.isLoading = NO;
}

#pragma mark - View Helpers

- (UIButton *)timeSpanButtonWithFrame:(CGRect)frame title:(NSString *)title
{
    UIFont *normalFont = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];
    UIFont *selectedFont = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    
    NSAttributedString *attrNormal = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:normalFont, NSForegroundColorAttributeName:UIColor.brandPrimary, NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleNone]}];
    NSAttributedString *attrSelected = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:selectedFont, NSForegroundColorAttributeName:UIColor.brandPrimary, NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]}];
    
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setAttributedTitle:attrNormal forState:UIControlStateNormal];
    [button setAttributedTitle:attrSelected forState:UIControlStateSelected];
    [button addTarget:self action:@selector(timeSpanButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *testButton = [UIButton new];
    [testButton setTitle:title forState:UIControlStateNormal];
    [testButton sizeToFit];
    
    [button changeWidth:testButton.frame.size.width];
    [button changeXPosition:frame.origin.x + 8];
    return button;
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    
    if (isLoading) {
        [self showSpinner];
    } else {
        [self hideSpinner];
    }
}

- (void)showSpinner
{
    if (!self.spinner) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.spinner.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self addSubview:self.spinner];
    }
    
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
}

- (void)hideSpinner
{
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
}

- (NSString *)getChartTitleText
{
    LegacyAssetType assetType = self.assetType;
    if (assetType == LegacyAssetTypeBitcoin) {
        return [BC_STRING_BITCOIN_PRICE uppercaseString];
    } else if (assetType == LegacyAssetTypeEther) {
        return [BC_STRING_ETHER_PRICE uppercaseString];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [BC_STRING_BITCOIN_CASH_PRICE uppercaseString];
    }
    DLog(@"Error: unknown asset type!");
    return nil;
}

- (NSString *)getPriceLabelText
{
    LegacyAssetType assetType = self.assetType;
    if (assetType == LegacyAssetTypeBitcoin) {
        return [NSNumberFormatter formatMoney:SATOSHI localCurrency:YES];
    } else if (assetType == LegacyAssetTypeEther) {
        return [NSNumberFormatter formatEthToFiatWithSymbol:@"1" exchangeRate:self.lastEthExchangeRate];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [NSNumberFormatter formatBchWithSymbol:SATOSHI localCurrency:YES];
    }
    DLog(@"Error: unknown asset type!");
    return nil;
}

#pragma mark - Chart View Delegate

- (void)chartValueNothingSelected:(ChartViewBase *)chartView
{
    [self updateTitleContainer];
}

- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight
{
    [self updateTitleContainerWithChartDataEntry:entry];
}

@end
