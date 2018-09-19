//
//  DashboardViewController.h
//  Blockchain
//
//  Created by kevinwu on 8/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardsViewController.h"
#import "Assets.h"

// TICKET: IOS-1297 - Complete Dashboard Swift Refactor
@interface DashboardViewController : CardsViewController
@property (nonatomic) LegacyAssetType assetType;
- (void)reload;
- (void)reloadSymbols;
- (void)updateEthExchangeRate:(NSDecimalNumber *)rate;
@end
