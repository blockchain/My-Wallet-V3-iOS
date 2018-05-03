//
//  AccountsAndAddressesViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 1/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AccountsAndAddressesViewController.h"
#import "AccountsAndAddressesDetailViewController.h"
#import "RootService.h"
#import "ReceiveTableCell.h"
#import "BCCreateAccountView.h"
#import "BCModalViewController.h"
#import "PrivateKeyReader.h"
#import "UIViewController+AutoDismiss.h"
#import "Blockchain-Swift.h"
#import "UIView+ChangeFrameAttribute.h"

#define CELL_HEIGHT_DEFAULT 44.0f

@interface AccountsAndAddressesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSString *clickedAddress;
@property (nonatomic) int clickedAccount;
@end

@implementation AccountsAndAddressesViewController

@synthesize allKeys;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [UIApplication sharedApplication].keyWindow.frame;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectOffset([UIApplication sharedApplication].keyWindow.frame, 0, DEFAULT_HEADER_HEIGHT + ASSET_SELECTOR_ROW_HEIGHT + 8)];
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.tableView changeHeight:self.view.frame.size.height - CELL_HEIGHT_DEFAULT*2];
    self.tableView.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
    [self.containerView addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_KEY_RELOAD_ACCOUNTS_AND_ADDRESSES object:nil];
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AccountsAndAddressesNavigationController *navigationController = (AccountsAndAddressesNavigationController *)self.navigationController;
    navigationController.headerLabel.text = BC_STRING_ADDRESSES;
    
    if (IS_USING_SCREEN_SIZE_4S) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self displayTransferFundsWarningIfAppropriate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AccountsAndAddressesNavigationController *navigationController = (AccountsAndAddressesNavigationController *)self.navigationController;
    navigationController.warningButton.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload
{
    allKeys = [WalletManager.sharedInstance.wallet allLegacyAddresses:self.assetType];
    [self.tableView reloadData];
    
    [self displayTransferFundsWarningIfAppropriate];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL]) {
        AccountsAndAddressesDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.assetType = self.assetType;
        if (self.clickedAddress) {
            detailViewController.address = self.clickedAddress;
            detailViewController.account = -1;
        } else if (self.clickedAccount >= 0) {
            detailViewController.account = self.clickedAccount;
            detailViewController.address = nil;
        }
    }
}

#pragma mark - Actions

- (void)setAssetType:(AssetType)assetType
{
    _assetType = assetType;
    
    [self reload];
}

- (void)didSelectAddress:(NSString *)address
{
    self.clickedAddress = address;
    self.clickedAccount = -1;
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL sender:nil];
}

- (void)didSelectAccount:(int)account
{
    self.clickedAccount = account;
    self.clickedAddress = nil;
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL sender:nil];
}

#pragma mark - Helpers

- (void)newAccountClicked:(id)sender
{
    BCCreateAccountView *createAccountView = [[BCCreateAccountView alloc] init];
    
    BCModalViewController *modalViewController = [[BCModalViewController alloc] initWithCloseType:ModalCloseTypeClose showHeader:YES headerText:BC_STRING_CREATE view:createAccountView];
    
    [self presentViewController:modalViewController animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [createAccountView.labelTextField becomeFirstResponder];
    });
}

- (void)newAddressClicked:(id)sender
{
    if ([WalletManager.sharedInstance.wallet didUpgradeToHd]) {
        [self importAddress];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:BC_STRING_NEW_ADDRESS message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *generateNewAddressAction = [UIAlertAction actionWithTitle:BC_STRING_NEW_ADDRESS_CREATE_NEW style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self generateNewAddress];
        }];
        UIAlertAction *importAddressAction = [UIAlertAction actionWithTitle:BC_STRING_IMPORT_ADDRESS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self importAddress];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:generateNewAddressAction];
        [alertController addAction:importAddressAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:^{
            [[NSNotificationCenter defaultCenter] addObserver:alertController
                                                     selector:@selector(autoDismiss)
                                                         name:ConstantsObjcBridge.notificationKeyReloadToDismissViews
                                                       object:nil];
        }];
    }
}

