//
//  Assets.h
//  Blockchain
//
//  Created by kevinwu on 8/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#ifndef Assets_h
#define Assets_h

typedef NS_CLOSED_ENUM(NSInteger, LegacyAssetType) {
    LegacyAssetTypeBitcoin,
    LegacyAssetTypeEther,
    LegacyAssetTypeBitcoinCash,
    LegacyAssetTypeStellar,
    LegacyAssetTypePax,
    LegacyAssetTypeAlgorand,
    LegacyAssetTypeTether,
    LegacyAssetTypeWDGLD,
    LegacyAssetTypeYearnFinance,
    LegacyAssetTypeAave,
    LegacyAssetTypePolkadot
};

#endif /* Assets_h */
