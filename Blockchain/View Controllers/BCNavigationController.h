//
//  BCNavigationController.h
//  Blockchain
//
//  Created by Kevin Wu on 10/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCFadeView.h"

@interface BCNavigationController : UINavigationController <TopViewController>
@property (nonatomic) UIView *topBar;
@property (nonatomic) BCFadeView *busyView;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UILabel *headerLabel;
@property (nonatomic) UILabel *busyLabel;
@property (nonatomic) NSString *headerTitle;
@property (nonatomic) UIButton *topRightButton;

@property (nonatomic) BOOL shouldHideBusyView;

@property(nonatomic, copy) void (^onPopViewController)(void);
@property(nonatomic, copy) void (^onViewWillDisappear)(void);

- (void)applyLightAppearance;
- (void)applyDarkAppearance;

- (_Nonnull id)initWithRootViewController:(UIViewController *)rootViewController title:(NSString *)title;
- (void)showBusyViewWithLoadingText:(NSString *)text;
- (void)hideBusyView;

@end
