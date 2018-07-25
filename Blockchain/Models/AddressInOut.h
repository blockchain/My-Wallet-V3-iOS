//
//  AddressInOut.h
//  Blockchain
//
//  Created by Mark Pfluger on 12/16/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

@interface AddressInOut : NSObject

@property(nonatomic, strong) NSString *address;
@property(nonatomic, assign) uint64_t amount;

@end
