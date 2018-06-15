//
//  AccountsAndAddressesNavigationController.h
//  Blockchain
//
//  Created by Kevin Wu on 1/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCFadeView.h"
#import "AssetSelectorView.h"

@interface AccountsAndAddressesNavigationController : UINavigationController <TopViewController>
@property (nonatomic) UIBarButtonItem *warningButton;
@property (nonatomic) BCFadeView *busyView;
@property (nonatomic) UILabel *busyLabel;
@property (nonatomic, readonly) AssetSelectorView *assetSelectorView;

- (void)didGenerateNewAddress;
- (void)reload;
- (void)alertUserToTransferAllFunds:(BOOL)automaticallyShown;

@end
