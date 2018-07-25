//
//  ExchangeTrade.h
//  Blockchain
//
//  Created by kevinwu on 11/13/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TRADE_STATUS_NO_DEPOSITS @"no_deposits"
#define TRADE_STATUS_RECEIVED @"received"
#define TRADE_STATUS_COMPLETE @"complete"
#define TRADE_STATUS_RESOLVED @"resolved"
#define TRADE_STATUS_IN_PROGRESS @"IN_PROGRESS"
#define TRADE_STATUS_CANCELLED @"CANCELLED"
#define TRADE_STATUS_FAILED @"failed"
#define TRADE_STATUS_EXPIRED @"EXPIRED"

#define DICTIONARY_KEY_STATUS @"status"
#define DICTIONARY_KEY_PAIR @"pair"
#define DICTIONARY_KEY_QUOTE @"quote"
#define DICTIONARY_KEY_QUOTED_RATE @"quotedRate"
#define DICTIONARY_KEY_ORDER_ID @"orderId"
#define DICTIONARY_KEY_WITHDRAWAL_AMOUNT @"withdrawalAmount"
#define DICTIONARY_KEY_EXPIRATION_DATE @"expirationDate"
#define DICTIONARY_KEY_DEPOSIT_AMOUNT @"depositAmount"
#define DICTIONARY_KEY_MINER_FEE @"minerFee"

@interface ExchangeTrade : NSObject
@property (nonatomic) NSString *orderID;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSDate *expirationDate;
@property (nonatomic) NSString *status;
@property (nonatomic) NSString *pair;
@property (nonatomic) NSDecimalNumber *depositAmount;
@property (nonatomic) NSDecimalNumber *withdrawalAmount;
@property (nonatomic) NSDecimalNumber *transactionFee;
@property (nonatomic) NSDecimalNumber *minerFee;
@property (nonatomic) NSDecimalNumber *exchangeRate;
@property (nonatomic) NSString *exchangeRateString;

+ (ExchangeTrade *)fetchedTradeFromJSONDict:(NSDictionary *)dict;
+ (ExchangeTrade *)builtTradeFromJSONDict:(NSDictionary *)dict;

- (NSString *)exchangeRateString;
- (NSString *)depositCurrency;
- (NSString *)withdrawalCurrency;

@end
