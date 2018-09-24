//
//  BCAddressSelectionView.m
//  Blockchain
//
//  Created by Ben Reeves on 17/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCAddressSelectionView.h"
#import "Wallet.h"
#import "ReceiveTableCell.h"
#import "SendBitcoinViewController.h"
#import "Blockchain-Swift.h"
#import "NSNumberFormatter+Currencies.h"

#define DICTIONARY_KEY_ACCOUNTS @"accounts"
#define DICTIONARY_KEY_ACCOUNT_LABELS @"accountLabels"

@implementation BCAddressSelectionView

@synthesize addressBookAddresses;
@synthesize addressBookAddressLabels;

@synthesize legacyAddresses;
@synthesize legacyAddressLabels;

@synthesize btcAccounts;
@synthesize btcAccountLabels;

@synthesize ethAccounts;
@synthesize ethAccountLabels;

@synthesize bchAccounts;
@synthesize bchAccountLabels;

@synthesize bchAddresses;
@synthesize bchAddressLabels;

@synthesize wallet;
@synthesize delegate;

SelectMode selectMode;

int addressBookSectionNumber;
int btcAccountsSectionNumber;
int ethAccountsSectionNumber;
int bchAccountsSectionNumber;
int legacyAddressesSectionNumber;
int bchAddressesSectionNumber;

typedef enum {
    GetAccountsAll,
    GetAccountsPositiveBalance,
    GetAccountsZeroBalance
} GetAccountsType;

