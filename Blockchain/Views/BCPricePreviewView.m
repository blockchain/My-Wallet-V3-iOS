//
//  BCPricePreviewView.m
//  Blockchain
//
//  Created by kevinwu on 2/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCPricePreviewView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface BCPricePreviewView ()
@property (nonatomic) UILabel *priceLabel;
@property (nonatomic) UIView *containerView;
@end

@implementation BCPricePreviewView

- (id)initWithFrame:(CGRect)frame assetName:(NSString *)name price:(NSString *)price assetImage:(NSString *)assetImage
{
    if (self == [super initWithFrame:frame]) {
        
        CGSize shadowOffset = CGSizeMake(0, 2);
        CGFloat shadowRadius = 3;
        float shadowOpacity = 0.25;
        
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = shadowOffset;
        self.layer.shadowRadius = shadowRadius;
        self.layer.shadowOpacity = shadowOpacity;
        
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 0, 24)];
        titleLabel.text = [[name stringByAppendingFormat:@" %@", BC_STRING_PRICE] uppercaseString];
        titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_EXTRALIGHT size:FONT_SIZE_EXTRA_SMALL];
        titleLabel.textColor = UIColor.brandPrimary;
        [titleLabel sizeToFit];
        titleLabel.center = CGPointMake(self.frame.size.width/2, titleLabel.center.y);
        [self addSubview:titleLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, 0, 30)];
        priceLabel.text = price;
        priceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_LARGE];
        priceLabel.textColor = UIColor.brandPrimary;
        [priceLabel sizeToFit];
        priceLabel.center = CGPointMake(self.frame.size.width/2, priceLabel.center.y);
        [self addSubview:priceLabel];
        
        self.priceLabel = priceLabel;
        
        UILabel *seeChartsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        seeChartsLabel.textColor = UIColor.brandSecondary;
        seeChartsLabel.text = BC_STRING_SEE_CHARTS;
        seeChartsLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];
        [seeChartsLabel sizeToFit];
        seeChartsLabel.center = CGPointMake(seeChartsLabel.center.x, 20);
        
        CGFloat imageViewWidth = 22;
        [seeChartsLabel changeXPosition:imageViewWidth + 8];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewWidth)];
        imageView.image = [[UIImage imageNamed:assetImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.tintColor = UIColor.brandSecondary;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, priceLabel.frame.origin.y + priceLabel.frame.size.height + 8, imageViewWidth + seeChartsLabel.frame.size.width + 8, 40)];
        [containerView addSubview:seeChartsLabel];
        [containerView addSubview:imageView];
        [imageView changeYPosition:(containerView.frame.size.height - imageViewWidth)/2];
        [self addSubview:containerView];
        
        containerView.center = CGPointMake(frame.size.width/2, containerView.center.y);
        self.containerView = containerView;
    }
    
    return self;
}

- (void)updatePrice:(NSString *)price
{
    self.priceLabel.text = price;
    [self.priceLabel sizeToFit];
    self.priceLabel.center = CGPointMake(self.frame.size.width/2, self.priceLabel.center.y);
    
    [self.containerView changeYPosition:self.priceLabel.frame.origin.y + self.priceLabel.frame.size.height + 8];
}

@end
