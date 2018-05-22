//
//  TransferAllFundsBuilder.m
//  Blockchain
//
//  Created by Kevin Wu on 10/14/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransferAllFundsBuilder.h"
#import "RootService.h"
#import "Blockchain-Swift.h"

@interface TransferAllFundsBuilder()
@property (nonatomic) NSString *temporarySecondPassword;
@property (nonatomic) LegacyAssetType assetType;
@end
@implementation TransferAllFundsBuilder

- (id)initWithAssetType:(LegacyAssetType)assetType usingSendScreen:(BOOL)usesSendScreen
{
    if (self = [super init]) {
        self.assetType = assetType;
        _usesSendScreen = usesSendScreen;
        [self getTransferAllInfo];
    }
    return self;
}

- (Wallet *)wallet
{
    return WalletManager.sharedInstance.wallet;
}

- (void)getTransferAllInfo
{
    [WalletManager.sharedInstance.wallet getInfoForTransferAllFundsToAccount];
}

- (NSString *)getLabelForDestinationAccount
{
    return [WalletManager.sharedInstance.wallet getLabelForAccount:self.destinationAccount assetType:self.assetType];
}

- (NSString *)formatMoney:(uint64_t)amount localCurrency:(BOOL)useLocalCurrency
{
    return [NSNumberFormatter formatMoney:amount localCurrency:useLocalCurrency];
}

- (NSString *)getLabelForAmount:(uint64_t)amount
{
    return [NSNumberFormatter formatMoney:amount localCurrency:NO];
}

- (void)setupFirstTransferWithAddressesUsed:(NSArray *)addressesUsed
{
    self.transferAllAddressesToTransfer = [[NSMutableArray alloc] initWithArray:addressesUsed];
    self.transferAllAddressesTransferred = [[NSMutableArray alloc] init];
    self.transferAllAddressesInitialCount = (int)[self.transferAllAddressesToTransfer count];
    self.transferAllAddressesUnspendable = 0;
    
    // use default account, but can select new destination account by calling setupTransfersToAccount:
    [self setupTransfersToAccount:[WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType]];
}

- (void)setupTransfersToAccount:(int)account
{
    _destinationAccount = account;
    [WalletManager.sharedInstance.wallet setupFirstTransferForAllFundsToAccount:account address:[self.transferAllAddressesToTransfer firstObject] secondPassword:nil useSendPayment:self.usesSendScreen];
}

- (void)transferAllFundsToAccountWithSecondPassword:(NSString *)_secondPassword
{
    if (self.userCancelledNext) {
        [self finishedTransferFunds];
        return;
    }
    
    Wallet *wallet = WalletManager.sharedInstance.wallet;
    
    transactionProgressListeners *listener = [[transactionProgressListeners alloc] init];
    
    listener.on_start = self.on_start;
    
    listener.on_begin_signing = self.on_begin_signing;
    
    listener.on_sign_progress = self.on_sign_progress;
    
    listener.on_finish_signing = self.on_finish_signing;
    
    listener.on_success = ^(NSString*secondPassword, NSString *transactionHash) {
        
        DLog(@"SendViewController: on_success_transfer_all for address %@", [self.transferAllAddressesToTransfer firstObject]);
        
        self.temporarySecondPassword = secondPassword;
        
        [wallet changeLastUsedReceiveIndexOfDefaultAccount];
        // Fields are automatically reset by reload, called by MyWallet.wallet.getHistory() after a utx websocket message is received. However, we cannot rely on the websocket 100% of the time.
        [wallet performSelector:@selector(getHistoryIfNoTransactionMessage) withObject:nil afterDelay:DELAY_GET_HISTORY_BACKUP];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueTransferringFunds) name:[ConstantsObjcBridge notificationKeyMultiAddressResponseReload] object:nil];
        
        if (self.on_success) self.on_success(secondPassword);
    };
    
    listener.on_error = ^(NSString* error, NSString* secondPassword) {
        DLog(@"Send error: %@", error);
        
        if ([error containsString:ERROR_ALL_OUTPUTS_ARE_VERY_SMALL]) {
            self.transferAllAddressesUnspendable++;
            self.temporarySecondPassword = secondPassword;
            [self continueTransferringFunds];
            DLog(@"Output too small; continuing transfer all");
            return;
        }
                
        if ([error isEqualToString:ERROR_UNDEFINED]) {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_SEND_ERROR_NO_INTERNET_CONNECTION title:BC_STRING_ERROR handler: nil];
        } else if ([error isEqualToString:ERROR_FAILED_NETWORK_REQUEST]) {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[LocalizationConstantsObjcBridge requestFailedCheckConnection] title:BC_STRING_ERROR handler: nil];
        } else if (error && error.length != 0)  {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR handler: nil];
        }
        
        if (self.on_error) self.on_error(error, secondPassword);
        
        [wallet getHistory];
    };
    
    WalletManager.sharedInstance.wallet.didReceiveMessageForLastTransaction = NO;
    
    if (self.usesSendScreen) {
        if (self.on_before_send) self.on_before_send();
        [wallet sendPaymentWithListener:listener secondPassword:_secondPassword];
    } else {
        if (wallet.needsSecondPassword && !_secondPassword) {
            [AuthenticationCoordinator.shared showPasswordConfirmWithDisplayText:BC_STRING_ACTION_REQUIRES_SECOND_PASSWORD headerText:BC_STRING_ACTION_REQUIRES_SECOND_PASSWORD validateSecondPassword:YES confirmHandler:^(NSString * _Nonnull secondPasswordInput) {
                if (self.on_before_send) self.on_before_send();
                [wallet transferFundsBackupWithListener:listener secondPassword:secondPasswordInput];
            }];
        } else {
            if (self.on_before_send) self.on_before_send();
            [wallet transferFundsBackupWithListener:listener secondPassword:_secondPassword];
        }
    }
}

