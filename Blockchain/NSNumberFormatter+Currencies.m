//
//  NSNumberFormatter+Currencies.m
//  Blockchain
//
//  Created by Kevin Wu on 8/22/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

@implementation NSNumberFormatter (Currencies)

#pragma mark - Format helpers

+ (NSString *)localCurrencyCode
{
    return WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.code;
}

+ (NSDecimalNumber *)formatSatoshiInLocalCurrency:(uint64_t)value
{
    if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion) {
        return [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:(double)WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion]];
    } else {
        return nil;
    }
}

+ (NSString *)satoshiToBTC:(uint64_t)value
{
    uint64_t currentConversion = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion;
    WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion = SATOSHI;
    NSString *result = [NSNumberFormatter formatAmount:value localCurrency:NO];
    WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion = currentConversion;
    return result;
}

// Format amount in satoshi as NSString (with symbol)
+ (NSString*)formatMoney:(uint64_t)value localCurrency:(BOOL)fsymbolLocal
{
    if (fsymbolLocal && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion) {
        @try {
            NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:(double)WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion]];
            
            return [WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol stringByAppendingString:[[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator] stringFromNumber:number]];
            
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc) {
        NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion]];

        NSString * string = [[NSNumberFormatter assetFormatterWithGroupingSeparator] stringFromNumber:number];
        
        return [string stringByAppendingFormat:@" %@", WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.symbol];
    }
    
    return [NSNumberFormatter formatBTC:value];
}

+ (NSString*)formatBTC:(uint64_t)value
{
    NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:SATOSHI]];
    
    NSString * string = [[NSNumberFormatter assetFormatterWithGroupingSeparator] stringFromNumber:number];
    
    return [string stringByAppendingString:@" BTC"];
}

+ (NSString*)formatMoney:(uint64_t)value
{
    return [self formatMoney:value localCurrency:BlockchainSettings.sharedAppInstance.symbolLocal];
}

// Format amount in satoshi as NSString (without symbol)
+ (NSString *)internalFormatAmount:(uint64_t)amount localCurrency:(BOOL)localCurrency localCurrencyFormatter:(NSNumberFormatter *)localCurrencyFormatter
{
    if (amount == 0) {
        return nil;
    }
    
    NSString *returnValue;
    
    if (localCurrency) {
        
        if (!WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local) return nil;
        
        @try {
            NSDecimalNumber *number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:(double)WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion]];
            
            returnValue = [localCurrencyFormatter stringFromNumber:number];
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else {
        @try {
            NSDecimalNumber *number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion]];
            
            returnValue = [localCurrencyFormatter stringFromNumber:number];
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    }
    
    return returnValue;
}

+ (NSString *)formatAmountFromUSLocale:(uint64_t)amount localCurrency:(BOOL)localCurrency
{
    return [NSNumberFormatter internalFormatAmount:amount localCurrency:localCurrency localCurrencyFormatter:[NSNumberFormatter assetFormatterWithUSLocale]];
}

+ (NSString *)formatAmount:(uint64_t)amount localCurrency:(BOOL)localCurrency
{
    return [NSNumberFormatter internalFormatAmount:amount localCurrency:localCurrency localCurrencyFormatter:[NSNumberFormatter assetFormatter]];
}

+ (BOOL)stringHasBitcoinValue:(NSString *)string
{
    return string != nil && [string doubleValue] > 0;
}

+ (NSString *)appendStringToFiatSymbol:(NSString *)string
{
    return [WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol stringByAppendingFormat:@"%@", string];
}

+ (NSString *)formatMoneyWithLocalSymbol:(uint64_t)value
{
    return [self formatMoney:value localCurrency:BlockchainSettings.sharedAppInstance.symbolLocal];
}

#pragma mark - Ether

+ (NSString *)formatEth:(id)ethAmount
{
    return [NSString stringWithFormat:@"%@ %@", ethAmount ? : @"0", CURRENCY_SYMBOL_ETH];
}

