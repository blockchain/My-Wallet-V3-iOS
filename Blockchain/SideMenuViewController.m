//
//  SideMenuViewController.m
//  Blockchain
//
//  Created by Mark Pfluger on 10/3/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SideMenuViewController.h"
#import "ECSlidingViewController.h"
#import "BCCreateAccountView.h"
#import "BCEditAccountView.h"
#import "AccountTableCell.h"
#import "SideMenuViewCell.h"
#import "BCLine.h"
#import "UIViewController+AutoDismiss.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Blockchain-Swift.h"

#define MENU_ENTRY_HEIGHT 54

@interface SideMenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *menuEntries;

@end

@implementation SideMenuViewController

ECSlidingViewController *sideMenu;

UITapGestureRecognizer *tapToCloseGestureRecognizerViewController;
UITapGestureRecognizer *tapToCloseGestureRecognizerTabBar;

NSString *entryKeyUpgradeBackup = @"upgrade_backup";
NSString *entryKeySettings = @"settings";
NSString *entryKeyAccountsAndAddresses = @"accounts_and_addresses";
NSString *entryKeyWebLogin = @"web_login";
NSString *entryKeySupport = @"support";
NSString *entryKeyLogout = @"logout";
NSString *entryKeyBuyBitcoin = @"buy_bitcoin";
NSString *entryKeyExchange = @"exchange";

CGFloat safeAreaInsetTop = 20;
CGFloat safeAreaInsetBottom = 0;

int balanceEntries = 0;
int accountEntries = 0;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
        safeAreaInsetBottom = window.rootViewController.view.safeAreaInsets.bottom;
    }
    
    sideMenu = [AppCoordinator sharedInstance].slidingViewController;
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               self.view.frame.size.width - sideMenu.anchorLeftPeekAmount,
                                                                               self.view.frame.size.height - safeAreaInsetBottom) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.scrollEnabled = NO;
        tableView;
    });

    
    [self.view addSubview:self.tableView];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Blue background for bounce area
    CGRect frame = self.view.bounds;
    frame.origin.y = -frame.size.height;
    UIView* blueView = [[UIView alloc] initWithFrame:frame];
    blueView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    [self.tableView addSubview:blueView];
    // Make sure the refresh control is in front of the blue area
    blueView.layer.zPosition -= 1;
    
    sideMenu.delegate = self;

    tapToCloseGestureRecognizerViewController = [[UITapGestureRecognizer alloc] initWithTarget:AppCoordinator.sharedInstance action:@selector(toggleSideMenu)];
    tapToCloseGestureRecognizerTabBar = [[UITapGestureRecognizer alloc] initWithTarget:AppCoordinator.sharedInstance action:@selector(toggleSideMenu)];
}

- (NSUInteger)menuEntriesCount {
    return [self.menuEntries count];
}

- (NSDictionary *)getMenuEntry:(NSInteger)index {
    return [self.menuEntries objectAtIndex:index];
}

- (void)clearMenuEntries {
    self.menuEntries = [NSMutableArray new];
}

- (void)addMenuEntry:(NSString *)key text:(NSString *)text icon:(NSString *)icon {
    NSDictionary *entry = @{ @"key": key, @"text": text, @"icon": icon };
    [self.menuEntries addObject:entry];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self clearMenuEntries];
    
    if ([WalletManager.sharedInstance.wallet isBuyEnabled]) {
        [self addMenuEntry:entryKeyBuyBitcoin text:BC_STRING_BUY_AND_SELL_BITCOIN icon:@"buy"];
    }
    if ([WalletManager.sharedInstance.wallet isExchangeEnabled]) {
        [self addMenuEntry:entryKeyExchange text:BC_STRING_EXCHANGE icon:@"exchange_menu"];
    }
    if (!WalletManager.sharedInstance.wallet.didUpgradeToHd) {
        [self addMenuEntry:entryKeyUpgradeBackup text:[LocalizationConstantsObjcBridge upgrade] icon:@"icon_upgrade"];
    } else {
        [self addMenuEntry:entryKeyUpgradeBackup text:BC_STRING_BACKUP_FUNDS icon:@"lock"];
    }

    [self addMenuEntry:entryKeySettings text:BC_STRING_SETTINGS icon:@"settings"];
    [self addMenuEntry:entryKeyAccountsAndAddresses text:BC_STRING_ADDRESSES icon:@"wallet"];
    [self addMenuEntry:entryKeyWebLogin text:BC_STRING_LOG_IN_TO_WEB_WALLET icon:@"web"];
    [self addMenuEntry:entryKeySupport text:BC_STRING_SUPPORT icon:@"help"];
    [self addMenuEntry:entryKeyLogout text:LocalizationConstantsObjcBridge.logout icon:@"logout"];

    [self setSideMenuGestures];
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resetSideMenuGestures];
}

