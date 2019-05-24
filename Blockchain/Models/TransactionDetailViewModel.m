//
//  TransactionDetailViewModel.m
//  Blockchain
//
//  Created by kevinwu on 9/7/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailViewModel.h"
#import "Transaction.h"
#import "EtherTransaction.h"
#import "NSNumberFormatter+Currencies.h"
#import "NSDateFormatter+VerboseString.h"
#import "Blockchain-Swift.h"

@interface TransactionDetailViewModel ()
@property (nonatomic) uint64_t feeInSatoshi;
@end

@implementation TransactionDetailViewModel

- (id)initWithTransaction:(Transaction *)transaction
{
    if (self == [super init]) {
        self.assetType = LegacyAssetTypeBitcoin;
        
        id fromLabel = [transaction.from objectForKey:DICTIONARY_KEY_LABEL];
        id toLabel = [transaction.to.firstObject objectForKey:DICTIONARY_KEY_LABEL];
        
        NSString *fromLabelString = [fromLabel isKindOfClass:[NSNumber class]] ? [fromLabel stringValue] : fromLabel;
        NSString *toLabelString = [toLabel isKindOfClass:[NSNumber class]] ? [toLabel stringValue] : toLabel;
        
        self.fromString = fromLabelString;
        self.fromAddress = [transaction.from objectForKey:DICTIONARY_KEY_ADDRESS];
        self.hasFromLabel = [transaction.from objectForKey:DICTIONARY_KEY_ACCOUNT_INDEX] || ![fromLabelString isEqualToString:self.fromAddress];
        self.hasToLabel = [[transaction.to firstObject] objectForKey:DICTIONARY_KEY_ACCOUNT_INDEX] || ![toLabelString isEqualToString:[[transaction.to firstObject] objectForKey:DICTIONARY_KEY_ADDRESS]];
        self.to = transaction.to;
        self.toString = toLabelString;
        
        self.amountInSatoshi = ABS(transaction.amount);
        self.feeInSatoshi = transaction.fee;
        self.txType = transaction.txType;
        self.time = transaction.time;
        self.note = transaction.note;
        // TODO: IOS-1988 Add tests for confirmations string
        self.confirmationsString = [NSString stringWithFormat:@"%lu/%u", (unsigned long)transaction.confirmations, kConfirmationBitcoinThreshold];
        self.confirmations = transaction.confirmations;
        self.confirmed = transaction.confirmations >= kConfirmationBitcoinThreshold;
        self.fiatAmountsAtTime = transaction.fiatAmountsAtTime;
        self.doubleSpend = transaction.doubleSpend;
        self.replaceByFee = transaction.replaceByFee;
        self.dateString = [NSDateFormatter verboseStringFromDate:[NSDate dateWithTimeIntervalSince1970:self.time]];
        self.myHash = transaction.myHash;
        
        CurrencySymbol *currentSymbol = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc;
        WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc = [CurrencySymbol btcSymbolFromCode:CURRENCY_CODE_BTC];
        NSString *decimalString = [NSNumberFormatter formatAmountFromUSLocale:imaxabs(self.amountInSatoshi) localCurrency:NO] ? : @"0";
        self.decimalAmount = [NSDecimalNumber decimalNumberWithString:decimalString];
        WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc = currentSymbol;
        
        self.detailButtonTitle = [[NSString stringWithFormat:@"%@ %@",BC_STRING_VIEW_ON_URL_ARGUMENT, [[BlockchainAPI sharedInstance] blockchainDotCom]] uppercaseString];
        self.detailButtonLink = [[[BlockchainAPI sharedInstance] bitcoinExplorerUrl] stringByAppendingFormat:@"/tx/%@", self.myHash];
    }
    return self;
}

