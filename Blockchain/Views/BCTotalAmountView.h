//
//  BCTotalAmountView.h
//  Blockchain
//
//  Created by kevinwu on 7/19/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCTotalAmountView : UIView
@property (nonatomic) UILabel *btcAmountLabel;
@property (nonatomic) UILabel *fiatAmountLabel;
- (id)initWithFrame:(CGRect)frame color:(UIColor *)color amount:(uint64_t)amount;
- (void)updateLabelsWithAmount:(uint64_t)amount;
@end
