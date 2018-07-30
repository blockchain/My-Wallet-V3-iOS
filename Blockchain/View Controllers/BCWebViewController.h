//
//  BCWebViewController.h
//  Blockchain
//
//  Created by Mark Pfluger on 10/9/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCWebViewController : UIViewController <UIWebViewDelegate> {
    UIWebView * webView;
}

- (id)initWithTitle:(NSString *)title;

- (void)loadURL:(NSString*)url;

@end
