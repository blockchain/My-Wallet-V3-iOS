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

#import <UIKit/UIKit.h>
#import "Assets.h"

@class Wallet;

@protocol AddressSelectionDelegate <NSObject>
@optional
- (LegacyAssetType)getAssetType;
- (void)didSelectFromAccount:(int)account;
- (void)didSelectFromAccount:(int)account assetType:(LegacyAssetType)asset;
- (void)didSelectToAccount:(int)account;
- (void)didSelectToAccount:(int)account assetType:(LegacyAssetType)asset;
- (void)didSelectFromAddress:(NSString*)address;
- (void)didSelectToAddress:(NSString*)address;
- (void)didSelectWatchOnlyAddress:(NSString*)address;
- (void)didSelectFilter:(int)filter;
@end

@interface BCAddressSelectionView : UIView <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIView *mainView;
    IBOutlet UITableView *tableView;
}

typedef enum {
    SelectModeFilter = 50,
    SelectModeSendFrom = 100,
    SelectModeSendTo = 200,
    SelectModeReceiveTo = 300,
    SelectModeTransferTo = 400,
    SelectModeExchangeAccountFrom = 600,
    SelectModeExchangeAccountTo = 700
}SelectMode;

- (id)initWithWallet:(Wallet*)_wallet selectMode:(SelectMode)selectMode delegate:(id<AddressSelectionDelegate>)delegate;
- (void)reloadTableView;

@property(nonatomic, strong) NSMutableArray *addressBookAddresses;
@property(nonatomic, strong) NSMutableArray *addressBookAddressLabels;

@property(nonatomic, strong) NSMutableArray *legacyAddresses;
@property(nonatomic, strong) NSMutableArray *legacyAddressLabels;

@property(nonatomic, strong) NSMutableArray *btcAccounts;
@property(nonatomic, strong) NSMutableArray *btcAccountLabels;

@property(nonatomic, strong) NSMutableArray *ethAccounts;
@property(nonatomic, strong) NSMutableArray *ethAccountLabels;

@property(nonatomic, strong) NSMutableArray *bchAccounts;
@property(nonatomic, strong) NSMutableArray *bchAccountLabels;

@property(nonatomic, strong) NSMutableArray *bchAddresses;
@property(nonatomic, strong) NSMutableArray *bchAddressLabels;

@property(nonatomic, strong) Wallet *wallet;
@property(nonatomic, strong) id<AddressSelectionDelegate> delegate;

@end
