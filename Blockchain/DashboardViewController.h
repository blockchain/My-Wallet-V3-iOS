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

@interface DashboardViewController : CardsViewController
@property (nonatomic) LegacyAssetType assetType;
- (void)reload;
- (void)updateEthExchangeRate:(NSDecimalNumber *)rate;
@end
