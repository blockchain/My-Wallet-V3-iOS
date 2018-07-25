//
//  SettingsNavigationController.h
//  Blockchain
//
//  Created by Kevin Wu on 7/13/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCFadeView.h"

@interface SettingsNavigationController : UINavigationController <TopViewController>

@property (nonatomic) UILabel *headerLabel;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) BCFadeView *busyView;
@property(nonatomic, copy) void (^onDismissViewController)();

- (void)reload;
- (void)reloadAfterMultiAddressResponse;
- (void)showSettings;
- (void)showBackup;
- (void)showTwoStep;
@end
