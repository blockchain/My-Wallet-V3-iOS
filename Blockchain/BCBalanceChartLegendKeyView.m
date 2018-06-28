//
//  BCBalanceChartLegendKeyView.m
//  Blockchain
//
//  Created by kevinwu on 2/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCBalanceChartLegendKeyView.h"

@interface BCBalanceChartLegendKeyView ()
@property (nonatomic) UILabel *balanceLabel;
@property (nonatomic) UILabel *fiatBalanceLabel;
@end

@implementation BCBalanceChartLegendKeyView

- (id)initWithFrame:(CGRect)frame assetColor:(UIColor *)color assetName:(NSString *)name
{
    if (self == [super initWithFrame:frame]) {
        
        CGFloat lineHeight = 3;
        CGFloat fontSize = 12.0;
        
        UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, lineHeight)];
        colorView.backgroundColor = color;
        [self addSubview:colorView];
        
        CGFloat labelHeight = frame.size.height/3 - lineHeight/3;
        UIColor *labelTextColor = COLOR_TEXT_DARK_GRAY;
        
        UILabel *assetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, colorView.frame.origin.y + colorView.frame.size.height, frame.size.width, labelHeight)];
        assetLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:fontSize];
        assetLabel.text = name;
        assetLabel.textColor = labelTextColor;
        [self addSubview:assetLabel];

        UILabel *fiatBalanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, assetLabel.frame.origin.y + assetLabel.frame.size.height, frame.size.width, labelHeight)];
        fiatBalanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:fontSize];
        fiatBalanceLabel.textColor = labelTextColor;
        [self addSubview:fiatBalanceLabel];
        self.fiatBalanceLabel = fiatBalanceLabel;

        UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, fiatBalanceLabel.frame.origin.y + fiatBalanceLabel.frame.size.height, frame.size.width, labelHeight)];
        balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:fontSize];
        balanceLabel.textColor = labelTextColor;
        balanceLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:balanceLabel];
        self.balanceLabel = balanceLabel;
    }
    
    return self;
}

- (void)changeBalance:(NSString *)balance
{
    self.balanceLabel.text = balance;
}

- (void)changeFiatBalance:(NSString *)balance
{
    self.fiatBalanceLabel.text = balance;
}

@end
