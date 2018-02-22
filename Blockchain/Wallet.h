/*
 * 
 * Copyright (c) 2012, Ben Reeves. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

#import "MultiAddressResponse.h"
#import "SRWebSocket.h"
#import "FeeTypes.h"
#import "Assets.h"

@interface transactionProgressListeners : NSObject
@property(nonatomic, copy) void (^on_start)();
@property(nonatomic, copy) void (^on_begin_signing)();
@property(nonatomic, copy) void (^on_sign_progress)(int input);
@property(nonatomic, copy) void (^on_finish_signing)();
@property(nonatomic, copy) void (^on_success)(NSString*secondPassword, NSString*transactionHash);
@property(nonatomic, copy) void (^on_error)(NSString*error, NSString*secondPassword);
@end

@interface Key : NSObject {
    int tag;
}
@property(nonatomic, strong) NSString *addr;
@property(nonatomic, strong) NSString *priv;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, assign) int tag;
@end

@class Wallet, Transaction, JSValue, JSContext, Contact, ContactTransaction;

@protocol ExchangeAccountDelegate
- (void)watchPendingTrades:(BOOL)shouldSync;
- (void)showCompletedTrade:(NSString *)txHash;
@end

@protocol WalletDelegate <NSObject>
@optional
- (void)didSetLatestBlock:(LatestBlock*)block;
- (void)didGetMultiAddressResponse:(MultiAddressResponse*)response;
- (void)didFilterTransactions:(NSArray *)transactions;
- (void)walletDidDecrypt;
- (void)walletFailedToDecrypt;
- (void)walletDidLoad;
- (void)walletFailedToLoad;
- (void)walletDidFinishLoad;
- (void)didBackupWallet;
- (void)didFailBackupWallet;
- (void)walletJSReady;
- (void)didGenerateNewAddress;
- (void)didParsePairingCode:(NSDictionary *)dict;
- (void)errorParsingPairingCode:(NSString *)message;
- (void)didMakePairingCode:(NSString *)code;
- (void)errorMakingPairingCode:(NSString *)message;
- (void)didCreateNewAccount:(NSString *)guid sharedKey:(NSString *)sharedKey password:(NSString *)password;
- (void)errorCreatingNewAccount:(NSString *)message;
- (void)didFailPutPin:(NSString *)value;
- (void)didPutPinSuccess:(NSDictionary *)dictionary;
- (void)didFailGetPinTimeout;
- (void)didFailGetPinNoResponse;
- (void)didFailGetPinInvalidResponse;
- (void)didGetPinResponse:(NSDictionary *)dictionary;
- (void)didImportKey:(NSString *)address;
- (void)didImportIncorrectPrivateKey:(NSString *)address;
- (void)didImportPrivateKeyToLegacyAddress;
- (void)didFailToImportPrivateKey:(NSString *)error;
- (void)didFailRecovery;
- (void)didRecoverWallet;
- (void)didFailGetHistory:(NSString *)error;
- (void)resendTwoFactorSuccess;
- (void)resendTwoFactorError:(NSString *)error;
- (void)didFailToImportPrivateKeyForWatchOnlyAddress:(NSString *)error;
- (void)returnToAddressesScreen;
- (void)alertUserOfInvalidAccountName;
- (void)alertUserOfInvalidPrivateKey;
- (void)sendFromWatchOnlyAddress;
- (void)estimateTransactionSize:(uint64_t)size;
- (void)didCheckForOverSpending:(NSNumber *)amount fee:(NSNumber *)fee;
- (void)didGetMaxFee:(NSNumber *)fee amount:(NSNumber *)amount dust:(NSNumber *)dust willConfirm:(BOOL)willConfirm;
- (void)didUpdateTotalAvailable:(NSNumber *)sweepAmount finalFee:(NSNumber *)finalFee;
- (void)didGetFee:(NSNumber *)fee dust:(NSNumber *)dust txSize:(NSNumber *)txSize;
- (void)didChangeSatoshiPerByte:(NSNumber *)sweepAmount fee:(NSNumber *)fee dust:(NSNumber *)dust updateType:(FeeUpdateType)updateType;
- (void)enableSendPaymentButtons;
- (void)didGetSurgeStatus:(BOOL)surgeStatus;
- (void)updateSendBalance:(NSNumber *)balance fees:(NSDictionary *)fees;
- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed;
- (void)showSummaryForTransferAll;
- (void)sendDuringTransferAll:(NSString *)secondPassword;
- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *)secondPassword;
- (void)updateLoadedAllTransactions:(NSNumber *)loadedAll;
- (void)receivedTransactionMessage;
- (void)paymentReceivedOnPINScreen:(NSString *)amount;
- (void)didReceivePaymentNotice:(NSString *)notice;
- (void)didGetFiatAtTime:(NSNumber *)fiatAmount currencyCode:(NSString *)currencyCode assetType:(AssetType)assetType;
- (void)didErrorWhenGettingFiatAtTime:(NSString *)error;
- (void)didSetDefaultAccount;
- (void)didChangeLocalCurrency;
- (void)setupBackupTransferAll:(id)transferAllController;
- (void)didCreateInvitation:(NSDictionary *)invitation;
- (void)didReadInvitation:(NSDictionary *)invitation identifier:(NSString *)identifier;
- (void)didCompleteRelation;
- (void)didFailCompleteRelation;
- (void)didFailAcceptRelation:(NSString *)name;
- (void)didAcceptRelation:(NSString *)invitation name:(NSString *)name;
- (void)didFetchExtendedPublicKey;
- (void)didGetNewMessages:(NSArray *)newMessages;
- (void)didGetMessagesOnFirstLoad;
- (void)didSendPaymentRequest:(NSDictionary *)info amount:(uint64_t)amount name:(NSString *)name requestId:(NSString *)requestId;
- (void)didRequestPaymentRequest:(NSDictionary *)info name:(NSString *)name;
- (void)didSendPaymentRequestResponse;
- (void)didChangeContactName:(NSDictionary *)info;
- (void)didDeleteContact:(NSDictionary *)info;
- (void)didDeleteContactAfterStoringInfo:(NSDictionary *)info;
- (void)didRejectContactTransaction;
- (void)didCompleteTrade:(NSDictionary *)trade;
- (void)didPushTransaction;
- (void)showCompletedTrade:(NSString *)txHash;
- (void)didGetSwipeAddresses:(NSArray *)newSwipeAddresses;
- (void)didFetchEthHistory;
- (void)didUpdateEthPayment:(NSDictionary *)payment;
- (void)didFetchEthExchangeRate:(NSNumber *)rate;
- (void)didSendEther;
- (void)didErrorDuringEtherSend:(NSString *)error;
- (void)didGetEtherAddressWithSecondPassword;
- (void)didGetExchangeTrades:(NSArray *)trades;
- (void)didGetExchangeRate:(NSDictionary *)result;
- (void)didGetAvailableEthBalance:(NSDictionary *)result;
- (void)didGetAvailableBtcBalance:(NSDictionary *)result;
- (void)didBuildExchangeTrade:(NSDictionary *)tradeInfo;
- (void)didShiftPayment:(NSDictionary *)info;
- (void)showGetAssetsAlertForCurrencySymbol:(NSString *)currencySymbol;
- (void)didCreateEthAccountForExchange;
- (void)initializeWebView;
@end

@interface Wallet : NSObject <UIWebViewDelegate, SRWebSocketDelegate, ExchangeAccountDelegate> {
}

// Core Wallet Init Properties
@property (readonly, nonatomic) JSContext *context;

@property(nonatomic, strong) NSString *guid;
@property(nonatomic, strong) NSString *sharedKey;
@property(nonatomic, strong) NSString *password;

@property(nonatomic, strong) NSString *sessionToken;

@property(nonatomic, strong) id<WalletDelegate> delegate;

@property(nonatomic) uint64_t final_balance;
@property(nonatomic) uint64_t total_sent;
@property(nonatomic) uint64_t total_received;

@property(nonatomic, strong) NSMutableDictionary *transactionProgressListeners;

@property(nonatomic) NSDictionary *accountInfo;
@property(nonatomic) BOOL hasLoadedAccountInfo;

@property(nonatomic) NSString *lastScannedWatchOnlyAddress;
@property(nonatomic) NSString *lastImportedAddress;
@property(nonatomic) BOOL didReceiveMessageForLastTransaction;

// HD properties:
@property NSString *recoveryPhrase;
@property int emptyAccountIndex;
@property int recoveredAccountIndex;

@property BOOL didPairAutomatically;
@property BOOL isFilteringTransactions;
@property BOOL isFetchingTransactions;
@property BOOL isSyncing;
@property BOOL isNew;
@property NSString *twoFactorInput;
@property (nonatomic) NSDictionary *currencySymbols;

@property (nonatomic) SRWebSocket *webSocket;
@property (nonatomic) SRWebSocket *ethSocket;
@property (nonatomic) NSMutableArray *pendingEthSocketMessages;

@property (nonatomic) NSTimer *webSocketTimer;
@property (nonatomic) NSString *swipeAddressToSubscribe;

@property (nonatomic) int lastLabelledAddressesCount;

@property (nonatomic) NSDictionary<NSString *, Contact *> *contacts;
@property (nonatomic) NSMutableArray<ContactTransaction *> *pendingContactTransactions;
@property (nonatomic) NSMutableDictionary<NSString *, ContactTransaction *> *completedContactTransactions;
@property (nonatomic) NSMutableArray<ContactTransaction *> *rejectedContactTransactions;
@property (nonatomic) NSNumber *contactsActionCount;

@property (nonatomic) NSArray *etherTransactions;
@property (nonatomic) NSDecimalNumber *latestEthExchangeRate;

typedef enum {
    ContactActionRequiredNone,
    ContactActionRequiredSingleRequest,
    ContactActionRequiredSinglePayment,
    ContactActionRequiredMultiple,
} ContactActionRequired;
@property (nonatomic) ContactActionRequired contactsActionRequired;

- (id)init;

- (void)login;

- (void)loadWalletWithGuid:(NSString *)_guid sharedKey:(NSString *)_sharedKey password:(NSString *)_password;
- (void)loadBlankWallet;

- (void)resetSyncStatus;

- (NSDictionary *)addressBook;

- (void)setLabel:(NSString *)label forLegacyAddress:(NSString *)address;

- (void)loadWalletLogin;

- (void)toggleArchiveLegacyAddress:(NSString *)address;
- (void)toggleArchiveAccount:(int)account;
- (void)archiveTransferredAddresses:(NSArray *)transferredAddresses;

- (void)sendPaymentWithListener:(transactionProgressListeners*)listener secondPassword:(NSString *)secondPassword;
- (void)sendFromWatchOnlyAddress:(NSString *)watchOnlyAddress privateKey:(NSString *)privateKeyString;

- (NSString *)labelForLegacyAddress:(NSString *)address;
- (Boolean)isAddressArchived:(NSString *)address;

- (void)subscribeToSwipeAddress:(NSString *)address;

- (void)addToAddressBook:(NSString *)address label:(NSString *)label;

- (BOOL)isBitcoinAddress:(NSString *)string;
- (BOOL)isWatchOnlyLegacyAddress:(NSString*)address;

- (BOOL)addKey:(NSString *)privateKeyString;
- (BOOL)addKey:(NSString*)privateKeyString toWatchOnlyAddress:(NSString *)watchOnlyAddress;

// Fetch String Array Of Addresses
- (NSArray *)activeLegacyAddresses;
- (NSArray *)spendableActiveLegacyAddresses;
- (NSArray *)allLegacyAddresses;
- (NSArray *)archivedLegacyAddresses;

- (BOOL)isInitialized;
- (BOOL)hasEncryptedWalletData;

- (float)getStrengthForPassword:(NSString *)password;

- (BOOL)needsSecondPassword;
- (BOOL)validateSecondPassword:(NSString *)secondPassword;

- (void)getHistory;
- (void)getHistoryWithoutBusyView;
- (void)getHistoryIfNoTransactionMessage;
- (void)getWalletAndHistory;

- (uint64_t)getLegacyAddressBalance:(NSString *)address;
- (uint64_t)parseBitcoinValueFromTextField:(UITextField *)textField;
- (uint64_t)parseBitcoinValueFromString:(NSString *)inputString;
- (void)changeLocalCurrency:(NSString *)currencyCode;
- (void)changeBtcCurrency:(NSString *)btcCode;

- (void)parsePairingCode:(NSString *)code;
- (void)makePairingCode;
- (void)resendTwoFactorSMS;

- (NSString *)detectPrivateKeyFormat:(NSString *)privateKeyString;

- (void)newAccount:(NSString *)password email:(NSString *)email;

- (void)pinServerPutKeyOnPinServerServer:(NSString *)key value:(NSString *)value pin:(NSString *)pin;
- (void)apiGetPINValue:(NSString *)key pin:(NSString *)pin;

- (NSString *)encrypt:(NSString *)data password:(NSString *)password pbkdf2_iterations:(int)pbkdf2_iterations;
- (NSString *)decrypt:(NSString *)data password:(NSString *)password pbkdf2_iterations:(int)pbkdf2_iterations;

- (BOOL)isAddressAvailable:(NSString *)address;
- (BOOL)isAccountAvailable:(int)account;
- (int)getIndexOfActiveAccount:(int)account;

- (void)fetchMoreTransactions;
- (void)reloadFilter;

- (int)getAllTransactionsCount;

// HD Wallet
- (void)upgradeToV3Wallet;
- (Boolean)hasAccount;
- (Boolean)didUpgradeToHd;
- (void)getRecoveryPhrase:(NSString *)secondPassword;
- (BOOL)isRecoveryPhraseVerified;
- (void)markRecoveryPhraseVerified;
- (int)getFilteredOrDefaultAccountIndex;
- (int)getDefaultAccountIndex;
- (void)setDefaultAccount:(int)index;
- (int)getActiveAccountsCount;
- (int)getAllAccountsCount;
- (BOOL)hasLegacyAddresses;
- (Boolean)isAccountArchived:(int)account;
- (BOOL)isAccountNameValid:(NSString *)name;

- (uint64_t)getTotalActiveBalance;
- (uint64_t)getTotalBalanceForActiveLegacyAddresses;
- (uint64_t)getTotalBalanceForSpendableActiveLegacyAddresses;
- (uint64_t)getBalanceForAccount:(int)account;

- (NSString *)getLabelForAccount:(int)account;
- (void)setLabelForAccount:(int)account label:(NSString *)label;

- (void)createAccountWithLabel:(NSString *)label;
- (void)generateNewKey;

- (NSString *)getReceiveAddressOfDefaultAccount;
- (NSString *)getReceiveAddressForAccount:(int)account;

- (NSString *)getXpubForAccount:(int)accountIndex;

- (void)setPbkdf2Iterations:(int)iterations;

- (void)loading_start_get_history;
- (void)loading_start_upgrade_to_hd;
- (void)loading_start_recover_wallet;
- (void)loading_stop;
- (void)upgrade_success;

- (BOOL)checkIfWalletHasAddress:(NSString *)address;

- (NSDictionary *)filteredWalletJSON;

- (int)getDefaultAccountLabelledAddressesCount;

- (BOOL)isBuyEnabled;
- (void)setupBuySellWebview;
- (NSString *)buySellWebviewRootURLString;

// Settings
- (void)getAccountInfo;
- (NSString *)getEmail;
- (NSString *)getSMSNumber;
- (BOOL)getSMSVerifiedStatus;
- (NSDictionary *)getFiatCurrencies;
- (NSDictionary *)getBtcCurrencies;
- (int)getTwoStepType;
- (BOOL)getEmailVerifiedStatus;

- (void)changeEmail:(NSString *)newEmail;
- (void)resendVerificationEmail:(NSString *)email;
- (void)getAllCurrencySymbols;
- (void)changeMobileNumber:(NSString *)newMobileNumber;
- (void)verifyMobileNumber:(NSString *)code;
- (void)enableTwoStepVerificationForSMS;
- (void)disableTwoStepVerification;
- (void)changePassword:(NSString *)changedPassword;
- (BOOL)isCorrectPassword:(NSString *)inputedPassword;
- (void)enableEmailNotifications;
- (void)disableEmailNotifications;
- (void)enableSMSNotifications;
- (void)disableSMSNotifications;
- (BOOL)emailNotificationsEnabled;
- (BOOL)SMSNotificationsEnabled;

// Security Center
- (BOOL)hasVerifiedEmail;
- (BOOL)hasVerifiedMobileNumber;
- (BOOL)hasEnabledTwoStep;
- (int)securityCenterScore;
- (int)securityCenterCompletedItemsCount;

// Payment Spender
- (void)createNewBitcoinPayment;
- (void)changePaymentFromAddress:(NSString *)fromString isAdvanced:(BOOL)isAdvanced;
- (void)changePaymentFromAccount:(int)fromInt isAdvanced:(BOOL)isAdvanced;
- (void)changePaymentToAccount:(int)toInt;
- (void)changePaymentToAddress:(NSString *)toString;
- (void)changePaymentAmount:(uint64_t)amount;
- (void)sweepPaymentRegular;
- (void)sweepPaymentRegularThenConfirm;
- (void)sweepPaymentAdvanced;
- (void)sweepPaymentAdvancedThenConfirm:(uint64_t)fee;
- (void)setupBackupTransferAll:(id)transferAllController;
- (void)getInfoForTransferAllFundsToAccount;
- (void)setupFirstTransferForAllFundsToAccount:(int)account address:(NSString *)address secondPassword:(NSString *)secondPassword useSendPayment:(BOOL)useSendPayment;
- (void)setupFollowingTransferForAllFundsToAccount:(int)account address:(NSString *)address secondPassword:(NSString *)secondPassword useSendPayment:(BOOL)useSendPayment;
- (void)transferFundsBackupWithListener:(transactionProgressListeners*)listener secondPassword:(NSString *)secondPassword;
- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address;
- (void)changeLastUsedReceiveIndexOfDefaultAccount;
- (void)checkIfOverspending;
- (void)changeSatoshiPerByte:(uint64_t)satoshiPerByte updateType:(FeeUpdateType)updateType;
- (void)getTransactionFeeWithUpdateType:(FeeUpdateType)updateType;
- (void)getSurgeStatus;
- (uint64_t)dust;
- (NSArray *)getSwipeAddresses:(int)numberOfAddresses label:(NSString *)label;

// Recover with passphrase
- (void)recoverWithEmail:(NSString *)email password:(NSString *)recoveryPassword passphrase:(NSString *)passphrase;

- (void)updateServerURL:(NSString *)newURL;

// Transaction Details
- (void)saveNote:(NSString *)note forTransaction:(NSString *)hash;
- (void)saveEtherNote:(NSString *)note forTransaction:(NSString *)hash;
- (void)getFiatAtTime:(uint64_t)time value:(NSDecimalNumber *)value currencyCode:(NSString *)currencyCode assetType:(AssetType)assetType;
- (NSString *)getNotePlaceholderForTransactionHash:(NSString *)myHash;

- (JSValue *)executeJSSynchronous:(NSString *)command;

// Contacts
- (void)loadContacts;
- (void)loadContactsThenGetMessages;
- (void)getMessages;
- (void)createContactWithName:(NSString *)name ID:(NSString *)idString;
- (void)readInvitation:(NSString *)invitation;
- (void)completeRelation:(NSString *)identifier;
- (void)sendCancellation:(ContactTransaction *)transaction;
- (void)sendDeclination:(ContactTransaction *)transaction;
- (void)acceptRelation:(NSString *)invitation name:(NSString *)name identifier:(NSString *)identifier;
- (void)fetchExtendedPublicKey:(NSString *)contactIdentifier;
- (void)changeName:(NSString *)newName forContact:(NSString *)contactIdentifier;
- (void)deleteContact:(NSString *)contactIdentifier;
- (void)sendPaymentRequest:(NSString *)userId amount:(uint64_t)amount requestId:(NSString *)requestId note:(NSString *)note initiatorSource:(id)initiatorSource;
- (void)requestPaymentRequest:(NSString *)userId amount:(uint64_t)amount requestId:(NSString *)requestId note:(NSString *)note initiatorSource:(id)initiatorSource; // from account (NSNumber) or address (NSString)
- (void)sendPaymentRequestResponse:(NSString *)userId transactionHash:(NSString *)hash transactionIdentifier:(NSString *)transactionIdentifier;
- (BOOL)actionRequiredForContact:(Contact *)contact;
- (void)deleteContactAfterStoringInfo:(NSString *)contactIdentifier;

// Ethereum
- (NSString *)getEthBalance;
- (NSString *)getEthBalanceTruncated;
- (NSArray *)getEthTransactions;
- (void)getEthHistory;
- (void)getEthExchangeRate;
- (NSString *)getLabelForEthAccount;

// Ether send
- (void)createNewEtherPayment;
- (void)changeEtherPaymentTo:(NSString *)to;
- (void)changeEtherPaymentAmount:(id)amount;
- (BOOL)isEthAddress:(NSString *)address;
- (void)sendEtherPaymentWithNote:(NSString *)note;
- (NSString *)getEtherAddress;
- (void)isEtherContractAddress:(NSString *)address completion:(void (^ __nullable)(NSData *data, NSURLResponse *response, NSError *error))completion;
- (void)sweepEtherPayment;
- (BOOL)hasEthAccount;
- (BOOL)isWaitingOnEtherTransaction;

// Exchange
- (void)createEthAccountForExchange:(NSString *)secondPassword;
- (BOOL)isExchangeEnabled;
- (NSArray *)availableUSStates;
- (BOOL)isStateWhitelistedForShapeshift:(NSString *)stateCode;
- (void)selectState:(NSString *)name code:(NSString *)code;
- (void)getExchangeTrades;
- (void)getRate:(NSString *)coinPair;
- (NSURLSessionDataTask *)getApproximateQuote:(NSString *)coinPair usingFromField:(BOOL)usingFromField amount:(NSString *)amount completion:(void (^)(NSDictionary *, NSURLResponse *, NSError *))completion;
- (void)getAvailableBtcBalanceForAccount:(int)account;
- (void)getAvailableEthBalance;
- (void)buildExchangeTradeFromAccount:(int)fromAccount toAccount:(int)toAccount coinPair:(NSString *)coinPair amount:(NSString *)amount fee:(NSString *)fee;
- (void)shiftPayment;
- (BOOL)isDepositTransaction:(NSString *)txHash;
- (BOOL)isWithdrawalTransaction:(NSString *)txHash;

// Top Bar Display
- (NSDecimalNumber *)btcDecimalBalance;
- (NSDecimalNumber *)ethDecimalBalance;

- (NSString *)getMobileMessage;
@end
