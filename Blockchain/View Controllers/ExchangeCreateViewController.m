//
//  ExchangeCreateViewController.m
//  Blockchain
//
//  Created by kevinwu on 10/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeCreateViewController.h"
#import "FromToView.h"
#import "Blockchain-Swift.h"
#import "ContinueButtonInputAccessoryView.h"
#import "ExchangeTrade.h"
#import "ExchangeConfirmViewController.h"
#import "BCNavigationController.h"
#import "NSNumberFormatter+Currencies.h"

#define DICTIONARY_KEY_TRADE_MINIMUM @"minimum"
#define DICTIONARY_KEY_TRADE_MAX_LIMIT @"maxLimit"

#define IMAGE_NAME_SWITCH_CURRENCIES @"switch_currencies"

@interface ExchangeCreateViewController () <UITextFieldDelegate, FromToButtonDelegate, AddressSelectionDelegate, ContinueButtonInputAccessoryViewDelegate, ExchangeCreateViewDelegate>

@property (nonatomic) NSTimer *quoteTimer;

@property (nonatomic) id amount;
@property (nonatomic) int btcAccount;
@property (nonatomic) int ethAccount;
@property (nonatomic) int bchAccount;

@property (nonatomic) NSString *oldFromSymbol;
@property (nonatomic) NSString *oldToSymbol;

@property (nonatomic) NSString *availableBalanceFromSymbol;
@property (nonatomic) NSString *fromSymbol;
@property (nonatomic) NSString *toSymbol;
@property (nonatomic) NSString *fromAddress;
@property (nonatomic) NSString *toAddress;

@property (nonatomic) NSURLSessionDataTask *currentDataTask;

// uint64_t or NSDecimalNumber
@property (nonatomic) id minimum;
@property (nonatomic) id maximum;
@property (nonatomic) id maximumHardLimit;
@property (nonatomic) id availableBalance;
@property (nonatomic) id fee;

@property (nonatomic) ExchangeCreateView *exchangeView;
@end

@implementation ExchangeCreateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.exchangeView = [[ExchangeCreateView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.exchangeView];
    [self.exchangeView setupWithCreateViewDelegate:self fromToButtonDelegate:self continueButtonInputAccessoryDelegate:self textFieldDelegate:self];
    
    self.btcAccount = [WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:LegacyAssetTypeBitcoin];
    
    [self selectFromBitcoin];
    [self selectToEther];
    
    [self clearAmount];
    [self clearAvailableBalance];
    
    [self.exchangeView disablePaymentButtons];
    
    if ([WalletManager.sharedInstance.wallet getTotalActiveBalance] > 0 ||
        [[NSDecimalNumber decimalNumberWithString:[WalletManager.sharedInstance.wallet getEthBalance]] compare:@0] == NSOrderedDescending ||
        [WalletManager.sharedInstance.wallet getBchBalance] > 0) {
        [self getRate];
    } else {
        [[AppCoordinator sharedInstance].tabControllerManager showGetAssetsAlert];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    navigationController.headerTitle = BC_STRING_EXCHANGE;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.quoteTimer invalidate];
    self.quoteTimer = nil;
}

#pragma mark - JS Callbacks

- (void)didGetExchangeRate:(ExchangeRate *)exchangeRate
{
    [self.exchangeView enableAssetToggleButton];
    [self.exchangeView stopSpinner];
    
    if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC] || [self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        NSString *minNumberString = exchangeRate.minimum.stringValue;
        self.minimum = [NSNumber numberWithLongLong:[NSNumberFormatter parseBtcValueFromString:minNumberString]];
        NSString *maxNumberString = exchangeRate.maxLimit.stringValue;
        self.maximum = [NSNumber numberWithLongLong:[NSNumberFormatter parseBtcValueFromString:maxNumberString]];
        NSString *hardLimitString = exchangeRate.hardLimit.stringValue;
        self.maximumHardLimit = [NSNumber numberWithLongLong:[NSNumberFormatter parseBtcValueFromString:hardLimitString]];
        if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
            [WalletManager.sharedInstance.wallet getAvailableBtcBalanceForAccount:self.btcAccount];
            self.availableBalanceFromSymbol = self.fromSymbol;
        } else {
            [WalletManager.sharedInstance.wallet getAvailableBchBalanceForAccount:self.bchAccount];
            self.availableBalanceFromSymbol = self.fromSymbol;
        }
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        self.minimum = exchangeRate.minimum;
        self.maximum = exchangeRate.maxLimit;
        self.maximumHardLimit = exchangeRate.hardLimit;
        [WalletManager.sharedInstance.wallet getAvailableEthBalance];
    }
}

- (void)didGetAvailableEthBalance:(NSDictionary *)result
{
    self.availableBalance = [NSDecimalNumber decimalNumberWithDecimal:[[result objectForKey:DICTIONARY_KEY_AMOUNT] decimalValue]];
    self.fee = [result objectForKey:DICTIONARY_KEY_FEE];
    
    self.maximumHardLimit = self.fee ? [self.maximumHardLimit decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:[self.fee stringValue]]] : self.maximumHardLimit;
    
    [self updateAvailableBalance];
}

