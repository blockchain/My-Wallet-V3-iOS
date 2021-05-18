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

#import "TransactionProgressListeners.h"
#import "SRWebSocket.h"
#import "FeeTypes.h"
#import "Assets.h"
#import "WalletDelegate.h"

@class JSValue,
       JSContext,
       OrderTransactionLegacy,
       BitcoinWallet,
       EthereumWallet,
       WalletCryptoJS,
       WalletRepository,
       EtherTransaction;

@interface Wallet : NSObject <SRWebSocketDelegate>

// Core Wallet Init Properties
@property (nonatomic, readonly, strong) JSContext *context;

@property (nonatomic, weak) id<WalletDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary *transactionProgressListeners;

@property (nonatomic, copy) NSDictionary *accountInfo;
@property (nonatomic, assign) BOOL hasLoadedAccountInfo;

@property (nonatomic, assign) BOOL shouldLoadMetadata;

@property (nonatomic, copy) NSString *lastScannedWatchOnlyAddress;
@property (nonatomic, copy) NSString *lastImportedAddress;
@property (nonatomic, assign) BOOL didReceiveMessageForLastTransaction;

// HD properties:
@property (nonatomic, copy) NSString *recoveryPhrase;
@property (nonatomic, assign) int emptyAccountIndex;
@property (nonatomic, assign) int recoveredAccountIndex;

@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, copy) NSString *twoFactorInput;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *btcRates;

@property (nonatomic, strong) SRWebSocket *btcSocket;
@property (nonatomic, strong) SRWebSocket *bchSocket;
@property (nonatomic, strong) SRWebSocket *ethSocket;
@property (nonatomic, strong) NSMutableArray *pendingEthSocketMessages;

@property (nonatomic, strong) NSTimer *btcSocketTimer;
@property (nonatomic, strong) NSTimer *bchSocketTimer;
@property (nonatomic, copy) NSString *btcSwipeAddressToSubscribe;
@property (nonatomic, copy) NSString *bchSwipeAddressToSubscribe;

@property (nonatomic, assign) int lastLabelledAddressesCount;

@property (nonatomic, readonly, strong, nonnull) BitcoinWallet * bitcoin;
@property (nonatomic, readonly, strong, nonnull) EthereumWallet * ethereum;
@property (nonatomic, readonly, strong, nonnull) WalletCryptoJS * crypto;
@property (nonatomic, strong, nonnull) WalletRepository * repository;

@property (nonatomic, copy, nullable) NSDecimalNumber *latestEthExchangeRate;

- (instancetype)init;

# pragma mark - JS

/// Forces the JS layer to load - should be used to reset the context and rebind the methods
- (void)loadJS;
/// Load the JS - but only if needed - and return it.
- (JSContext *)loadContextIfNeeded;
/// Load the JS - but only if needed
- (void)loadJSIfNeeded;
- (BOOL)isInitialized;
- (JSValue *)executeJSSynchronous:(NSString *)command;

# pragma mark - Login

- (void)fetchWalletWith:(nonnull NSString *)password;
- (void)loadWalletWithGuid:(nonnull NSString *)guid sharedKey:(nullable NSString *)sharedKey password:(nullable NSString *)password;
- (void)resetSyncStatus;

# pragma mark - Addresses

- (NSDictionary *)addressBook;

- (void)setLabel:(NSString *)label forLegacyAddress:(NSString *)address;

- (void)toggleArchiveLegacyAddress:(NSString *)address;
- (void)toggleArchiveAccount:(int)account assetType:(LegacyAssetType)assetType;
- (void)archiveTransferredAddresses:(NSArray *)transferredAddresses;

- (NSString *)labelForLegacyAddress:(NSString *)address assetType:(LegacyAssetType)assetType;

- (BOOL)isAddressArchived:(NSString *)address;

- (void)subscribeToSwipeAddress:(NSString *)address assetType:(LegacyAssetType)assetType;
- (void)subscribeToAddress:(NSString *)address assetType:(LegacyAssetType)assetType;

- (void)addToAddressBook:(NSString *)address label:(NSString *)label;

- (BOOL)isValidAddress:(NSString *)string assetType:(LegacyAssetType)assetType;
- (BOOL)isWatchOnlyLegacyAddress:(NSString*)address;

- (BOOL)addKey:(NSString *)privateKeyString;
- (BOOL)addKey:(NSString*)privateKeyString toWatchOnlyAddress:(NSString *)watchOnlyAddress;

// Fetch String Array Of Addresses
- (NSArray *)activeLegacyAddresses:(LegacyAssetType)assetType;
- (NSArray *)spendableActiveLegacyAddresses;
- (NSArray *)allLegacyAddresses:(LegacyAssetType)assetType;
- (NSArray *)archivedLegacyAddresses;


- (float)getStrengthForPassword:(NSString *)password;

- (BOOL)needsSecondPassword;
- (BOOL)validateSecondPassword:(NSString *)secondPassword;

- (void)getHistory;
- (void)getHistoryIfNoTransactionMessage;
- (void)getBitcoinCashHistoryIfNoTransactionMessage;
- (void)getHistoryForAllAssets;

