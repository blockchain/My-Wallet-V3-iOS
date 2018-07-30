//
//  AccountInOut.h
//  Blockchain
//
//  Created by Mark Pfluger on 12/16/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

@interface AccountInOut : NSObject

@property(nonatomic, assign) uint32_t accountIndex;
@property(nonatomic, assign) uint64_t amount;

@end
