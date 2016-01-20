//
//  WelcomeView.m
//  Blockchain
//
//  Created by Mark Pfluger on 9/23/14.
//  Copyright (c) 2014 Qkos Services Ltd. All rights reserved.
//

#import "BCWelcomeView.h"
#import "AppDelegate.h"
#import "LocalizationConstants.h"
#import "DebugTableViewController.h"

@implementation BCWelcomeView

UIImageView *imageView;
Boolean shouldShowAnimation;

-(id)init
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = appDelegate.window;
    
    shouldShowAnimation = true;
    
    self = [super initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height - 20)];
    
    if (self) {
        self.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
        
        // Logo
        UIImage *logo = [UIImage imageNamed:@"welcome_logo"];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake((window.frame.size.width -logo.size.width) / 2, 80, logo.size.width, logo.size.height)];
        imageView.image = logo;
        imageView.alpha = 0;
        
        [self addSubview:imageView];
        
        // Buttons
        self.createWalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.createWalletButton.frame = CGRectMake(40, self.frame.size.height - 220, 240, BUTTON_HEIGHT);
        self.createWalletButton.layer.cornerRadius = 16;
        self.createWalletButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.createWalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.createWalletButton setTitleColor:COLOR_BLOCKCHAIN_BLUE forState:UIControlStateNormal];
        [self.createWalletButton setTitle:[BC_STRING_CREATE_NEW_WALLET uppercaseString] forState:UIControlStateNormal];
        [self.createWalletButton setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.createWalletButton];
        self.createWalletButton.enabled = NO;
        self.createWalletButton.alpha = 0.0;
        
        self.existingWalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.existingWalletButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.existingWalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.existingWalletButton setTitle:BC_STRING_LOG_IN_TO_WALLET forState:UIControlStateNormal];
        self.existingWalletButton.frame = CGRectMake(20, self.frame.size.height - 160, 280, BUTTON_HEIGHT);
        [self.existingWalletButton setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
        [self addSubview:self.existingWalletButton];
        self.existingWalletButton.enabled = NO;
        self.existingWalletButton.alpha = 0.0;
        
        self.recoverWalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.recoverWalletButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.recoverWalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.recoverWalletButton setTitle:BC_STRING_RECOVER_FUNDS forState:UIControlStateNormal];
        self.recoverWalletButton.frame = CGRectMake(0, 0, 230, BUTTON_HEIGHT);
        self.recoverWalletButton.center = CGPointMake(self.frame.size.width / 2, self.existingWalletButton.center.y + BUTTON_HEIGHT);
        [self.recoverWalletButton setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
        [self addSubview:self.recoverWalletButton];
        self.recoverWalletButton.enabled = NO;
        self.recoverWalletButton.alpha = 0.0;
#ifdef ENABLE_DEBUG_MENU
        UIButton *debugButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 0, 80, 51)];
        debugButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        debugButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [debugButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)];
        [debugButton setTitle:BC_STRING_DEBUG forState:UIControlStateNormal];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGesture.minimumPressDuration = DURATION_LONG_PRESS_GESTURE_DEBUG;
        [debugButton addGestureRecognizer:longPressGesture];
        [self addSubview:debugButton];
#endif
        // Version
        [self setupVersionLabel];
    }
    
    return self;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [app showDebugMenu:DEBUG_PRESENTER_WELCOME_VIEW];
    }
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
    versionLabel.font = [UIFont systemFontOfSize:12];
    versionLabel.textAlignment = NSTextAlignmentRight;
    versionLabel.textColor = [UIColor whiteColor];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[@"CFBundleVersion"];
    NSString *versionAndBuild = [NSString stringWithFormat:@"%@ b%@", version, build];
    versionLabel.text =  [NSString stringWithFormat:@"%@", versionAndBuild];
    
    [self addSubview:versionLabel];
}

@end
