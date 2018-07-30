//
//  AccountsAndAddressesNavigationController.m
//  Blockchain
//
//  Created by Kevin Wu on 1/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AccountsAndAddressesNavigationController.h"
#import "AccountsAndAddressesViewController.h"
#import "AccountsAndAddressesDetailViewController.h"
#import "SendBitcoinViewController.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface AccountsAndAddressesNavigationController () <AssetSelectorViewDelegate, WalletAddressesDelegate>
@property (nonatomic, readwrite) AssetSelectorView *assetSelectorView;
@property (nonatomic) BOOL isOpeningSelector;
@end

@implementation AccountsAndAddressesNavigationController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat safeAreaInsetTop = UIView.rootViewSafeAreaInsets.top;
    CGFloat navBarHeight = [ConstantsObjcBridge defaultNavigationBarHeight];

    self.view.frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:NO assetSelector:YES];

    [self.navigationBar setTitleTextAttributes:[UINavigationBar largeTitleTextAttributes]];
    self.warningButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"warning"]
                          style:UIBarButtonItemStylePlain
                          target:self action:@selector(transferAllFundsWarningClicked)];

    WalletManager.sharedInstance.addressesDelegate = self;

    self.assetSelectorView = [[AssetSelectorView alloc] initWithFrame:CGRectMake(0, safeAreaInsetTop + navBarHeight, self.view.frame.size.width, ASSET_SELECTOR_ROW_HEIGHT) assets:@[[NSNumber numberWithInteger:LegacyAssetTypeBitcoin], [NSNumber numberWithInteger:LegacyAssetTypeBitcoinCash]] delegate:self];
    [self.view addSubview:self.assetSelectorView];
    
    [self setupBusyView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.isOpeningSelector) { return; }
}

- (void)reload
{
    if (![self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]] &&
        ![self.visibleViewController isMemberOfClass:[AccountsAndAddressesDetailViewController class]]) {
        [self popViewControllerAnimated:YES];
    }
    
    if (!self.view.window) {
        [self popToRootViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RELOAD_ACCOUNTS_AND_ADDRESSES object:nil];
}

#pragma mark - Busy view

- (void)showBusyViewWithLoadingText:(NSString *)text
{
    self.busyLabel.text = text;
    [self.view bringSubviewToFront:self.busyView];
    if (self.busyView.alpha < 1.0) {
        [self.busyView fadeIn];
    }
}

- (void)updateBusyViewLoadingText:(NSString *)text
{
    if (self.busyView.alpha == 1.0) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self.busyLabel setText:text];
        }];
    }
}

- (void)hideBusyView
{
    if (self.busyView.alpha == 1.0) {
        [self.busyView fadeOut];
    }
}

#pragma mark - UI helpers

- (void)setupBusyView
{
    BCFadeView *busyView = [[BCFadeView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.rootViewController.view.frame];
    busyView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    UIView *textWithSpinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 110)];
    textWithSpinnerView.backgroundColor = [UIColor whiteColor];
    [busyView addSubview:textWithSpinnerView];
    textWithSpinnerView.center = busyView.center;
    
    self.busyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 30)];
    self.busyLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    self.busyLabel.alpha = 0.75;
    self.busyLabel.textAlignment = NSTextAlignmentCenter;
    self.busyLabel.adjustsFontSizeToFitWidth = YES;
    self.busyLabel.text = [LocalizationConstantsObjcBridge syncingWallet];
    self.busyLabel.center = CGPointMake(textWithSpinnerView.bounds.origin.x + textWithSpinnerView.bounds.size.width/2, textWithSpinnerView.bounds.origin.y + textWithSpinnerView.bounds.size.height/2 + 15);
    [textWithSpinnerView addSubview:self.busyLabel];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(textWithSpinnerView.bounds.origin.x + textWithSpinnerView.bounds.size.width/2, textWithSpinnerView.bounds.origin.y + textWithSpinnerView.bounds.size.height/2 - 15);
    [textWithSpinnerView addSubview:spinner];
    [textWithSpinnerView bringSubviewToFront:spinner];
    [spinner startAnimating];
    
    busyView.containerView = textWithSpinnerView;
    [busyView fadeOut];
    
    [self.view addSubview:busyView];
    
    [self.view bringSubviewToFront:busyView];
    
    self.busyView = busyView;
}

- (void)alertUserToTransferAllFunds:(BOOL)userClicked
{
    AppFeatureConfiguration *transferFundsConfig = [AppFeatureConfigurator.sharedInstance configurationFor:AppFeatureTransferFundsFromImportedAddress];
    if (!transferFundsConfig.isEnabled) {
        return;
    }

    UIAlertController *alertToTransfer = [UIAlertController alertControllerWithTitle:BC_STRING_TRANSFER_FUNDS message:[NSString stringWithFormat:@"%@\n\n%@", BC_STRING_TRANSFER_FUNDS_DESCRIPTION_ONE, BC_STRING_TRANSFER_FUNDS_DESCRIPTION_TWO] preferredStyle:UIAlertControllerStyleAlert];
    [alertToTransfer addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
    [alertToTransfer addAction:[UIAlertAction actionWithTitle:BC_STRING_TRANSFER_FUNDS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self transferAllFundsClicked];
    }]];
    
    if (!userClicked) {
        [alertToTransfer addAction:[UIAlertAction actionWithTitle:[LocalizationConstantsObjcBridge dontShowAgain] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BlockchainSettings.sharedAppInstance.hideTransferAllFundsAlert = YES;
        }]];
    }
    
    [self presentViewController:alertToTransfer animated:YES completion:nil];
}

#pragma mark - Transfer Funds

- (void)transferAllFundsWarningClicked
{
    [self alertUserToTransferAllFunds:YES];
}

- (void)transferAllFundsClicked
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[AppCoordinator sharedInstance] closeSideMenu];
    }];
    
    [[TransferAllCoordinator sharedInstance] startWithSendScreen];
}

#pragma mark - Navigation

- (void)resetAddressesViewControllerContainerFrame
{
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
        [accountsAndAddressesViewController.containerView changeYPosition:8 + ASSET_SELECTOR_ROW_HEIGHT];
    }
}

#pragma mark - Asset Selector View Delegate

- (void)didSelectAsset:(LegacyAssetType)assetType
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self resetAddressesViewControllerContainerFrame];
    }];
    
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
        accountsAndAddressesViewController.assetType = assetType;
    };
}

- (void)didOpenSelector
{
    self.isOpeningSelector = YES;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
            AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
            [accountsAndAddressesViewController.containerView changeYPosition:8 + ASSET_SELECTOR_ROW_HEIGHT*self.assetSelectorView.assets.count];
        }
    } completion:^(BOOL finished) {
        self.isOpeningSelector = NO;
    }];
}

#pragma mark WalletAddressesDelegate

- (void)didSetDefaultAccount
{
    [AssetAddressRepository.sharedInstance removeAllSwipeAddressesFor:AssetTypeBitcoin];
    [AssetAddressRepository.sharedInstance removeAllSwipeAddressesFor:AssetTypeBitcoinCash];
    [AppCoordinator.sharedInstance.tabControllerManager didSetDefaultAccount];
}

- (void)didGenerateNewAddress
{
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
        [accountsAndAddressesViewController didGenerateNewAddress];
    }
}

- (void)returnToAddressesScreen
{
    [self popToRootViewControllerAnimated:YES];
}

@end
