//
//  MainViewController.m
//  Tube Delays
//
//  Created by Ben Reeves on 10/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TabViewController.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface TabViewController () <AssetSelectorViewDelegate>
@end

@implementation TabViewController

@synthesize oldViewController;
@synthesize activeViewController;
@synthesize contentView;

UILabel *titleLabel;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.assetSelectorView = [[AssetSelectorView alloc] initWithFrame:CGRectMake(0, 0, bannerView.bounds.size.width, bannerView.bounds.size.height) delegate:self];
    [bannerView addSubview:self.assetSelectorView];

    [self setupNavigationItemTitleView];
    
    tabBar.delegate = self;

    selectedIndex = TAB_DASHBOARD;
    
    [self setupTabButtons];
}

- (void)viewDidLayoutSubviews
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat safeAreaInsetBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetBottom = window.rootViewController.view.safeAreaInsets.bottom;
    }
    _tabBarBottomConstraint.constant = safeAreaInsetBottom;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Add side bar to swipe open the sideMenu
    if (!_menuSwipeRecognizerView) {
        _menuSwipeRecognizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.view.frame.size.height)];
        
        ECSlidingViewController *sideMenu = [AppCoordinator sharedInstance].slidingViewController;
        [_menuSwipeRecognizerView addGestureRecognizer:sideMenu.panGesture];
        
        [self.view addSubview:_menuSwipeRecognizerView];
    }
}

/**
 Setup custom title view for tap gesture support
 - SeeAlso:
 [titleView](https://developer.apple.com/documentation/uikit/uinavigationitem/1624935-titleview)
 */
- (void)setupNavigationItemTitleView
{
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationBar.frame.size.height)];
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:20];
    titleLabel.textColor = UIColor.whiteColor;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSymbol)];
    [titleLabel addGestureRecognizer:tapGesture];

    self.navigationItem.titleView = titleLabel;
}

- (void)toggleSymbol
{
    BlockchainSettings.sharedAppInstance.symbolLocal = !BlockchainSettings.sharedAppInstance.symbolLocal;
}

- (void)setupTabButtons
{
    NSDictionary *tabButtons = @{BC_STRING_SEND:sendButton, BC_STRING_DASHBOARD:dashBoardButton, BC_STRING_TRANSACTIONS:overviewButton, BC_STRING_REQUEST:requestButton};
    
    for (UITabBarItem *button in [tabButtons allValues]) {
        NSString *label = [[tabButtons allKeysForObject:button] firstObject];
        button.title = label;
        button.image = [button.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        button.selectedImage = [button.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL], NSForegroundColorAttributeName : COLOR_TEXT_DARK_GRAY} forState:UIControlStateNormal];
        [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL], NSForegroundColorAttributeName : COLOR_BLOCKCHAIN_LIGHT_BLUE} forState:UIControlStateSelected];
    }
}

- (void)setActiveViewController:(UIViewController *)nviewcontroller
{
    [self setActiveViewController:nviewcontroller animated:NO index:selectedIndex];
}

- (void)setActiveViewController:(UIViewController *)nviewcontroller animated:(BOOL)animated index:(int)newIndex
{
    if (nviewcontroller == activeViewController)
        return;
    
    self.oldViewController = activeViewController;
    
    activeViewController = nviewcontroller;

    CGFloat previousSelectedIndex = selectedIndex;
    
    [self setSelectedIndex:newIndex];

    [self insertActiveView];
    
    self.oldViewController = nil;
    
    if (animated) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:ANIMATION_DURATION];
        [animation setType:kCATransitionPush];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        
        if (newIndex > previousSelectedIndex || (newIndex == previousSelectedIndex && self.assetSelectorView.selectedAsset == LegacyAssetTypeEther)) {
            [animation setSubtype:kCATransitionFromRight];
        } else {
            [animation setSubtype:kCATransitionFromLeft];
        }
        
        [[contentView layer] addAnimation:animation forKey:@"SwitchToView1"];
    }
    
    [self updateTopBarForIndex:newIndex];
}

- (void)insertActiveView
{
    if ([contentView.subviews count] > 0) {
        [[contentView.subviews firstObject] removeFromSuperview];
    }
    
    [contentView addSubview:activeViewController.view];

    CGFloat offsetForAssetSelector = (self.selectedIndex == TAB_DASHBOARD) ? 0 : ASSET_SELECTOR_ROW_HEIGHT;
    activeViewController.view.frame = CGRectMake(0,
                                                 offsetForAssetSelector,
                                                 contentView.frame.size.width,
                                                 contentView.frame.size.height - offsetForAssetSelector);
    
    [activeViewController.view setNeedsLayout];
}

- (int)selectedIndex
{
    return selectedIndex;
}

