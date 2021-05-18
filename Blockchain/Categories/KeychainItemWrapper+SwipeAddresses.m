//
//  KeychainItemWrapper+SwipeAddresses.m
//  Blockchain
//
//  Created by Kevin Wu on 10/21/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "KeychainItemWrapper+SwipeAddresses.h"

@implementation KeychainItemWrapper (SwipeAddresses)

#pragma mark - Swipe To Receive

+ (NSString *)keychainKeyForAssetType:(LegacyAssetType)assetType
{
    switch (assetType) {
        case LegacyAssetTypeAave:
            return KEYCHAIN_KEY_AAVE_ADDRESS;
        case LegacyAssetTypeAlgorand:
            return KEYCHAIN_KEY_ALGO_ADDRESS;
        case LegacyAssetTypeBitcoin:
            return KEYCHAIN_KEY_BTC_SWIPE_ADDRESSES;
        case LegacyAssetTypeBitcoinCash:
            return KEYCHAIN_KEY_BCH_SWIPE_ADDRESSES;
        case LegacyAssetTypeEther:
            return KEYCHAIN_KEY_ETHER_ADDRESS;
        case LegacyAssetTypePax:
            return KEYCHAIN_KEY_PAX_ADDRESS;
        case LegacyAssetTypePolkadot:
            return KEYCHAIN_KEY_DOT_ADDRESS;
        case LegacyAssetTypeStellar:
            return KEYCHAIN_KEY_XLM_ADDRESS;
        case LegacyAssetTypeTether:
            return KEYCHAIN_KEY_USDT_ADDRESS;
        case LegacyAssetTypeWDGLD:
            return KEYCHAIN_KEY_WDGLD_ADDRESS;
        case LegacyAssetTypeYearnFinance:
            return KEYCHAIN_KEY_YFI_ADDRESS;
    }
}

+ (NSArray *)getSwipeAddressesForAssetType:(LegacyAssetType)assetType
{
    return [KeychainItemWrapper getMutableSwipeAddressesForAssetType:assetType];
}

+ (NSMutableArray *)getMutableSwipeAddressesForAssetType:(LegacyAssetType)assetType
{
    NSString *keychainKey = [KeychainItemWrapper keychainKeyForAssetType:assetType];
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:keychainKey accessGroup:nil];
    NSData *arrayData = [keychain objectForKey:(__bridge id)kSecValueData];
    NSMutableArray *swipeAddresses = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    
    return swipeAddresses;
}

+ (void)addSwipeAddress:(NSString *)swipeAddress assetType:(LegacyAssetType)assetType
{
    NSMutableArray *swipeAddresses = [KeychainItemWrapper getMutableSwipeAddressesForAssetType:assetType];
    if (!swipeAddresses) swipeAddresses = [NSMutableArray new];
    [swipeAddresses addObject:swipeAddress];
    
    [KeychainItemWrapper saveSwipeAddresses: swipeAddresses assetType: assetType];
}

+ (void)removeSwipeAddress:(NSString *)swipeAddress assetType:(LegacyAssetType)assetType {
    
    NSMutableArray *swipeAddresses = [KeychainItemWrapper getMutableSwipeAddressesForAssetType:assetType];
    if (!swipeAddresses) {
        return;
    }
    [swipeAddresses removeObject:swipeAddress];
    [KeychainItemWrapper saveSwipeAddresses:swipeAddresses assetType:assetType];
}

+ (void)saveSwipeAddresses:(NSArray *)addresses assetType:(LegacyAssetType)assetType {
    NSString *keychainKey = [KeychainItemWrapper keychainKeyForAssetType:assetType];
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:keychainKey accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    
    [keychain setObject:keychainKey forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[NSKeyedArchiver archivedDataWithRootObject:addresses] forKey:(__bridge id)kSecValueData];
}

+ (void)removeFirstSwipeAddressForAssetType:(LegacyAssetType)assetType
{
    NSMutableArray *swipeAddresses = [KeychainItemWrapper getMutableSwipeAddressesForAssetType:assetType];
    if (swipeAddresses.count > 0) {
        [swipeAddresses removeObjectAtIndex:0];
        
        NSString *keychainKey = [KeychainItemWrapper keychainKeyForAssetType:assetType];
        
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:keychainKey accessGroup:nil];
        [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
        
        [keychain setObject:keychainKey forKey:(__bridge id)kSecAttrAccount];
        [keychain setObject:[NSKeyedArchiver archivedDataWithRootObject:swipeAddresses] forKey:(__bridge id)kSecValueData];
    } else {
        DLog(@"Error removing first swipe address: no swipe addresses stored!");
    }
}

+ (void)removeAllSwipeAddressesForAssetType:(LegacyAssetType)assetType
{
    NSString *keychainKey = [KeychainItemWrapper keychainKeyForAssetType:assetType];

    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:keychainKey accessGroup:nil];
    [keychain resetKeychainItem];
}

+ (void)removeAllSwipeAddresses
{
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeBitcoin];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeBitcoinCash];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeEther];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeStellar];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypePax];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeAlgorand];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeTether];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeWDGLD];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeYearnFinance];
}

#pragma mark - Single Address Swipe to Receive

+ (void)setSingleSwipeAddress:(NSString *_Nonnull)swipeAddress forAssetType:(LegacyAssetType)assetType
{
    NSString *key = [self keychainKeyForAssetType:assetType];
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:key accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

    [keychain setObject:key forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[swipeAddress dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
}

+ (NSString *_Nullable)getSingleSwipeAddressForAssetType:(LegacyAssetType)assetType
{
    NSString *key = [self keychainKeyForAssetType:assetType];
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:key accessGroup:nil];
    NSData *addressData = [keychain objectForKey:(__bridge id)kSecValueData];
    NSString *address = [[NSString alloc] initWithData:addressData encoding:NSUTF8StringEncoding];
    return address.length == 0 ? nil : address;
}

@end
