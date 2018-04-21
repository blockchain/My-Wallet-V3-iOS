//
//  BCAddressSelectionView.m
//  Blockchain
//
//  Created by Ben Reeves on 17/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCAddressSelectionView.h"
#import "Wallet.h"
#import "RootService.h"
#import "ReceiveTableCell.h"
#import "SendBitcoinViewController.h"
#import "Contact.h"
#import "Blockchain-Swift.h"

#define DICTIONARY_KEY_ACCOUNTS @"accounts"
#define DICTIONARY_KEY_ACCOUNT_LABELS @"accountLabels"

@implementation BCAddressSelectionView

@synthesize contacts;

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

int contactsSectionNumber;
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
        
        contacts = [NSMutableArray new];
        
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

        AssetType assetType = [self.delegate getAssetType];

        NSMutableArray *accounts = assetType == AssetTypeBitcoin ? btcAccounts : bchAccounts;
        NSMutableArray *accountLabels = assetType == AssetTypeBitcoin ? btcAccountLabels : bchAccountLabels;
        
        // Select from address
        if ([self showFromAddresses]) {
            
            if (selectMode == SelectModeExchangeAccountFrom) {
                
                NSDictionary *accountsAndLabelsBitcoin = [self getAccountsAndLabels:AssetTypeBitcoin getAccountsType:GetAccountsAll];
                [btcAccounts addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNTS]];
                [btcAccountLabels addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNT_LABELS]];
                
                NSDictionary *accountsAndLabelsBitcoinCash = [self getAccountsAndLabels:AssetTypeBitcoinCash getAccountsType:GetAccountsAll];
                [bchAccounts addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNTS]];
                [bchAccountLabels addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNT_LABELS]];
                
            } else if (assetType == AssetTypeBitcoin || assetType == AssetTypeBitcoinCash) {
                
                // First show the HD accounts with positive balance
                NSDictionary *accountsAndLabelsPositiveBalance = [self getAccountsAndLabels:assetType getAccountsType:GetAccountsPositiveBalance];
                [accounts addObjectsFromArray:accountsAndLabelsPositiveBalance[DICTIONARY_KEY_ACCOUNTS]];
                [accountLabels addObjectsFromArray:accountsAndLabelsPositiveBalance[DICTIONARY_KEY_ACCOUNT_LABELS]];

                // Then show the HD accounts with a zero balance
                NSDictionary *accountsAndLabelsZeroBalance = [self getAccountsAndLabels:assetType getAccountsType:GetAccountsZeroBalance];
                [accounts addObjectsFromArray:accountsAndLabelsZeroBalance[DICTIONARY_KEY_ACCOUNTS]];
                [accountLabels addObjectsFromArray:accountsAndLabelsZeroBalance[DICTIONARY_KEY_ACCOUNT_LABELS]];
                
                // Finally show all the user's active legacy addresses
                if (assetType == AssetTypeBitcoin) {
                    for (NSString * addr in [_wallet activeLegacyAddresses:assetType]) {
                        [legacyAddresses addObject:addr];
                        [legacyAddressLabels addObject:[_wallet labelForLegacyAddress:addr assetType:assetType]];
                    }
                }
                
                if (assetType == AssetTypeBitcoinCash && (selectMode == SelectModeSendFrom || selectMode == SelectModeFilter)) {
                    if ([_wallet hasLegacyAddresses:AssetTypeBitcoinCash]) {
                        [bchAddresses addObject:BC_STRING_IMPORTED_ADDRESSES];
                        [bchAddressLabels addObject:BC_STRING_IMPORTED_ADDRESSES];
                    }
                }
            }
            
            if (assetType == AssetTypeEther || (selectMode == SelectModeExchangeAccountFrom && [app.wallet hasEthAccount])) {
                [ethAccounts addObject:[NSNumber numberWithInt:0]];
                [ethAccountLabels addObject:BC_STRING_MY_ETHER_WALLET];
            }

            addressBookSectionNumber = -1;
            contactsSectionNumber = contacts.count > 0 ? 0 : -1;
            btcAccountsSectionNumber = btcAccounts.count > 0 ? contactsSectionNumber + 1 : -1;
            ethAccountsSectionNumber = ethAccounts.count > 0 ? btcAccountsSectionNumber + 1 : -1;
            bchAccountsSectionNumber = bchAccounts.count > 0 ? ethAccountsSectionNumber + 1 : -1;
            legacyAddressesSectionNumber = (legacyAddresses.count > 0) ? btcAccountsSectionNumber + 1 : -1;
            bchAddressesSectionNumber = (bchAddresses.count > 0) ? bchAccountsSectionNumber + 1 : -1;
        }
        // Select to address
        else {
            
            // Show contacts
            if (selectMode != SelectModeReceiveFromContact) {
                for (Contact *contact in [_wallet.contacts allValues]) {
                    [contacts addObject:contact];
                }
            }
            
            if (selectMode != SelectModeContact) {
                
                if (selectMode == SelectModeExchangeAccountTo) {
                    
                    NSDictionary *accountsAndLabelsBitcoin = [self getAccountsAndLabels:AssetTypeBitcoin getAccountsType:GetAccountsAll];
                    [btcAccounts addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNTS]];
                    [btcAccountLabels addObjectsFromArray:accountsAndLabelsBitcoin[DICTIONARY_KEY_ACCOUNT_LABELS]];
                    
                    NSDictionary *accountsAndLabelsBitcoinCash = [self getAccountsAndLabels:AssetTypeBitcoinCash getAccountsType:GetAccountsAll];
                    [bchAccounts addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNTS]];
                    [bchAccountLabels addObjectsFromArray:accountsAndLabelsBitcoinCash[DICTIONARY_KEY_ACCOUNT_LABELS]];
                    
                } else if (assetType == AssetTypeBitcoin || assetType == AssetTypeBitcoinCash) {
                    // Show the address book
                    for (NSString * addr in [_wallet.addressBook allKeys]) {
                        [addressBookAddresses addObject:addr];
                        [addressBookAddressLabels addObject:[app.tabControllerManager.sendBitcoinViewController labelForLegacyAddress:addr]];
                    }
                    
                    // Then show the HD accounts
                    NSDictionary *accountsAndLabels = [self getAccountsAndLabels:assetType getAccountsType:GetAccountsAll];
                    [accounts addObjectsFromArray:accountsAndLabels[DICTIONARY_KEY_ACCOUNTS]];
                    [accountLabels addObjectsFromArray:accountsAndLabels[DICTIONARY_KEY_ACCOUNT_LABELS]];
                    
                    // Finally show all the user's active legacy addresses
                    if (![self accountsOnly] && assetType == AssetTypeBitcoin) {
                        for (NSString * addr in [_wallet activeLegacyAddresses:assetType]) {
                            [legacyAddresses addObject:addr];
                            [legacyAddressLabels addObject:[_wallet labelForLegacyAddress:addr assetType:assetType]];
                        }
                    }
                }
                
                if ([self.delegate getAssetType] == AssetTypeEther || (selectMode == SelectModeExchangeAccountTo && [app.wallet hasEthAccount])) {
                    [ethAccounts addObject:[NSNumber numberWithInt:0]];
                    [ethAccountLabels addObject:BC_STRING_MY_ETHER_WALLET];
                }
            }
            
            contactsSectionNumber = contacts.count > 0 ? 0 : -1;
            btcAccountsSectionNumber = btcAccounts.count > 0 ? contactsSectionNumber + 1 : -1;
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
        
        mainView.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height);
        
        [tableView layoutIfNeeded];
        float tableHeight = [tableView contentSize].height;
        float tableSpace = mainView.frame.size.height - DEFAULT_HEADER_HEIGHT;
        
        CGRect frame = tableView.frame;
        frame.size.height = tableSpace;
        tableView.frame = frame;
        
        // Disable scrolling if table content fits on screen
        if (tableHeight < tableSpace) {
            tableView.scrollEnabled = NO;
        }
        else {
            tableView.scrollEnabled = YES;
        }
        
        tableView.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
        
        if (selectMode == SelectModeContact && contacts.count == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width - 50, 40)];
            label.textColor = COLOR_TEXT_DARK_GRAY;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:14];
            label.text = BC_STRING_NO_CONTACTS_YET_TITLE;
            [self addSubview:label];
            label.center = CGPointMake(mainView.center.x, mainView.center.y - DEFAULT_HEADER_HEIGHT);
        }
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
    selectMode == SelectModeReceiveFromContact ||
    selectMode == SelectModeExchangeAccountFrom ||
    selectMode == SelectModeExchangeAccountTo;
}

