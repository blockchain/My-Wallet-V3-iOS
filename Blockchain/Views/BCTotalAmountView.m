//
//  BCTotalAmountView.m
//  Blockchain
//
//  Created by kevinwu on 7/19/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCTotalAmountView.h"
#import "NSNumberFormatter+Currencies.h"
#import "UIView+ChangeFrameAttribute.h"

@interface BCTotalAmountView ()
@property (nonatomic) UILabel *totalLabel;
@end

@implementation BCTotalAmountView

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color amount:(uint64_t)amount
{
    if ([super initWithFrame:frame]) {
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 0, 0)];
        totalLabel.text = BC_STRING_TOTAL;
        totalLabel.textColor = [UIColor darkGrayColor];
        totalLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_SEMIBOLD size:FONT_SIZE_SMALL];
        totalLabel.textAlignment = NSTextAlignmentCenter;
        [totalLabel sizeToFit];
        totalLabel.center = CGPointMake(self.center.x, totalLabel.center.y);
        [self addSubview:totalLabel];
        self.totalLabel = totalLabel;
        
        UILabel *btcAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, totalLabel.frame.origin.y + totalLabel.frame.size.height + 8, 0, 0)];
        btcAmountLabel.text = [NSNumberFormatter formatBTC:amount];
        btcAmountLabel.textColor = color;
        btcAmountLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_SEMIBOLD size:FONT_SIZE_EXTRA_EXTRA_LARGE];
        btcAmountLabel.textAlignment = NSTextAlignmentCenter;
        [btcAmountLabel sizeToFit];
        [btcAmountLabel changeWidth:self.frame.size.width - 30];
        btcAmountLabel.center = CGPointMake(self.center.x, btcAmountLabel.center.y);
        [self addSubview:btcAmountLabel];
        self.btcAmountLabel = btcAmountLabel;
        
        UILabel *fiatAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, btcAmountLabel.frame.origin.y + btcAmountLabel.frame.size.height + 8, 0, 0)];
        fiatAmountLabel.text = [NSNumberFormatter formatMoney:amount localCurrency:YES];
        fiatAmountLabel.textColor = color;
        fiatAmountLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
        fiatAmountLabel.textAlignment = NSTextAlignmentCenter;
        [fiatAmountLabel sizeToFit];
        [fiatAmountLabel changeWidth:self.frame.size.width - 30];
        fiatAmountLabel.center = CGPointMake(self.center.x, fiatAmountLabel.center.y);
        [self addSubview:fiatAmountLabel];
        self.fiatAmountLabel = fiatAmountLabel;
    }
    
    return self;
}

- (void)updateLabelsWithAmount:(uint64_t)amount
{
    self.btcAmountLabel.text = [NSNumberFormatter formatMoney:amount localCurrency:NO];
    self.fiatAmountLabel.text = [NSNumberFormatter formatMoney:amount localCurrency:YES];
}

@end