- (void)continueTransferringFunds
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConstantsObjcBridge notificationKeyMultiAddressResponseReload] object:nil];
    
    if ([self.transferAllAddressesToTransfer count] > 0) {
        [self.transferAllAddressesTransferred addObject:self.transferAllAddressesToTransfer[0]];
    }
    
    if ([self.transferAllAddressesToTransfer count] > 1 && !self.userCancelledNext) {
        [self.transferAllAddressesToTransfer removeObjectAtIndex:0];
        if (self.on_prepare_next_transfer) self.on_prepare_next_transfer(self.transferAllAddressesToTransfer);
        [WalletManager.sharedInstance.wallet setupFollowingTransferForAllFundsToAccount:self.destinationAccount address:self.transferAllAddressesToTransfer[0] secondPassword:self.temporarySecondPassword useSendPayment:self.usesSendScreen];
    } else {
        [self.transferAllAddressesToTransfer removeAllObjects];
        [self finishedTransferFunds];
    }
}

- (void)finishedTransferFunds
{
    NSString *summary;
    if (self.transferAllAddressesUnspendable > 0) {
        
        NSString *addressOrAddressesTransferred = self.transferAllAddressesInitialCount - self.transferAllAddressesUnspendable == 1 ? [BC_STRING_ADDRESS lowercaseString] : [BC_STRING_ADDRESSES lowercaseString];
        NSString *addressOrAddressesSkipped = self.transferAllAddressesUnspendable == 1 ? [BC_STRING_ADDRESS lowercaseString] : [BC_STRING_ADDRESSES lowercaseString];
        
        summary = [NSString stringWithFormat:BC_STRING_PAYMENT_TRANSFERRED_FROM_ARGUMENT_ARGUMENT_OUTPUTS_ARGUMENT_ARGUMENT_TOO_SMALL, self.transferAllAddressesInitialCount - self.transferAllAddressesUnspendable, addressOrAddressesTransferred, self.transferAllAddressesUnspendable, addressOrAddressesSkipped];
    } else {
        
        NSString *addressOrAddressesTransferred = [self.transferAllAddressesTransferred count] == 1 ? [BC_STRING_ADDRESS lowercaseString] : [BC_STRING_ADDRESSES lowercaseString];
        
        summary = [NSString stringWithFormat:BC_STRING_PAYMENT_TRANSFERRED_FROM_ARGUMENT_ARGUMENT, [self.transferAllAddressesTransferred count], addressOrAddressesTransferred];
    }
    
    [self.delegate didFinishTransferFunds:summary];
}

- (void)archiveTransferredAddresses
{
    [WalletManager.sharedInstance.wallet archiveTransferredAddresses:self.transferAllAddressesTransferred];
}

@end
