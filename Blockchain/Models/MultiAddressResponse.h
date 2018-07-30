/*
 * 
 * Copyright (c) 2012, Ben Reeves. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */


#import <Foundation/Foundation.h>

@interface CurrencySymbol : NSObject

@property(nonatomic, assign) uint64_t conversion;

@property(nonatomic, strong) NSString * code;
@property(nonatomic, strong) NSString * symbol;
@property(nonatomic, strong) NSString * name;

+(CurrencySymbol*)symbolFromDict:(NSDictionary*)dict;
+(CurrencySymbol*)btcSymbolFromCode:(NSString *)code;
+ (NSDictionary *)currencyNames;

@end

@interface LatestBlock : NSObject
@property(nonatomic, assign) uint32_t blockIndex;
@property(nonatomic, assign) uint32_t height;
@property(nonatomic, assign) uint64_t time;

@end

@interface MultiAddressResponse : NSObject

@property(nonatomic, assign) uint64_t total_received;
@property(nonatomic, assign) uint64_t total_sent;
@property(nonatomic, assign) uint64_t final_balance;
@property(nonatomic, assign) uint32_t n_transactions;

@property(nonatomic, strong) NSArray * addresses;
@property(nonatomic, strong) NSMutableArray * transactions;
@property(nonatomic, strong) CurrencySymbol * symbol_btc;
@property(nonatomic, strong) CurrencySymbol * symbol_local;

@end
