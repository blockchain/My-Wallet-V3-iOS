//
//  API.m
//  Blockchain
//
//  Created by Ben Reeves on 10/01/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "MultiAddressResponse.h"
#import "Address.h"
#import "Transaction.h"
#import "Wallet.h"
#import "NSString+SHA256.h"
#import "NSString+URLEncode.h"
#import "Blockchain-Swift.h"

@implementation CurrencySymbol
@synthesize code;
@synthesize symbol;
@synthesize name;
@synthesize conversion;

+(CurrencySymbol*)symbolFromDict:(NSDictionary *)dict {
    
    CurrencySymbol * symbol = [[CurrencySymbol alloc] init];
    symbol.code = [dict objectForKey:DICTIONARY_KEY_CODE];
    symbol.symbol = [dict objectForKey:DICTIONARY_KEY_SYMBOL];
    NSNumber *last = [dict objectForKey:DICTIONARY_KEY_LAST];
    
#ifdef DEBUG
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_ZERO_TICKER]) last = 0;
#endif
    if (!last || [last isEqualToNumber:@0]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_ERROR_TICKER title:BC_STRING_ERROR handler: nil];
        });
        return nil;
    }
    symbol.conversion = [[[(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI] decimalNumberByDividingBy: (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[last doubleValue]]] stringValue] longLongValue];
    symbol.name = [[CurrencySymbol currencyNames] objectForKey:symbol.code];
    
    return symbol;
}

+(CurrencySymbol*)btcSymbolFromCode:(NSString *)code
{
    NSDictionary *btc = @{DICTIONARY_KEY_SYMBOL: CURRENCY_SYMBOL_BTC, DICTIONARY_KEY_CONVERSION: CURRENCY_CONVERSION_BTC, DICTIONARY_KEY_NAME: CURRENCY_NAME_BTC};
    
    NSDictionary *btcCurrencies = @{CURRENCY_CODE_BTC: btc};
    
    CurrencySymbol * symbol = [[CurrencySymbol alloc] init];
    symbol.code = CURRENCY_CODE_BTC;
    NSDictionary * currency = [btcCurrencies objectForKey:CURRENCY_CODE_BTC];
    symbol.symbol = [currency objectForKey:DICTIONARY_KEY_SYMBOL];
    symbol.conversion = [[currency objectForKey:DICTIONARY_KEY_CONVERSION] longLongValue];
    symbol.name = [currency objectForKey:DICTIONARY_KEY_NAME];
    
    return symbol;
}

+ (NSDictionary *)currencyNames
{
    return @{
             CURRENCY_CODE_USD: BC_STRING_US_DOLLAR,
             CURRENCY_CODE_EUR: BC_STRING_EURO,
             CURRENCY_CODE_ISK: BC_STRING_ICELANDIC_KRONA,
             CURRENCY_CODE_HKD: BC_STRING_HONG_KONG_DOLLAR,
             CURRENCY_CODE_TWD: BC_STRING_NEW_TAIWAN_DOLLAR,
             CURRENCY_CODE_CHF: BC_STRING_SWISS_FRANC,
             CURRENCY_CODE_DKK: BC_STRING_DANISH_KRONE,
             CURRENCY_CODE_CLP: BC_STRING_CHILEAN_PESO,
             CURRENCY_CODE_CAD: BC_STRING_CANADIAN_DOLLAR,
             CURRENCY_CODE_INR: BC_STRING_INDIAN_RUPEE,
             CURRENCY_CODE_CNY: BC_STRING_CHINESE_YUAN,
             CURRENCY_CODE_THB: BC_STRING_THAI_BAHT,
             CURRENCY_CODE_AUD: BC_STRING_AUSTRALIAN_DOLLAR,
             CURRENCY_CODE_SGD: BC_STRING_SINGAPORE_DOLLAR,
             CURRENCY_CODE_KRW: BC_STRING_SOUTH_KOREAN_WON,
             CURRENCY_CODE_JPY: BC_STRING_JAPANESE_YEN,
             CURRENCY_CODE_PLN: BC_STRING_POLISH_ZLOTY,
             CURRENCY_CODE_GBP: BC_STRING_GREAT_BRITISH_POUND,
             CURRENCY_CODE_SEK: BC_STRING_SWEDISH_KRONA,
             CURRENCY_CODE_NZD: BC_STRING_NEW_ZEALAND_DOLLAR,
             CURRENCY_CODE_BRL: BC_STRING_BRAZIL_REAL,
             CURRENCY_CODE_RUB: BC_STRING_RUSSIAN_RUBLE
    };
}

@end

@implementation LatestBlock
@synthesize blockIndex;
@synthesize height;
@synthesize time;


@end

@implementation MultiAddressResponse

@synthesize transactions;
@synthesize total_received;
@synthesize total_sent;
@synthesize final_balance;
@synthesize n_transactions;
@synthesize symbol_local;
@synthesize symbol_btc;


@end