- (void)generateNewAddress
{
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }
    
    [WalletManager.sharedInstance.wallet generateNewKey];
}

- (void)didGenerateNewAddress
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(promptForLabelAfterGenerate)
                                                 name:ConstantsObjcBridge.notificationKeyNewAddress object:nil];
}

- (void)promptForLabelAfterGenerate
{
    //newest address is the last object in activeKeys
    self.clickedAddress = [allKeys lastObject];
    [self didSelectAddress:self.clickedAddress];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ConstantsObjcBridge.notificationKeyNewAddress
                                                  object:nil];
}

- (void)importAddress
{
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputForQRScannerAndReturnError:&error];
    if (!input) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
            [AlertViewPresenter.sharedInstance showNeedsCameraPermissionAlert];
        } else {
            [AlertViewPresenter.sharedInstance standardNotifyWithMessage:[error localizedDescription] title:LocalizationConstantsObjcBridge.error handler:nil];
        }
        return;
    }
    
    PrivateKeyReader *reader = [[PrivateKeyReader alloc] initWithAssetType:self.assetType success:^(NSString* keyString) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(promptForLabelAfterScan)
                                                     name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
        [WalletManager.sharedInstance.wallet addKey:keyString];
    } error:nil acceptPublicKeys:YES busyViewText:BC_STRING_LOADING_IMPORT_KEY];
    
    [[NSNotificationCenter defaultCenter] addObserver:reader selector:@selector(autoDismiss) name:ConstantsObjcBridge.notificationKeyReloadToDismissViews object:nil];
    
    [self presentViewController:reader animated:YES completion:nil];
}

- (void)promptForLabelAfterScan
{
    //newest address is the last object in activeKeys
    self.clickedAddress = [allKeys lastObject];
    [self didSelectAddress:self.clickedAddress];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_BACKUP_SUCCESS
                                                  object:nil];
}