+ (NSDecimalNumber *)convertEthToFiat:(NSDecimalNumber *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate
{
    if (ethAmount == 0 || !exchangeRate) return 0;
    
    return [ethAmount decimalNumberByMultiplyingBy:exchangeRate];
}

+ (NSString *)formatEthToFiat:(NSString *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate localCurrencyFormatter:(NSNumberFormatter *)localCurrencyFormatter
{
    NSString *requestedAmountString = [NSNumberFormatter convertedDecimalString:ethAmount];
    
    if (requestedAmountString != nil && [requestedAmountString doubleValue] > 0) {
        NSDecimalNumber *ethAmountDecimalNumber = [NSDecimalNumber decimalNumberWithString:requestedAmountString];
        NSString *result = [localCurrencyFormatter stringFromNumber:[NSNumberFormatter convertEthToFiat:ethAmountDecimalNumber exchangeRate:exchangeRate]];
        return result;
    } else {
        return nil;
    }
}

+ (NSString *)formatEthToFiatWithSymbol:(NSString *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate
{
    NSString *formatString = [NSNumberFormatter formatEthToFiat:ethAmount exchangeRate:exchangeRate localCurrencyFormatter:[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator]];
    if (!formatString) {
        return [NSString stringWithFormat:@"%@0.00", WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol];
    } else {
        return [NSString stringWithFormat:@"%@%@", WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol, formatString];
    }
}

+ (NSDecimalNumber *)convertFiatToEth:(NSDecimalNumber *)fiatAmount exchangeRate:(NSDecimalNumber *)exchangeRate
{
    if (fiatAmount == 0 || !exchangeRate) return 0;
    
    return [fiatAmount decimalNumberByDividingBy:exchangeRate];
}

+ (NSString *)formatFiatToEth:(NSString *)fiatAmount exchangeRate:(NSDecimalNumber *)exchangeRate
{
    if (fiatAmount != nil && [fiatAmount doubleValue] > 0) {
        NSDecimalNumber *fiatAmountDecimalNumber = [NSDecimalNumber decimalNumberWithString:fiatAmount];
        return [NSString stringWithFormat:@"%@", [NSNumberFormatter convertFiatToEth:fiatAmountDecimalNumber exchangeRate:exchangeRate]];
    } else {
        return nil;
    }
}

+ (NSString *)formatFiatToEthWithSymbol:(NSString *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate
{
    NSString *formatString = [NSNumberFormatter formatFiatToEth:ethAmount exchangeRate:exchangeRate];
    if (!formatString) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%@ %@", WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.code, formatString];
    }
}

+ (NSString *)formatEthWithLocalSymbol:(NSString *)ethAmount exchangeRate:(NSDecimalNumber *)exchangeRate
{
    NSString *symbol = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol;
    BOOL hasSymbol = symbol && ![symbol isKindOfClass:[NSNull class]];

    if (BlockchainSettings.sharedAppInstance.symbolLocal && hasSymbol) {
        return [NSNumberFormatter formatEthToFiatWithSymbol:ethAmount exchangeRate:exchangeRate];
    } else {
        return [NSNumberFormatter formatEth:ethAmount];
    }
}

+ (NSString *)truncatedEthAmount:(NSDecimalNumber *)amount locale:(NSLocale *)preferredLocale
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    if (preferredLocale) formatter.locale = preferredLocale;
    [formatter setMaximumFractionDigits:8];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:amount];
}

+ (NSString *)ethAmount:(NSDecimalNumber *)amount
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.usesGroupingSeparator = NO;
    [formatter setMaximumFractionDigits:ETH_DECIMAL_LIMIT];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:amount];
}

