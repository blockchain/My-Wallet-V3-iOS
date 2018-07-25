//
//  ExchangeTrade.m
//  Blockchain
//
//  Created by kevinwu on 11/13/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeTrade.h"
#import "NSNumberFormatter+Currencies.h"

#define ORDER_NUMBER_PREFIX @"SFT-"

@implementation ExchangeTrade

+ (ExchangeTrade *)fetchedTradeFromJSONDict:(NSDictionary *)dict
{
    ExchangeTrade *trade = [[ExchangeTrade alloc] init];
    
    trade.date = [dict objectForKey:DICTIONARY_KEY_TIME];
    trade.status = [dict objectForKey:DICTIONARY_KEY_STATUS];
    
    NSDictionary *quote = [dict objectForKey:DICTIONARY_KEY_QUOTE];
    trade.orderID = [ORDER_NUMBER_PREFIX stringByAppendingString:[quote objectForKey:DICTIONARY_KEY_ORDER_ID]];
    trade.pair = [quote objectForKey:DICTIONARY_KEY_PAIR];
    trade.depositAmount = [ExchangeTrade decimalNumberFromDictValue:[quote objectForKey:DICTIONARY_KEY_DEPOSIT_AMOUNT]];
    trade.withdrawalAmount = [ExchangeTrade decimalNumberFromDictValue:[quote objectForKey:DICTIONARY_KEY_WITHDRAWAL_AMOUNT]];
    trade.minerFee = [ExchangeTrade decimalNumberFromDictValue:[quote objectForKey:DICTIONARY_KEY_MINER_FEE]];
    
    trade.exchangeRate = [ExchangeTrade decimalNumberFromDictValue:[quote objectForKey:DICTIONARY_KEY_QUOTED_RATE]];
    trade.exchangeRateString = [trade exchangeRateString];
    
    return trade;
}

+ (ExchangeTrade *)builtTradeFromJSONDict:(NSDictionary *)dict
{
    ExchangeTrade *trade = [[ExchangeTrade alloc] init];
    trade.depositAmount = [ExchangeTrade decimalNumberFromDictValue:[dict objectForKey:DICTIONARY_KEY_DEPOSIT_AMOUNT]];
    trade.withdrawalAmount = [ExchangeTrade decimalNumberFromDictValue:[dict objectForKey:DICTIONARY_KEY_WITHDRAWAL_AMOUNT]];
    trade.minerFee = [ExchangeTrade decimalNumberFromDictValue:[dict objectForKey:DICTIONARY_KEY_MINER_FEE]];
    trade.expirationDate = [dict objectForKey:DICTIONARY_KEY_EXPIRATION_DATE];
    trade.exchangeRate = [ExchangeTrade decimalNumberFromDictValue:[dict objectForKey:DICTIONARY_KEY_RATE]];
    
    return trade;
}

+ (NSDecimalNumber *)decimalNumberFromDictValue:(id)value
{
    NSDecimalNumber *decimalNumber;
    if ([value isKindOfClass:[NSString class]]) {
        decimalNumber = [NSDecimalNumber decimalNumberWithString:value];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setMaximumFractionDigits:8];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US];
        [formatter setLocale:usLocale];
        NSString *numberString = [formatter stringFromNumber:value];
        decimalNumber = [[NSDecimalNumber alloc] initWithString:numberString];
    }
    
    return decimalNumber;
}

- (NSString *)exchangeRateString
{
    NSArray *coinPairComponents = [self.pair componentsSeparatedByString:@"_"];
    NSString *from = [[coinPairComponents firstObject] uppercaseString];
    NSString *to = [[coinPairComponents lastObject] uppercaseString];
    NSString *amount = [NSNumberFormatter localFormattedString:[self.exchangeRate stringValue]];
    return [NSString stringWithFormat:@"%@ %@ = %@ %@", [NSNumberFormatter localFormattedString:@"1"], from, amount, to];
}

- (NSString *)depositCurrency
{
    NSArray *components = [self.pair componentsSeparatedByString:@"_"];
    return components.firstObject;
}

- (NSString *)withdrawalCurrency
{
    NSArray *components = [self.pair componentsSeparatedByString:@"_"];
    return components.lastObject;
    
}

@end