- (void)displayTransferFundsWarningIfAppropriate
{
    AccountsAndAddressesNavigationController *navigationController = (AccountsAndAddressesNavigationController *)self.navigationController;
    
    if (self.assetType == AssetTypeBitcoin && [WalletManager.sharedInstance.wallet didUpgradeToHd] && [WalletManager.sharedInstance.wallet getTotalBalanceForSpendableActiveLegacyAddresses] >= [WalletManager.sharedInstance.wallet dust] && navigationController.visibleViewController == self) {
        navigationController.warningButton.hidden = NO;
    } else {
        navigationController.warningButton.hidden = YES;
    }
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CELL_HEIGHT_DEFAULT;
    }
    
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (![WalletManager.sharedInstance.wallet isInitialized]) {
            return 45.0f;
        } else {
            if ([WalletManager.sharedInstance.wallet didUpgradeToHd]) {
                return 45.0f;
            } else {
                return 0;
            }
        }
    } else {
        return 45.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (IS_USING_SCREEN_SIZE_4S && section == [tableView numberOfSections] - 1) {
        return DEFAULT_HEADER_HEIGHT;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    view.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width, 14)];
    label.textColor = COLOR_BLOCKCHAIN_BLUE;
    label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    
    [view addSubview:label];
    
    NSString *labelString;
    
    if (section == 0) {
        labelString = BC_STRING_WALLETS;
        if (self.assetType == AssetTypeBitcoin) {
            UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 30, 4, 50, 40)];
            [addButton setImage:[[UIImage imageNamed:@"new"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            addButton.imageView.tintColor = COLOR_BLOCKCHAIN_BLUE;
            [addButton addTarget:self action:@selector(newAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:addButton];
        }
    }
    else if (section == 1) {
        labelString = BC_STRING_IMPORTED_ADDRESSES;
        if (self.assetType == AssetTypeBitcoin) {
            UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 30, 4, 50, 40)];
            [addButton setImage:[[UIImage imageNamed:@"new"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            addButton.imageView.tintColor = COLOR_BLOCKCHAIN_BLUE;
            [addButton addTarget:self action:@selector(newAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:addButton];
        }
    } else
        @throw @"Unknown Section";
    
    label.text = labelString;
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [WalletManager.sharedInstance.wallet getAllAccountsCount:self.assetType];
    else if (section == 1) {
        if (self.assetType == AssetTypeBitcoin) {
            return [allKeys count];
        } else {
            return [allKeys count] > 0 ? 1 : 0;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.assetType == AssetTypeBitcoin) {
        return 2;
    } else {
        return [WalletManager.sharedInstance.wallet hasLegacyAddresses:self.assetType] ? 2 : 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self didSelectAccount:(int)indexPath.row];
    } else if (indexPath.section == 1) {
        if (self.assetType == AssetTypeBitcoin) [self didSelectAddress:allKeys[indexPath.row]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        int accountIndex = (int) indexPath.row;
        NSString *accountLabelString = [WalletManager.sharedInstance.wallet getLabelForAccount:accountIndex assetType:self.assetType];
        
        ReceiveTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"receiveAccount"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ReceiveCell" owner:nil options:nil] objectAtIndex:0];
            cell.backgroundColor = [UIColor whiteColor];
            cell.balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];

            if ([WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType] == accountIndex) {
                
                cell.labelLabel.autoresizingMask = UIViewAutoresizingNone;
                cell.balanceLabel.autoresizingMask = UIViewAutoresizingNone;
                cell.balanceButton.autoresizingMask = UIViewAutoresizingNone;
                cell.watchLabel.autoresizingMask = UIViewAutoresizingNone;
                
                CGFloat labelLabelCenterY = cell.labelLabel.center.y;
                cell.labelLabel.text = accountLabelString;
                [cell.labelLabel sizeToFit];
                [cell.labelLabel changeXPosition:20];
                cell.labelLabel.center = CGPointMake(cell.labelLabel.center.x, labelLabelCenterY);
                
                cell.watchLabel.hidden = NO;
                cell.watchLabel.text = BC_STRING_DEFAULT;
                CGFloat watchLabelCenterY = cell.watchLabel.center.y;
                [cell.watchLabel sizeToFit];
                [cell.watchLabel changeXPosition:cell.labelLabel.frame.origin.x + cell.labelLabel.frame.size.width + 8];
                cell.watchLabel.center = CGPointMake(cell.watchLabel.center.x, watchLabelCenterY);
                cell.watchLabel.textColor = [UIColor grayColor];
                
                CGFloat minimumBalanceButtonOriginX = IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 235 : 194;
                CGFloat watchLabelEndX = cell.watchLabel.frame.origin.x + cell.watchLabel.frame.size.width + 8;
                
                if (watchLabelEndX > minimumBalanceButtonOriginX) {
                    CGFloat smallestDefaultLabelWidth = 18;
                    CGFloat difference = cell.watchLabel.frame.size.width - (watchLabelEndX - minimumBalanceButtonOriginX);
                    CGFloat newWidth = difference > smallestDefaultLabelWidth ? difference : smallestDefaultLabelWidth;
                    [cell.watchLabel changeWidth:newWidth];
                }
                
                CGFloat windowWidth = WINDOW_WIDTH;
                cell.balanceLabel.frame = CGRectMake(minimumBalanceButtonOriginX, 11, windowWidth - minimumBalanceButtonOriginX - 20, 21);
                cell.balanceButton.frame = CGRectMake(minimumBalanceButtonOriginX, 0, windowWidth - minimumBalanceButtonOriginX, CELL_HEIGHT_DEFAULT);
            } else {
                
                // Don't show the watch only tag and resize the label and balance labels to use up the freed up space
                cell.labelLabel.frame = CGRectMake(20, 11, 185, 21);
                cell.balanceLabel.frame = CGRectMake(217, 11, 120, 21);
                UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 217, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
                cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);
                
                cell.watchLabel.hidden = YES;
                cell.watchLabel.text = BC_STRING_WATCH_ONLY;
                cell.watchLabel.textColor = COLOR_WARNING_RED;
            }
        }
        
        cell.labelLabel.text = accountLabelString;
        cell.addressLabel.text = @"";
        
        uint64_t balance = [[WalletManager.sharedInstance.wallet getBalanceForAccount:accountIndex assetType:self.assetType] longLongValue];
        
        // Selected cell color
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
        [v setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
        [cell setSelectedBackgroundView:v];
        
        if ([WalletManager.sharedInstance.wallet isAccountArchived:accountIndex assetType:self.assetType]) {
            cell.balanceLabel.text = BC_STRING_ARCHIVED;
            cell.balanceLabel.textColor = COLOR_BUTTON_BLUE;
        } else {
            cell.balanceLabel.text = self.assetType == AssetTypeBitcoin ? [NSNumberFormatter formatMoney:balance] : [NSNumberFormatter formatBchWithSymbol:balance];
            cell.balanceLabel.textColor = COLOR_BLOCKCHAIN_GREEN;
        }
        cell.balanceLabel.minimumScaleFactor = 0.75f;
        [cell.balanceLabel setAdjustsFontSizeToFitWidth:YES];
        
        [cell.balanceButton addTarget:app action:@selector(toggleSymbol) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }

    // Imported addresses
    
    NSString *addr = [allKeys objectAtIndex:[indexPath row]];
    
    Boolean isWatchOnlyLegacyAddress = [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:addr];
    
    ReceiveTableCell *cell;
    if (isWatchOnlyLegacyAddress) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"receiveWatchOnly"];
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"receiveNormal"];
    }
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReceiveCell" owner:nil options:nil] objectAtIndex:0];
        cell.backgroundColor = [UIColor whiteColor];
        cell.balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];

        if (isWatchOnlyLegacyAddress) {
            // Show the watch only tag and resize the label and balance labels so there is enough space
            cell.labelLabel.frame = CGRectMake(20, 11, 148, 21);
            
            cell.balanceLabel.frame = CGRectMake(254, 11, 83, 21);
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 254, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
            cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);
            
            [cell.watchLabel setHidden:FALSE];
        }
        else {
            // Don't show the watch only tag and resize the label and balance labels to use up the freed up space
            cell.labelLabel.frame = CGRectMake(20, 11, 185, 21);
            
            cell.balanceLabel.frame = CGRectMake(217, 11, 120, 21);
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 217, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
            cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);
            
            [cell.watchLabel setHidden:TRUE];

            // Disable cell highlighting for BCH imported addresses
            if (self.assetType == AssetTypeBitcoinCash) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        }
    }
    
    NSString *label = self.assetType == AssetTypeBitcoin ? [WalletManager.sharedInstance.wallet labelForLegacyAddress:addr assetType:self.assetType] : BC_STRING_IMPORTED_ADDRESSES;
    
    if (label)
        cell.labelLabel.text = label;
    else
        cell.labelLabel.text = BC_STRING_NO_LABEL;
    
    cell.addressLabel.text = self.assetType == AssetTypeBitcoin ? addr : nil;
    
    uint64_t balance = self.assetType == AssetTypeBitcoin ? [[WalletManager.sharedInstance.wallet getLegacyAddressBalance:addr assetType:self.assetType] longLongValue] : [WalletManager.sharedInstance.wallet getTotalBalanceForActiveLegacyAddresses:self.assetType];
    
    // Selected cell color
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
    [v setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
    [cell setSelectedBackgroundView:v];
    
    if ([WalletManager.sharedInstance.wallet isAddressArchived:addr]) {
        cell.balanceLabel.text = BC_STRING_ARCHIVED;
        cell.balanceLabel.textColor = COLOR_BUTTON_BLUE;
    } else {
        cell.balanceLabel.text = self.assetType == AssetTypeBitcoin ? [NSNumberFormatter formatMoney:balance] : [NSNumberFormatter formatBchWithSymbol:balance];
        cell.balanceLabel.textColor = COLOR_LABEL_BALANCE_GREEN;
    }
    cell.balanceLabel.minimumScaleFactor = 0.75f;
    [cell.balanceLabel setAdjustsFontSizeToFitWidth:YES];
    
    [cell.balanceButton addTarget:app action:@selector(toggleSymbol) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

@end
