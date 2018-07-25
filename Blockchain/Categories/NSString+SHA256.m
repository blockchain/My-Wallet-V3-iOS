//
//  NSString+SHA256.m
//  Blockchain
//
//  Created by Ben Reeves on 18/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#include <CommonCrypto/CommonDigest.h>

#import "NSString+SHA256.h"
#import "NSData+Hex.h"

@implementation NSString (SHA256)

-(NSString*)SHA256:(int)rounds {
    unsigned char hash[32];
    
    CC_SHA256([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], hash);

    for (int ii = 1; ii < rounds; ++ii) {
        CC_SHA256(hash, 32, hash);
    }
    
    NSData * data = [NSData dataWithBytes:hash length:32];
    
    return [data hexadecimalString];
}

-(NSString*)SHA256 {
    unsigned char result[32];
    
    CC_SHA256([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], result);
    
    NSData * data = [NSData dataWithBytes:result length:32];
    
    return [data hexadecimalString];
}

@end