- (id)initWithWallet:(Wallet *)_wallet selectMode:(SelectMode)_selectMode delegate:(id<AddressSelectionDelegate>)delegate
{
    if ([super initWithFrame:CGRectZero]) {
        [[NSBundle mainBundle] loadNibNamed:@"BCAddressSelectionView" owner:self options:nil];
        
        self.delegate = delegate;
        
        selectMode = _selectMode;
        
        self.wallet = _wallet;
        // The From Address View shows accounts and legacy addresses with their balance. Entries with 0 balance are not selectable.
        // The To Address View shows address book entries, account and legacy addresses without a balance.

        addressBookAddresses = [NSMutableArray array];
        addressBookAddressLabels = [NSMutableArray array];
        
        btcAccounts = [NSMutableArray array];
        btcAccountLabels = [NSMutableArray array];
        
        legacyAddresses = [NSMutableArray array];
        legacyAddressLabels = [NSMutableArray array];
        
        ethAccounts = [NSMutableArray array];
        ethAccountLabels = [NSMutableArray array];
        
        bchAccounts = [NSMutableArray array];
        bchAccountLabels = [NSMutableArray array];
        
        bchAddresses = [NSMutableArray array];
        bchAddressLabels = [NSMutableArray array];

        LegacyAssetType assetType = [self.delegate getAssetType];

        NSMutableArray *accounts = assetType == LegacyAssetTypeBitcoin ? btcAccounts : bchAccounts;
        NSMutableArray *accountLabels = assetType == LegacyAssetTypeBitcoin ? btcAccountLabels : bchAccountLabels;
        
        // Select from address
        if ([self showFromAddresses]) {
            
            if (selectMode == SelectModeExchangeAccountFrom) {
                
                NSDictionary *accountsAndLabelsBitcoin = [self getAccountsAndLabels:LegacyAssetTypeBitcoin getAccountsType:GetAccountsAll];
                [btcAccounts addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNTS]];
                [btcAccountLabels addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNT_LABELS]];
                
                NSDictionary *accountsAndLabelsBitcoinCash = [self getAccountsAndLabels:LegacyAssetTypeBitcoinCash getAccountsType:GetAccountsAll];
                [bchAccounts addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNTS]];
                [bchAccountLabels addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNT_LABELS]];
                
            } else if (assetType == LegacyAssetTypeBitcoin || assetType == LegacyAssetTypeBitcoinCash) {
                
                // First show the HD accounts with positive balance
                NSDictionary *accountsAndLabelsPositiveBalance = [self getAccountsAndLabels:assetType getAccountsType:GetAccountsPositiveBalance];
                [accounts addObjectsFromArray:accountsAndLabelsPositiveBalance[DICTIONARY_KEY_ACCOUNTS]];
                [accountLabels addObjectsFromArray:accountsAndLabelsPositiveBalance[DICTIONARY_KEY_ACCOUNT_LABELS]];

                // Then show the HD accounts with a zero balance
                NSDictionary *accountsAndLabelsZeroBalance = [self getAccountsAndLabels:assetType getAccountsType:GetAccountsZeroBalance];
                [accounts addObjectsFromArray:accountsAndLabelsZeroBalance[DICTIONARY_KEY_ACCOUNTS]];
                [accountLabels addObjectsFromArray:accountsAndLabelsZeroBalance[DICTIONARY_KEY_ACCOUNT_LABELS]];
                
                // Finally show all the user's active legacy addresses
                if (assetType == LegacyAssetTypeBitcoin) {
                    for (NSString * addr in [_wallet activeLegacyAddresses:assetType]) {
                        [legacyAddresses addObject:addr];
                        [legacyAddressLabels addObject:[_wallet labelForLegacyAddress:addr assetType:assetType]];
                    }
                }
                
                if (assetType == LegacyAssetTypeBitcoinCash && (selectMode == SelectModeSendFrom || selectMode == SelectModeFilter)) {
                    if ([_wallet hasLegacyAddresses:LegacyAssetTypeBitcoinCash]) {
                        [bchAddresses addObject:BC_STRING_IMPORTED_ADDRESSES];
                        [bchAddressLabels addObject:BC_STRING_IMPORTED_ADDRESSES];
                    }
                }
            }
            
            if (assetType == LegacyAssetTypeEther || (selectMode == SelectModeExchangeAccountFrom && [WalletManager.sharedInstance.wallet hasEthAccount])) {
                [ethAccounts addObject:[NSNumber numberWithInt:0]];
                [ethAccountLabels addObject:[LocalizationConstantsObjcBridge myEtherWallet]];
            }

            addressBookSectionNumber = -1;
            btcAccountsSectionNumber = btcAccounts.count > 0 ? 0 : -1;
            ethAccountsSectionNumber = ethAccounts.count > 0 ? btcAccountsSectionNumber + 1 : -1;
            bchAccountsSectionNumber = bchAccounts.count > 0 ? ethAccountsSectionNumber + 1 : -1;
            legacyAddressesSectionNumber = (legacyAddresses.count > 0) ? btcAccountsSectionNumber + 1 : -1;
            bchAddressesSectionNumber = (bchAddresses.count > 0) ? bchAccountsSectionNumber + 1 : -1;
        }
        // Select to address
        else {
            if (selectMode == SelectModeExchangeAccountTo) {

                NSDictionary *accountsAndLabelsBitcoin = [self getAccountsAndLabels:LegacyAssetTypeBitcoin getAccountsType:GetAccountsAll];
                [btcAccounts addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNTS]];
                [btcAccountLabels addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNT_LABELS]];

                NSDictionary *accountsAndLabelsBitcoinCash = [self getAccountsAndLabels:LegacyAssetTypeBitcoinCash getAccountsType:GetAccountsAll];
                [bchAccounts addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNTS]];
                [bchAccountLabels addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNT_LABELS]];

            } else if (assetType == LegacyAssetTypeBitcoin || assetType == LegacyAssetTypeBitcoinCash) {
                TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;

                // Show the address book
                for (NSString * addr in [_wallet.addressBook allKeys]) {
                    [addressBookAddresses addObject:addr];
                    [addressBookAddressLabels addObject:[tabControllerManager.sendBitcoinViewController labelForLegacyAddress:addr]];
                }

                // Then show the HD accounts
                NSDictionary *accountsAndLabels = [self getAccountsAndLabels:assetType getAccountsType:GetAccountsAll];
                [accounts addObjectsFromArray:accountsAndLabels[DICTIONARY_KEY_ACCOUNTS]];
                [accountLabels addObjectsFromArray:accountsAndLabels[DICTIONARY_KEY_ACCOUNT_LABELS]];

                // Finally show all the user's active legacy addresses
                if (![self accountsOnly] && assetType == LegacyAssetTypeBitcoin) {
                    for (NSString * addr in [_wallet activeLegacyAddresses:assetType]) {
                        [legacyAddresses addObject:addr];
                        [legacyAddressLabels addObject:[_wallet labelForLegacyAddress:addr assetType:assetType]];
                    }
                }
            }

            if ([self.delegate getAssetType] == LegacyAssetTypeEther || (selectMode == SelectModeExchangeAccountTo && [WalletManager.sharedInstance.wallet hasEthAccount])) {
                [ethAccounts addObject:[NSNumber numberWithInt:0]];
                [ethAccountLabels addObject:[LocalizationConstantsObjcBridge myEtherWallet]];
            }

            btcAccountsSectionNumber = btcAccounts.count > 0 ? 0 : -1;
            ethAccountsSectionNumber = ethAccounts.count > 0 ? btcAccountsSectionNumber + 1 : -1;
            bchAccountsSectionNumber = bchAccounts.count > 0 ? ethAccountsSectionNumber + 1 : -1;
            legacyAddressesSectionNumber = (legacyAddresses.count > 0) ? btcAccountsSectionNumber + 1 : -1;
            bchAddressesSectionNumber = (bchAddresses.count > 0) ? bchAccountsSectionNumber + 1 : -1;
            if (addressBookAddresses.count > 0) {
                addressBookSectionNumber = (legacyAddressesSectionNumber > 0) ? legacyAddressesSectionNumber + 1 : btcAccountsSectionNumber + 1;
            } else {
                addressBookSectionNumber = -1;
            }
        }
        
        [self addSubview:mainView];
        
        mainView.frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:NO assetSelector:NO];
        CGRect tableViewFrame = mainView.frame;
        tableViewFrame.size.height = mainView.frame.size.height + [UIView rootViewSafeAreaInsets].bottom;
        tableView.frame = tableViewFrame;
        tableView.backgroundColor = UIColor.lightGray;
    }
    return self;
}

