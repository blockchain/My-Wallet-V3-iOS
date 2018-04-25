//
//  BCBalancesChartView.h
//  Blockchain
//
//  Created by kevinwu on 2/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BCBalancesChartViewDelegate
- (void)bitcoinLegendTapped;
- (void)etherLegendTapped;
- (void)bitcoinCashLegendTapped;
@end
@interface BCBalancesChartView : UIView
@property (nonatomic, weak) id<BCBalancesChartViewDelegate> delegate;
- (void)updateBitcoinFiatBalance:(double)fiatBalance;
- (void)updateEtherFiatBalance:(double)fiatBalance;
- (void)updateBitcoinCashFiatBalance:(double)fiatBalance;
- (void)updateTotalFiatBalance:(NSString *)fiatBalance;

- (void)updateBitcoinBalance:(NSString *)balance;
- (void)updateEtherBalance:(NSString *)balance;
- (void)updateBitcoinCashBalance:(NSString *)balance;

- (void)updateFiatSymbol:(NSString *)symbol;

- (void)updateChart;

@end
