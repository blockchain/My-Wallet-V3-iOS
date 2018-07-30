//
//  EtherTransaction.m
//  Blockchain
//
//  Created by kevinwu on 8/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "EtherTransaction.h"

@implementation EtherTransaction

+ (EtherTransaction *)fromJSONDict:(NSDictionary *)dict
{
    EtherTransaction *transaction = [[EtherTransaction alloc] init];
    
    transaction.amount = [[dict objectForKey:DICTIONARY_KEY_AMOUNT] stringValue];
    transaction.amountTruncated = [EtherTransaction truncatedAmount:transaction.amount];
    transaction.fee = [dict objectForKey:DICTIONARY_KEY_FEE];
    transaction.from = [dict objectForKey:DICTIONARY_KEY_FROM];
    transaction.to = [dict objectForKey:DICTIONARY_KEY_TO];
    transaction.time = [[dict objectForKey:DICTIONARY_KEY_TIME] longLongValue];
    transaction.txType = [dict objectForKey:DICTIONARY_KEY_TRANSACTION_TX_TYPE];
    transaction.myHash = [dict objectForKey:DICTIONARY_KEY_HASH];
    transaction.confirmations = [[dict objectForKey:DICTIONARY_KEY_TRANSACTION_CONFIRMATIONS] longLongValue];
    
    id noteObject = [dict objectForKey:DICTIONARY_KEY_NOTE];
    transaction.note = [noteObject isKindOfClass:[NSString class]] ? noteObject : nil;

    transaction.fiatAmountsAtTime = [[NSMutableDictionary alloc] init];
    
    return transaction;
}

+ (NSString *)truncatedAmount:(NSString *)amountString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:8];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSDecimalNumber decimalNumberWithString:amountString]];
}

@end