- (BOOL)showFromAddresses
{
    return selectMode == SelectModeReceiveTo ||
    selectMode == SelectModeSendFrom ||
    selectMode == SelectModeTransferTo ||
    selectMode == SelectModeFilter ||
    selectMode == SelectModeExchangeAccountFrom;
}

- (BOOL)accountsOnly
{
    return selectMode == SelectModeTransferTo ||
    selectMode == SelectModeExchangeAccountFrom ||
    selectMode == SelectModeExchangeAccountTo;
}

- (BOOL)allSelectable
{
    return selectMode == SelectModeReceiveTo ||
    selectMode == SelectModeSendTo ||
    selectMode == SelectModeTransferTo ||
    selectMode == SelectModeFilter ||
    selectMode == SelectModeExchangeAccountFrom ||
    selectMode == SelectModeExchangeAccountTo;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldCloseModal = YES;
    
    if ([self showFromAddresses]) {
        if (indexPath.section == btcAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                [self filterWithRow:indexPath.row assetType:LegacyAssetTypeBitcoin];
            } else {
                int accountIndex = [WalletManager.sharedInstance.wallet getIndexOfActiveAccount:[[btcAccounts objectAtIndex:indexPath.row] intValue] assetType:LegacyAssetTypeBitcoin];
                [delegate didSelectFromAccount:accountIndex assetType:LegacyAssetTypeBitcoin];
            }
        }
        else if (indexPath.section == ethAccountsSectionNumber) {
            [delegate didSelectFromAccount:0 assetType:LegacyAssetTypeEther];
        } else if (indexPath.section == bchAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                [self filterWithRow:indexPath.row assetType:LegacyAssetTypeBitcoinCash];
            } else {
                int accountIndex = [WalletManager.sharedInstance.wallet getIndexOfActiveAccount:[[bchAccounts objectAtIndex:indexPath.row] intValue] assetType:LegacyAssetTypeBitcoinCash];
                [delegate didSelectFromAccount:accountIndex assetType:LegacyAssetTypeBitcoinCash];
            }
        } else if (indexPath.section == legacyAddressesSectionNumber) {
            NSString *legacyAddress = [legacyAddresses objectAtIndex:[indexPath row]];
            if ([self allSelectable] &&
                [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:legacyAddress] &&
                ![[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_HIDE_WATCH_ONLY_RECEIVE_WARNING]) {
                if ([delegate respondsToSelector:@selector(didSelectWatchOnlyAddress:)]) {
                    [delegate didSelectWatchOnlyAddress:legacyAddress];
                    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
                    shouldCloseModal = NO;
                } else {
                    [delegate didSelectFromAddress:legacyAddress];
                }
            } else {
                [delegate didSelectFromAddress:legacyAddress];
            }
        } else if (indexPath.section == bchAddressesSectionNumber) {
            if (selectMode == SelectModeFilter) {
                [self filterWithRow:indexPath.row assetType:LegacyAssetTypeBitcoinCash];
            } else {
                [delegate didSelectFromAddress:BC_STRING_IMPORTED_ADDRESSES];
            }
        }
    } else {
        if (indexPath.section == addressBookSectionNumber) {
            [delegate didSelectToAddress:[addressBookAddresses objectAtIndex:[indexPath row]]];
        }
        else if (indexPath.section == btcAccountsSectionNumber) {
            [delegate didSelectToAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:(int)indexPath.row assetType:LegacyAssetTypeBitcoin] assetType:LegacyAssetTypeBitcoin];
        }
        else if (indexPath.section == ethAccountsSectionNumber) {
            [delegate didSelectToAccount:0 assetType:LegacyAssetTypeEther];
        }
        else if (indexPath.section == bchAccountsSectionNumber) {
            [delegate didSelectToAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:(int)indexPath.row assetType:LegacyAssetTypeBitcoinCash] assetType:LegacyAssetTypeBitcoinCash];
        }
        else if (indexPath.section == legacyAddressesSectionNumber) {
            [delegate didSelectToAddress:[legacyAddresses objectAtIndex:[indexPath row]]];
        } else if (indexPath.section == bchAddressesSectionNumber) {
            [delegate didSelectToAddress:[bchAddresses objectAtIndex:[indexPath row]]];
        }
    }

    UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;
    if (shouldCloseModal && ![topViewController conformsToProtocol:@protocol(TopViewController)]) {
        [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFromLeft];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self showFromAddresses]) {
        return (btcAccounts.count > 0 ? 1 : 0) +
        (ethAccounts.count > 0 ? 1 : 0) +
        (bchAccounts.count > 0 ? 1 : 0) +
        (legacyAddresses.count > 0 && selectMode != SelectModeFilter ? 1 : 0) +
        (bchAddresses.count > 0 && selectMode != SelectModeFilter ? 1 : 0);
    }
    
    return (addressBookAddresses.count > 0 ? 1 : 0) +
    (btcAccounts.count > 0 ? 1 : 0) +
    (ethAccounts.count > 0 ? 1 : 0) +
    (bchAccounts.count > 0 ? 1 : 0) +
    (legacyAddresses.count > 0 ? 1 : 0) +
    (bchAddresses.count > 0 ? 1 : 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 45)];
    view.backgroundColor = UIColor.lightGray;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, mainView.frame.size.width, 30)];
    label.textColor = UIColor.brandPrimary;
    label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    
    [view addSubview:label];
    
    NSString *labelString;
    
    if ([self showFromAddresses]) {
        if (section == btcAccountsSectionNumber) {
            labelString = selectMode == SelectModeFilter ? @"" : BC_STRING_WALLETS;
        }
        else if (section == ethAccountsSectionNumber) {
            labelString = nil;
        }
        else if (section == legacyAddressesSectionNumber) {
            labelString = BC_STRING_IMPORTED_ADDRESSES;
        }
    }
    else {
        if (section == addressBookSectionNumber) {
            labelString = BC_STRING_ADDRESS_BOOK;
        }
        else if (section == btcAccountsSectionNumber) {
            labelString = BC_STRING_WALLETS;
        }
        else if (section == legacyAddressesSectionNumber) {
            labelString = BC_STRING_IMPORTED_ADDRESSES;
        }
    }
    
    label.text = labelString;
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self showFromAddresses]) {
        if (section == btcAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                if (legacyAddresses.count > 0) {
                    return btcAccounts.count + 2;
                } else {
                    return btcAccounts.count + 1;
                }
            } else {
                return btcAccounts.count;
            }
        }
        else if (section == ethAccountsSectionNumber) {
            return ethAccounts.count;
        }
        else if (section == bchAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                if (bchAddresses.count > 0) {
                    return bchAccounts.count + 2;
                } else {
                    return bchAccounts.count + 1;
                }
            } else {
                return bchAccounts.count;
            }
        }
        else if (section == legacyAddressesSectionNumber) {
            return legacyAddresses.count;
        }
        else if (section == bchAddressesSectionNumber) {
            return bchAddresses.count;
        }
    }
    else {
        if (section == addressBookSectionNumber) {
            return addressBookAddresses.count;
        }
        else if (section == btcAccountsSectionNumber) {
            return btcAccounts.count;
        }
        else if (section == ethAccountsSectionNumber) {
            return ethAccounts.count;
        }
        else if (section == bchAccountsSectionNumber) {
            return bchAccounts.count;
        }
        else if (section == legacyAddressesSectionNumber) {
            return legacyAddresses.count;
        }
        else if (section == bchAddressesSectionNumber) {
            return bchAddresses.count;
        }
    }
    
    assert(false); // Should never get here
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == btcAccountsSectionNumber || indexPath.section == ethAccountsSectionNumber || indexPath.section == bchAccountsSectionNumber) {
        return ROW_HEIGHT_ACCOUNT;
    }
    
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    
    ReceiveTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiveCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReceiveCell" owner:nil options:nil] objectAtIndex:0];
        cell.backgroundColor = [UIColor whiteColor];
        
        NSString *label;
        if (section == addressBookSectionNumber) {
            label = [addressBookAddressLabels objectAtIndex:row];
            cell.addressLabel.text = [addressBookAddresses objectAtIndex:row];
        }
        else if (section == btcAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                if (btcAccounts.count == row - 1) {
                    label = BC_STRING_IMPORTED_ADDRESSES;
                } else if (row == 0) {
                    label = BC_STRING_TOTAL_BALANCE;
                } else {
                    label = btcAccountLabels[indexPath.row - 1];
                }
            } else {
                label = btcAccountLabels[indexPath.row];
            }
            cell.addressLabel.text = nil;
        }
        else if (section == ethAccountsSectionNumber) {
            label = [LocalizationConstantsObjcBridge myEtherWallet];
            cell.addressLabel.text = nil;
        }
        else if (section == bchAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                if (bchAccounts.count == row - 1) {
                    label = BC_STRING_IMPORTED_ADDRESSES;
                } else if (row == 0) {
                    label = BC_STRING_TOTAL_BALANCE;
                } else {
                    label = bchAccountLabels[indexPath.row - 1];
                }
            } else {
                label = bchAccountLabels[indexPath.row];
            }
            cell.addressLabel.text = nil;
        }
        else if (section == legacyAddressesSectionNumber) {
            label = [legacyAddressLabels objectAtIndex:row];
            cell.addressLabel.text = [legacyAddresses objectAtIndex:row];
        } else if (section == bchAddressesSectionNumber) {
            label = [bchAddressLabels objectAtIndex:row];
            cell.addressLabel.text = nil;
        }
        
        if (label) {
            cell.labelLabel.text = label;
        } else {
            cell.labelLabel.text = BC_STRING_NO_LABEL;
        }
        
        NSString *addr = cell.addressLabel.text;
        Boolean isWatchOnlyLegacyAddress = false;
        if (addr) {
            isWatchOnlyLegacyAddress = [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:addr];
        }
        
        if ([self showFromAddresses] || selectMode == SelectModeExchangeAccountTo) {
            BOOL zeroBalance;
            uint64_t btcBalance = 0;
            
            if (section == addressBookSectionNumber) {
                btcBalance = [[WalletManager.sharedInstance.wallet getLegacyAddressBalance:[addressBookAddresses objectAtIndex:row] assetType:LegacyAssetTypeBitcoin] longLongValue];
            } else if (section == btcAccountsSectionNumber) {
                if (selectMode == SelectModeFilter) {
                    if (btcAccounts.count == row - 1) {
                        btcBalance = [WalletManager.sharedInstance.wallet getTotalBalanceForActiveLegacyAddresses:LegacyAssetTypeBitcoin];
                    } else if (row == 0) {
                        btcBalance = [WalletManager.sharedInstance.wallet getTotalActiveBalance];
                    } else {
                        btcBalance = [[WalletManager.sharedInstance.wallet getBalanceForAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:[[btcAccounts objectAtIndex:indexPath.row - 1] intValue] assetType:LegacyAssetTypeBitcoin] assetType:LegacyAssetTypeBitcoin] longLongValue];
                    }
                } else {
                    btcBalance = [[WalletManager.sharedInstance.wallet getBalanceForAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:[[btcAccounts objectAtIndex:indexPath.row] intValue] assetType:LegacyAssetTypeBitcoin] assetType:LegacyAssetTypeBitcoin] longLongValue];
                }
            } else if (section == legacyAddressesSectionNumber) {
                btcBalance = [[WalletManager.sharedInstance.wallet getLegacyAddressBalance:[legacyAddresses objectAtIndex:row] assetType:LegacyAssetTypeBitcoin] longLongValue];
            }

            if (section == btcAccountsSectionNumber || (btcAccounts.count > 0 && section == legacyAddressesSectionNumber)) {
                zeroBalance = btcBalance == 0;
                cell.balanceLabel.text = [NSNumberFormatter formatMoney:btcBalance];
            } else if (section == ethAccountsSectionNumber) {
                NSDecimalNumber *ethBalance = [[NSDecimalNumber alloc] initWithString:[WalletManager.sharedInstance.wallet getEthBalance]];
                NSComparisonResult result = [ethBalance compare:[NSDecimalNumber numberWithInt:0]];
                zeroBalance = result == NSOrderedDescending || result == NSOrderedSame;
                TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
                cell.balanceLabel.text = BlockchainSettings.sharedAppInstance.symbolLocal ? [NSNumberFormatter formatEthToFiatWithSymbol:[ethBalance stringValue] exchangeRate:tabControllerManager.latestEthExchangeRate] : [NSNumberFormatter formatEth:[NSNumberFormatter localFormattedString:[ethBalance stringValue]]];
            } else {
                uint64_t bchBalance = 0;
                if (section == bchAccountsSectionNumber) {
                    if (selectMode == SelectModeFilter) {
                        if (bchAccounts.count == row - 1) {
                            bchBalance = [WalletManager.sharedInstance.wallet getTotalBalanceForActiveLegacyAddresses:LegacyAssetTypeBitcoinCash];
                        } else if (row == 0) {
                            bchBalance = [WalletManager.sharedInstance.wallet getBchBalance];
                        } else {
                            bchBalance = [[WalletManager.sharedInstance.wallet getBalanceForAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:[[bchAccounts objectAtIndex:indexPath.row - 1] intValue] assetType:LegacyAssetTypeBitcoinCash] assetType:LegacyAssetTypeBitcoinCash] longLongValue];
                        }
                    } else {
                        bchBalance = [[WalletManager.sharedInstance.wallet getBalanceForAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:[[bchAccounts objectAtIndex:indexPath.row] intValue] assetType:LegacyAssetTypeBitcoinCash] assetType:LegacyAssetTypeBitcoinCash] longLongValue];
                    }
                } else if (section == bchAddressesSectionNumber) {
                    bchBalance = [WalletManager.sharedInstance.wallet getTotalBalanceForActiveLegacyAddresses:LegacyAssetTypeBitcoinCash];
                }
                zeroBalance = bchBalance == 0;
                cell.balanceLabel.text = [NSNumberFormatter formatBchWithSymbol:bchBalance];
            }
            
            // Cells with empty balance can't be clicked and are dimmed
            if (zeroBalance && ![self allSelectable]) {
                cell.userInteractionEnabled = NO;
                cell.labelLabel.alpha = 0.5;
                cell.addressLabel.alpha = 0.5;
            } else {
                cell.userInteractionEnabled = YES;
                cell.labelLabel.alpha = 1.0;
                cell.addressLabel.alpha = 1.0;
            }
        } else {
            cell.balanceLabel.text = nil;
        }
        
        if (isWatchOnlyLegacyAddress) {
            // Show the watch only tag and resize the label and balance labels so there is enough space
            cell.labelLabel.frame = CGRectMake(20, 11, 110, 21);
            cell.balanceLabel.frame = CGRectMake(254, 11, 83, 21);
            cell.watchLabel.hidden = NO;
            
        } else {
            cell.labelLabel.frame = CGRectMake(20, 11, 185, 21);
            cell.balanceLabel.frame = CGRectMake(217, 11, 120, 21);
            cell.watchLabel.hidden = YES;
        }
        
        [cell layoutSubviews];
        
        // Disable user interaction on the balance button so the hit area is the full width of the table entry
        [cell.balanceButton setUserInteractionEnabled:NO];
        
        cell.balanceLabel.adjustsFontSizeToFitWidth = YES;
        
        // Selected cell color
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
        [v setBackgroundColor:UIColor.brandPrimary];
        [cell setSelectedBackgroundView:v];
    }
    
    return cell;
}

