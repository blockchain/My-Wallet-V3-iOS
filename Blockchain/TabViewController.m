//
//  MainViewController.m
//  Tube Delays
//
//  Created by Ben Reeves on 10/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TabViewController.h"
#import "RootService.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface TabViewcontroller () <AssetSelectorViewDelegate>
@end

@implementation TabViewcontroller

@synthesize oldViewController;
@synthesize activeViewController;
@synthesize contentView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.assetSelectorView = [[AssetSelectorView alloc] initWithFrame:CGRectMake(0, 0, bannerView.bounds.size.width, bannerView.bounds.size.height) delegate:self];
    [bannerView addSubview:self.assetSelectorView];
    
    balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_EXTRA_LARGE];
    balanceLabel.adjustsFontSizeToFitWidth = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:app action:@selector(toggleSymbol)];
    [balanceLabel addGestureRecognizer:tapGesture];
    
    tabBar.delegate = self;
    
    // Default selected: transactions
    selectedIndex = TAB_TRANSACTIONS;
    
    [self setupTabButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Add side bar to swipe open the sideMenu
    if (!_menuSwipeRecognizerView) {
        _menuSwipeRecognizerView = [[UIView alloc] initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT, 20, self.view.frame.size.height)];
        
        ECSlidingViewController *sideMenu = [AppCoordinator sharedInstance].slidingViewController;
        [_menuSwipeRecognizerView addGestureRecognizer:sideMenu.panGesture];
        
        [self.view addSubview:_menuSwipeRecognizerView];
    }
}

- (void)setupTabButtons
{
    NSDictionary *tabButtons = @{BC_STRING_SEND:sendButton, BC_STRING_DASHBOARD:dashBoardButton, BC_STRING_TRANSACTIONS:homeButton, BC_STRING_REQUEST:receiveButton};
    
    for (UITabBarItem *button in [tabButtons allValues]) {
        NSString *label = [[tabButtons allKeysForObject:button] firstObject];
        button.title = label;
        button.image = [button.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        button.selectedImage = [button.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [button setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL], NSForegroundColorAttributeName : COLOR_TEXT_DARK_GRAY} forState:UIControlStateNormal];
        [button setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL], NSForegroundColorAttributeName : COLOR_BLOCKCHAIN_LIGHT_BLUE} forState:UIControlStateSelected];
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
    
    [self insertActiveView];
    
    self.oldViewController = nil;
    
    if (animated) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:ANIMATION_DURATION];
        [animation setType:kCATransitionPush];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        
        if (newIndex > selectedIndex || (newIndex == selectedIndex && self.assetSelectorView.selectedAsset == AssetTypeEther))
            [animation setSubtype:kCATransitionFromRight];
        else
            [animation setSubtype:kCATransitionFromLeft];
        
        [[contentView layer] addAnimation:animation forKey:@"SwitchToView1"];
    }
    
    [self setSelectedIndex:newIndex];
    
    [self updateTopBarForIndex:newIndex];
}

- (void)insertActiveView
{
    if ([contentView.subviews count] > 0) {
        [[contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    [contentView addSubview:activeViewController.view];
    
    //Resize the View Sub Controller
    activeViewController.view.frame = CGRectMake(activeViewController.view.frame.origin.x, activeViewController.view.frame.origin.y, contentView.frame.size.width, activeViewController.view.frame.size.height);
    
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
    
    if (nindex < titles.count) {
        [self setTitleLabelText:[titles objectAtIndex:nindex]];
    } else {
        DLog(@"TabViewController Warning: no title found for selected index (array out of bounds)");
    }
}

- (void)updateTopBarForIndex:(int)newIndex
{
    if (newIndex == TAB_DASHBOARD) {
        titleLabel.text = BC_STRING_DASHBOARD;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [topBar changeHeight:DEFAULT_HEADER_HEIGHT];
        }];
        [self.assetSelectorView hide];
        [self.bannerSelectorView changeHeight:0];
    } else {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [topBar changeHeight:DEFAULT_HEADER_HEIGHT + DEFAULT_HEADER_HEIGHT_OFFSET];
        }];
        [self.assetSelectorView show];
        [self.bannerSelectorView changeHeight:ASSET_SELECTOR_ROW_HEIGHT];
    }
    
    if (newIndex == TAB_TRANSACTIONS) {
        balanceLabel.hidden = NO;
        balanceLabel.userInteractionEnabled = YES;
        titleLabel.hidden = YES;
    } else {
        balanceLabel.hidden = YES;
        balanceLabel.userInteractionEnabled = NO;
        titleLabel.hidden = NO;
    }
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
        [app.tabControllerManager sendCoinsClicked:item];
    } else if (item == homeButton) {
        [app.tabControllerManager transactionsClicked:item];
    } else if (item == receiveButton) {
        [app.tabControllerManager receiveCoinClicked:item];
    } else if (item == dashBoardButton) {
        [app.tabControllerManager dashBoardClicked:item];
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
    titleLabel.hidden = NO;
}

- (void)updateBalanceLabelText:(NSString *)text
{
    balanceLabel.text = text;
}

- (void)selectAsset:(AssetType)assetType
{
    self.assetSelectorView.selectedAsset = assetType;
    
    [self assetSelectorChanged];
}

- (void)assetSelectorChanged
{
    AssetType asset = self.assetSelectorView.selectedAsset;
    
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

- (void)didSendEther
{
    [[ModalPresenter sharedInstance] closeAllModals];
    
    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:BC_STRING_SUCCESS message:BC_STRING_PAYMENT_SENT_ETHER preferredStyle:UIAlertControllerStyleAlert];
    [successAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:successAlert animated:YES completion:nil];
}

- (void)didErrorDuringEtherSend:(NSString *)error
{
    [[ModalPresenter sharedInstance] closeAllModals];
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:error preferredStyle:UIAlertControllerStyleAlert];
    [errorAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:errorAlert animated:YES completion:nil];
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

- (void)didSelectAsset:(AssetType)assetType
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [topBar changeHeight:DEFAULT_HEADER_HEIGHT + DEFAULT_HEADER_HEIGHT_OFFSET];
        self.activeViewController.view.frame = CGRectMake(0,
                                                          DEFAULT_HEADER_HEIGHT_OFFSET,
                                                          [UIScreen mainScreen].bounds.size.width,
                                                          [UIScreen mainScreen].bounds.size.height - DEFAULT_HEADER_HEIGHT - DEFAULT_HEADER_HEIGHT_OFFSET - DEFAULT_FOOTER_HEIGHT);
        [bannerView changeHeight:ASSET_SELECTOR_ROW_HEIGHT];
    }];
    
    [self selectAsset:assetType];
}

- (void)didOpenSelector
{
    CGFloat bannerOffset = 2;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [topBar changeHeight:DEFAULT_HEADER_HEIGHT + ASSET_SELECTOR_ROW_HEIGHT*self.assetSelectorView.assets.count + bannerOffset];
        self.activeViewController.view.frame = CGRectMake(0,
                                                          ASSET_SELECTOR_ROW_HEIGHT*self.assetSelectorView.assets.count + bannerOffset,
                                                          [UIScreen mainScreen].bounds.size.width,
                                                          [UIScreen mainScreen].bounds.size.height - DEFAULT_HEADER_HEIGHT - DEFAULT_HEADER_HEIGHT_OFFSET - DEFAULT_FOOTER_HEIGHT);
        [bannerView changeHeight:ASSET_SELECTOR_ROW_HEIGHT*3];
    }];
}

@end
