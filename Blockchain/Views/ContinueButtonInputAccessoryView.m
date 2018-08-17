//
//  ContinueButtonInputAccessoryView.m
//  Blockchain
//
//  Created by kevinwu on 11/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ContinueButtonInputAccessoryView.h"
#import "Blockchain-Swift.h"

@interface ContinueButtonInputAccessoryView()
@property (nonatomic) UIButton *continueButton;
@property (nonatomic) UIButton *closeButton;
@end
@implementation ContinueButtonInputAccessoryView

- (id)init
{
    CGFloat windowWidth = UIApplication.sharedApplication.keyWindow.rootViewController.view.frame.size.width;
    if (self = [super initWithFrame:CGRectMake(0, 0, windowWidth, BUTTON_HEIGHT)]) {
        UIButton *continueButton = [[UIButton alloc] initWithFrame:self.bounds];
        [continueButton setTitle:BC_STRING_CONTINUE forState:UIControlStateNormal];
        continueButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
        [continueButton addTarget:self action:@selector(continueButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        continueButton.backgroundColor = UIColor.brandSecondary;
        [self addSubview:continueButton];
        self.continueButton = continueButton;
        
        CGFloat closeButtonWidth = 50;
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - closeButtonWidth, 0, closeButtonWidth, BUTTON_HEIGHT)];
        [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        closeButton.backgroundColor = UIColor.gray4;
        [self addSubview:closeButton];
        self.closeButton = closeButton;
    }
    return self;
}

- (void)continueButtonTapped
{
    [self.delegate continueButtonTapped];
}

- (void)closeButtonTapped
{
    [self.delegate closeButtonTapped];
}

- (void)enableContinueButton
{
    self.continueButton.enabled = YES;
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton setBackgroundColor:UIColor.brandSecondary];
}

- (void)disableContinueButton
{
    self.continueButton.enabled = NO;
    [self.continueButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.continueButton setBackgroundColor:UIColor.keyPadButton];
}

@end
