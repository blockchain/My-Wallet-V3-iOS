/*
 * 
 * Copyright (c) 2012, Ben Reeves. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

#import "TransactionDetailViewController.h"
#import "TransactionsViewController.h"

@class MultiAddressResponse;
@class LatestBlock;

@interface TransactionsBitcoinViewController : TransactionsViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>
{
    IBOutlet UITableView *tableView;
    
    IBOutlet UIView *headerView;
    
    MultiAddressResponse *data;
    LatestBlock *latestBlock;
}

@property (nonatomic) LegacyAssetType assetType;

@property(nonatomic, strong) MultiAddressResponse *data;
@property(nonatomic, strong) LatestBlock *latestBlock;

@property(nonatomic) BOOL loadedAllTransactions;
@property(nonatomic) UIButton *moreButton;
@property(nonatomic) BOOL clickedFetchMore;
@property(nonatomic) TransactionDetailViewController *detailViewController;
@property(nonatomic) NSString *messageIdentifier;
- (void)reload;
- (void)reloadSymbols;
- (void)didReceiveTransactionMessage;
- (void)setText;
- (UITableView*)tableView;
- (void)selectPayment:(NSString *)payment;
- (void)updateData:(MultiAddressResponse *)newData;
- (void)didGetMessages;
- (void)showFilterMenu;

- (void)showTransactionDetailForHash:(NSString *)hash;
- (void)showTransactionDetail:(Transaction *)transaction;
@end
