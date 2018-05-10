//
//  UIApplication+Suspend.h
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@implementation UIApplication (Suspend)

- (void)suspendApp
{
    [self performSelector:@selector(suspend)];
}

@end
