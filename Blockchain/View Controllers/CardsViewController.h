//
//  DashboardViewController.h
//  Blockchain
//
//  Created by kevinwu on 8/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnnouncementCardViewModel;

@interface CardsViewController : UIViewController
// TICKET: IOS-1249 - Refactor CardsViewController
@property (nonatomic) CGFloat cardsViewHeight;
@property (nonatomic) UIView *dashboardContentView;
@property (nonatomic) UIScrollView *dashboardScrollView;
- (void)reloadWelcomeCards;
- (void)animateHideCards;
- (void)showSingleCardWithViewModel:(AnnouncementCardViewModel *)viewModel;
@end
