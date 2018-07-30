//
//  BCQRCodeView.m
//  Blockchain
//
//  Created by Kevin Wu on 1/29/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCQRCodeView.h"
#import "QRCodeGenerator.h"
#import "Blockchain-Swift.h"

const float imageWidth = 190;

@interface BCQRCodeView ()
@property (nonatomic) QRCodeGenerator *qrCodeGenerator;
@property (nonatomic) BOOL shouldAddAddressPrefix;
@end

@implementation BCQRCodeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithQRHeaderText:nil];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame qrHeaderText:(NSString *)qrHeaderText addAddressPrefix:(BOOL)addPrefix
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupWithQRHeaderText:qrHeaderText];
        self.shouldAddAddressPrefix = addPrefix;
    }
    return self;
}

- (void)setupWithQRHeaderText:(NSString *)qrHeaderText
{
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *qrCodeHeaderLabel;
    if (qrHeaderText) {
        qrCodeHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 64)];
        qrCodeHeaderLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
        qrCodeHeaderLabel.textColor = UIColor.gray5;
        qrCodeHeaderLabel.numberOfLines = 5;
        qrCodeHeaderLabel.textAlignment = NSTextAlignmentCenter;
        qrCodeHeaderLabel.text = qrHeaderText;
        qrCodeHeaderLabel.center = CGPointMake(self.center.x, qrCodeHeaderLabel.center.y);
        [self addSubview:qrCodeHeaderLabel];
    }
    
    CGFloat qrCodeImageViewYPosition = qrCodeHeaderLabel ? qrCodeHeaderLabel.frame.origin.y + qrCodeHeaderLabel.frame.size.height + 15 : 25 ;
    
    self.qrCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - imageWidth) / 2, qrCodeImageViewYPosition, imageWidth, imageWidth)];
    [self addSubview:self.qrCodeImageView];
    
    self.qrCodeFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.qrCodeImageView.frame.origin.y + self.qrCodeImageView.frame.size.height + 15, 280, 24)];
    self.qrCodeFooterLabel.textColor = UIColor.gray5;
    self.qrCodeFooterLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
    self.qrCodeFooterLabel.textAlignment = NSTextAlignmentCenter;
    self.qrCodeFooterLabel.adjustsFontSizeToFitWidth = YES;
    self.qrCodeFooterLabel.center = CGPointMake(self.center.x, self.qrCodeFooterLabel.center.y);
    
    UITapGestureRecognizer *tapFooterLabelGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(QRCodeClicked)];
    [self.qrCodeFooterLabel addGestureRecognizer:tapFooterLabelGestureRecognizer];
    self.qrCodeFooterLabel.userInteractionEnabled = YES;
    
    [self addSubview:self.qrCodeFooterLabel];
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.doneButton.backgroundColor = UIColor.brandSecondary;
    self.doneButton.layer.cornerRadius = 4;
    [self.doneButton setTitle:BC_STRING_DONE forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:13];
    [self.doneButton addTarget:self action:@selector(doneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.doneButton];
    self.doneButton.center = CGPointMake(self.center.x, self.frame.size.height - 100);
}

- (QRCodeGenerator *)qrCodeGenerator
{
    if (!_qrCodeGenerator) {
        _qrCodeGenerator = [[QRCodeGenerator alloc] init];
    }
    return _qrCodeGenerator;
}

- (void)setAddress:(NSString *)address
{
    _address = address;
    
    self.qrCodeImageView.image = self.shouldAddAddressPrefix ? [self.qrCodeGenerator qrImageFromAddress:address] : [self.qrCodeGenerator createQRImageFromString:address];
    self.qrCodeFooterLabel.text = address;
}

- (void)QRCodeClicked
{
    [UIPasteboard generalPasteboard].string = self.address;
    [self animateTextOfLabel:self.qrCodeFooterLabel toIntermediateText:BC_STRING_COPIED_TO_CLIPBOARD speed:1 gestureReceiver:self.qrCodeFooterLabel];
}

- (void)doneButtonClicked
{
    [self.doneButtonDelegate doneButtonClicked];
}

- (void)animateTextOfLabel:(UILabel *)labelToAnimate toIntermediateText:(NSString *)intermediateText speed:(float)speed gestureReceiver:(UIView *)gestureReceiver
{
    gestureReceiver.userInteractionEnabled = NO;
    
    CGRect originalFrame = labelToAnimate.frame;
    NSString *originalText = labelToAnimate.text;
    UIColor *originalTextColor = labelToAnimate.textColor;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        labelToAnimate.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        labelToAnimate.text = intermediateText;
        [labelToAnimate sizeToFit];
        labelToAnimate.center = CGPointMake(self.center.x, labelToAnimate.center.y);
        
        UIImageView *checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(labelToAnimate.frame.origin.x - labelToAnimate.frame.size.height - 5, labelToAnimate.frame.origin.y, labelToAnimate.frame.size.height, labelToAnimate.frame.size.height)];
        checkImageView.image = [UIImage imageNamed:@"check"];
        checkImageView.image = [checkImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        checkImageView.tintColor = UIColor.green;
        [self addSubview:checkImageView];
        checkImageView.alpha = 0.0;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            labelToAnimate.text = intermediateText;
            labelToAnimate.textColor = UIColor.green;
            labelToAnimate.alpha = 1.0;
            checkImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    labelToAnimate.alpha = 0.0;
                    checkImageView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    
                    labelToAnimate.frame = originalFrame;
                    
                    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                        labelToAnimate.text = originalText;
                        labelToAnimate.textColor = originalTextColor;
                        labelToAnimate.alpha = 1.0;
                        gestureReceiver.userInteractionEnabled = YES;
                    } completion:^(BOOL finished) {
                        [checkImageView removeFromSuperview];
                    }];
                }];
            });
        }];
    }];
}


@end
