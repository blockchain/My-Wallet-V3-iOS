//
//  BCConfirmPaymentViewModel.m
//  Blockchain
//
//  Created by kevinwu on 8/29/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCConfirmPaymentViewModel.h"
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

@interface BCConfirmPaymentViewModel ()
@end
@implementation BCConfirmPaymentViewModel

- (id)initWithFrom:(NSString *)from
                To:(NSString *)to
            amount:(uint64_t)amount
               fee:(uint64_t)fee
             total:(uint64_t)total
             surge:(BOOL)surgePresent
{
    self = [super init];
    
    if (self) {
        self.from = from;
        self.to = to;
        self.surgeIsOccurring = surgePresent;
        self.buttonTitle = BC_STRING_SEND;
        self.fiatTotalAmountText = [NSNumberFormatter formatMoney:total localCurrency:YES];
        self.totalAmountText = [NSNumberFormatter formatBTC:total];
        self.cryptoWithFiatAmountText = [self formatAmountInBTCAndFiat:amount];
        self.amountWithFiatFeeText = [self formatAmountInBTCAndFiat:fee];
        self.showDescription = YES;
    }
    return self;
}

- (id)initWithTo:(NSString *)to
       ethAmount:(NSString *)ethAmount
          ethFee:(NSString *)ethFee
        ethTotal:(NSString *)ethTotal
      fiatAmount:(NSString *)fiatAmount
         fiatFee:(NSString *)fiatFee
       fiatTotal:(NSString *)fiatTotal
{
    if (self == [super init]) {
        self.from = [LocalizationConstantsObjcBridge myEtherWallet];
        self.to = to;
        self.fiatTotalAmountText = fiatTotal;
        self.totalAmountText = ethTotal;
        self.cryptoWithFiatAmountText = [NSString stringWithFormat:@"%@ (%@)", ethAmount, fiatAmount];
        self.amountWithFiatFeeText = [NSString stringWithFormat:@"%@ (%@)", ethFee, fiatFee];
        self.showDescription = YES;
    }
    return self;
}

- (id)initWithFrom:(NSString *)from
                To:(NSString *)to
            bchAmount:(uint64_t)amount
               fee:(uint64_t)fee
             total:(uint64_t)total
             surge:(BOOL)surgePresent
{
    self = [super init];
    
    if (self) {
        self.from = from;
        self.to = to;
        self.surgeIsOccurring = surgePresent;
        
        self.fiatTotalAmountText = [NSNumberFormatter formatBchWithSymbol:total localCurrency:YES];
        self.totalAmountText = [NSNumberFormatter formatBCH:total];
        self.cryptoWithFiatAmountText = [self formatAmountInBCHAndFiat:amount];
        self.amountWithFiatFeeText = [self formatAmountInBCHAndFiat:fee];
        self.showDescription = YES;
        
        if ([WalletManager.sharedInstance.wallet isValidAddress:self.to assetType:LegacyAssetTypeBitcoin]) {
            CGFloat fontSize = FONT_SIZE_EXTRA_SMALL;
            NSMutableAttributedString *warning = [[NSMutableAttributedString alloc] initWithString:BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_ONE];
            [warning addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:fontSize] range:NSMakeRange(0, [warning length])];
            
            NSMutableAttributedString *warningSuffix = [[NSMutableAttributedString alloc] initWithString:BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_TWO];
            
            [warningSuffix addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:fontSize] range:NSMakeRange(0, [warningSuffix length])];
            
            [warning appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [warning appendAttributedString:warningSuffix];
            
            self.warningText = warning;
        }
    }
    return self;
}

#pragma mark - Text Helpers

- (NSString *)formatAmountInBTCAndFiat:(uint64_t)amount
{
    return [NSString stringWithFormat:@"%@ (%@)", [NSNumberFormatter formatMoney:amount localCurrency:NO], [NSNumberFormatter formatMoney:amount localCurrency:YES]];
}

- (NSString *)formatAmountInBCHAndFiat:(uint64_t)amount
{
    return [NSString stringWithFormat:@"%@ (%@)", [NSNumberFormatter formatBchWithSymbol:amount localCurrency:NO], [NSNumberFormatter formatBchWithSymbol:amount localCurrency:YES]];
}

@end
