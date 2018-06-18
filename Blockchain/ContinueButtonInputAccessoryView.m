//
//  ContinueButtonInputAccessoryView.m
//  Blockchain
//
//  Created by kevinwu on 11/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ContinueButtonInputAccessoryView.h"

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
        [continueButton addTarget:self action:@selector(continueButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        continueButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
        [self addSubview:continueButton];
        self.continueButton = continueButton;
        
        CGFloat closeButtonWidth = 50;
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - closeButtonWidth, 0, closeButtonWidth, BUTTON_HEIGHT)];
        [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        closeButton.backgroundColor = COLOR_BUTTON_DARK_GRAY;
        [self addSubview:closeButton];
        self.closeButton = closeButton;
    }
    return self;
}

- (void)continueButtonClicked
{
    [self.delegate continueButtonClicked];
}

- (void)closeButtonClicked
{
    [self.delegate closeButtonClicked];
}

- (void)enableContinueButton
{
    self.continueButton.enabled = YES;
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton setBackgroundColor:COLOR_BLOCKCHAIN_LIGHT_BLUE];
}

- (void)disableContinueButton
{
    self.continueButton.enabled = NO;
    [self.continueButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.continueButton setBackgroundColor:COLOR_BUTTON_KEYPAD_GRAY];
}

@end
