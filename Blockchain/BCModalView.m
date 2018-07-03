//
//  BCModalView.m
//  Blockchain
//
//  Created by Ben Reeves on 19/07/2014.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCModalView.h"
#import "LocalizationConstants.h"
#import "Blockchain-Swift.h"

// TODO: deprecate BCModalView
@implementation BCModalView

- (id)initWithCloseType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //: Pre iOS 11 devices only need to consider the status bar (20pt)
    CGFloat safeAreaInsetTop = 20;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
    }
    
    self = [super initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.closeType = closeType;

        if (showHeader) {
            // TODO: use UINavigationBar & autolayout
            CGFloat topBarHeight = [ConstantsObjcBridge defaultNavigationBarHeight] + safeAreaInsetTop;
            UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, topBarHeight)];
            topBarView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
            [self addSubview:topBarView];

            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            headerLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_TOP_BAR_TEXT];
            headerLabel.textColor = [UIColor whiteColor];
            headerLabel.textAlignment = NSTextAlignmentCenter;
            headerLabel.adjustsFontSizeToFitWidth = YES;
            headerLabel.text = headerText;
            [headerLabel sizeToFit];
            CGFloat labelWidth = MIN(headerLabel.frame.size.width, topBarView.frame.size.width - 105);
            CGFloat labelHeight = headerLabel.frame.size.height;
            CGFloat labelPosX = (topBarView.frame.size.width / 2) - (labelWidth / 2);
            CGFloat labelPosY = (topBarView.frame.size.height / 2) - (headerLabel.frame.size.height / 2) + (safeAreaInsetTop / 2);
            CGRect frame = CGRectMake(labelPosX, labelPosY, labelWidth, labelHeight);
            [headerLabel setFrame:frame];
            [topBarView addSubview:headerLabel];

            if (closeType == ModalCloseTypeBack) {
                self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 44)];
                self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                self.backButton.center = CGPointMake(self.backButton.center.x, headerLabel.center.y);
                [self.backButton setImage:[UIImage imageNamed:@"back_chevron_icon"] forState:UIControlStateNormal];
                [self.backButton addTarget:self action:@selector(closeModalClicked:) forControlEvents:UIControlEventTouchUpInside];
                [topBarView addSubview:self.backButton];
            } else if (closeType == ModalCloseTypeClose) {
                CGFloat rightEdgeInset = 8;
                self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 37 - rightEdgeInset, 0, 37, 44)];
                self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                self.closeButton.center = CGPointMake(self.closeButton.center.x, headerLabel.center.y);
                [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
                [self.closeButton addTarget:self action:@selector(closeModalClicked:) forControlEvents:UIControlEventTouchUpInside];
                [topBarView addSubview:self.closeButton];
            }

            if (@available(iOS 11.0, *)) {
                CGRect frame = window.rootViewController.view.safeAreaLayoutGuide.layoutFrame;
                CGFloat topInset = window.rootViewController.view.safeAreaInsets.top;
                CGFloat posX = frame.origin.x;
                CGFloat posY = topBarView.frame.size.height;
                CGFloat height = frame.size.height - topBarView.frame.size.height + topInset;
                CGFloat width = frame.size.width;
                self.myHolderView = [[UIView alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
            } else {
                self.myHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, topBarView.frame.size.height, window.frame.size.width, window.frame.size.height - DEFAULT_HEADER_HEIGHT)];
            }

            [self addSubview:self.myHolderView];
            
            [self bringSubviewToFront:topBarView];
        } else {
            if (@available(iOS 11.0, *)) {
                self.myHolderView = [[UIView alloc] initWithFrame:window.rootViewController.view.safeAreaLayoutGuide.layoutFrame];
            } else {
                self.myHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, safeAreaInsetTop, window.frame.size.width, window.frame.size.height - safeAreaInsetTop)];
            }
            [self addSubview:self.myHolderView];
        }
    }
    
    return self;
}

- (IBAction)closeModalClicked:(id)sender
{
    if (self.closeType != ModalCloseTypeNone) {
        // Not pretty but works
        if ([self.myHolderView.subviews[0] respondsToSelector:@selector(prepareForModalDismissal)]) {
            [self.myHolderView.subviews[0] prepareForModalDismissal];
        }
        if ([self.myHolderView.subviews[0] respondsToSelector:@selector(modalWasDismissed)]) {
            [self.myHolderView.subviews[0] modalWasDismissed];
        }
        
        if (self.closeType == ModalCloseTypeBack) {
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFromLeft];
        }
        else {
            [self endEditing:YES];
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
        }
    }
}

@end
