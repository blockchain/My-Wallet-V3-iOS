//
//  AccountsAndAddressesDetailViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 1/14/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Assets.h"
@interface AccountsAndAddressesDetailViewController : UIViewController
@property (nonatomic) int account;
@property (nonatomic) NSString *address;
@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic) NSString *navigationItemTitle;
@end
