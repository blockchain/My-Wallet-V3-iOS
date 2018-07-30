//
//  NSNumberFormatter+Currencies.h
//  Blockchain
//
//  Created by Kevin Wu on 8/22/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (Currencies)

+ (NSString *)localCurrencyCode;
+ (NSString *)satoshiToBTC:(uint64_t)value;
+ (NSDecimalNumber *)formatSatoshiInLocalCurrency:(uint64_t)value;
+ (NSString*)formatMoney:(uint64_t)value;
+ (NSString*)formatMoney:(uint64_t)value localCurrency:(BOOL)fsymbolLocal;
+ (NSString *)formatAmount:(uint64_t)amount localCurrency:(BOOL)localCurrency;
+ (NSString *)formatAmountFromUSLocale:(uint64_t)amount localCurrency:(BOOL)localCurrency;
+ (NSString*)formatBTC:(uint64_t)value;
+ (BOOL)stringHasBitcoinValue:(NSString *)string;
+ (NSString *)appendStringToFiatSymbol:(NSString *)number;
+ (NSString *)formatMoneyWithLocalSymbol:(uint64_t)value;

+ (NSString *)formatEth:(id)ethAmount; // NSString or NSDecimalNumber
+ (NSDecimalNumber *)convertEthToFiat:(NSDecimalNumber *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate;
+ (NSDecimalNumber *)convertFiatToEth:(NSDecimalNumber *)fiatAmount exchangeRate:(NSDecimalNumber *)exchangeRate;

+ (NSString *)formatEthToFiat:(NSString *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate localCurrencyFormatter:(NSNumberFormatter *)localCurrencyFormatter;
+ (NSString *)formatFiatToEth:(NSString *)fiatAmount exchangeRate:(NSDecimalNumber *)exchangeRate;

+ (NSString *)formatEthToFiatWithSymbol:(NSString *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate;
+ (NSString *)formatFiatToEthWithSymbol:(NSString *)fiatAmount exchangeRate:(NSDecimalNumber *)exchangeRate;
+ (NSString *)formatEthWithLocalSymbol:(NSString *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate;

+ (NSString *)ethAmount:(NSDecimalNumber *)amount;
+ (NSString *)truncatedEthAmount:(NSDecimalNumber *)amount locale:(NSLocale *)preferredLocale;

+ (NSString *)convertedDecimalString:(NSString *)entryString;
+ (NSString *)localFormattedString:(NSString *)amountString;
+ (NSString *)fiatStringFromDouble:(double)fiatBalance;
    
+ (uint64_t)parseBtcValueFromString:(NSString *)inputString;

+ (NSString*)formatBCH:(uint64_t)value;
+ (NSString*)formatBch:(uint64_t)value localCurrency:(BOOL)fsymbolLocal;
+ (NSString*)formatBchWithSymbol:(uint64_t)value;
+ (NSString *)formatBchWithSymbol:(uint64_t)amount localCurrency:(BOOL)localCurrency;

@end
