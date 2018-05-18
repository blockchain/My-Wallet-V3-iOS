//
//  TransactionDetailViewModel.h
//  Blockchain
//
//  Created by kevinwu on 9/7/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Assets.h"
@class Transaction, EtherTransaction;

@interface TransactionDetailViewModel : NSObject
@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic) NSString *fromString;
@property (nonatomic) NSString *fromAddress;
@property (nonatomic) BOOL hasFromLabel;
@property (nonatomic) BOOL hasToLabel;
@property (nonatomic) NSArray *to;
@property (nonatomic) NSString *toString;
@property (nonatomic) uint64_t amountInSatoshi;
@property (nonatomic) NSString *txType;
@property (nonatomic) NSString *txDescription;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *status;
@property (nonatomic) NSString *myHash;
@property (nonatomic) NSString *note;
@property (nonatomic) uint64_t time;
@property (nonatomic) NSString *detailButtonTitle;
@property (nonatomic) NSString *detailButtonLink;
@property (nonatomic) NSMutableDictionary *fiatAmountsAtTime;
@property (nonatomic) BOOL doubleSpend;
@property (nonatomic) BOOL replaceByFee;
@property (nonatomic) NSString *confirmations;
@property (nonatomic) BOOL confirmed;
@property (nonatomic) BOOL hideNote;
@property (nonatomic) NSDecimalNumber *ethExchangeRate;
@property (nonatomic) NSDecimalNumber *decimalAmount;

- (id)initWithTransaction:(Transaction *)transaction;
- (id)initWithEtherTransaction:(EtherTransaction *)etherTransaction exchangeRate:(NSDecimalNumber *)exchangeRate defaultAddress:(NSString *)defaultAddress;
- (id)initWithBitcoinCashTransaction:(Transaction *)transaction;
- (NSString *)getAmountString;
- (NSString *)getFeeString;
@end
