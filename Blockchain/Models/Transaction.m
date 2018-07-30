//
//  Transaction.m
//  Blockchain
//
//  Created by Ben Reeves on 10/01/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

+ (Transaction*)fromJSONDict:(NSDictionary *)transactionDict {
    
    Transaction * transaction = [[Transaction alloc] init];
    
    transaction.from = [transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_FROM];
    transaction.to = [transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_TO];

    transaction.block_height = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_BLOCK_HEIGHT] intValue];
    transaction.confirmations = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_CONFIRMATIONS] intValue];
    transaction.fee = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_FEE] longLongValue];
    transaction.myHash = [transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_MY_HASH] ? : [transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_HASH];
    transaction.txType = [transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_TX_TYPE];
    transaction.amount = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_AMOUNT] longLongValue];
    transaction.time = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_TIME] longLongValue];
    transaction.lastUpdated = transaction.time;
    transaction.fromWatchOnly = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_FROM_WATCH_ONLY] boolValue];
    transaction.toWatchOnly = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_TO_WATCH_ONLY] boolValue];
    transaction.note = [transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_NOTE];
    transaction.doubleSpend = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_DOUBLE_SPEND] boolValue];
    transaction.replaceByFee = [[transactionDict objectForKey:DICTIONARY_KEY_TRANSACTION_REPLACE_BY_FEE] boolValue];
    
    transaction.fiatAmountsAtTime = [[NSMutableDictionary alloc] init];
    
    return transaction;
}

- (NSComparisonResult)reverseCompareLastUpdated:(Transaction *)transaction
{
    return [[NSDecimalNumber decimalNumberWithDecimal:[[NSDecimalNumber numberWithLongLong:transaction.lastUpdated] decimalValue]] compare:[NSDecimalNumber decimalNumberWithDecimal:[[NSDecimalNumber numberWithLongLong:self.lastUpdated] decimalValue]]];
}

@end