- (void)reloadTableView
{
    [tableView reloadData];
}

# pragma mark - Helper Methods

- (NSDictionary *)getAccountsAndLabels:(LegacyAssetType)assetType getAccountsType:(GetAccountsType)getAccountsType
{
    NSMutableArray *accounts = [NSMutableArray new];
    NSMutableArray *accountLabels = [NSMutableArray new];
    // First show the HD accounts with positive balance
    for (int i = 0; i < [WalletManager.sharedInstance.wallet getActiveAccountsCount:assetType]; i++) {

        BOOL balanceGreaterThanZero = [[WalletManager.sharedInstance.wallet getBalanceForAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:i assetType:assetType] assetType:assetType] longLongValue] > 0;
        
        BOOL shouldAddAccount;
        if (getAccountsType == GetAccountsAll) {
            shouldAddAccount = YES;
        } else if (getAccountsType == GetAccountsPositiveBalance) {
            shouldAddAccount = balanceGreaterThanZero;
        } else {
            shouldAddAccount = !balanceGreaterThanZero;
        }
        
        if (shouldAddAccount) {
            [accounts addObject:[NSNumber numberWithInt:i]];
            [accountLabels addObject:[WalletManager.sharedInstance.wallet getLabelForAccount:[WalletManager.sharedInstance.wallet getIndexOfActiveAccount:i assetType:assetType] assetType:assetType]];
        }
    }
    
    return @{DICTIONARY_KEY_ACCOUNTS : accounts ? : @[],
             DICTIONARY_KEY_ACCOUNT_LABELS : accountLabels ? : @[]};
}

- (void)filterWithRow:(NSInteger)row assetType:(LegacyAssetType)asset
{
    NSMutableArray *accounts;
    switch (asset) {
        case LegacyAssetTypeBitcoin:
            accounts = btcAccounts;
            break;
        case LegacyAssetTypeBitcoinCash:
            accounts = bchAccounts;
            break;
        case LegacyAssetTypeEther:
            accounts = ethAccounts;
            break;
    }

    if (row == 0) {
        [delegate didSelectFilter:FILTER_INDEX_ALL];
    } else if (accounts.count == row - 1) {
        [delegate didSelectFilter:FILTER_INDEX_IMPORTED_ADDRESSES];
    } else {
        int accountIndex = [WalletManager.sharedInstance.wallet getIndexOfActiveAccount:[[accounts objectAtIndex:row - 1] intValue] assetType:asset];
        [delegate didSelectFilter:accountIndex];
    }
}

@end