- (void)didGetAvailableBtcBalance:(NSDictionary *)result
{
    if (!result) {
        NSString *amountText = [[NSNumberFormatter satoshiToBTC:[self.minimum longLongValue]] stringByAppendingFormat:@" %@", self.availableBalanceFromSymbol];
        NSString *errorText = [NSString stringWithFormat:BC_STRING_ARGUMENT_NEEDED_TO_EXCHANGE, amountText];
        [self.exchangeView showErrorWithText:errorText];
        return;
    }
    
    self.availableBalance = [result objectForKey:DICTIONARY_KEY_AMOUNT];
    self.fee = [result objectForKey:DICTIONARY_KEY_FEE];
    
    self.maximumHardLimit = self.fee ? [NSNumber numberWithLongLong:[self.maximumHardLimit longLongValue] - [self.fee longLongValue]] : [NSNumber numberWithLongLong:[NSNumberFormatter parseBtcValueFromString:self.maximumHardLimit]];
    
    [self updateAvailableBalance];
}

- (void)updateAvailableBalance
{
    BOOL overAvailable = NO;
    BOOL overMax = NO;
    BOOL underMin = NO;
    BOOL zeroAmount = NO;
    BOOL notEnoughToExchange = NO;
    BOOL isWaitingOnTransaction = NO;
    
    NSString *errorText;
    
    NSString *fromSymbol = self.fromSymbol;
    if ([fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC] || [fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        
        uint64_t amount = [self.amount longLongValue];
        
        DLog(@"btc amount: %lld", amount);
        DLog(@"available: %lld", [self.availableBalance longLongValue]);
        DLog(@"max: %lld", [self.maximum longLongValue])
        
        if (![self hasEnoughFunds:self.fromSymbol]) {
            DLog(@"not enough %@", fromSymbol);
            notEnoughToExchange = YES;
            NSString *amountText = [[NSNumberFormatter satoshiToBTC:[self.minimum longLongValue]] stringByAppendingFormat:@" %@", self.fromSymbol];
            errorText = [NSString stringWithFormat:BC_STRING_ARGUMENT_NEEDED_TO_EXCHANGE, amountText];
        } else if (amount == 0) {
            zeroAmount = YES;
        } else if (amount > [self.availableBalance longLongValue]) {
            DLog(@"%@ over available", fromSymbol);
            overAvailable = YES;
            errorText = BC_STRING_NOT_ENOUGH_TO_EXCHANGE;
        } else if (amount > [self.maximum longLongValue] || amount > [self.maximumHardLimit longLongValue]) {
            DLog(@"%@ over max", fromSymbol);
            overMax = YES;
            errorText = BC_STRING_ABOVE_MAXIMUM_LIMIT;
        } else if (amount < [self.minimum longLongValue] ) {
            DLog(@"%@ under min", fromSymbol);
            underMin = YES;
            errorText = BC_STRING_BELOW_MINIMUM_LIMIT;
        }
        
    } else if ([fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        DLog(@"eth amount: %@", [self.amount stringValue]);
        DLog(@"available: %@", [self.availableBalance stringValue]);
        DLog(@"max: %@", [self.maximum stringValue])
        
        if ([WalletManager.sharedInstance.wallet isWaitingOnEtherTransaction]) {
            DLog(@"waiting on eth transaction");
            isWaitingOnTransaction = YES;
            errorText = BC_STRING_WAITING_FOR_ETHER_PAYMENT_TO_FINISH_MESSAGE;
        } else if (![self hasEnoughFunds:CURRENCY_SYMBOL_ETH]) {
            DLog(@"not enough eth");
            notEnoughToExchange = YES;
            NSString *amountString = [[NSNumberFormatter localFormattedString:[self amountString:self.minimum]] stringByAppendingFormat:@" %@", CURRENCY_SYMBOL_ETH];
            errorText = [NSString stringWithFormat:BC_STRING_ARGUMENT_NEEDED_TO_EXCHANGE, amountString];
        } else if ([self.amount compare:@0] == NSOrderedSame || !self.amount) {
            zeroAmount = YES;
        } else if ([self.amount compare:self.availableBalance] == NSOrderedDescending) {
            DLog(@"eth over available");
            overAvailable = YES;
            errorText = BC_STRING_NOT_ENOUGH_TO_EXCHANGE;
        } else if ([self.amount compare:self.maximum] == NSOrderedDescending || [self.amount compare:self.maximumHardLimit] == NSOrderedDescending) {
            DLog(@"eth over max");
            overMax = YES;
            errorText = BC_STRING_ABOVE_MAXIMUM_LIMIT;
        } else if ([self.amount compare:self.minimum] == NSOrderedAscending) {
            DLog(@"eth under min");
            underMin = YES;
            errorText = BC_STRING_BELOW_MINIMUM_LIMIT;
        }
    }
    
    if (zeroAmount) {
        self.exchangeView.errorTextView.hidden = YES;
        [self.exchangeView disablePaymentButtons];
    } else if (overAvailable || overMax || underMin || notEnoughToExchange || isWaitingOnTransaction) {
        [self.exchangeView showErrorWithText:errorText];
    } else {
        [self.exchangeView removeHighlightFromAmounts];
        [self.exchangeView enablePaymentButtons];
        self.exchangeView.errorTextView.hidden = YES;
    }
}

- (void)didGetApproximateQuote:(NSDictionary *)result
{
    id depositAmount = [result objectForKey:DICTIONARY_KEY_DEPOSIT_AMOUNT];
    id withdrawalAmount = [result objectForKey:DICTIONARY_KEY_WITHDRAWAL_AMOUNT];
    
    NSString *depositAmountString = [depositAmount isKindOfClass:[NSString class]] ? depositAmount : [depositAmount stringValue];
    NSString *withdrawalAmountString = [withdrawalAmount isKindOfClass:[NSString class]] ? withdrawalAmount : [withdrawalAmount stringValue];
    
    self.exchangeView.topLeftField.text = [NSNumberFormatter localFormattedString:depositAmountString];
    self.exchangeView.topRightField.text = [NSNumberFormatter localFormattedString:withdrawalAmountString];;
    
    NSString *pair = [self coinPair];
    if ([[pair lowercaseString] isEqualToString: [[result objectForKey:DICTIONARY_KEY_PAIR] lowercaseString]]) {
        
        NSString *btcResult = [self convertBtcAmountToFiat:self.exchangeView.btcField.text];
        NSString *ethResult = [self convertEthAmountToFiat:self.exchangeView.ethField.text];
        NSString *bchResult = [self convertBchAmountToFiat:self.exchangeView.bchField.text];
        
        NSString *fromSymbol = self.fromSymbol;
        if ([fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
            self.exchangeView.bottomLeftField.text = ethResult;
            self.amount = [NSDecimalNumber decimalNumberWithString:depositAmountString];
        } else if ([fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
            self.exchangeView.bottomLeftField.text = btcResult;
            self.amount = [NSNumber numberWithLongLong:[NSNumberFormatter parseBtcValueFromString:depositAmountString]];
        } else if ([fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
            self.exchangeView.bottomLeftField.text = bchResult;
            self.amount = [NSNumber numberWithLongLong:[NSNumberFormatter parseBtcValueFromString:depositAmountString]];
        }
        
        self.exchangeView.lastChangedField = self.exchangeView.bottomLeftField;
        
        NSString *toSymbol = self.toSymbol;
        if ([toSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
            self.exchangeView.bottomRightField.text = ethResult;
        } else if ([toSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
            self.exchangeView.bottomRightField.text = btcResult;
        } else if ([toSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
            self.exchangeView.bottomRightField.text = bchResult;
        }
        
        [self updateAvailableBalance];
    } else {
        DLog(@"Wrong coinpair!");
    }
}

- (void)didBuildExchangeTrade:(NSDictionary *)tradeInfo
{
    [[LoadingViewPresenter sharedInstance] hideBusyView];
    
    ExchangeTrade *trade = [ExchangeTrade builtTradeFromJSONDict:tradeInfo];
    // pair is not returned from API call - need to manually set
    trade.pair = [self coinPair];
    trade.exchangeRateString = [trade exchangeRateString];
    NSString *feeString = [NSNumberFormatter convertedDecimalString:[tradeInfo objectForKey:DICTIONARY_KEY_FEE]];
    trade.transactionFee = [NSDecimalNumber decimalNumberWithString:feeString];
    ExchangeConfirmViewController *confirmViewController = [[ExchangeConfirmViewController alloc] initWithExchangeTrade:trade];
    [self.navigationController pushViewController:confirmViewController animated:YES];
}

#pragma mark - Conversion

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray  *points = [newString componentsSeparatedByString:@"."];
    NSLocale *locale = [textField.textInputMode.primaryLanguage isEqualToString:LOCALE_IDENTIFIER_AR] ? [NSLocale localeWithLocaleIdentifier:textField.textInputMode.primaryLanguage] : [NSLocale currentLocale];
    NSArray  *commas = [newString componentsSeparatedByString:[locale objectForKey:NSLocaleDecimalSeparator]];
    
    // Only one comma or point in input field allowed
    if ([points count] > 2 || [commas count] > 2)
        return NO;
    
    // Only 1 leading zero
    if (points.count == 1 || commas.count == 1) {
        if (range.location == 1 && ![string isEqualToString:@"."] && ![string isEqualToString:@","] && ![string isEqualToString:@"٫"] && [textField.text isEqualToString:@"0"]) {
            return NO;
        }
    }
    
    // When entering amount in ETH, max 18 decimal places
    if (textField == self.exchangeView.ethField) {
        // Max number of decimal places depends on bitcoin unit
        NSUInteger maxlength = ETH_DECIMAL_LIMIT;
        
        if (points.count == 2) {
            NSString *decimalString = points[1];
            if (decimalString.length > maxlength) {
                return NO;
            }
        }
        else if (commas.count == 2) {
            NSString *decimalString = commas[1];
            if (decimalString.length > maxlength) {
                return NO;
            }
        }
    }
    
    // When entering amount in BTC, max 8 decimal places
    else if (textField == self.exchangeView.btcField || textField == self.exchangeView.bchField) {
        // Max number of decimal places depends on bitcoin unit
        NSUInteger maxlength = [@(SATOSHI) stringValue].length - [@(SATOSHI / WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion) stringValue].length;
        
        if (points.count == 2) {
            NSString *decimalString = points[1];
            if (decimalString.length > maxlength) {
                return NO;
            }
        }
        else if (commas.count == 2) {
            NSString *decimalString = commas[1];
            if (decimalString.length > maxlength) {
                return NO;
            }
        }
    }
    
    // Fiat currencies have a max of 3 decimal places, most of them actually only 2. For now we will use 2.
    else if (textField == self.exchangeView.bottomLeftField || self.exchangeView.bottomRightField) {
        if (points.count == 2) {
            NSString *decimalString = points[1];
            if (decimalString.length > 2) {
                return NO;
            }
        }
        else if (commas.count == 2) {
            NSString *decimalString = commas[1];
            if (decimalString.length > 2) {
                return NO;
            }
        }
    }
    
    self.exchangeView.lastChangedField = textField;
    
    NSString *amountString = [NSNumberFormatter convertedDecimalString:newString];
    
    [self saveAmount:amountString fromField:textField];
    
    [self.exchangeView clearOppositeFields];
    
    [self cancelCurrentDataTask];
    
    [self.quoteTimer invalidate];
    
    [self performSelector:@selector(doCurrencyConversionAfterTyping) withObject:nil afterDelay:0.1f];
    return YES;
}

- (void)saveAmount:(NSString *)amountString fromField:(UITextField *)textField
{
    ExchangeCreateView *exchangeView = self.exchangeView;
    
    if (textField == exchangeView.ethField) {
        self.amount = [NSDecimalNumber decimalNumberWithString:amountString];
    } else if (textField == exchangeView.btcField || textField == exchangeView.bchField) {
        self.amount = [NSNumber numberWithLongLong:[NSNumberFormatter parseBtcValueFromString:amountString]];
    } else {
        if (textField == exchangeView.bottomLeftField) {
            if (exchangeView.topLeftField == exchangeView.ethField) {
                [self convertFiatStringToEth:amountString];
            } else if (exchangeView.topLeftField == exchangeView.btcField) {
                [self convertFiatStringToBtc:amountString];
            } else if (exchangeView.topLeftField == exchangeView.bchField) {
                [self convertFiatStringToBch:amountString];
            }
        } else if (textField == exchangeView.bottomRightField) {
            if (exchangeView.topRightField == exchangeView.ethField) {
                [self convertFiatStringToEth:amountString];
            } else if (exchangeView.topRightField == exchangeView.btcField) {
                [self convertFiatStringToBtc:amountString];
            } else if (exchangeView.topRightField == exchangeView.bchField) {
                [self convertFiatStringToBch:amountString];
            }
        }
    }
}

- (void)convertFiatStringToEth:(NSString *)amountString
{
    NSDecimalNumber *amountStringDecimalNumber = amountString && [amountString doubleValue] > 0 ? [NSDecimalNumber decimalNumberWithString:amountString] : 0;
    self.amount = [NSNumberFormatter convertFiatToEth:amountStringDecimalNumber exchangeRate:WalletManager.sharedInstance.wallet.latestEthExchangeRate];
}

- (void)convertFiatStringToBtc:(NSString *)amountString
{
    self.amount = [NSNumber numberWithLongLong:WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion * [amountString doubleValue]];
}

- (void)convertFiatStringToBch:(NSString *)amountString
{
    self.amount = [NSNumber numberWithLongLong:[WalletManager.sharedInstance.wallet getBitcoinCashConversion] * [amountString doubleValue]];
}

- (NSString *)convertBtcAmountToFiat
{
    return [self convertBtcAmountToFiat:self.amount];
}

- (NSString *)convertBchAmountToFiat
{
    return [self convertBchAmountToFiat:self.amount];
}

- (NSString *)convertEthAmountToFiat
{
    return [self convertEthAmountToFiat:self.amount];
}

- (NSString *)convertBtcAmountToFiat:(id)amount
{
    uint64_t amountArg = 0;
    if ([amount isKindOfClass:[NSString class]]) {
        amountArg = [NSNumberFormatter parseBtcValueFromString:amount];
    } else if ([amount isKindOfClass:[NSNumber class]])  {
        amountArg = [amount longLongValue];
    } else {
        DLog(@"Amount is not a string or number!");
    }
    
    return [NSNumberFormatter formatAmount:amountArg localCurrency:YES];
}

- (NSString *)convertBchAmountToFiat:(id)amount
{
    uint64_t amountArg = 0;
    if ([amount isKindOfClass:[NSString class]]) {
        amountArg = [NSNumberFormatter parseBtcValueFromString:amount];
    } else if ([amount isKindOfClass:[NSNumber class]])  {
        amountArg = [amount longLongValue];
    } else {
        DLog(@"Amount is not a string or number!");
    }
    
    return [NSNumberFormatter formatBch:amountArg localCurrency:YES];
}

- (NSString *)convertEthAmountToFiat:(id)amount
{
    id amountArg;
    if ([amount isKindOfClass:[NSString class]]) {
        amountArg = amount;
    } else if ([amount isKindOfClass:[NSNumber class]])  {
        amountArg = [amount stringValue];
    } else {
        DLog(@"Amount is not a string or number!");
    }
    
    NSString *result = [NSNumberFormatter formatEthToFiat:amountArg exchangeRate:WalletManager.sharedInstance.wallet.latestEthExchangeRate localCurrencyFormatter:[NSNumberFormatter localCurrencyFormatter]];
    return result;
}

- (void)doCurrencyConversionAfterTyping
{
    [self doCurrencyConversion];
    
    if ([self.exchangeView.bottomLeftField isFirstResponder] || [self.exchangeView.topLeftField isFirstResponder]) {
        [self updateAvailableBalance];
    }
    
    [self.exchangeView disablePaymentButtons];
    
    self.quoteTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getApproximateQuoteAfterTimer) userInfo:nil repeats:NO];
}

- (void)doCurrencyConversion
{
    ExchangeCreateView *exchangeView = self.exchangeView;
    
    if ([exchangeView.btcField isFirstResponder]) {
        
        NSString *result = [self convertBtcAmountToFiat];
        
        if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
            exchangeView.bottomRightField.text = result;
        } else {
            exchangeView.bottomLeftField.text = result;
        }
        
    } else if ([exchangeView.ethField isFirstResponder]) {
        
        NSString *result = [self convertEthAmountToFiat];
        
        if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
            exchangeView.bottomLeftField.text = result;
        } else {
            exchangeView.bottomRightField.text = result;
        }
        
    } else if ([exchangeView.bchField isFirstResponder]) {
        
        NSString *result = [self convertBchAmountToFiat];
        
        if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
            exchangeView.bottomLeftField.text = result;
        } else {
            exchangeView.bottomRightField.text = result;
        }
        
    } else if ([exchangeView.bottomLeftField isFirstResponder] || [exchangeView.bottomRightField isFirstResponder]) {
        
        NSString *ethString = [self.amount stringValue];
        NSString *btcString = [NSNumberFormatter satoshiToBTC:[self.amount longLongValue]];
        NSString *bchString = [NSNumberFormatter satoshiToBTC:[self.amount longLongValue]];
        
        if ([exchangeView.bottomLeftField isFirstResponder]) {
            if (exchangeView.topLeftField == exchangeView.ethField) {
                exchangeView.ethField.text = ethString;
            } else if (exchangeView.topLeftField == exchangeView.btcField) {
                exchangeView.btcField.text = btcString;
            } else if (exchangeView.topLeftField == exchangeView.bchField) {
                exchangeView.bchField.text = bchString;
            }
        } else if ([exchangeView.bottomRightField isFirstResponder]) {
            if (exchangeView.topRightField == exchangeView.ethField) {
                exchangeView.ethField.text = ethString;
            } else if (exchangeView.topRightField == exchangeView.btcField) {
                exchangeView.btcField.text = btcString;
            } else if (exchangeView.topRightField == exchangeView.bchField) {
                exchangeView.bchField.text = bchString;
            }
        }
    }
}

#pragma mark - View actions

- (void)clearAmount
{
    self.amount = 0;
}

- (void)clearAvailableBalance
{
    self.availableBalance = 0;
    
    self.exchangeView.errorTextView.hidden = YES;
    [self.exchangeView disablePaymentButtons];
}

- (void)clearFieldOfSymbol:(NSString *)symbol
{
    if ([symbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        self.exchangeView.btcField = nil;
    } else if ([symbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        self.exchangeView.ethField = nil;
    } else if ([symbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        self.exchangeView.bchField = nil;
    }
}

- (void)selectFromEther
{
    self.oldFromSymbol = self.fromSymbol;
    
    self.fromSymbol = CURRENCY_SYMBOL_ETH;
    self.exchangeView.ethField = self.exchangeView.topLeftField;
    self.exchangeView.fromToView.fromLabel.text = [self etherLabelText];
    self.exchangeView.leftLabel.text = CURRENCY_SYMBOL_ETH;
    self.fromAddress = [WalletManager.sharedInstance.wallet getEtherAddress];
    
    [self clearAvailableBalance];
    
    [self didChangeFrom];
}

- (void)selectFromBitcoin
{
    self.oldFromSymbol = self.fromSymbol;
    
    self.fromSymbol = CURRENCY_SYMBOL_BTC;
    self.exchangeView.btcField = self.exchangeView.topLeftField;
    self.exchangeView.fromToView.fromLabel.text = [self bitcoinLabelText];
    self.exchangeView.leftLabel.text = CURRENCY_SYMBOL_BTC;
    self.fromAddress = [WalletManager.sharedInstance.wallet getReceiveAddressForAccount:self.btcAccount assetType:LegacyAssetTypeBitcoin];
    
    [self clearAvailableBalance];
    
    [self didChangeFrom];
}

- (void)selectFromBitcoinCash
{
    self.oldFromSymbol = self.fromSymbol;
    
    self.fromSymbol = CURRENCY_SYMBOL_BCH;
    self.exchangeView.bchField = self.exchangeView.topLeftField;
    self.exchangeView.fromToView.fromLabel.text = [self bitcoinCashLabelText];
    self.exchangeView.leftLabel.text = CURRENCY_SYMBOL_BCH;
    self.fromAddress = [WalletManager.sharedInstance.wallet getReceiveAddressForAccount:self.bchAccount assetType:LegacyAssetTypeBitcoin];
    
    [self clearAvailableBalance];
    
    [self didChangeFrom];
}

- (void)selectToBitcoinCash
{
    self.oldToSymbol = self.toSymbol;
    
    self.toSymbol = CURRENCY_SYMBOL_BCH;
    self.exchangeView.bchField = self.exchangeView.topRightField;
    self.exchangeView.fromToView.toLabel.text = [self bitcoinCashLabelText];
    self.exchangeView.rightLabel.text = CURRENCY_SYMBOL_BCH;
    self.toAddress = [WalletManager.sharedInstance.wallet getReceiveAddressForAccount:self.bchAccount assetType:LegacyAssetTypeBitcoinCash];
    
    [self didChangeTo];
}

- (void)selectToEther
{
    self.oldToSymbol = self.toSymbol;
    
    self.toSymbol = CURRENCY_SYMBOL_ETH;
    self.exchangeView.ethField = self.exchangeView.topRightField;
    self.exchangeView.fromToView.toLabel.text = [self etherLabelText];
    self.exchangeView.rightLabel.text = CURRENCY_SYMBOL_ETH;
    self.toAddress = [WalletManager.sharedInstance.wallet getEtherAddress];
    
    [self didChangeTo];
}

- (void)selectToBitcoin
{
    self.oldToSymbol = self.toSymbol;
    
    self.toSymbol = CURRENCY_SYMBOL_BTC;
    self.exchangeView.btcField = self.exchangeView.topRightField;
    self.exchangeView.fromToView.toLabel.text = [self bitcoinLabelText];
    self.exchangeView.rightLabel.text = CURRENCY_SYMBOL_BTC;
    self.toAddress = [WalletManager.sharedInstance.wallet getReceiveAddressForAccount:self.btcAccount assetType:LegacyAssetTypeBitcoin];
    
    [self didChangeTo];
}

- (void)switchToSymbol
{
    if ([self.oldFromSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        [self selectToBitcoin];
    } else if ([self.oldFromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        [self selectToEther];
    } else if ([self.oldFromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        [self selectToBitcoinCash];
    }
    [self getRate];
}

- (void)switchFromSymbol
{
    if ([self.oldToSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        [self selectFromBitcoin];
    } else if ([self.oldToSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        [self selectFromEther];
    } else if ([self.oldToSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        [self selectFromBitcoinCash];
    }
    [self getRate];
}

- (void)autoFillFromAmount:(id)amount
{
    [self.exchangeView clearRightFields];
    
    NSString *amountString = [self amountString:amount];
    self.exchangeView.topLeftField.text = amountString;
    [self saveAmount:amountString fromField:self.exchangeView.topLeftField];
    
    NSString *fiatResult;
    if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        fiatResult = [self convertEthAmountToFiat];
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        fiatResult = [self convertBtcAmountToFiat];
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        fiatResult = [self convertBchAmountToFiat];
    }
    self.exchangeView.bottomLeftField.text = fiatResult;
    
    [self updateAvailableBalance];
    
    [self.exchangeView hideKeyboard];
    
    [self.exchangeView disablePaymentButtons];
    
    [self performSelector:@selector(getApproximateQuote) withObject:nil afterDelay:0.5];
}

#pragma mark - Wallet actions

- (void)getRate
{
    [self.exchangeView disableAssetToggleButton];
    [self.exchangeView startSpinner];
    
    [WalletManager.sharedInstance.wallet getRate:[self coinPair]];
}

- (void)getApproximateQuote
{
    if (![self hasEnoughFunds:self.fromSymbol] || ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH] && [WalletManager.sharedInstance.wallet isWaitingOnEtherTransaction])) {
        DLog(@"Not enough funds or waiting on ether transaction - will not get approximate quote");
        return;
    }
    
    [self cancelCurrentDataTask];
    
    ExchangeCreateView *exchangeView = self.exchangeView;
    
    BOOL usingFromField = exchangeView.lastChangedField != exchangeView.topRightField && exchangeView.lastChangedField != exchangeView.bottomRightField;
    
    NSString *amount;
    if ([self hasAmountGreaterThanZero:self.amount]) {
        
        [exchangeView disableAssetToggleButton];
        [exchangeView startSpinner];
        
        amount = [self amountString:self.amount];
        
        self.currentDataTask = [WalletManager.sharedInstance.wallet getApproximateQuote:[self coinPair]
                                                                         usingFromField:usingFromField
                                                                                 amount:amount
                                                                             completion:^(NSDictionary *result, NSURLResponse *response, NSError *error) {
                                                                                 DLog(@"approximate quote result: %@", result);
                                                                                 
                                                                                 [exchangeView enableAssetToggleButton];
                                                                                 [exchangeView stopSpinner];
                                                                                 
                                                                                 NSDictionary *resultSuccess = [result objectForKey:DICTIONARY_KEY_SUCCESS];
                                                                                 if (resultSuccess) {
                                                                                     [self didGetApproximateQuote:resultSuccess];
                                                                                 } else {
                                                                                     DLog(@"Error getting approximate quote:%@", result);
                                                                                     if ([[result objectForKey:DICTIONARY_KEY_ERROR] containsString:ERROR_MAXIMUM]) {
                                                                                         [exchangeView showErrorWithText:BC_STRING_ABOVE_MAXIMUM_LIMIT];
                                                                                     } else if ([[result objectForKey:DICTIONARY_KEY_ERROR] containsString:ERROR_MINIMUM]) {
                                                                                         [exchangeView showErrorWithText:BC_STRING_BELOW_MINIMUM_LIMIT];
                                                                                     } else {
                                                                                         [exchangeView showErrorWithText:BC_STRING_FAILED_TO_LOAD_EXCHANGE_DATA];
                                                                                     }
                                                                                 }
                                                                             }];
    }
}

- (void)buildTrade
{
    int fromAccount;
    if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        fromAccount = self.btcAccount;
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        fromAccount = self.ethAccount;
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        fromAccount = self.bchAccount;
    } else {
        DLog(@"buildTrade: unsupported asset type");
        return;
    }
    
    int toAccount;
    if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        toAccount = self.btcAccount;
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        toAccount = self.ethAccount;
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        toAccount = self.bchAccount;
    } else {
        DLog(@"buildTrade: unsupported asset type");
        return;
    }
    
    [WalletManager.sharedInstance.wallet buildExchangeTradeFromAccount:fromAccount toAccount:toAccount coinPair:[self coinPair] amount:[self amountString:self.amount] fee:[self feeString:self.fee]];
}

#pragma mark - Helpers

- (void)getApproximateQuoteAfterTimer
{
    [self.exchangeView disablePaymentButtons];
    [self getApproximateQuote];
    self.quoteTimer = nil;
}

- (void)cancelCurrentDataTask
{
    if (self.currentDataTask) {
        [self.currentDataTask cancel];
        self.currentDataTask = nil;
        [self.exchangeView stopSpinner];
    }
}

- (BOOL)hasAmountGreaterThanZero:(id)amount
{
    if ([amount isMemberOfClass:[NSDecimalNumber class]]) {
        return [amount compare:@0] == NSOrderedDescending;
    } else if ([amount respondsToSelector:@selector(longLongValue)]) {
        return [amount longLongValue] > 0;
    } else if (!amount) {
        DLog(@"Nil amount saved");
        return NO;
    } else {
        DLog(@"Error: unknown class for amount: %@", [self.amount class]);
        return NO;
    }
}

- (NSString *)amountString:(id)amount
{
    NSString *amountString;
    if ([self hasAmountGreaterThanZero:amount]) {
        if ([amount isMemberOfClass:[NSDecimalNumber class]]) {
            amountString = [amount stringValue];
        } else if ([amount respondsToSelector:@selector(longLongValue)]) {
            amountString = [NSNumberFormatter satoshiToBTC:[amount longLongValue]];
        } else {
            DLog(@"Error: unknown class for amount: %@", [amount class]);
        }
    }
    
    return amountString;
}

- (NSString *)feeString:(id)fee
{
    if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        return [self amountString:self.fee];;
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        return [NSString stringWithFormat:@"%lld", [self.fee longLongValue]];
    } else if ([self.fromSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        return [NSString stringWithFormat:@"%lld", [self.fee longLongValue]];
    }
    DLog(@"FeeString: unsupported asset type!");
    return nil;
}

- (BCSecureTextField *)inputTextFieldWithFrame:(CGRect)frame
{
    BCSecureTextField *textField = [[BCSecureTextField alloc] initWithFrame:frame];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    textField.textColor = UIColor.gray5;
    textField.delegate = self;
    return textField;
}

- (NSString *)coinPair
{
    return [NSString stringWithFormat:@"%@_%@", self.fromSymbol, self.toSymbol];
}

- (NSString *)bitcoinLabelText
{
    if ([WalletManager.sharedInstance.wallet getActiveAccountsCount:LegacyAssetTypeBitcoin] > 1) {
        return [WalletManager.sharedInstance.wallet getLabelForAccount:self.btcAccount assetType:LegacyAssetTypeBitcoin];
    }
    return [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin];
}

- (NSString *)bitcoinCashLabelText
{
    if ([WalletManager.sharedInstance.wallet getActiveAccountsCount:LegacyAssetTypeBitcoinCash] > 1) {
        return [WalletManager.sharedInstance.wallet getLabelForAccount:self.bchAccount assetType:LegacyAssetTypeBitcoinCash];
    }
    return [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash];
}

- (NSString *)etherLabelText
{
    if ([WalletManager.sharedInstance.wallet getActiveAccountsCount:LegacyAssetTypeBitcoin] > 1) {
        return [WalletManager.sharedInstance.wallet getLabelForAccount:0 assetType:LegacyAssetTypeEther];
    }
    return [AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum];
}

- (void)didChangeFrom
{
    [self clearAmount];
    [self.exchangeView clearFields];
    
    if ([self.fromSymbol isEqualToString:self.toSymbol]) {
        [self switchToSymbol];
    }
}

- (void)didChangeTo
{
    [self clearAmount];
    [self.exchangeView clearFields];
    
    if ([self.fromSymbol isEqualToString:self.toSymbol]) {
        [self switchFromSymbol];
    }
}

- (BOOL)hasEnoughFunds:(NSString *)currencySymbol
{
    if ([currencySymbol isEqualToString:CURRENCY_SYMBOL_BTC] || [currencySymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        return !([self.availableBalance longLongValue] < [self.minimum longLongValue] && [self.minimum longLongValue] > 0);
    } else if ([currencySymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        return !([self.availableBalance compare:self.minimum] == NSOrderedAscending && [self.minimum compare:@0] == NSOrderedDescending);
    }
    
    return NO;
}

#pragma mark - Address Selection Delegate

- (LegacyAssetType)getAssetType
{
    // Exchange controller uses all assets
    return -1;
}

- (void)didSelectFromAccount:(int)account assetType:(LegacyAssetType)asset
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearFieldOfSymbol:self.fromSymbol];
    
    switch (asset) {
        case LegacyAssetTypeBitcoin:
            self.btcAccount = account;
            [self selectFromBitcoin];
            break;
        case LegacyAssetTypeBitcoinCash:
            self.bchAccount = account;
            [self selectFromBitcoinCash];
            break;
        case LegacyAssetTypeEther:
            self.ethAccount = account;
            [self selectFromEther];
            break;
    }
    
    [self getRate];
}

- (void)didSelectToAccount:(int)account assetType:(LegacyAssetType)asset
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearFieldOfSymbol:self.toSymbol];
    
    switch (asset) {
        case LegacyAssetTypeBitcoin:
            self.btcAccount = account;
            [self selectToBitcoin];
            break;
        case LegacyAssetTypeBitcoinCash:
            self.bchAccount = account;
            [self selectToBitcoinCash];
            break;
        case LegacyAssetTypeEther:
            self.ethAccount = account;
            [self selectToEther];
            break;
    }
    
    [self getRate];
}

#pragma mark - Continue Button Input Accessory View Delegate

- (void)continueButtonClicked
{
    [self.exchangeView hideKeyboard];
    
    [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:[LocalizationConstantsObjcBridge gettingQuote]];
    
    [self performSelector:@selector(buildTrade) withObject:nil afterDelay:DELAY_KEYBOARD_DISMISSAL];
}

- (void)closeButtonClicked
{
    [self.exchangeView hideKeyboard];
}

#pragma mark - Exchange Create View Delegate

- (void)assetToggleButtonClicked
{
    [self clearFieldOfSymbol:self.fromSymbol];
    
    NSString *toSymbol = self.toSymbol;
    if ([toSymbol isEqualToString:CURRENCY_SYMBOL_BTC]) {
        [self selectFromBitcoin];
    } else if ([toSymbol isEqualToString:CURRENCY_SYMBOL_ETH]) {
        [self selectFromEther];
    } else if ([toSymbol isEqualToString:CURRENCY_SYMBOL_BCH]) {
        [self selectFromBitcoinCash];
    }
}

- (void)fromButtonClicked
{
    [self selectAccountClicked:SelectModeExchangeAccountFrom];
}

- (void)toButtonClicked
{
    [self selectAccountClicked:SelectModeExchangeAccountTo];
}

- (void)selectAccountClicked:(SelectMode)selectMode
{
    BCAddressSelectionView *selectorView = [[BCAddressSelectionView alloc] initWithWallet:WalletManager.sharedInstance.wallet selectMode:selectMode delegate:self];
    selectorView.frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:NO assetSelector:NO];
    
    UIViewController *viewController = [UIViewController new];
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    [viewController.view addSubview:selectorView];
    
    [self.navigationController pushViewController:viewController animated:YES];
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    navigationController.headerTitle = selectMode == SelectModeExchangeAccountTo ? BC_STRING_TO : BC_STRING_FROM;
}

- (void)useMinButtonClicked
{
    [self autoFillFromAmount:self.minimum];
}

- (void)useMaxButtonClicked
{
    id maximum = [self.maximum compare:self.maximumHardLimit] == NSOrderedAscending ? self.maximum : self.maximumHardLimit;
    
    id maxAmount;
    if ([self hasEnoughFunds:self.fromSymbol] && [self.availableBalance compare:@0] != NSOrderedSame && [self.availableBalance compare:maximum] == NSOrderedAscending) {
        maxAmount = self.availableBalance;
    } else {
        maxAmount = maximum;
    }
    
    [self autoFillFromAmount:maxAmount];
}

@end
