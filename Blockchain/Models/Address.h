//
//  Address.h
//  Blockchain
//
//  Created by Ben Reeves on 13/01/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

@interface Address : NSObject

@property(nonatomic, strong) NSString *address;
@property(nonatomic, assign) uint64_t total_received;
@property(nonatomic, assign) uint64_t total_sent;
@property(nonatomic, assign) uint64_t final_balance;
@property(nonatomic, assign) uint32_t n_transactions;

@end
