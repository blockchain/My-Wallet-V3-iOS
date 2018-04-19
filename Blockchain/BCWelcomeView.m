//
//  WelcomeView.m
//  Blockchain
//
//  Created by Mark Pfluger on 9/23/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCWelcomeView.h"
#import "LocalizationConstants.h"
#import "DebugTableViewController.h"
#import "Blockchain-Swift.h"

@implementation BCWelcomeView

UIImageView *imageView;
Boolean shouldShowAnimation;

-(id)init
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    shouldShowAnimation = true;
    
    self = [super initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height - 20)];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        // Logo
        UIImage *logo = [UIImage imageNamed:@"logo_both"];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake((window.frame.size.width -logo.size.width) / 2, 80, logo.size.width, logo.size.height)];
        imageView.image = logo;
        imageView.alpha = 0;
        
        [self addSubview:imageView];
        
        // Buttons
        self.createWalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.createWalletButton.frame = CGRectMake(0, self.frame.size.height - 230, 240, BUTTON_HEIGHT);
        self.createWalletButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
        self.createWalletButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
        self.createWalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.createWalletButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.createWalletButton.titleEdgeInsets = WELCOME_VIEW_BUTTON_EDGE_INSETS;
        self.createWalletButton.center = CGPointMake(self.center.x, self.createWalletButton.center.y);
        [self.createWalletButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.createWalletButton setTitle:[BC_STRING_CREATE_A_WALLET uppercaseString] forState:UIControlStateNormal];
        [self.createWalletButton setBackgroundColor:COLOR_BLOCKCHAIN_LIGHT_BLUE];
        [self addSubview:self.createWalletButton];
        self.createWalletButton.enabled = NO;
        self.createWalletButton.alpha = 0.0;
        
        self.existingWalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.existingWalletButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
        self.existingWalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.existingWalletButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
        [self.existingWalletButton setTitle:[BC_STRING_LOG_IN uppercaseString] forState:UIControlStateNormal];
        self.existingWalletButton.frame = CGRectMake(0, self.frame.size.height - 160, 240, BUTTON_HEIGHT);
        [self.existingWalletButton setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
        [self addSubview:self.existingWalletButton];
        self.existingWalletButton.enabled = NO;
        self.existingWalletButton.center = CGPointMake(self.center.x, self.existingWalletButton.center.y);
        self.existingWalletButton.alpha = 0.0;
        
        self.recoverWalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.recoverWalletButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
        self.recoverWalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.recoverWalletButton setTitleColor:COLOR_BLOCKCHAIN_BLUE forState:UIControlStateNormal];
        [self.recoverWalletButton setTitle:[BC_STRING_RECOVER_FUNDS uppercaseString] forState:UIControlStateNormal];
        self.recoverWalletButton.frame = CGRectMake(0, self.frame.size.height - 90, 240, BUTTON_HEIGHT);
        self.recoverWalletButton.center = CGPointMake(self.center.x, self.recoverWalletButton.center.y);
        [self.recoverWalletButton setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.recoverWalletButton];
        self.recoverWalletButton.enabled = NO;
        self.recoverWalletButton.alpha = 0.0;
#ifdef DEBUG
        UIButton *debugButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 0, 80, 51)];
        debugButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        debugButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [debugButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)];
        [debugButton setTitle:DEBUG_STRING_DEBUG forState:UIControlStateNormal];
        [debugButton setTitleColor:COLOR_BLOCKCHAIN_BLUE forState:UIControlStateNormal];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGesture.minimumPressDuration = DURATION_LONG_PRESS_GESTURE_DEBUG;
        [debugButton addGestureRecognizer:longPressGesture];
        [self addSubview:debugButton];
#endif
        // Version
        [self setupVersionLabel];
        
        // Add touch handlers to buttons
        [self.createWalletButton addTarget:self action:@selector(showCreateWallet:) forControlEvents:UIControlEventTouchUpInside];
        [self.existingWalletButton addTarget:self action:@selector(showPairWallet:) forControlEvents:UIControlEventTouchUpInside];
        [self.recoverWalletButton addTarget:self action:@selector(showRecoverWallet:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)showCreateWallet:(id)sender
{
    [self.delegate showCreateWallet];
}

- (void)showPairWallet:(id)sender
{
    [self.delegate showPairWallet];
}

- (void)showRecoverWallet:(id)sender
{
    [self.delegate showRecoverWallet];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [[AppCoordinator sharedInstance] showDebugViewWithPresenter: DEBUG_PRESENTER_WELCOME_VIEW];
    }
}

- (void)didMoveToWindow
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didMoveToSuperview
{
    // If the animation has started already, don't show it again until init is called again
    if (!shouldShowAnimation) {
        return;
    }
    shouldShowAnimation = false;
    
    // Some nice animations
    [UIView animateWithDuration:2*ANIMATION_DURATION
                     animations:^{
                         // Fade in logo
                         imageView.alpha = 1.0;
                         
                         // Fade in controls
                         self.createWalletButton.alpha = 1.0;
                         self.existingWalletButton.alpha = 1.0;
                         self.recoverWalletButton.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         // Activate controls
                         self.createWalletButton.enabled = YES;
                         self.existingWalletButton.enabled = YES;
                         self.recoverWalletButton.enabled = YES;
                     }];
}

- (void)setupVersionLabel
{
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.frame.size.height - 30, self.frame.size.width - 30, 20)];
    versionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    versionLabel.textAlignment = NSTextAlignmentRight;
    versionLabel.textColor = COLOR_BLOCKCHAIN_BLUE;

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[@"CFBundleVersion"];
    NSString *versionAndBuild = [NSString stringWithFormat:@"%@ b%@", version, build];
    versionLabel.text =  [NSString stringWithFormat:@"%@", versionAndBuild];
    
    [self addSubview:versionLabel];
}

@end
