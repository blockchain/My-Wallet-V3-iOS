//
//  BCModalViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 1/26/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCModalViewController.h"
#import "Blockchain-Swift.h"

@interface BCModalViewController ()
@property (nonatomic) UIView *modalView;
@end

@implementation BCModalViewController

- (id)initWithCloseType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText view:(UIView *)view
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.modalView = view;
        [self.view addSubview:self.modalView];
        CGRect frame = self.modalView.frame;
        frame.origin.y = self.view.frame.origin.y + DEFAULT_HEADER_HEIGHT;
        [self.modalView setFrame:frame];
        self.modalView.center = CGPointMake(self.view.center.x, self.modalView.center.y);
        self.closeType = closeType;
        
        if (showHeader) {
            UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, DEFAULT_HEADER_HEIGHT)];
            topBarView.backgroundColor = UIColor.brandPrimary;
            [self.view addSubview:topBarView];
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:FRAME_HEADER_LABEL];
            headerLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_TOP_BAR_TEXT];
            headerLabel.textColor = [UIColor whiteColor];
            headerLabel.textAlignment = NSTextAlignmentCenter;
            headerLabel.adjustsFontSizeToFitWidth = YES;
            headerLabel.text = headerText;
            headerLabel.center = CGPointMake(topBarView.center.x, headerLabel.center.y);
            [topBarView addSubview:headerLabel];
            
            if (closeType == ModalCloseTypeBack) {
                self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.backButton.frame = FRAME_BACK_BUTTON;
                self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                self.backButton.imageEdgeInsets = IMAGE_EDGE_INSETS_BACK_BUTTON_CHEVRON;
                [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MEDIUM]];
                [self.backButton setImage:[UIImage imageNamed:@"back_chevron_icon"] forState:UIControlStateNormal];
                [self.backButton setTitleColor:[UIColor colorWithWhite:0.56 alpha:1.0] forState:UIControlStateHighlighted];
                [self.backButton addTarget:self action:@selector(closeModalClicked) forControlEvents:UIControlEventTouchUpInside];
                [topBarView addSubview:self.backButton];
            }
            else if (closeType == ModalCloseTypeClose) {
                self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 80, 51)];
                self.closeButton.imageEdgeInsets = IMAGE_EDGE_INSETS_CLOSE_BUTTON_X;
                self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
                self.closeButton.center = CGPointMake(self.closeButton.center.x, headerLabel.center.y);
                [self.closeButton addTarget:self action:@selector(closeModalClicked) forControlEvents:UIControlEventTouchUpInside];
                [topBarView addSubview:self.closeButton];
            }
            
            [self.view bringSubviewToFront:topBarView];
        }
        else {
            self.myHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
            
            [self.view addSubview:self.myHolderView];
        }

    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeModalClicked) name:[ConstantsObjcBridge notificationKeyModalViewDismissed] object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)closeModalClicked
{
    [self.modalView removeFromSuperview];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeButtonClicked
{
    [self closeModalClicked];
}

@end
