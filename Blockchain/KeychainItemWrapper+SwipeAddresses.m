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
    if (assetType == LegacyAssetTypeBitcoin) {
        return KEYCHAIN_KEY_BTC_SWIPE_ADDRESSES;
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return KEYCHAIN_KEY_BCH_SWIPE_ADDRESSES;
    } else if (assetType == LegacyAssetTypeEther) {
        return KEYCHAIN_KEY_ETHER_ADDRESS;
    } else {
        DLog(@"KeychainItemWrapper error: Unsupported asset type!")
        return nil;
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

+ (void)addSwipeAddress:(id)swipeAddress assetType:(LegacyAssetType)assetType
{
    NSMutableArray *swipeAddresses = [KeychainItemWrapper getMutableSwipeAddressesForAssetType:assetType];
    if (!swipeAddresses) swipeAddresses = [NSMutableArray new];
    [swipeAddresses addObject:swipeAddress];
    
    NSString *keychainKey = [KeychainItemWrapper keychainKeyForAssetType:assetType];
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:keychainKey accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    
    [keychain setObject:keychainKey forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[NSKeyedArchiver archivedDataWithRootObject:swipeAddresses] forKey:(__bridge id)kSecValueData];
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
}

+ (void)setSwipeEtherAddress:(NSString *)swipeAddress
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_ETHER_ADDRESS accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    
    [keychain setObject:KEYCHAIN_KEY_ETHER_ADDRESS forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[swipeAddress dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
}

+ (void)removeSwipeEtherAddress
{
    KeychainItemWrapper *etherKeychain = [[KeychainItemWrapper alloc] initWithIdentifier:[self keychainKeyForAssetType:LegacyAssetTypeEther] accessGroup:nil];
    [etherKeychain resetKeychainItem];
}

+ (NSString *)getSwipeEtherAddress
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[self keychainKeyForAssetType:LegacyAssetTypeEther] accessGroup:nil];
    NSData *etherAddressData = [keychain objectForKey:(__bridge id)kSecValueData];
    NSString *etherAddress = [[NSString alloc] initWithData:etherAddressData encoding:NSUTF8StringEncoding];
    
    return etherAddress.length == 0 ? nil : etherAddress;
}

@end
