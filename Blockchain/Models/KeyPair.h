//
//  KeyPair.h
//  Blockchain
//
//  Created by Kevin Wu on 11/2/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
@class BTCKey, KeyPair;

@protocol ExportKeyPair <JSExport>
@property (nonatomic, readonly) JSValue *d;
@property (nonatomic, readonly) JSValue *Q;
@property (nonatomic, readonly) JSValue *network;

+ (KeyPair *)fromPublicKey:(NSString *)buffer buffer:(JSValue *)network;
+ (KeyPair *)from:(NSString *)string WIF:(JSValue *)network;
+ (KeyPair *)makeRandom:(JSValue *)options;

- (NSString *)getAddress;
- (JSValue *)getPublicKeyBuffer;
- (JSValue *)sign:(JSValue *)hash;
- (NSString *)toWIF;

- (BOOL)verify:(NSString *)hash signature:(NSString *)signature;
@end

@interface KeyPair : NSObject <ExportKeyPair>
@property (nonatomic) BTCKey *key;
- (id)initWithKey:(BTCKey *)key network:(JSValue *)network;
@end