- (void)setSideMenuGestures
{
    TabViewController *tabViewController = [AppCoordinator sharedInstance].tabControllerManager.tabViewController;
    
    // Disable all interactions on main view
    for (UIView *view in tabViewController.activeViewController.view.subviews) {
        [view setUserInteractionEnabled:NO];
    }
    [tabViewController.menuSwipeRecognizerView setUserInteractionEnabled:NO];
    
    // Enable Pan gesture and tap gesture to close sideMenu
    [tabViewController.activeViewController.view setUserInteractionEnabled:YES];
    ECSlidingViewController *sideMenu = [AppCoordinator sharedInstance].slidingViewController;
    [tabViewController.activeViewController.view addGestureRecognizer:sideMenu.panGesture];
    
    [tabViewController.activeViewController.view addGestureRecognizer:tapToCloseGestureRecognizerViewController];
    
    [tabViewController addTapGestureRecognizerToTabBar:tapToCloseGestureRecognizerTabBar];
    
    // Show shadow on current viewController in tabBarView
    UIView *castsShadowView = [AppCoordinator sharedInstance].slidingViewController.topViewController.view;
    castsShadowView.layer.shadowOpacity = 0.3f;
    castsShadowView.layer.shadowRadius = 10.0f;
    castsShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)resetSideMenuGestures
{
    TabViewController *tabViewController = [AppCoordinator sharedInstance].tabControllerManager.tabViewController;

    // Show status bar again
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    
    // Disable Pan and Tap gesture on main view
    [tabViewController.activeViewController.view removeGestureRecognizer:sideMenu.panGesture];
    [tabViewController.activeViewController.view removeGestureRecognizer:tapToCloseGestureRecognizerViewController];
    [tabViewController removeTapGestureRecognizerFromTabBar:tapToCloseGestureRecognizerTabBar];

    // Enable interaction on main view
    for (UIView *view in tabViewController.activeViewController.view.subviews) {
        [view setUserInteractionEnabled:YES];
    }
    
    // Enable swipe to open side menu gesture on small bar on the left of main view
    [tabViewController.menuSwipeRecognizerView setUserInteractionEnabled:YES];
    [tabViewController.menuSwipeRecognizerView addGestureRecognizer:sideMenu.panGesture];
}

- (void)reload
{
    [self.tableView reloadData];
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)removeTransactionsFilter
{
    UITableViewHeaderFooterView *headerView = [self.tableView headerViewForSection:0];
    UIView *backgroundView = [[UIView alloc] initWithFrame:headerView.frame];
    [backgroundView setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
    headerView.backgroundView = backgroundView;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];

    [AppCoordinator.sharedInstance.tabControllerManager removeTransactionsFilter];
    [WalletManager.sharedInstance.wallet reloadFilter];
}

#pragma mark - SlidingViewController Delegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController animationControllerForOperation:(ECSlidingViewControllerOperation)operation topViewController:(UIViewController *)topViewController
{
    // SideMenu will slide in
    if (operation == ECSlidingViewControllerOperationAnchorRight) {
        [self setSideMenuGestures];
    }
    // SideMenu will slide out
    else if (operation == ECSlidingViewControllerOperationResetFromRight) {
        // Everything happens in viewDidDisappear: which is called after the slide animation is done
    }
    
    return nil;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *rowKey = [self getMenuEntry:indexPath.row][@"key"];

    [self.delegate onSideMenuItemTapped:rowKey];
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MENU_ENTRY_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Empty table if not logged in:
    if (!WalletManager.sharedInstance.wallet.guid) {
        return 0;
    }
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [ConstantsObjcBridge defaultNavigationBarHeight] + safeAreaInsetTop;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) { return nil; }
    
    CGFloat defaultAnchorRevealWidth = 276;
    CGFloat xOffset = self.view.frame.size.width - defaultAnchorRevealWidth;
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0,
                                                                                                            0,
                                                                                                            self.view.frame.size.width,
                                                                                                            [self tableView:tableView heightForHeaderInSection:section])];
    UIView *backgroundView = [[UIView alloc] initWithFrame:headerView.bounds];
    backgroundView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    headerView.backgroundView = backgroundView;
    CGFloat imageHeight = 30; CGFloat imageWidth = 161;
    CGFloat posX = ((headerView.frame.size.width - xOffset) / 2) - (imageWidth / 2);
    CGFloat posY = (safeAreaInsetTop == 44) ? (headerView.frame.size.height / 2) : ((headerView.frame.size.height - safeAreaInsetTop) / 2);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(posX, posY, imageWidth, imageHeight)];
    imageView.clipsToBounds = NO;
    imageView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"logo_and_banner_white"];
    [headerView addSubview:imageView];

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return 0;
    }
    if (sectionIndex == 1) {
        return self.menuEntriesCount;
    }
    
    return balanceEntries;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    
    if (indexPath.section == 1) {

        cellIdentifier = @"CellMenu";
        
        SideMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[SideMenuViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
            [v setBackgroundColor:COLOR_TABLE_VIEW_CELL_SELECTED_LIGHT_GRAY];
            cell.selectedBackgroundView = v;
        }

        NSDictionary *entry = [self getMenuEntry:indexPath.row];
        cell.textLabel.text = entry[@"text"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        NSString *imageName = entry[@"icon"];
        cell.imageView.image = [UIImage imageNamed:imageName];

        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        // No separator
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, CGRectGetWidth(cell.bounds)-15)];
    }
}

@end