+ (NSString *)convertedDecimalString:(NSString *)entryString
{
    __block NSString *requestedAmountString;
    if ([entryString containsString:@"٫"]) {
        // Special case for Eastern Arabic numerals: NSDecimalNumber decimalNumberWithString: returns NaN for Eastern Arabic numerals, and NSNumberFormatter results have precision errors even with generatesDecimalNumbers set to YES.
        NSError *error;
        NSRange range = NSMakeRange(0, [entryString length]);
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_EASTERN_ARABIC_NUMERALS options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSDictionary *easternArabicNumeralDictionary = DICTIONARY_EASTERN_ARABIC_NUMERAL;
        
        NSMutableString *replaced = [entryString mutableCopy];
        __block NSInteger offset = 0;
        [regex enumerateMatchesInString:entryString options:0 range:range usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            NSRange range1 = [result rangeAtIndex:0]; // range of the matched subgroup
            NSString *key = [entryString substringWithRange:range1];
            NSString *value = easternArabicNumeralDictionary[key];
            if (value != nil) {
                NSRange range = [result range]; // range of the matched pattern
                // Update location according to previous modifications:
                range.location += offset;
                [replaced replaceCharactersInRange:range withString:value];
                offset += value.length - range.length; // Update offset
            }
            requestedAmountString = [NSString stringWithString:replaced];
        }];
    } else {
        requestedAmountString = [entryString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    }
    
    return requestedAmountString;
}

+ (NSString *)localFormattedString:(NSString *)amountString
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:8];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSLocale *currentLocale = numberFormatter.locale;
    numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US];
    NSNumber *number = [numberFormatter numberFromString:amountString];
    numberFormatter.locale = currentLocale;
    return [numberFormatter stringFromNumber:number];
}
    
+ (NSString *)fiatStringFromDouble:(double)fiatBalance
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumIntegerDigits = 1;
    NSUInteger decimalPlaces = 2;
    numberFormatter.minimumFractionDigits = decimalPlaces;
    numberFormatter.maximumFractionDigits = decimalPlaces;
    numberFormatter.usesGroupingSeparator = YES;
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:fiatBalance]];
}

+ (uint64_t)parseBtcValueFromString:(NSString *)inputString
{
    // Always use BTC conversion rate
    uint64_t currentConversion = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion;
    WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion = SATOSHI;
    uint64_t result = [WalletManager.sharedInstance.wallet parseBitcoinValueFromString:inputString];
    WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion = currentConversion;
    return result;
}

#pragma mark - Bitcoin Cash

+ (NSString*)formatBCH:(uint64_t)value
{
    NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithDouble:SATOSHI]];
    
    NSString * string = [[NSNumberFormatter assetFormatterWithGroupingSeparator] stringFromNumber:number];
    
    return [string stringByAppendingString:@" BCH"];
}

+ (NSString*)formatBchWithSymbol:(uint64_t)value
{
    return [self formatBchWithSymbol:value localCurrency:BlockchainSettings.sharedAppInstance.symbolLocal];
}

// Format amount in satoshi as NSString (with symbol)
+ (NSString*)formatBchWithSymbol:(uint64_t)value localCurrency:(BOOL)fsymbolLocal
{
    if (fsymbolLocal && [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate]) {
        @try {
            
            NSString *lastRate = [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate];
            
            NSDecimalNumber *conversion = [[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:SATOSHI] decimalValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:lastRate]];
            
            NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:conversion];
            
            return [WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol stringByAppendingString:[[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator] stringFromNumber:number]];
            
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc) {
        NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion]];
        
        NSString * string = [[NSNumberFormatter assetFormatterWithGroupingSeparator] stringFromNumber:number];
        
        NSString *currencyCode = CURRENCY_SYMBOL_BCH;
        
        return [string stringByAppendingFormat:@" %@", currencyCode];
    }
    
    return [NSNumberFormatter formatBCH:value];
}

// Format amount in satoshi as NSString (without symbol)
+ (NSString *)formatBch:(uint64_t)amount localCurrency:(BOOL)localCurrency
{
    if (amount == 0) {
        return nil;
    }
    
    NSString *returnValue;
    
    if (localCurrency && [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate]) {
        @try {
            
            NSString *lastRate = [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate];
            
            NSDecimalNumber *conversion = [[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:SATOSHI] decimalValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:lastRate]];
            
            NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount] decimalNumberByDividingBy:conversion];
            
            returnValue = [[NSNumberFormatter localCurrencyFormatter] stringFromNumber:number];
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc) {
        @try {
            NSDecimalNumber *number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount] decimalNumberByDividingBy:(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion]];
            
            returnValue = [[NSNumberFormatter assetFormatter] stringFromNumber:number];
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    }
    
    return returnValue;
}

@end
