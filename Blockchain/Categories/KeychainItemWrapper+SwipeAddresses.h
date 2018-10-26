//
//  KeychainItemWrapper+SwipeAddresses.h
//  Blockchain
//
//  Created by Kevin Wu on 10/21/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "KeychainItemWrapper.h"
#import "Assets.h"

@interface KeychainItemWrapper (SwipeAddresses)
+ (NSArray *)getSwipeAddressesForAssetType:(LegacyAssetType)assetType;
+ (void)addSwipeAddress:(NSString *)swipeAddress assetType:(LegacyAssetType)assetType;
+ (void)removeFirstSwipeAddressForAssetType:(LegacyAssetType)assetType;
+ (void)removeAllSwipeAddressesForAssetType:(LegacyAssetType)assetType;
+ (void)removeAllSwipeAddresses;
+ (void)setSingleSwipeAddress:(NSString *_Nonnull)swipeAddress forAssetType:(LegacyAssetType)assetType;
+ (NSString *_Nullable)getSingleSwipeAddressForAssetType:(LegacyAssetType)assetType;
@end