- (void)setSelectedIndex:(int)nindex
{
    selectedIndex = nindex;
    
    tabBar.selectedItem = nil;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tabBar.selectedItem = [[tabBar items] objectAtIndex:selectedIndex];
    });
    
    NSArray *titles = @[BC_STRING_SEND, BC_STRING_DASHBOARD, BC_STRING_TRANSACTIONS, BC_STRING_REQUEST];
    if (nindex == 2) { return; }
    if (nindex < titles.count) {
        [self setTitleLabelText:[titles objectAtIndex:nindex]];
    } else {
        DLog(@"TabViewController Warning: no title found for selected index (array out of bounds)");
    }
}

- (void)updateTopBarForIndex:(int)newIndex
{
    if (newIndex == TAB_DASHBOARD) {
        [self.assetSelectorView hide];
    } else {

        [self.assetSelectorView show];
    }
    
    self.navigationItem.titleView.userInteractionEnabled = (newIndex == TAB_TRANSACTIONS);
}

- (void)addTapGestureRecognizerToTabBar:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!self.tabBarGestureView) {
        self.tabBarGestureView = [[UIView alloc] initWithFrame:tabBar.bounds];
        self.tabBarGestureView.userInteractionEnabled = YES;
        [self.tabBarGestureView addGestureRecognizer:tapGestureRecognizer];
        [tabBar addSubview:self.tabBarGestureView];
    }
}

- (void)removeTapGestureRecognizerFromTabBar:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.tabBarGestureView removeGestureRecognizer:tapGestureRecognizer];
    [self.tabBarGestureView removeFromSuperview];
    self.tabBarGestureView = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self.assetSelectorView close];
    
    if (item == sendButton) {
        [[AppCoordinator sharedInstance].tabControllerManager sendCoinsClicked:item];
    } else if (item == overviewButton) {
        [[AppCoordinator sharedInstance].tabControllerManager transactionsClicked:item];
    } else if (item == requestButton) {
        [[AppCoordinator sharedInstance].tabControllerManager receiveCoinClicked:item];
    } else if (item == dashBoardButton) {
        [[AppCoordinator sharedInstance].tabControllerManager dashBoardClicked:item];
    }
}

- (void)updateBadgeNumber:(NSInteger)number forSelectedIndex:(int)index
{
    NSString *badgeString = number > 0 ? [NSString stringWithFormat:@"%lu", number] : nil;
    [[[tabBar items] objectAtIndex:index] setBadgeValue:badgeString];
}

- (void)setTitleLabelText:(NSString *)text
{
    titleLabel.text = text;
    titleLabel.font = [titleLabel.font fontWithSize:20];
    [self.navigationItem.titleView sizeToFit];
}

- (void)updateBalanceLabelText:(NSString *)text
{
    titleLabel.text = text;
    titleLabel.font = [titleLabel.font fontWithSize:27];
    [self.navigationItem.titleView sizeToFit];
}

- (void)selectAsset:(LegacyAssetType)assetType
{
    self.assetSelectorView.selectedAsset = assetType;
    
    [self assetSelectorChanged];
}

- (void)assetSelectorChanged
{
    LegacyAssetType asset = self.assetSelectorView.selectedAsset;
    
    [self.assetDelegate didSetAssetType:asset];
}

- (void)didFetchEthExchangeRate
{
    [self updateTopBarForIndex:self.selectedIndex];
}

- (void)selectorButtonClicked
{
    [self.assetDelegate selectorButtonClicked];
}

- (IBAction)qrCodeButtonClicked:(UIButton *)sender
{
    [self.assetDelegate qrCodeButtonClicked];
}

- (void)reloadSymbols
{
    [self updateTopBarForIndex:self.selectedIndex];
}

# pragma mark - Asset Selector Delegate

- (void)didSelectAsset:(LegacyAssetType)assetType
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        CGFloat offsetForAssetSelector = (self.selectedIndex == TAB_DASHBOARD) ? 0 : ASSET_SELECTOR_ROW_HEIGHT;
        self.activeViewController.view.frame = CGRectMake(0,
                                                          offsetForAssetSelector,
                                                          contentView.frame.size.width,
                                                          contentView.frame.size.height - offsetForAssetSelector);
        [bannerView changeHeight:offsetForAssetSelector];
    }];
    
    [self selectAsset:assetType];
}

- (void)didOpenSelector
{
    CGFloat offsetForAssetSelector = ASSET_SELECTOR_ROW_HEIGHT * self.assetSelectorView.assets.count;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.activeViewController.view.frame = CGRectMake(0,
                                                          offsetForAssetSelector,
                                                          contentView.frame.size.width,
                                                          contentView.frame.size.height - offsetForAssetSelector);
        [bannerView changeHeight:offsetForAssetSelector];
    }];
}

@end
