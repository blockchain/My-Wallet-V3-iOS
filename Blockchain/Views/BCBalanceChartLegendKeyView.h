//
//  BCBalanceChartLegendKeyView.h
//  Blockchain
//
//  Created by kevinwu on 2/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCBalanceChartLegendKeyView : UIView

- (id)initWithFrame:(CGRect)frame
         assetColor:(UIColor *)color
          assetName:(NSString *)name;

- (void)changeBalance:(NSString *)balance;
- (void)changeFiatBalance:(NSString *)balance;

@end
