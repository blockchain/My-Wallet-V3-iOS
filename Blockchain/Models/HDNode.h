//
//  HDNode.h
//  Blockchain
//
//  Created by Kevin Wu on 10/20/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
@class HDNode, BTCKeychain, KeyPair;

@protocol ExportHDNode <JSExport>

// Chain code associated with the key.
@property (nonatomic, readonly) JSValue* chainCode;
@property (nonatomic, readonly) KeyPair* keyPair;
@property (nonatomic, readonly) uint8_t depth;
@property (nonatomic, readonly) uint32_t index;
@property (nonatomic, readonly) uint32_t parentFingerprint;
@property (nonatomic, readonly) BTCKeychain *keychain;
@property (nonatomic, readonly) JSValue *network;

+ (HDNode *)fromSeed:(JSValue *)seed buffer:(JSValue *)network;
+ (HDNode *)from:(NSString *)seed base58:(JSValue *)networks;
- (NSString *)getAddress;
- (NSString *)getIdentifier;
- (JSValue *)getNetwork;
- (JSValue *)getPublicKeyBuffer;
- (JSValue *)getFingerprint;
- (NSString *)toBase58:(JSValue *)isPrivate;
- (HDNode *)derive:(JSValue *)_index;
- (HDNode *)deriveHardened:(JSValue *)_index;
- (BOOL)isNeutered;
- (HDNode *)derivePath:(JSValue *)path;
- (HDNode *)neutered;
- (JSValue *)sign:(JSValue *)hash;

- (BOOL)verify:(NSString *)hash signature:(NSString *)signature;
@end

@interface HDNode : NSObject <ExportHDNode>
@property (nonatomic) BTCKeychain *keychain;
@end
