//
//  NSArray+EncodedJSONString.m
//  Blockchain
//
//  Created by Kevin Wu on 4/5/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "NSArray+EncodedJSONString.h"

@implementation NSArray (EncodedJSONString)

- (NSData *)arrayToJSON
{
    NSError *error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

- (NSString *)jsonString
{
    return [[NSString alloc] initWithData:[self arrayToJSON]
                                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)encodedJSONString
{
    NSData *jsonArray = [self arrayToJSON];
    // Pass the JSON to an UTF8 string
    return [jsonArray base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
