//
//  TabControllerManager.h
//  Blockchain
//
//  Created by kevinwu on 8/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabViewController.h"
#import "Assets.h"
#import "TransactionsBitcoinViewController.h"
#import "SendBitcoinViewController.h"
#import "ReceiveBitcoinViewController.h"
#import "SendEtherViewController.h"
#import "TransactionsBitcoinCashViewController.h"

@class TransactionsEthereumViewController;

@interface TabControllerManager : UIViewController <AssetDelegate>

@property (strong, nonatomic) TabViewController *tabViewController;

@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic) NSDecimalNumber *latestEthExchangeRate;

@property (strong, nonatomic) TransactionsBitcoinViewController *transactionsBitcoinViewController;
@property (strong, nonatomic) ReceiveBitcoinViewController *receiveBitcoinViewController;
@property (strong, nonatomic) ReceiveBitcoinViewController *receiveBitcoinCashViewController;
@property (strong, nonatomic) SendBitcoinViewController *sendBitcoinViewController;
@property (strong, nonatomic) SendBitcoinViewController *sendBitcoinCashViewController;

@property (strong, nonatomic) SendEtherViewController *sendEtherViewController;

@property (strong, nonatomic) TransactionsEthereumViewController *transactionsEtherViewController;

@property (strong, nonatomic) TransactionsBitcoinCashViewController *transactionsBitcoinCashViewController;

- (void)reload;
- (void)reloadAfterMultiAddressResponse;
- (void)reloadMessageViews;
- (void)didSetLatestBlock:(LatestBlock *)block;
- (void)didGetMessagesOnFirstLoad;

- (void)logout;
- (void)forgetWallet;

- (void)didFetchEthExchangeRate:(NSNumber *)rate;

// Navigation
- (void)dashBoardClicked:(UITabBarItem *)sender;
- (void)receiveCoinClicked:(UITabBarItem *)sender;
- (void)transactionsClicked:(UITabBarItem *)sender;
- (void)sendCoinsClicked:(UITabBarItem *)sender;
- (void)swapTapped:(nullable UITabBarItem *)sender;
- (void)qrCodeButtonClicked;
- (void)transitionToIndex:(NSInteger)index;

- (void)showReceiveBitcoinCash;
- (void)showTransactionsBitcoin;
- (void)showTransactionsEther;
- (void)showTransactionsBitcoinCash;
- (void)showTransactionsStellar;
- (void)showTransactionsPax;

// Send Bitcoin View Controller
- (BOOL)isSending;
- (void)showSendCoinsAnimated:(BOOL)animated;
- (void)setupTransferAllFunds;
- (void)hideSendKeyboard;
- (void)reloadSendController;
- (void)clearSendToAddressAndAmountFields;
- (BOOL)isSendViewControllerTransferringAll;
- (void)setupBitcoinPaymentFromURLHandlerWithAmountString:(NSString *)amountString address:(NSString *)address;
- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address;
- (void)sendFromWatchOnlyAddress;
- (void)didGetSurgeStatus:(BOOL)surgeStatus;
- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed;
- (void)showSummaryForTransferAll;
- (void)sendDuringTransferAll:(NSString *)secondPassword;
- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *_Nullable)secondPassword;
- (void)receivedTransactionMessage;
- (DestinationAddressSource)getSendAddressSource;
- (void)setupSendToAddress:(NSString *)address;

// Receive View Controller
- (void)didGetEtherAddressWithSecondPassword;
- (void)clearReceiveAmounts;
- (void)didSetDefaultAccount;
- (void)paymentReceived:(uint64_t)amount showBackupReminder:(BOOL)showBackupReminder;

// Transactions View Controller
- (void)updateTransactionsViewControllerData:(MultiAddressResponse *)data;
- (void)filterTransactionsByAccount:(int)accountIndex filterLabel:(NSString *)filterLabel assetType:(LegacyAssetType)assetType;
- (void)filterTransactionsByImportedAddresses;
- (void)selectPayment:(NSString *)payment;
- (void)showTransactionDetailForHash:(NSString *)hash;
- (void)setTransactionsViewControllerMessageIdentifier:(NSString *)identifier;

- (void)removeTransactionsFilter;
- (void)reloadSymbols;
- (void)didChangeLocalCurrency;

- (void)hideSendAndReceiveKeyboards;

- (void)showTransactionsAnimated:(BOOL)animated;

- (void)updateBadgeNumber:(NSInteger)number forSelectedIndex:(int)index;

- (void)showGetAssetsAlert;
@end
