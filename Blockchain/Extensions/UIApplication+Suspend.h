//
//  UIApplication+Suspend.h
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Suspend)

/**
 Suspends the current UIApplication. Used mainly by legacy code and using this
 should be avoided if possible.
 */
- (void)suspendApp;

@end