- (id)initWithEtherTransaction:(EtherTransaction *)etherTransaction exchangeRate:(NSDecimalNumber *)exchangeRate defaultAddress:(NSString *)defaultAddress
{
    if (self == [super init]) {
        self.exchangeRate = exchangeRate;
        self.assetType = LegacyAssetTypeEther;
        self.txType = etherTransaction.txType;
        self.fromString = etherTransaction.from;
        self.fromAddress = etherTransaction.from;
        self.to = @[etherTransaction.to];
        self.toString = etherTransaction.to;
        self.amountString = [NSNumberFormatter truncatedEthAmount:[NSDecimalNumber decimalNumberWithString:etherTransaction.amount] locale:nil];
        self.decimalAmount = [NSDecimalNumber decimalNumberWithString:[NSNumberFormatter truncatedEthAmount:[NSDecimalNumber decimalNumberWithString:etherTransaction.amount] locale:[NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US]]];
        self.myHash = etherTransaction.myHash;
        self.feeString = etherTransaction.fee;
        self.note = etherTransaction.note;
        self.time = etherTransaction.time;
        self.dateString = [NSDateFormatter verboseStringFromDate:[NSDate dateWithTimeIntervalSince1970:self.time]];
        self.detailButtonTitle = [[NSString stringWithFormat:@"%@ %@",BC_STRING_VIEW_ON_URL_ARGUMENT, [[BlockchainAPI sharedInstance] blockchainDotCom]] uppercaseString];
        self.detailButtonLink =
        [[[BlockchainAPI sharedInstance] etherExplorer] stringByAppendingFormat:@"/tx/%@", self.myHash];

        self.ethExchangeRate = exchangeRate;
        // TODO: IOS-1988 Add tests for confirmations string
        self.confirmationsString = [NSString stringWithFormat:@"%lu/%u", (unsigned long)etherTransaction.confirmations, kConfirmationEtherThreshold];
        self.confirmations = etherTransaction.confirmations;
        self.confirmed = etherTransaction.confirmations >= kConfirmationEtherThreshold;
        self.fiatAmountsAtTime = etherTransaction.fiatAmountsAtTime;
    }
    return self;
}

- (id)initWithBitcoinCashTransaction:(Transaction *)transaction
{
    TransactionDetailViewModel *model = [self initWithTransaction:transaction];

    Wallet *wallet = WalletManager.sharedInstance.wallet;
    AddressValidator *addressValidator = [[AddressValidator alloc] initWithContext:wallet.context];

    // Populate "from" field
    BitcoinCashAddress *fromAddress = [[BitcoinCashAddress alloc] initWithString:model.fromAddress];
    if ([addressValidator validateWithBitcoinCashAddress:fromAddress]) {
        BitcoinAddress *fromBtcAddress = [[BitcoinAddress alloc] initWithString:model.fromAddress];
        model.fromString = [fromBtcAddress toBitcoinCashAddressWithWallet:wallet].address;
    }

    // Populate "to" field
    BitcoinAddress *toBtcAddress = [[BitcoinAddress alloc] initWithString:model.toString];
    BitcoinCashAddress *toBchAddress = [toBtcAddress toBitcoinCashAddressWithWallet:WalletManager.sharedInstance.wallet];
    model.toString = toBchAddress.address ?: model.toString;

    model.assetType = LegacyAssetTypeBitcoinCash;
    model.hideNote = YES;
    model.detailButtonTitle = [[BC_STRING_VIEW_ON_URL_ARGUMENT stringByAppendingFormat:@" %@", [[BlockchainAPI sharedInstance] blockchainDotCom]] uppercaseString];
    model.detailButtonLink = [BlockchainAPI.sharedInstance transactionDetailURLFor:model.myHash assetType:AssetTypeBitcoinCash];
    return model;
}

- (NSString *)getAmountString
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        return [NSNumberFormatter formatMoneyWithLocalSymbol:ABS(self.amountInSatoshi)];
    } else if (self.assetType == LegacyAssetTypeEther) {
        return [NSNumberFormatter formatEthWithLocalSymbol:self.amountString exchangeRate:self.ethExchangeRate];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        return [NSNumberFormatter formatBchWithSymbol:ABS(self.amountInSatoshi)];
    } else if (self.assetType == LegacyAssetTypeStellar) {
        return self.amountString;
    } else if (self.assetType == LegacyAssetTypePax) {
        return self.amountString;
    }
    
    return nil;
}

- (NSString *)getFeeString
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        return [self getBtcFeeString];
    } else if (self.assetType == LegacyAssetTypeEther) {
        return [self getEthFeeString];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        return [self getBchFeeString];
    } else if (self.assetType == LegacyAssetTypeStellar) {
        return self.feeString;
    } else if (self.assetType == LegacyAssetTypePax) {
        return self.feeString;
    }
    return nil;
}

- (NSString *)getBtcFeeString
{
    return [NSNumberFormatter formatMoneyWithLocalSymbol:ABS(self.feeInSatoshi)];
}

- (NSString *)getEthFeeString
{
    return [NSNumberFormatter formatEthWithLocalSymbol:self.feeString exchangeRate:self.exchangeRate];
}

- (NSString *)getBchFeeString
{
    return [NSNumberFormatter formatBchWithSymbol:ABS(self.feeInSatoshi)];
}

@end
