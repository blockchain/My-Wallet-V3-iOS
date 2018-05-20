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
#import "DashboardViewController.h"
#import "SendEtherViewController.h"
#import "TransactionsEtherViewController.h"
#import "ReceiveEtherViewController.h"
#import "ExchangeOverviewViewController.h"
#import "TransactionsBitcoinCashViewController.h"

@protocol TabControllerDelegate
- (void)toggleSideMenu;
@end
@interface TabControllerManager : NSObject <AssetDelegate>
@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic) NSDecimalNumber *latestEthExchangeRate;

@property (weak, nonatomic) id <TabControllerDelegate> delegate;

@property (strong, nonatomic) TabViewcontroller *tabViewController;

@property (strong, nonatomic) DashboardViewController *dashboardViewController;

@property (strong, nonatomic) TransactionsBitcoinViewController *transactionsBitcoinViewController;
@property (strong, nonatomic) ReceiveBitcoinViewController *receiveBitcoinViewController;
@property (strong, nonatomic) ReceiveBitcoinViewController *receiveBitcoinCashViewController;
@property (strong, nonatomic) SendBitcoinViewController *sendBitcoinViewController;
@property (strong, nonatomic) SendBitcoinViewController *sendBitcoinCashViewController;

@property (strong, nonatomic) SendEtherViewController *sendEtherViewController;
@property (strong, nonatomic) TransactionsEtherViewController *transactionsEtherViewController;
@property (strong, nonatomic) ReceiveEtherViewController *receiveEtherViewController;

@property (strong, nonatomic) TransactionsBitcoinCashViewController *transactionsBitcoinCashViewController;

@property (strong, nonatomic) ExchangeOverviewViewController *exchangeOverviewViewController;

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
- (void)qrCodeButtonClicked;
- (void)transitionToIndex:(NSInteger)index;

- (void)showReceiveBitcoinCash;
- (void)showTransactionsBitcoin;
- (void)showTransactionsEther;
- (void)showTransactionsBitcoinCash;

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
- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *)secondPassword;
- (void)updateLoadedAllTransactions:(NSNumber *)loadedAll;
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
- (NSInteger)getFilterIndex;
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

- (void)exchangeClicked;
- (void)didCreateEthAccountForExchange;
- (void)didGetExchangeTrades:(NSArray *)trades;
- (void)didGetExchangeRate:(NSDictionary *)result;
- (void)didGetAvailableBtcBalance:(NSDictionary *)result;
- (void)didGetAvailableEthBalance:(NSDictionary *)result;
- (void)didBuildExchangeTrade:(NSDictionary *)tradeInfo;
- (void)didShiftPayment:(NSDictionary *)info;
- (void)showGetAssetsAlert;
@end
