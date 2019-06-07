//
//  BCSwipeAddressViewModel.m
//  Blockchain
//
//  Created by kevinwu on 3/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCSwipeAddressViewModel.h"
#import "Blockchain-Swift.h"

@implementation BCSwipeAddressViewModel

- (id)initWithAssetType:(LegacyAssetType)assetType
{
    if (self == [super init]) {
        self.assetType = assetType;
        NSString *suffix;
        NSString *assetImageViewName;
        switch (assetType) {
            case LegacyAssetTypeBitcoin: {
                suffix = [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin];
                assetImageViewName = @"filled_btc_large";
                break;
            }
            case LegacyAssetTypeEther: {
                suffix = [AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum];
                assetImageViewName = @"filled_eth_large";
                break;
            }
            case LegacyAssetTypeBitcoinCash: {
                suffix = [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash];
                assetImageViewName = @"filled_bch_large";
                break;
            }
            case LegacyAssetTypeStellar: {
                suffix = [AssetTypeLegacyHelper descriptionFor:AssetTypeStellar];
                assetImageViewName = @"filled_xlm_large";
                break;
            }
            case LegacyAssetTypePax: {
                suffix = [AssetTypeLegacyHelper descriptionFor:AssetTypePax];
                assetImageViewName = @"filled_pax_large";
                break;
            }
        }
        self.assetImageViewName = assetImageViewName;
        self.action = [[[BC_STRING_REQUEST stringByAppendingString:@" "] stringByAppendingString:suffix] uppercaseString];
    }
    return self;
}

- (void)setAddress:(NSString *)address
{
    _address = address;

    self.textAddress = self.assetType == LegacyAssetTypeBitcoinCash ? [address substringFromIndex:[[[ConstantsObjcBridge bitcoinCashUriPrefix] stringByAppendingString:@":"] length]] : address;
}

@end