- (id)getLegacyAddressBalance:(NSString *)address assetType:(LegacyAssetType)assetType;
- (void)changeLocalCurrency:(NSString *)currencyCode;
- (void)changeBtcCurrency:(NSString *)btcCode;
- (double)conversionForBitcoinAssetType:(LegacyAssetType)assetType;

- (NSString *)detectPrivateKeyFormat:(NSString *)privateKeyString;

- (void)newAccount:(NSString *)password email:(NSString *)email;

- (BOOL)isAddressAvailable:(NSString *)address;
- (BOOL)isAccountAvailable:(int)account;
- (int)getIndexOfActiveAccount:(int)account assetType:(LegacyAssetType)assetType;
- (int)getAllTransactionsCount;

# pragma mark - HD Wallet

- (void)upgradeToV3Wallet;
- (BOOL)hasAccount;
- (BOOL)didUpgradeToHd;
- (void)getRecoveryPhrase:(NSString *)secondPassword;

/**
 Returns the mnemonic used to generate the HD wallet. Similar to `getRecoveryPhrase`.

 @param secondPassword the optional second password if set
 @return the mnemonic, or nil if the wallet is not yet initialized
 */
- (nullable NSString *)getMnemonic:(nullable NSString *)secondPassword;

- (BOOL)isRecoveryPhraseVerified;
- (void)markRecoveryPhraseVerifiedWithCompletion:(void (^ _Nullable)(void))completion error: (void (^ _Nullable)(void))error;
- (int)getDefaultAccountIndexForAssetType:(LegacyAssetType)assetType;
- (void)setDefaultAccount:(int)index assetType:(LegacyAssetType)assetType;
- (int)getActiveAccountsCount:(LegacyAssetType)assetType;
- (int)getAllAccountsCount:(LegacyAssetType)assetType;
- (BOOL)hasLegacyAddresses:(LegacyAssetType)assetType;
- (BOOL)isAccountArchived:(int)account assetType:(LegacyAssetType)assetType;
- (BOOL)isAccountNameValid:(NSString *)name;

- (uint64_t)getTotalActiveBalance;
- (uint64_t)getWatchOnlyBalance;
- (uint64_t)getTotalBalanceForActiveLegacyAddresses:(LegacyAssetType)assetType;
- (uint64_t)getTotalBalanceForSpendableActiveLegacyAddresses;
- (id)getBalanceForAccount:(int)account assetType:(LegacyAssetType)assetType;

- (NSString *)getLabelForAccount:(int)account assetType:(LegacyAssetType)assetType;

- (void)createAccountWithLabel:(NSString *)label;
- (void)generateNewKey;

- (NSString *)getReceiveAddressOfDefaultAccount:(LegacyAssetType)assetType;
- (NSString *)getReceiveAddressForAccount:(int)account assetType:(LegacyAssetType)assetType;

- (NSString *)getXpubForAccount:(int)accountIndex assetType:(LegacyAssetType)assetType;

- (void)loading_stop;

- (NSDictionary *)filteredWalletJSON;

- (int)getDefaultAccountLabelledAddressesCount;

# pragma mark - Settings

- (BOOL)isLockboxEnabled;
- (NSString *)getMobileMessage;
- (void)getAccountInfoAndExchangeRates;

# pragma mark - Bitcoin and Bitcoin Cash Payment Spender

- (void)createNewPayment:(LegacyAssetType)assetType;
- (void)changePaymentFromAddress:(NSString *)fromString isAdvanced:(BOOL)isAdvanced assetType:(LegacyAssetType)assetType;
- (void)changePaymentFromAccount:(int)fromInt isAdvanced:(BOOL)isAdvanced assetType:(LegacyAssetType)assetType;
- (void)changePaymentToAccount:(int)toInt assetType:(LegacyAssetType)assetType;
- (void)changePaymentToAddress:(NSString *)toString assetType:(LegacyAssetType)assetType;
- (void)changePaymentAmount:(id)amount assetType:(LegacyAssetType)assetType;
- (void)sweepPaymentRegular;
- (void)sweepPaymentRegularThenConfirm;
- (void)sweepPaymentAdvanced;
- (void)sweepPaymentAdvancedThenConfirm:(uint64_t)fee;
- (void)setupBackupTransferAll:(id)transferAllController;
- (void)getInfoForTransferAllFundsToAccount;
- (void)setupFirstTransferForAllFundsToAccount:(int)account address:(NSString *)address secondPassword:(NSString *)secondPassword useSendPayment:(BOOL)useSendPayment;
- (void)setupFollowingTransferForAllFundsToAccount:(int)account address:(NSString *)address secondPassword:(NSString *)secondPassword useSendPayment:(BOOL)useSendPayment;
- (void)transferFundsBackupWithListener:(TransactionProgressListeners*)listener secondPassword:(NSString *)secondPassword;
- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address;
- (void)changeLastUsedReceiveIndexOfDefaultAccount;
- (void)checkIfOverspending;
- (void)changeSatoshiPerByte:(uint64_t)satoshiPerByte updateType:(FeeUpdateType)updateType;
- (void)getTransactionFeeWithUpdateType:(FeeUpdateType)updateType;
- (void)getSurgeStatus;
- (uint64_t)dust;
- (void)getSwipeAddresses:(int)numberOfAddresses assetType:(LegacyAssetType)assetType;

