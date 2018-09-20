//
//  BCCardView.m
//  Blockchain
//
//  Created by kevinwu on 3/28/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCCardView.h"
#import "Blockchain-Swift.h"

@interface BCCardView ()
@property (nonatomic) ActionType actionType;
@property (nonatomic) BOOL reducedHeightForPageIndicator;
@end

@implementation BCCardView

- (id)initWithContainerFrame:(CGRect)frame title:(NSString *)title description:(NSString *)description actionType:(ActionType)actionType imageName:(NSString *)imageName reducedHeightForPageIndicator:(BOOL)reducedHeightForPageIndicator delegate:(id<CardViewDelegate>)delegate
{
    if (self == [super init]) {
        self.delegate = delegate;
        self.actionType = actionType;
        self.reducedHeightForPageIndicator = reducedHeightForPageIndicator;
        self.frame = [self frameFromContainer:frame];
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.15;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect imageViewFrame;
        switch (actionType) {
            case ActionTypeBuySell:
                imageViewFrame = CGRectMake(0, 16, 100, self.frame.size.height - 32);
                break;
            default:
                imageViewFrame = CGRectMake(0, 16, 100, 100);
                break;
        }

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.image = [UIImage imageNamed:imageName];
        [self addSubview:imageView];
        
        CGFloat textWidth = self.frame.size.width - imageView.frame.size.width - 16;
        
        NSString *actionName;
        UIColor *actionColor, *titleColor;

        switch (actionType) {
            case ActionTypeScanQR:
                actionName = BC_STRING_SCAN_ADDRESS;
                actionColor = UIColor.brandPrimary;
                titleColor = actionColor;
                break;
            case ActionTypeShowReceive:
                actionName = BC_STRING_REQUEST;
                actionColor = UIColor.aqua;
                titleColor = actionColor;
                break;
            case ActionTypeBuyBitcoin:
                actionName = BC_STRING_BUY_AND_SELL_BITCOIN;
                actionColor = UIColor.brandSecondary;
                titleColor = actionColor;
                break;
            case ActionTypeBuySell:
                actionName = BC_STRING_GET_STARTED;
                actionColor = UIColor.brandPrimary;
                titleColor = UIColor.brandPrimary;
                break;
            default:
                break;
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width + 8, imageView.frame.origin.y, textWidth, 54)];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
        titleLabel.text = title;
        titleLabel.textColor = titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height, textWidth, 100 - titleLabel.frame.size.height)];
        descriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.adjustsFontSizeToFitWidth = YES;
        descriptionLabel.text = description;
        descriptionLabel.textColor = UIColor.gray5;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:descriptionLabel];
        
        CGFloat buttonYOrigin = descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height;
        
        UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x, buttonYOrigin, textWidth, self.frame.size.height - buttonYOrigin)];
        actionButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
        actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [actionButton setTitleColor:actionColor forState:UIControlStateNormal];
        [actionButton setTitle:actionName forState:UIControlStateNormal];
        UIImage *chevronImage = [UIImage imageNamed:@"chevron_right"];
        [actionButton setImage:[chevronImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        actionButton.tintColor = actionColor;
        
        [actionButton sizeToFit];
        actionButton.frame = CGRectInset(actionButton.frame, -8, -10);
        actionButton.frame = CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y, actionButton.frame.size.width, actionButton.frame.size.height);
        actionButton.center = CGPointMake(actionButton.center.x, buttonYOrigin + (self.frame.size.height - buttonYOrigin)/2);
        
        actionButton.titleEdgeInsets = UIEdgeInsetsMake(0, -actionButton.imageView.frame.size.width, 0, actionButton.imageView.frame.size.width);
        actionButton.imageEdgeInsets = UIEdgeInsetsMake(16, actionButton.titleLabel.frame.size.width + 4, 14, -actionButton.titleLabel.frame.size.width);
        actionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [actionButton addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:actionButton];
    }
    return self;
}

- (void)setupCloseButton
{
    CGRect closeFrame = CGRectMake(self.bounds.size.width - ConstantsObjcBridge.minimumTapTargetSize - 4, 4, ConstantsObjcBridge.minimumTapTargetSize, ConstantsObjcBridge.minimumTapTargetSize);
    UIButton *closeButton = [[UIButton alloc] initWithFrame:closeFrame];
    UIImage *buttonImage = [[UIImage imageNamed:@"close_large"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [closeButton setImage:buttonImage forState:UIControlStateNormal];
    closeButton.tintColor = UIColor.gray5;
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self addSubview:closeButton];
    self.closeButton = closeButton;
}

- (CGRect)frameFromContainer:(CGRect)containerFrame
{
    CGRect frame = CGRectInset(containerFrame, 8, 16);
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.reducedHeightForPageIndicator ? frame.size.height - 32 : frame.size.height);
}

- (void)actionButtonClicked
{
    [self.delegate cardActionClicked:self.actionType];
}

@end
