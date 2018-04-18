//
//  KeychainItemWrapper+Credentials.h
//  Blockchain
//
//  Created by Kevin Wu on 8/22/16.
//  Copyright © 2016  Blockchain Luxembourg S.A. All rights reserved.
//

#import "KeychainItemWrapper.h"

@interface KeychainItemWrapper (Credentials)
+ (nullable NSString *)guid;
+ (NSString *)hashedGuid;
+ (void)setGuidInKeychain:(NSString *)guid;
+ (void)removeGuidFromKeychain;

+ (nullable NSString *)sharedKey;
+ (void)setSharedKeyInKeychain:(NSString *)sharedKey;
+ (void)removeSharedKeyFromKeychain;

+ (void)setPINInKeychain:(NSString *)pin;
+ (NSString *)pinFromKeychain;
+ (void)removePinFromKeychain;

@end
