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

@interface TabViewController () <AssetSelectorContainerDelegate>

#pragma mark - Private IBOutlets

@property (strong, nonatomic) IBOutlet UITabBarItem *requestTabBarItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *sendTabBarItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *homeTabBarItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *activityTabBarItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *swapTabBarItem;
@property (strong, nonatomic) AssetSelectorContainerViewController *assetSelectorViewController;
@property (strong, nonatomic) IBOutlet UIView *assetContainerView;


@end

@implementation TabViewController

@synthesize activeViewController;
@synthesize contentView;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    tabBar.delegate = self;

    selectedIndex = [ConstantsObjcBridge tabDashboard];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat safeAreaInsetBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetBottom = window.rootViewController.view.safeAreaInsets.bottom;
    }
    _tabBarBottomConstraint.constant = safeAreaInsetBottom;
    self.requestTabBarItem.accessibilityIdentifier = [AccessibilityIdentifiers_TabViewContainerScreen request];
    self.activityTabBarItem.accessibilityIdentifier = [AccessibilityIdentifiers_TabViewContainerScreen activity];
    self.swapTabBarItem.accessibilityIdentifier = [AccessibilityIdentifiers_TabViewContainerScreen swap];
    self.homeTabBarItem.accessibilityIdentifier = [AccessibilityIdentifiers_TabViewContainerScreen home];
    self.sendTabBarItem.accessibilityIdentifier = [AccessibilityIdentifiers_TabViewContainerScreen send];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[BaseNavigationController class]]) {
        BaseNavigationController *controller = (BaseNavigationController *)segue.destinationViewController;
        self.assetSelectorViewController = (AssetSelectorContainerViewController *)[controller viewControllers].firstObject;
        self.assetSelectorViewController.delegate = self;
    }
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

- (void)setActiveViewController:(UIViewController *)nviewcontroller
{
    [self setActiveViewController:nviewcontroller animated:NO index:selectedIndex];
}

- (void)setActiveViewController:(UIViewController *)nviewcontroller animated:(BOOL)animated index:(int)newIndex
{
    if (nviewcontroller == activeViewController)
        return;
    
    activeViewController = nviewcontroller;
    
    [self setSelectedIndex:newIndex];
    
    switch (newIndex) {
        case 1:
        case 2:
            [self.assetContainerView setHidden:YES];
            [self insertActiveView];
            break;
        default:
            [self.assetContainerView setHidden:NO];
            [self.assetSelectorViewController insertWithViewController:activeViewController];
            break;
    }
    [self updateTopBarForIndex:newIndex];

    if ([self.childViewControllers.firstObject isKindOfClass:[BaseNavigationController class]]) {
        BaseNavigationController *controller = (BaseNavigationController *) self.childViewControllers.firstObject;
        [controller update];
    }
}

- (void)insertActiveView
{
    if ([contentView.subviews count] > 0) {
        [[contentView.subviews firstObject] removeFromSuperview];
    }
    
    BOOL noOffset = (self.selectedIndex == [ConstantsObjcBridge tabDashboard] || [ConstantsObjcBridge tabSwap]);
    
    CGFloat offsetForAssetSelector = (noOffset) ? 0 : [ConstantsObjcBridge assetTypeCellHeight];
    activeViewController.view.frame = CGRectMake(0,
                                                 offsetForAssetSelector,
                                                 contentView.frame.size.width,
                                                 contentView.frame.size.height - offsetForAssetSelector);
    
    [activeViewController.view setNeedsLayout];

    [contentView addSubview:activeViewController.view];
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
        self->tabBar.selectedItem = [[self->tabBar items] objectAtIndex:selectedIndex];
    });
}

- (void)updateTopBarForIndex:(int)newIndex
{
    self.navigationItem.titleView.userInteractionEnabled = (newIndex == [ConstantsObjcBridge tabTransactions]);
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
    // TODO: Close asset selectors
    if (item == self.sendTabBarItem) {
        [[AppCoordinator sharedInstance].tabControllerManager sendCoinsClicked:item];
    } else if (item == self.activityTabBarItem) {
        [[AppCoordinator sharedInstance].tabControllerManager transactionsClicked:item];
    } else if (item == self.requestTabBarItem) {
        [[AppCoordinator sharedInstance].tabControllerManager receiveCoinClicked:item];
    } else if (item == self.homeTabBarItem) {
        [[AppCoordinator sharedInstance].tabControllerManager dashBoardClicked:item];
    } else if (item == self.swapTabBarItem) {
        [[AppCoordinator sharedInstance].tabControllerManager swapTapped:item];
    }
}

- (void)updateBadgeNumber:(NSInteger)number forSelectedIndex:(int)index
{
    NSString *badgeString = number > 0 ? [NSString stringWithFormat:@"%lu", number] : nil;
    [[[tabBar items] objectAtIndex:index] setBadgeValue:badgeString];
}

- (void)selectAsset:(LegacyAssetType)assetType
{
    self.assetSelectorViewController.currentAsset = assetType;
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

- (void)assetSelectorContainer:(AssetSelectorContainerViewController *)viewController selectedAsset:(LegacyAssetType)selectedAsset
{
    [self.assetDelegate didSetAssetType:selectedAsset];
}

- (void)assetSelectorContainer:(AssetSelectorContainerViewController *)viewController tappedQRReaderFor:(LegacyAssetType)assetType
{
    [self.assetDelegate qrCodeButtonClicked];
}

@end
