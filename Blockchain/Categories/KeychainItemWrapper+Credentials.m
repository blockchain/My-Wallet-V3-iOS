//
//  KeychainItemWrapper+Credentials.m
//  Blockchain
//
//  Created by Kevin Wu on 8/22/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "KeychainItemWrapper+Credentials.h"
#import "NSString+SHA256.h"

@implementation KeychainItemWrapper (Credentials)

#pragma mark - GUID

+ (NSString *)guid
{
    // Attempt to migrate guid from NSUserDefaults to KeyChain
    NSString *guidFromUserDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_GUID];
    if (guidFromUserDefaults) {
        [self setGuidInKeychain:guidFromUserDefaults];
        
        if ([self guidFromKeychain]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_GUID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Remove all UIWebView cached data for users upgrading from older versions
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
        } else {
            DLog(@"failed to set GUID in keychain");
            return guidFromUserDefaults;
        }
    }
    
    return [self guidFromKeychain];
}

+ (void)setGuidInKeychain:(NSString *)guid
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_GUID accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    
    [keychain setObject:KEYCHAIN_KEY_GUID forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[guid dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
}

+ (NSString *)guidFromKeychain {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_GUID accessGroup:nil];
    NSData *guidData = [keychain objectForKey:(__bridge id)kSecValueData];
    NSString *guid = [[NSString alloc] initWithData:guidData encoding:NSUTF8StringEncoding];
    
    return guid.length == 0 ? nil : guid;
}

+ (void)removeGuidFromKeychain
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_GUID accessGroup:nil];
    
    [keychain resetKeychainItem];
}

+ (NSString *)hashedGuid
{
    return [[self guid] SHA256];
}

#pragma mark - SharedKey

+ (NSString *)sharedKey
{
    // Migrate sharedKey from NSUserDefaults (for users updating from old version)
    NSString *sharedKeyFromUserDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_SHARED_KEY];
    if (sharedKeyFromUserDefaults) {
        [self setSharedKeyInKeychain:sharedKeyFromUserDefaults];
        
        if ([self sharedKeyFromKeychain]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_SHARED_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            DLog(@"!!! failed to set sharedKey in keychain ???");
            return sharedKeyFromUserDefaults;
        }
    }
    
    return [self sharedKeyFromKeychain];
}

+ (NSString *)sharedKeyFromKeychain {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_SHARED_KEY accessGroup:nil];
    NSData *sharedKeyData = [keychain objectForKey:(__bridge id)kSecValueData];
    NSString *sharedKey = [[NSString alloc] initWithData:sharedKeyData encoding:NSUTF8StringEncoding];
    
    return sharedKey.length == 0 ? nil : sharedKey;
}

+ (void)setSharedKeyInKeychain:(NSString *)sharedKey
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_SHARED_KEY accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    
    [keychain setObject:KEYCHAIN_KEY_SHARED_KEY forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[sharedKey dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
}

+ (void)removeSharedKeyFromKeychain
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_SHARED_KEY accessGroup:nil];
    
    [keychain resetKeychainItem];
}

#pragma mark - PIN

+ (void)setPINInKeychain:(NSString *)pin
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_PIN accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    
    [keychain setObject:KEYCHAIN_KEY_PIN forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[pin dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
}

+ (NSString *)pinFromKeychain
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_PIN accessGroup:nil];
    NSData *pinData = [keychain objectForKey:(__bridge id)kSecValueData];
    NSString *pin = [[NSString alloc] initWithData:pinData encoding:NSUTF8StringEncoding];
    
    return pin.length == 0 ? nil : pin;
}

+ (void)removePinFromKeychain
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_KEY_PIN accessGroup:nil];
    
    [keychain resetKeychainItem];
}

@end