# pragma mark - Transaction Details

- (void)saveNote:(NSString *)note forTransaction:(NSString *)hash;
- (void)saveEtherNote:(NSString *)note forTransaction:(NSString *)hash;
- (NSString *)getBitcoinNotePlaceholderForTransactionHash:(NSString *)myHash;

# pragma mark - Ethereum

- (nullable NSDecimalNumber *)getEthBalance;
- (nullable NSString *)getEtherAddress __deprecated_msg("Use `getEthereumAddressWithSuccess:error` instead.");

- (void)isEtherContractAddress:(NSString *)address completion:(void (^ __nullable)(NSData *data, NSURLResponse *response, NSError *error))completion;
- (BOOL)hasEthAccount;

# pragma mark - Bitcoin Cash

- (NSString *)fromBitcoinCash:(NSString *)address;
- (NSString *)toBitcoinCash:(NSString *)address includePrefix:(BOOL)includePrefix;
- (void)fetchBitcoinCashExchangeRates;
- (NSString *)getLabelForBitcoinCashAccount:(int)account;
- (void)buildBitcoinCashPaymentTo:(id)to amount:(uint64_t)amount;
- (void)sendBitcoinCashPaymentWithListener:(TransactionProgressListeners*)listener;
- (BOOL)hasBchAccount;
- (uint64_t)getBchBalance;
- (NSString *)bitcoinCashExchangeRate;
- (nullable NSString *)getLabelForDefaultBchAccount;

# pragma mark - Lockbox

- (nonnull NSArray *)getLockboxDevices;

# pragma mark - Stellar

- (nullable NSArray *)getXlmAccounts;
- (void)saveXlmAccount:(nonnull NSString *)publicKey label:(nullable NSString *)label success:(void (^ _Nonnull)(void))success error:(void (^)(NSString *_Nonnull))error;

# pragma mark - Bitcoin and Bitcoin Cash Transacting

- (void)signBitcoinPaymentWithSecondPassword:(nullable NSString *)secondPassword successBlock:(void (^)(NSString *_Nonnull))transactionHex error:(void (^ _Nonnull)(NSString *_Nonnull))error;
- (void)signBitcoinCashPaymentWithSecondPassword:(nullable NSString *)secondPassword successBlock:(void (^)(NSString *_Nonnull))transactionHex error:(void (^ _Nonnull)(NSString *_Nonnull))error;
- (void)sendPaymentWithListener:(TransactionProgressListeners*)listener secondPassword:(NSString *)secondPassword;

/// Call this method to build an Exchange order.
/// It constructs and stores a payment object with a given CryptoCurrency, to, from, and amount (properties of OrderTransactionLegacy).
/// To send the order, call sendOrderTransaction:completion:success:error:cancel.
///
/// - Parameters:
///   - orderTransaction: the object containing the payment information (AssetType, to, from, and amount)
///   - completion: handler called when the payment is successfully built
///   - error: handler called when an error occurs while building the payment
- (void)createOrderPaymentWithOrderTransaction:(OrderTransactionLegacy * _Nonnull)orderTransaction
                                    completion:(void (^ _Nonnull)(void))completion
                                       success:(void (^ _Nonnull)(NSDictionary * _Nonnull))success
                                         error:(void (^ _Nonnull)(NSDictionary * _Nonnull))error;

/// Sign and publish a transaction that was built by createOrderPaymentWithOrderTransaction:completion:success:error.
/// This is the last step in sending an exchange order via Homebrew.
///
/// - Parameters:
///   - legacyAssetType: used to determine the type of payment to use
///   - completion: handler called when the payment is successfully sent
///   - error: handler called when an error occurs while sending the payment
///   - cancel: handler called when the payment is cancelled (e.g., when an intermediate screen such as second password is dismissed)
- (void)sendOrderTransaction:(LegacyAssetType)legacyAssetType
              secondPassword:(NSString* _Nullable)secondPassword
                  completion:(void (^ _Nonnull)(void))completion
                     success:(void (^ _Nonnull)(NSString *_Nonnull))success
                       error:(void (^ _Nonnull)(NSString *_Nonnull))error
                      cancel:(void (^ _Nonnull)(void))cancel;

# pragma mark - Wallet Recovery

/// Recovers wallet associated with mnemonic passphrase, setting to it the given email and password and a new GUID.
- (void)recoverWithEmail:(nonnull NSString *)email password:(nonnull NSString *)recoveryPassword mnemonicPassphrase:(nonnull NSString *)mnemonicPassphrase;
/// Tries to recover wallet associated with mnemonic passphrase, reusing same GUID.
/// Succeeds if the wallet has the correct backup data in its metadata, otherwise fails with 'NO_METADATA' error.
- (void)recoverFromMetadataWithMnemonicPassphrase:(nonnull NSString *)mnemonicPassphrase;


@end
