//
//  BCLine.m
//  Blockchain
//
//  Created by Mark Pfluger on 2/13/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCLine.h"
#import "Blockchain-Swift.h"

@implementation BCLine

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupAtYPosition:0];
}

- (id)initWithYPosition:(CGFloat)yPosition
{
    if (self == [super init]) {
        [self setupAtYPosition:yPosition];
    }
    
    return self;
}

- (void)setupAtYPosition:(CGFloat)yPosition
{
    float onePixelHeight = 1.0/[UIScreen mainScreen].scale;

    CGFloat windowWidth = UIApplication.sharedApplication.keyWindow.rootViewController.view.frame.size.width;
    UIView *onePixelLine = [[UIView alloc] initWithFrame:CGRectMake(0, yPosition, windowWidth, onePixelHeight)];
    
    onePixelLine.userInteractionEnabled = NO;
    [onePixelLine setBackgroundColor:self.backgroundColor ? : UIColor.grayLine];
    [self addSubview:onePixelLine];
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

@end
