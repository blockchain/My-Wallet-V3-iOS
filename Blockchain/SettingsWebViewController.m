//
//  SettingsWebViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 7/15/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SettingsWebViewController.h"
#import "SettingsNavigationController.h"
#import "DebugTableViewController.h"
#import "Blockchain-Swift.h"

@interface SettingsWebViewController ()
@property (nonatomic) UIWebView *webView;
@property (nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic) UIButton *debugButton;
@end

@implementation SettingsWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSURL *url = [NSURL URLWithString:self.urlTargetString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:urlRequest];
    self.webView.scalesPageToFit = YES;
}

#pragma mark Debug Menu

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#ifdef DEBUG
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGesture.minimumPressDuration = DURATION_LONG_PRESS_GESTURE_DEBUG;
    self.debugButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 80, 51)];
    self.debugButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.debugButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.debugButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)];
    [self.debugButton setTitle:DEBUG_STRING_DEBUG forState:UIControlStateNormal];
    [self.navigationController.view addSubview:self.debugButton];
    [self.debugButton addGestureRecognizer:self.longPressGesture];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.longPressGesture = nil;
    [self.debugButton removeFromSuperview];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        DebugTableViewController *debugViewController = [[DebugTableViewController alloc] init];
        debugViewController.presenter = DEBUG_PRESENTER_SETTINGS_ABOUT;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:debugViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

@end
