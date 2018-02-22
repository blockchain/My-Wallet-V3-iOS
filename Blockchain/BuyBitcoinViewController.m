//
//  BuyBitcoinViewController.m
//  Blockchain
//
//  Created by kevinwu on 1/27/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <stdio.h>
#import "BuyBitcoinViewController.h"
#import <WebKit/WebKit.h>
#import "NSString+NSString_EscapeQuotes.h"
#import "RootService.h"
#import <SafariServices/SafariServices.h>
#import "TransactionDetailNavigationController.h"

#define URL_BUY_WEBVIEW_SUFFIX @"/#/intermediate"

@interface BuyBitcoinViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic) WKWebView *webView;
@property (nonatomic) BOOL didInitiateTrade;
@property (nonatomic) BOOL isReady;
@property (nonatomic) NSString* queuedScript;
@end

NSString* loginWithGuidScript(NSString*, NSString*, NSString*);
NSString* loginWithJsonScript(NSString*, NSString*, NSString*, NSString*, BOOL);

@implementation BuyBitcoinViewController

- (id)init
{
    if (self = [super init]) {
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController* userController = [[WKUserContentController alloc] init];
        
        [userController addScriptMessageHandler:self name:WEBKIT_HANDLER_BUY_COMPLETED];
        [userController addScriptMessageHandler:self name:WEBKIT_HANDLER_FRONTEND_INITIALIZED];
        [userController addScriptMessageHandler:self name:WEBKIT_HANDLER_SHOW_TX];
        
        configuration.userContentController = userController;
        
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - DEFAULT_HEADER_HEIGHT) configuration:configuration];
        [self.view addSubview:self.webView];
        
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        self.webView.scrollView.scrollEnabled = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        NSString *walletOptionsRootURL = [app.wallet buySellWebviewRootURLString];
        NSString *urlString = walletOptionsRootURL ? [walletOptionsRootURL stringByAppendingString:URL_BUY_WEBVIEW_SUFFIX] : URL_BUY_WEBVIEW;
        NSURL *login = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:login cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
        [self.webView loadRequest:request];
        
    }
    return self;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *reqUrl = navigationAction.request.URL;

    if (reqUrl != nil && navigationAction.navigationType == WKNavigationTypeLinkActivated && [[UIApplication sharedApplication] canOpenURL:reqUrl]) {
        
        if (![[reqUrl.absoluteString lowercaseString] hasPrefix:@"http://"] &&
            ![[reqUrl.absoluteString lowercaseString] hasPrefix:@"https://"]) {
            [[UIApplication sharedApplication] openURL:reqUrl];
        } else {
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:reqUrl];
            if (safariViewController) {
                [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
            } else {
                [[UIApplication sharedApplication] openURL:reqUrl];
            }
        }
        
        return decisionHandler(WKNavigationActionPolicyCancel);
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:navigationAction.request.URL];
    if (safariViewController) {
        [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (app.certificatePinner && [challenge.protectionSpace.host hasSuffix:HOST_NAME_WALLET_SERVER]) {
        [app.certificatePinner didReceiveChallenge:challenge completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

NSString* loginWithGuidScript(NSString* guid, NSString* sharedKey, NSString* password)
{
    return [NSString stringWithFormat:@"activateMobileBuy('%@','%@','%@')", [guid escapeStringForJS], [sharedKey escapeStringForJS], [password escapeStringForJS]];
}


- (void)loginWithGuid:(NSString *)guid sharedKey:(NSString *)sharedKey password:(NSString *)password
{
    NSString *script = loginWithGuidScript(guid, sharedKey, password);
    [self runScriptWhenReady:script];
}

NSString* loginWithJsonScript(NSString* json, NSString* externalJson, NSString* magicHash, NSString* password, BOOL isNew)
{
    return [NSString stringWithFormat:@"activateMobileBuyFromJson('%@','%@','%@','%@',%d)", [json escapeStringForJS], [externalJson escapeStringForJS], [magicHash escapeStringForJS], [password escapeStringForJS], isNew];
}

- (void)loginWithJson:(NSString *)json externalJson:(NSString *)externalJson magicHash:(NSString *)magicHash password:(NSString *)password
{
    NSString *script = loginWithJsonScript(json, externalJson, magicHash, password, self.isNew);
    [self runScriptWhenReady:script];
}

- (void)runScript:(NSString *)script
{
    [self.webView evaluateJavaScript:script completionHandler:^(id result, NSError * _Nullable error) {
        DLog(@"Ran script with result %@, error %@", result, error);
        if (error != nil) {
            
            UIViewController *targetController;
            
            if (app.topViewControllerDelegate) {
                targetController = app.topViewControllerDelegate;
            } else {
                targetController = app.window.rootViewController;
            }
            
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:BC_STRING_BUY_WEBVIEW_ERROR_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
            [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
            [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_VIEW_DETAILS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController *errorDetailAlert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:[NSString stringWithFormat:@"%@: %@",[error localizedDescription], error.userInfo] preferredStyle:UIAlertControllerStyleAlert];
                [errorDetailAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
                [targetController presentViewController:errorDetailAlert animated:YES completion:nil];
            }]];

            [targetController presentViewController:errorAlert animated:YES completion:nil];
        }
    }];
}

- (void)runScriptWhenReady:(NSString *)script
{
    if (self.isReady) {
        [self runScript:script];
        self.queuedScript = nil;
    } else {
        self.queuedScript = script;
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    DLog(@"Received script message: '%@'", message.name);
    
    if ([message.name isEqual:WEBKIT_HANDLER_FRONTEND_INITIALIZED]) {
        self.isReady = YES;
        if (self.queuedScript != nil) {
            [self runScript:self.queuedScript];
            self.queuedScript = nil;
        }
    }

    if ([message.name isEqual:WEBKIT_HANDLER_BUY_COMPLETED]) {
        self.didInitiateTrade = YES;
    }

    if ([message.name isEqual:WEBKIT_HANDLER_SHOW_TX]) {
        [self dismissViewControllerAnimated:YES completion:^(){
            app.topViewControllerDelegate = nil;
            [self.delegate showCompletedTrade:message.body];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.presentedViewController isMemberOfClass:[UIImagePickerController class]] ||
        [self.navigationController.presentedViewController isMemberOfClass:[TransactionDetailNavigationController class]] ||
        [self.navigationController.presentedViewController isMemberOfClass:[SFSafariViewController class]]) {
        return;
    }
    
    if (self.didInitiateTrade) {
        [self.delegate watchPendingTrades:YES];
    } else {
        [self.delegate watchPendingTrades:NO];
    }
    
    if (self.isReady) {
        [self runScript:@"teardown()"];
    }
    
    self.queuedScript = nil;
    self.didInitiateTrade = NO;
    self.isReady = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSOperatingSystemVersion ios9_0_0 = (NSOperatingSystemVersion){.majorVersion = 9, .minorVersion = 0, .patchVersion = 0};
    if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios9_0_0]) {
        // Device is using iOS 8.x - iSignThis will not work, so inform user and close
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_BUY_AND_SELL_BITCOIN message:BC_STRING_BUY_SELL_NOT_SUPPORTED_IOS_8_WEB_LOGIN preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
