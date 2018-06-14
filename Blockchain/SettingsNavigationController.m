//
//  SettingsNavigationController.m
//  Blockchain
//
//  Created by Kevin Wu on 7/13/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SettingsNavigationController.h"
#import "SettingsTableViewController.h"
#import "Blockchain-Swift.h"

@interface SettingsNavigationController ()
@end

@implementation SettingsNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIWindow *window = UIApplication.sharedApplication.keyWindow;

    CGFloat safeAreaInsetTop;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
    } else {
        safeAreaInsetTop = 20;
    }

    self.view.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);

    CGRect topBarFrame = CGRectMake(0, 0, self.view.frame.size.width, ConstantsObjcBridge.defaultNavigationBarHeight + safeAreaInsetTop);
    UIView *topBar = [[UIView alloc] initWithFrame:topBarFrame];
    topBar.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    [self.view addSubview:topBar];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, safeAreaInsetTop + 6, 200, 30)];
    headerLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_TOP_BAR_TEXT];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.text = BC_STRING_SETTINGS;
    headerLabel.center = CGPointMake(topBar.center.x, headerLabel.center.y);
    [topBar addSubview:headerLabel];
    self.headerLabel = headerLabel;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MEDIUM]];
    [backButton setImage:[UIImage imageNamed:@"back_chevron_icon"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithWhite:0.56 alpha:1.0] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backButton];
    self.backButton = backButton;
    
    BCFadeView *busyView = [[BCFadeView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.rootViewController.view.frame];
    busyView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    UIView *textWithSpinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 110)];
    textWithSpinnerView.backgroundColor = [UIColor whiteColor];
    [busyView addSubview:textWithSpinnerView];
    textWithSpinnerView.center = busyView.center;
    
    UILabel *busyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BUSY_VIEW_LABEL_WIDTH, BUSY_VIEW_LABEL_HEIGHT)];
    busyLabel.adjustsFontSizeToFitWidth = YES;
    busyLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:BUSY_VIEW_LABEL_FONT_SYSTEM_SIZE];
    busyLabel.alpha = BUSY_VIEW_LABEL_ALPHA;
    busyLabel.textAlignment = NSTextAlignmentCenter;
    busyLabel.text = [LocalizationConstantsObjcBridge syncingWallet];
    busyLabel.center = CGPointMake(textWithSpinnerView.bounds.origin.x + textWithSpinnerView.bounds.size.width/2, textWithSpinnerView.bounds.origin.y + textWithSpinnerView.bounds.size.height/2 + 15);
    [textWithSpinnerView addSubview:busyLabel];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(textWithSpinnerView.bounds.origin.x + textWithSpinnerView.bounds.size.width/2, textWithSpinnerView.bounds.origin.y + textWithSpinnerView.bounds.size.height/2 - 15);
    [textWithSpinnerView addSubview:spinner];
    [textWithSpinnerView bringSubviewToFront:spinner];
    [spinner startAnimating];

    busyView.containerView = textWithSpinnerView;
    [busyView fadeOut];
    
    [self.view addSubview:busyView];
    
    [self.view bringSubviewToFront:busyView];
    
    self.busyView = busyView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (self.viewControllers.count == 1) {
        self.backButton.frame = CGRectMake(self.view.frame.size.width - 80, 15, 80, 51);
        self.backButton.imageEdgeInsets = IMAGE_EDGE_INSETS_CLOSE_BUTTON_X;
        self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    } else {
        self.backButton.frame = CGRectMake(0, 15, 85, 51);
        self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.backButton setTitle:@"" forState:UIControlStateNormal];
        self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [self.backButton setImage:[UIImage imageNamed:@"back_chevron_icon"] forState:UIControlStateNormal];
    }
    self.backButton.center = CGPointMake(self.backButton.center.x, self.headerLabel.center.y);
}

- (void)backButtonClicked:(UIButton *)sender
{
    if ([self.visibleViewController isMemberOfClass:[SettingsTableViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self popViewControllerAnimated:YES];
    }
}

- (void)reload
{
    [self.busyView fadeOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RELOAD_SETTINGS object:nil];
}

- (void)reloadAfterMultiAddressResponse
{
    [self.busyView fadeOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RELOAD_SETTINGS_AFTER_MULTIADDRESS object:nil];
}

- (void)showSettings
{
    [self popToRootViewControllerAnimated:NO];
}

- (void)showBackup
{
    if ([self.visibleViewController isMemberOfClass:[SettingsTableViewController class]]) {
        SettingsTableViewController *tableViewController = (SettingsTableViewController *)self.visibleViewController;
        [tableViewController showBackup];
    } else {
        DLog(@"Error: Settings Navigation Controller's visible view controller is not a SettingsTableViewController!");
    }
}

- (void)showTwoStep
{
    if ([self.visibleViewController isMemberOfClass:[SettingsTableViewController class]]) {
        SettingsTableViewController *tableViewController = (SettingsTableViewController *)self.visibleViewController;
        [tableViewController showTwoStep];
    } else {
        DLog(@"Error: Settings Navigation Controller's visible view controller is not a SettingsTableViewController!");
    }
}

#pragma mark Top View Controller Delegate

- (void)showBusyViewWithLoadingText:(NSString *)text
{
    //TODO: use this delegate method instead of handling busy views manually from view controllers
    return;
}

- (void)updateBusyViewLoadingText:(NSString *)text
{
    //TODO: use this delegate method instead of handling busy views manually from view controllers
    return;
}

- (void)hideBusyView
{
    //TODO: use this delegate method instead of handling busy views manually from view controllers
    return;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:completion];
    
    if (self.onDismissViewController) {
        self.onDismissViewController();
        self.onDismissViewController = nil;
    }
}

@end
