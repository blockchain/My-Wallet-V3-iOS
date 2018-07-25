//
//  EtherTransaction.h
//  Blockchain
//
//  Created by kevinwu on 8/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EtherTransaction : NSObject

+ (EtherTransaction *)fromJSONDict:(NSDictionary *)dict;

@property (nonatomic) NSString *amount;
@property (nonatomic) NSString *amountTruncated;
@property (nonatomic) NSString *fee;
@property (nonatomic) NSString *from;
@property (nonatomic) NSString *to;
@property (nonatomic) NSString *myHash;
@property (nonatomic) NSString *note;
@property (nonatomic) NSString *txType;
@property (nonatomic) uint64_t time;
@property (nonatomic) uint64_t confirmations;

@property(nonatomic, strong) NSMutableDictionary *fiatAmountsAtTime;

@end
