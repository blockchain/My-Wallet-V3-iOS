//
//  BCPriceChartContainerViewController.h
//  Blockchain
//
//  Created by kevinwu on 2/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPriceChartView.h"

@class BCPriceChartView, ChartDataEntry, ChartAxisBase;
@interface BCPriceChartContainerViewController : UIViewController
@property (nonatomic, weak) id <BCPriceChartViewDelegate> delegate;
- (void)addPriceChartView:(BCPriceChartView *)priceChartView atIndex:(NSInteger)pageIndex;
- (void)clearChart;
- (void)updateChartWithValues:(NSArray *)values;
- (ChartAxisBase *)leftAxis;
- (ChartAxisBase *)xAxis;
- (void)updateTitleContainer;
- (void)updateTitleContainerWithChartDataEntry:(ChartDataEntry *)entry;
- (void)updateEthExchangeRate:(NSDecimalNumber *)rate;
@end
