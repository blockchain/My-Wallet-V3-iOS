//
//  BCSwipeAddressViewModel.m
//  Blockchain
//
//  Created by kevinwu on 3/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCSwipeAddressViewModel.h"

@implementation BCSwipeAddressViewModel

- (id)initWithAssetType:(LegacyAssetType)assetType
{
    if (self == [super init]) {
        self.assetType = assetType;
        NSString *suffix;
        NSString *assetImageViewName;
        if (assetType == LegacyAssetTypeBitcoin) {
            suffix = BC_STRING_BITCOIN;
            assetImageViewName = @"bitcoin_large";
        } else if (assetType == LegacyAssetTypeEther) {
            suffix = BC_STRING_ETHER;
            assetImageViewName = @"ether_large";
        } else if (assetType == LegacyAssetTypeBitcoinCash) {
            suffix = BC_STRING_BITCOIN_CASH;
            assetImageViewName = @"bitcoin_cash_large";
        }
        self.assetImageViewName = assetImageViewName;
        self.action = [[[BC_STRING_REQUEST stringByAppendingString:@" "] stringByAppendingString:suffix] uppercaseString];
    }
    return self;
}

- (void)setAddress:(NSString *)address
{
    _address = address;
    
    self.textAddress = self.assetType == LegacyAssetTypeBitcoinCash ? [address substringFromIndex:[PREFIX_BITCOIN_CASH length]] : address;
}

@end
