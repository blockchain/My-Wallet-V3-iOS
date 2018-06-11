//
//  MainViewController.h
//  Tube Delays
//
//  Created by Ben Reeves on 10/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "Assets.h"
#import "AssetSelectorView.h"

@protocol AssetDelegate
- (void)didSetAssetType:(LegacyAssetType)assetType;
- (void)selectorButtonClicked;
- (void)qrCodeButtonClicked;
@end

@interface TabViewController : UIViewController <UITabBarDelegate> {
    IBOutlet UITabBarItem *sendButton;
    IBOutlet UITabBarItem *dashBoardButton;
    IBOutlet UITabBarItem *overviewButton;
    IBOutlet UITabBarItem *requestButton;
    IBOutlet UITabBar *tabBar;
    IBOutlet UIView *bannerView;
    UIViewController *activeViewController;
	UIViewController *oldViewController;
    
	int selectedIndex;
}

@property(nonatomic, retain) UINavigationBar *navigationBar;
@property(nonatomic, retain) UIViewController *activeViewController;
@property(nonatomic, retain) UIViewController *oldViewController;
@property(nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic) IBOutlet AssetSelectorView *assetSelectorView;
@property (strong, nonatomic) IBOutlet UIView *assetControlContainer;
@property(nonatomic, retain) UIView *menuSwipeRecognizerView;
@property(nonatomic) UIView *tabBarGestureView;

@property (nonatomic) UIView *bannerPricesView;
@property (nonatomic) UILabel *ethPriceLabel;
@property (nonatomic) UILabel *btcPriceLabel;

@property (nonatomic) UIView *bannerSelectorView;
@property(weak, nonatomic) id <AssetDelegate> assetDelegate;
- (void)selectAsset:(LegacyAssetType)assetType;
- (void)setActiveViewController:(UIViewController *)nviewcontroller animated:(BOOL)animated index:(int)index;
- (void)addTapGestureRecognizerToTabBar:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)removeTapGestureRecognizerFromTabBar:(UITapGestureRecognizer *)tapGestureRecognizer;
- (int)selectedIndex;
- (void)updateBadgeNumber:(NSInteger)number forSelectedIndex:(int)index;
- (void)setTitleLabelText:(NSString *)text;
- (void)updateBalanceLabelText:(NSString *)text;
- (void)didFetchEthExchangeRate;
- (void)reloadSymbols;
@end
