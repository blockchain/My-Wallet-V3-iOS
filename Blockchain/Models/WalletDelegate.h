//
//  WalletDelegate.h
//  Blockchain
//
//  Created by Paulo on 17/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Wallet;
@class MultiAddressResponse;
@protocol WalletSuccessCallback;
@protocol WalletDismissCallback;

@protocol WalletDelegate <NSObject>

@optional
- (void)didGetMultiAddressResponse:(MultiAddressResponse *)response;
- (void)didFilterTransactions:(NSArray *)transactions;
- (void)walletDidDecryptWithSharedKey:(nullable NSString *)sharedKey guid:(nullable NSString *)guid;
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
- (void)didImportKey:(NSString *)address;
- (void)didImportIncorrectPrivateKey:(NSString *)address;
- (void)didImportPrivateKeyToLegacyAddress;
- (void)didFailToImportPrivateKey:(NSString *)error;
- (void)didFailRecovery;
- (void)didRecoverWallet;
- (void)didFailGetHistory:(NSString *_Nullable)error;
- (void)resendTwoFactorSuccess;
- (void)resendTwoFactorError:(NSString *)error;
- (void)returnToAddressesScreen;
- (void)estimateTransactionSize:(uint64_t)size;
- (void)didCheckForOverSpending:(NSNumber *)amount fee:(NSNumber *)fee;
- (void)didGetMaxFee:(NSNumber *)fee amount:(NSNumber *)amount dust:(NSNumber *_Nullable)dust willConfirm:(BOOL)willConfirm;
- (void)didUpdateTotalAvailableBTC:(NSNumber *)sweepAmount finalFee:(NSNumber *)finalFee;
- (void)didUpdateTotalAvailableBCH:(NSNumber *)sweepAmount finalFee:(NSNumber *)finalFee;
- (void)didGetFee:(NSNumber *)fee dust:(NSNumber *_Nullable)dust txSize:(NSNumber *)txSize;
- (void)didChangeSatoshiPerByte:(NSNumber *)sweepAmount fee:(NSNumber *)fee dust:(NSNumber *_Nullable)dust updateType:(FeeUpdateType)updateType;
- (void)enableSendPaymentButtons;
- (void)didGetSurgeStatus:(BOOL)surgeStatus;
- (void)updateSendBalance:(NSNumber *)balance fees:(NSDictionary *)fees;
- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed;
- (void)showSummaryForTransferAll;
- (void)sendDuringTransferAll:(NSString *_Nullable)secondPassword;
- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *_Nullable)secondPassword;
- (void)receivedTransactionMessage;
- (void)paymentReceivedOnPINScreen:(NSString *)amount assetType:(LegacyAssetType)assetType address:(NSString *)address;
- (void)didReceivePaymentNotice:(NSString *_Nullable)notice;
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
- (void)didSendPaymentRequest:(NSDictionary *)info amount:(uint64_t)amount name:(NSString *)name requestId:(NSString *)requestId;
- (void)didRequestPaymentRequest:(NSDictionary *)info name:(NSString *)name;
- (void)didSendPaymentRequestResponse;
- (void)didPushTransaction;
- (void)didGetSwipeAddresses:(NSArray *)newSwipeAddresses assetType:(LegacyAssetType)assetType;
- (void)didGetEtherAddressWithSecondPassword;
- (void)didGetAvailableBtcBalance:(NSDictionary *)result;
- (void)didFetchBitcoinCashHistory;
- (void)walletDidGetAccountInfo:(Wallet *)wallet;
- (void)walletDidGetBtcExchangeRates:(Wallet *)wallet;
- (void)walletDidGetAccountInfoAndExchangeRates:(Wallet *)wallet;
- (void)getSecondPasswordWithSuccess:(id<WalletSuccessCallback>)success dismiss:(id<WalletDismissCallback>)dismiss;
- (void)getPrivateKeyPasswordWithSuccess:(id<WalletSuccessCallback>)success;
- (void)didErrorWhenBuildingBitcoinPaymentWithError:(NSString *)error;

@end
