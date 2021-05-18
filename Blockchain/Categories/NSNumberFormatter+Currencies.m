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

+ (NSString *)satoshiToBTC:(uint64_t)value
{
    return [NSNumberFormatter formatAmount:value localCurrency:NO];
}

// Format amount in satoshi as NSString (with symbol)
+ (NSString*)formatMoney:(uint64_t)value localCurrency:(BOOL)fsymbolLocal
{
    if (fsymbolLocal && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion) {
        @try {
            NSDecimalNumber *valueDecimal = (NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value];
            NSDecimalNumber *conversionDecimal = (NSDecimalNumber*)[NSDecimalNumber numberWithDouble:(double)WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion];
            NSDecimalNumber *number = [valueDecimal decimalNumberByDividingBy:conversionDecimal];

            NSString *symbol = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol;
            NSString *valueString = [[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator] stringFromNumber:number];
            return [symbol stringByAppendingString:valueString];
            
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else {
        NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
        NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:satoshi];

        NSString * string = [[NSNumberFormatter bitcoinFormatterWithGroupingSeparator] stringFromNumber:number];
        
        return [string stringByAppendingString:@" BTC"];
    }
    
    return [NSNumberFormatter formatBTC:value];
}

+ (NSString*)formatBTC:(uint64_t)value
{
    NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
    NSDecimalNumber * number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:satoshi];
    
    NSString * string = [[NSNumberFormatter bitcoinFormatterWithGroupingSeparator] stringFromNumber:number];
    
    return [string stringByAppendingString:@" BTC"];
}

+ (NSString*)formatMoney:(uint64_t)value
{
    return [self formatMoney:value localCurrency:BlockchainSettingsApp.shared.symbolLocal];
}

// Format amount in satoshi as NSString (without symbol)
+ (NSString *)internalFormatAmount:(uint64_t)amount localCurrency:(BOOL)localCurrency localCurrencyFormatter:(NSNumberFormatter *)localCurrencyFormatter
{
    if (amount == 0) {
        return nil;
    }
    
    NSString *returnValue;
    
    if (localCurrency) {
        
        if (!WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local) {
            return nil;
        }
        
        @try {

            NSDecimalNumber *amountDecimal = (NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount];
            NSDecimalNumber *conversionDecimal = (NSDecimalNumber*)[NSDecimalNumber numberWithDouble:(double)WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion];
            NSDecimalNumber *number = [amountDecimal decimalNumberByDividingBy:conversionDecimal];
            
            returnValue = [localCurrencyFormatter stringFromNumber:number];
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else {
        @try {
            NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
            NSDecimalNumber *number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount] decimalNumberByDividingBy:satoshi];
            
            returnValue = [localCurrencyFormatter stringFromNumber:number];
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    }
    
    return returnValue;
}

+ (NSString *)formatAmount:(uint64_t)amount localCurrency:(BOOL)localCurrency
{
    return [NSNumberFormatter internalFormatAmount:amount localCurrency:localCurrency localCurrencyFormatter:localCurrency ? [NSNumberFormatter localCurrencyFormatter] : [NSNumberFormatter bitcoinAssetFormatter]];
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
    return [self formatMoney:value localCurrency:BlockchainSettingsApp.shared.symbolLocal];
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
    NSString *requestedAmountString = [NSNumberFormatter convertWithDecimalString:ethAmount];
    
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

    if (BlockchainSettingsApp.shared.symbolLocal && hasSymbol) {
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

#pragma mark - Bitcoin Cash

+ (NSString *)formatBCHAmountInAutomaticLocalCurrency:(uint64_t)amount {
    BOOL inLocalCurrency = BlockchainSettingsApp.shared.symbolLocal;
    return [NSNumberFormatter formatBCHAmount:amount includeSymbol:YES inLocalCurrency:inLocalCurrency];
}

// Format BCH amount in satoshi as NSString, option to include Symbol, option to show in fiat.
+ (NSString *)formatBCHAmount:(uint64_t)amount includeSymbol:(BOOL)includeSymbol inLocalCurrency:(BOOL)localCurrency
{
    NSString *returnValue = @"";
    
    if (localCurrency && [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate]) {
        @try {
            NSString *lastRate = [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate];
            NSDecimalNumber *lastRateDecimalNumber = [NSDecimalNumber decimalNumberWithString:lastRate];
            NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
            NSDecimalNumber *conversion = [satoshi decimalNumberByDividingBy:lastRateDecimalNumber];
            NSDecimalNumber *amountDecimalNumber = (NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount];
            NSDecimalNumber *resultAmount = [amountDecimalNumber decimalNumberByDividingBy:conversion];

            returnValue = [[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator] stringFromNumber:resultAmount];

            if (includeSymbol) {
                NSString *currencyCode = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol;
                returnValue = [currencyCode stringByAppendingFormat:@" %@", returnValue];
            }
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else {
        @try {
            NSDecimalNumber *amountDecimalNumber = (NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount];
            NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
            NSDecimalNumber *resultAmount = [amountDecimalNumber decimalNumberByDividingBy:satoshi];

            returnValue = [[NSNumberFormatter bitcoinFormatterWithGroupingSeparator] stringFromNumber:resultAmount];

            if (includeSymbol) {
                NSString *currencyCode = CURRENCY_SYMBOL_BCH;
                returnValue = [returnValue stringByAppendingFormat:@" %@", currencyCode];
            }
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    }

    
    return returnValue;
}

@end