- (BOOL)allSelectable
{
    return selectMode == SelectModeReceiveTo ||
    selectMode == SelectModeSendTo ||
    selectMode == SelectModeTransferTo ||
    selectMode == SelectModeFilter ||
    selectMode == SelectModeReceiveFromContact ||
    selectMode == SelectModeExchangeAccountFrom ||
    selectMode == SelectModeExchangeAccountTo;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldCloseModal = YES;
    
    if ([self showFromAddresses]) {
        if (indexPath.section == btcAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                [self filterWithRow:indexPath.row assetType:AssetTypeBitcoin];
            } else {
                int accountIndex = [app.wallet getIndexOfActiveAccount:[[btcAccounts objectAtIndex:indexPath.row] intValue] assetType:AssetTypeBitcoin];
                [delegate didSelectFromAccount:accountIndex assetType:AssetTypeBitcoin];
            }
        }
        else if (indexPath.section == ethAccountsSectionNumber) {
            [delegate didSelectFromAccount:0 assetType:AssetTypeEther];
        } else if (indexPath.section == bchAccountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                [self filterWithRow:indexPath.row assetType:AssetTypeBitcoinCash];
            } else {
                int accountIndex = [app.wallet getIndexOfActiveAccount:[[bchAccounts objectAtIndex:indexPath.row] intValue] assetType:AssetTypeBitcoinCash];
                [delegate didSelectFromAccount:accountIndex assetType:AssetTypeBitcoinCash];
            }
        } else if (indexPath.section == legacyAddressesSectionNumber) {
            NSString *legacyAddress = [legacyAddresses objectAtIndex:[indexPath row]];
            if ([self allSelectable] &&
                [app.wallet isWatchOnlyLegacyAddress:legacyAddress] &&
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
                [self filterWithRow:indexPath.row assetType:AssetTypeBitcoinCash];
            } else {
                [delegate didSelectFromAddress:BC_STRING_IMPORTED_ADDRESSES];
            }
        }
    } else {
        if (indexPath.section == addressBookSectionNumber) {
            [delegate didSelectToAddress:[addressBookAddresses objectAtIndex:[indexPath row]]];
        }
        else if (indexPath.section == btcAccountsSectionNumber) {
            [delegate didSelectToAccount:[app.wallet getIndexOfActiveAccount:(int)indexPath.row assetType:AssetTypeBitcoin] assetType:AssetTypeBitcoin];
        }
        else if (indexPath.section == ethAccountsSectionNumber) {
            [delegate didSelectToAccount:0 assetType:AssetTypeEther];
        }
        else if (indexPath.section == bchAccountsSectionNumber) {
            [delegate didSelectToAccount:[app.wallet getIndexOfActiveAccount:(int)indexPath.row assetType:AssetTypeBitcoinCash] assetType:AssetTypeBitcoinCash];
        }
        else if (indexPath.section == legacyAddressesSectionNumber) {
            [delegate didSelectToAddress:[legacyAddresses objectAtIndex:[indexPath row]]];
        }
        else if (indexPath.section == contactsSectionNumber) {
            [delegate didSelectContact:[contacts objectAtIndex:[indexPath row]]];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    (contacts.count > 0 ? 1 : 0) +
    (bchAddresses.count > 0 ? 1 : 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 45)];
    view.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, mainView.frame.size.width, 30)];
    label.textColor = COLOR_BLOCKCHAIN_BLUE;
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
        else if (section == contactsSectionNumber) {
            labelString = BC_STRING_CONTACTS;
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
        else if (section == contactsSectionNumber) {
            labelString = BC_STRING_CONTACTS;
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
        else if (section == contactsSectionNumber) {
            return contacts.count;
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
        else if (section == contactsSectionNumber) {
            return contacts.count;
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
    if (indexPath.section == btcAccountsSectionNumber || indexPath.section == contactsSectionNumber || indexPath.section == ethAccountsSectionNumber || indexPath.section == bchAccountsSectionNumber) {
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
            label = BC_STRING_MY_ETHER_WALLET;
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
        else if (section == contactsSectionNumber) {
            Contact *contact = [contacts objectAtIndex:row];
            cell.addressLabel.text = nil;
            cell.tintColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
            cell.accessoryType = contact == self.previouslySelectedContact ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            if (contact.mdid) {
                label = contact.name;
                cell.userInteractionEnabled = YES;
                cell.labelLabel.alpha = 1.0;
                cell.addressLabel.alpha = 1.0;
            } else {
                label = [NSString stringWithFormat:@"%@ (%@)", contact.name, BC_STRING_PENDING];
                cell.userInteractionEnabled = NO;
                cell.labelLabel.alpha = 0.5;
                cell.addressLabel.alpha = 0.5;
            }
        }
        
        if (label) {
            cell.labelLabel.text = label;
        } else {
            cell.labelLabel.text = BC_STRING_NO_LABEL;
        }
        
        NSString *addr = cell.addressLabel.text;
        Boolean isWatchOnlyLegacyAddress = false;
        if (addr) {
            isWatchOnlyLegacyAddress = [app.wallet isWatchOnlyLegacyAddress:addr];
        }
        
        if ([self showFromAddresses] || selectMode == SelectModeExchangeAccountTo) {
            BOOL zeroBalance;
            uint64_t btcBalance = 0;
            
            if (section == addressBookSectionNumber) {
                btcBalance = [[app.wallet getLegacyAddressBalance:[addressBookAddresses objectAtIndex:row] assetType:AssetTypeBitcoin] longLongValue];
            } else if (section == btcAccountsSectionNumber) {
                if (selectMode == SelectModeFilter) {
                    if (btcAccounts.count == row - 1) {
                        btcBalance = [app.wallet getTotalBalanceForActiveLegacyAddresses:AssetTypeBitcoin];
                    } else if (row == 0) {
                        btcBalance = [app.wallet getTotalActiveBalance];
                    } else {
                        btcBalance = [[app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:[[btcAccounts objectAtIndex:indexPath.row - 1] intValue] assetType:AssetTypeBitcoin] assetType:AssetTypeBitcoin] longLongValue];
                    }
                } else {
                    btcBalance = [[app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:[[btcAccounts objectAtIndex:indexPath.row] intValue] assetType:AssetTypeBitcoin] assetType:AssetTypeBitcoin] longLongValue];
                }
            } else if (section == legacyAddressesSectionNumber) {
                btcBalance = [[app.wallet getLegacyAddressBalance:[legacyAddresses objectAtIndex:row] assetType:AssetTypeBitcoin] longLongValue];
            }

            if (section == btcAccountsSectionNumber || (btcAccounts.count > 0 && section == legacyAddressesSectionNumber)) {
                zeroBalance = btcBalance == 0;
                cell.balanceLabel.text = [NSNumberFormatter formatMoney:btcBalance];
            } else if (section == ethAccountsSectionNumber) {
                NSDecimalNumber *ethBalance = [[NSDecimalNumber alloc] initWithString:[app.wallet getEthBalance]];
                NSComparisonResult result = [ethBalance compare:[NSDecimalNumber numberWithInt:0]];
                zeroBalance = result == NSOrderedDescending || result == NSOrderedSame;
                cell.balanceLabel.text = app->symbolLocal ? [NSNumberFormatter formatEthToFiatWithSymbol:[ethBalance stringValue] exchangeRate:app.tabControllerManager.latestEthExchangeRate] : [NSNumberFormatter formatEth:[NSNumberFormatter localFormattedString:[ethBalance stringValue]]];
            } else {
                uint64_t bchBalance = 0;
                if (section == bchAccountsSectionNumber) {
                    if (selectMode == SelectModeFilter) {
                        if (bchAccounts.count == row - 1) {
                            bchBalance = [app.wallet getTotalBalanceForActiveLegacyAddresses:AssetTypeBitcoinCash];
                        } else if (row == 0) {
                            bchBalance = [app.wallet bitcoinCashTotalBalance];
                        } else {
                            bchBalance = [[app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:[[bchAccounts objectAtIndex:indexPath.row - 1] intValue] assetType:AssetTypeBitcoinCash] assetType:AssetTypeBitcoinCash] longLongValue];
                        }
                    } else {
                        bchBalance = [[app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:[[bchAccounts objectAtIndex:indexPath.row] intValue] assetType:AssetTypeBitcoinCash] assetType:AssetTypeBitcoinCash] longLongValue];
                    }
                } else if (section == bchAddressesSectionNumber) {
                    bchBalance = [app.wallet getTotalBalanceForActiveLegacyAddresses:AssetTypeBitcoinCash];
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
            cell.labelLabel.frame = CGRectMake(20, 11, 148, 21);
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
        [v setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
        [cell setSelectedBackgroundView:v];
    }
    
    return cell;
}

- (void)reloadTableView
{
    [tableView reloadData];
}

# pragma mark - Helper Methods

- (NSDictionary *)getAccountsAndLabels:(AssetType)assetType getAccountsType:(GetAccountsType)getAccountsType
{
    NSMutableArray *accounts = [NSMutableArray new];
    NSMutableArray *accountLabels = [NSMutableArray new];
    // First show the HD accounts with positive balance
    for (int i = 0; i < [app.wallet getActiveAccountsCount:assetType]; i++) {
        
        BOOL balanceGreaterThanZero = [[app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:i assetType:assetType] assetType:assetType] longLongValue] > 0;
        
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
            [accountLabels addObject:[app.wallet getLabelForAccount:[app.wallet getIndexOfActiveAccount:i assetType:assetType] assetType:assetType]];
        }
    }
    
    return @{DICTIONARY_KEY_ACCOUNTS : accounts ? : @[],
             DICTIONARY_KEY_ACCOUNT_LABELS : accountLabels ? : @[]};
}

- (void)filterWithRow:(NSInteger)row assetType:(AssetType)asset
{
    NSMutableArray *accounts;
    switch (asset) {
        case AssetTypeBitcoin:
            accounts = btcAccounts;
            break;
        case AssetTypeBitcoinCash:
            accounts = bchAccounts;
            break;
        case AssetTypeEther:
            accounts = ethAccounts;
            break;
    }

    if (row == 0) {
        [delegate didSelectFilter:FILTER_INDEX_ALL];
    } else if (accounts.count == row - 1) {
        [delegate didSelectFilter:FILTER_INDEX_IMPORTED_ADDRESSES];
    } else {
        int accountIndex = [app.wallet getIndexOfActiveAccount:[[accounts objectAtIndex:row - 1] intValue] assetType:asset];
        [delegate didSelectFilter:accountIndex];
    }
}

@end
