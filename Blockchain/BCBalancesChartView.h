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
- (void)watchOnlyViewTapped;
@end
@interface BCBalancesChartView : UIView
@property (nonatomic, weak) id<BCBalancesChartViewDelegate> delegate;

- (void)updateBitcoinBalance:(NSString *)balance;
- (void)updateBitcoinFiatBalance:(double)fiatBalance;
- (void)updateBitcoinWatchOnlyBalance:(NSString *)watchOnlyBalance;
- (void)updateBitcoinWatchOnlyFiatBalance:(double)watchOnlyFiatBalance;

- (void)updateEtherBalance:(NSString *)balance;
- (void)updateEtherFiatBalance:(double)fiatBalance;

- (void)updateBitcoinCashBalance:(NSString *)balance;
- (void)updateBitcoinCashFiatBalance:(double)fiatBalance;
- (void)updateBitcoinCashWatchOnlyBalance:(NSString *)watchOnlyBalance;
- (void)updateBitcoinCashWatchOnlyFiatBalance:(double)watchOnlyFiatBalance;

- (void)updateTotalFiatBalance:(NSString *)fiatBalance;
- (void)updateFiatSymbol:(NSString *)symbol;

- (void)updateChart;

- (CGFloat)watchOnlyViewHeight;
- (void)showWatchOnlyView;
- (void)hideWatchOnlyView;
- (void)updateWatchOnlyViewBalance;
@end
