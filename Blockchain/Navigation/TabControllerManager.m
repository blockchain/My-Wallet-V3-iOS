//
//  TabControllerManager.m
//  Blockchain
//
//  Created by kevinwu on 8/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <PlatformUIKit/PlatformUIKit.h>
#import "TabControllerManager.h"
#import "BCNavigationController.h"
#import "Transaction.h"
#import "Blockchain-Swift.h"

@interface TabControllerManager () <WalletSettingsDelegate, WalletSendBitcoinDelegate, WalletSendEtherDelegate, WalletExchangeIntermediateDelegate, WalletTransactionDelegate, WalletWatchOnlyDelegate, WalletFiatAtTimeDelegate>

#pragma mark - Private Properties

@property (strong, nonatomic) DashboardContainerViewController *dashboardContainer;
@property (strong, nonatomic) SendLumensViewController *sendLumensViewController;
@property (strong, nonatomic) TransactionsXlmViewController *transactionsStellarViewController;
@property (strong, nonatomic) ExchangeContainerViewController *exchangeContainerViewController;

@property (strong, nonatomic) PaxActivityViewController *paxActivityViewController;

@property (strong, nonatomic) SendPaxViewController *sendPaxViewController;

@end
@implementation TabControllerManager

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tabViewController.assetDelegate = self;

    NSInteger assetType = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_ASSET_TYPE] integerValue];
    self.assetType = assetType;
    [self.tabViewController selectAsset:assetType];

    WalletManager *walletManager = WalletManager.sharedInstance;
    walletManager.settingsDelegate = self;
    walletManager.sendBitcoinDelegate = self;
    walletManager.sendEtherDelegate = self;
    walletManager.partnerExchangeIntermediateDelegate = self;
    walletManager.transactionDelegate = self;
    walletManager.watchOnlyDelegate = self;
    walletManager.fiatAtTimeDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [AppCoordinator.sharedInstance showHdUpgradeViewIfNeeded];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.destinationViewController isKindOfClass:[TabViewController class]]) {
        self.tabViewController = segue.destinationViewController;
    }
}

- (void)didSetAssetType:(LegacyAssetType)assetType
{
    self.assetType = assetType;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.assetType] forKey:USER_DEFAULTS_KEY_ASSET_TYPE];

    BOOL animated = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabSend]) {
            [self showSendCoinsAnimated:animated];
        } else if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabDashboard]) {
            [self showDashboardAnimated:animated];
        } else if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabTransactions]) {
            [self showTransactionsAnimated:animated];
        } else if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabReceive]) {
            [self showReceiveAnimated:animated];
        }
    });
}

#pragma mark - Wallet Settings Delegate

- (void)didChangeLocalCurrency
{
    [self.sendBitcoinViewController reloadFeeAmountLabel];
    [self.sendEtherViewController keepCurrentPayment];
    [self.receiveBitcoinViewController doCurrencyConversion];
    [self.transactionsEtherViewController reload];
}

#pragma mark - Wallet Transaction Delegate


- (void)onPaymentReceivedWithAmount:(NSString * _Nonnull)amount assetType:(enum AssetType)assetType
{
    [AlertViewPresenter.sharedInstance standardNotifyWithMessage:amount title:BC_STRING_PAYMENT_RECEIVED in:nil handler:nil];

    LegacyAssetType legacyType = [AssetTypeLegacyHelper convertToLegacy: assetType];

    [AuthenticationCoordinator.sharedInstance.pinEntryViewController paymentReceived:legacyType];
}

- (void)onTransactionReceived
{
    [SoundManager.sharedInstance playBeep];
    [self receivedTransactionMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:[ConstantsObjcBridge notificationKeyTransactionReceived] object:nil];
}

- (void)didPushTransaction
{
    DestinationAddressSource source = [self getSendAddressSource];
    NSString *eventName;

    if (source == DestinationAddressSourceQR) {
        eventName = WALLET_EVENT_TX_FROM_QR;
    } else if (source == DestinationAddressSourcePaste) {
        eventName = WALLET_EVENT_TX_FROM_PASTE;
    } else if (source == DestinationAddressSourceURI) {
        eventName = WALLET_EVENT_TX_FROM_URI;
    } else if (source == DestinationAddressSourceDropDown) {
        eventName = WALLET_EVENT_TX_FROM_DROPDOWN;
    } else if (source == DestinationAddressSourceNone) {
        DLog(@"Destination address source none");
        return;
    } else {
        DLog(@"Unknown destination address source %d", source);
        return;
    }

    NSURL *URL = [NSURL URLWithString:[[[BlockchainAPI sharedInstance] walletUrl] stringByAppendingFormat:URL_SUFFIX_EVENT_NAME_ARGUMENT, eventName]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"POST";

    NSURLSessionDataTask *dataTask = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            DLog(@"Error saving address input: %@", [error localizedDescription]);
        }
    }];

    [dataTask resume];
}

- (void)updateLoadedAllTransactionsWithLoadedAll:(BOOL)loadedAll
{
    // Should eventually apply to all asset types, but the fetching mechanism was never merged into My-Wallet-V3.
    _transactionsBitcoinViewController.loadedAllTransactions = loadedAll;
}

#pragma mark - Reloading

- (void)reload
{
    [self.dashboardContainer.dashboard reload];
    [_sendBitcoinViewController reload];
    [_sendEtherViewController reload];
    [_sendBitcoinCashViewController reload];
    [_transactionsBitcoinViewController reload];
    [_transactionsEtherViewController reload];
    [_transactionsBitcoinCashViewController reload];
    [_receiveBitcoinViewController reload];
    [_receiveBitcoinCashViewController reload];
}

- (void)reloadAfterMultiAddressResponse
{
    [self.dashboardContainer.dashboard reload];
    [_sendBitcoinViewController reloadAfterMultiAddressResponse];
    [_sendEtherViewController reloadAfterMultiAddressResponse];
    [_sendBitcoinCashViewController reloadAfterMultiAddressResponse];
    [_transactionsBitcoinViewController reload];
    [_receiveBitcoinViewController reload];
    [_receiveBitcoinCashViewController reload];
}

- (void)reloadMessageViews
{
    [self.sendBitcoinViewController hideSelectFromAndToButtonsIfAppropriate];

    [_transactionsBitcoinViewController didGetMessages];
}

- (void)logout
{
    [self updateTransactionsViewControllerData:nil];
    [self.sendEtherViewController clearFundsAvailable];
    [_receiveBitcoinViewController clearAmounts];
    [self.exchangeContainerViewController showWelcome];

    [self dashBoardClicked:nil];
}

- (void)forgetWallet
{
    self.receiveBitcoinViewController = nil;
    self.receiveBitcoinCashViewController = nil;
    self.transactionsStellarViewController = nil;
    self.sendLumensViewController = nil;
    self.exchangeContainerViewController = nil;
    [_transactionsBitcoinViewController setData:nil];
}

#pragma mark - BTC Send

- (BOOL)isSending
{
    return self.sendBitcoinViewController.isSending;
}

- (void)showSendCoinsAnimated:(BOOL)animated
{
    int tabIndex = (int)[ConstantsObjcBridge tabSend];
    
    switch (self.assetType) {
        case LegacyAssetTypeBitcoin: {
            if (!_sendBitcoinViewController) {
                _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
            }
            
            [_tabViewController setActiveViewController:_sendBitcoinViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeEther: {
            if (!_sendEtherViewController) {
                _sendEtherViewController = [[SendEtherViewController alloc] init];
            }
            
            [_tabViewController setActiveViewController:_sendEtherViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeBitcoinCash: {
            if (!_sendBitcoinCashViewController) {
                _sendBitcoinCashViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
                _sendBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
            }
            
            [_tabViewController setActiveViewController:_sendBitcoinCashViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeStellar: {
            if (!_sendLumensViewController) {
                _sendLumensViewController = [SendLumensViewController makeWith:XLMServiceProvider.sharedInstance];
            }
            
            [_tabViewController setActiveViewController:_sendLumensViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypePax: {
            if (!_sendPaxViewController) {
                _sendPaxViewController = [SendPaxViewController make];
            }
            [_tabViewController setActiveViewController:_sendPaxViewController animated:animated index:tabIndex];
            break;
        }
    }
}

- (void)setupTransferAllFunds
{
    if (!_sendBitcoinViewController) {
       _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }

    [self showSendCoinsAnimated:YES];

    [_sendBitcoinViewController setupTransferAll];
}

- (void)hideSendKeyboard
{
    [self.sendBitcoinViewController hideKeyboard];
}

- (DestinationAddressSource)getSendAddressSource
{
    if (self.assetType == AssetTypeEthereum) {
        return self.sendEtherViewController.addressSource;
    }
    return self.sendBitcoinViewController.addressSource;
}

- (void)setupSendToAddress:(NSString *)address
{
    [self showSendCoinsAnimated:YES];

    if (self.assetType == LegacyAssetTypeBitcoin) {
        self.sendBitcoinViewController.addressFromURLHandler = address;
        [self.sendBitcoinViewController reload];
    } else if (self.assetType == LegacyAssetTypeEther) {
        self.sendEtherViewController.addressToSet = address;
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        self.sendBitcoinCashViewController.addressFromURLHandler = address;
        [self.sendBitcoinCashViewController reload];
    }
}

#pragma mark - Wallet Watch Only Delegate

- (void)sendFromWatchOnlyAddress
{
    [_sendBitcoinViewController sendFromWatchOnlyAddress];
}

#pragma mark - Wallet Send Bitcoin Delegate

- (void)didChangeSatoshiPerByteWithSweepAmount:(NSNumber * _Nonnull)sweepAmount fee:(NSNumber * _Nonnull)fee dust:(NSNumber * _Nullable)dust updateType:(FeeUpdateType)updateType
{
    [_sendBitcoinViewController didChangeSatoshiPerByte:sweepAmount fee:fee dust:dust updateType:updateType];
}

- (void)didCheckForOverSpendingWithAmount:(NSNumber * _Nonnull)amount fee:(NSNumber * _Nonnull)fee
{
    [_sendBitcoinViewController didCheckForOverSpending:amount fee:fee];
}

- (void)didGetFeeWithFee:(NSNumber * _Nonnull)fee dust:(NSNumber * _Nullable)dust txSize:(NSNumber * _Nonnull)txSize
{
    [_sendBitcoinViewController didGetFee:fee dust:dust txSize:txSize];
}

- (void)didGetMaxFeeWithFee:(NSNumber * _Nonnull)fee amount:(NSNumber * _Nonnull)amount dust:(NSNumber * _Nullable)dust willConfirm:(BOOL)willConfirm
{
    [_sendBitcoinViewController didGetMaxFee:fee amount:amount dust:dust willConfirm:willConfirm];
}

- (void)didUpdateTotalAvailableWithSweepAmount:(NSNumber * _Nonnull)sweepAmount finalFee:(NSNumber * _Nonnull)finalFee
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [_sendBitcoinViewController didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [_sendBitcoinCashViewController didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
    }
}

- (void)updateSendBalanceWithBalance:(NSNumber * _Nonnull)balance fees:(NSDictionary * _Nonnull)fees
{
    [_sendBitcoinViewController updateSendBalance:balance fees:fees];
}

- (void)didGetSurgeStatus:(BOOL)surgeStatus
{
    _sendBitcoinViewController.surgeIsOccurring = surgeStatus;
}

- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed
{
    [_sendBitcoinViewController updateTransferAllAmount:amount fee:fee addressesUsed:addressesUsed];
}

- (void)showSummaryForTransferAll
{
    [_sendBitcoinViewController showSummaryForTransferAll];
}

- (void)sendDuringTransferAll:(NSString *)secondPassword
{
    [self.sendBitcoinViewController sendDuringTransferAll:secondPassword];
}

- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *)secondPassword
{
    [_sendBitcoinViewController didErrorDuringTransferAll:error secondPassword:secondPassword];
}

- (void)receivedTransactionMessage
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        if (_transactionsBitcoinViewController) {
            [_transactionsBitcoinViewController didReceiveTransactionMessage];
            [_receiveBitcoinViewController storeRequestedAmount];
        }
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [_receiveBitcoinCashViewController reload];
        if (_transactionsBitcoinCashViewController) {
            [_transactionsBitcoinCashViewController didReceiveTransactionMessage];
        } else {
            Transaction *transaction = [[WalletManager.sharedInstance.wallet getBitcoinCashTransactions:[ConstantsObjcBridge filterIndexAll]] firstObject];
            [_receiveBitcoinCashViewController paymentReceived:ABS(transaction.amount) showBackupReminder:NO];
        }
    }
}

- (void)didReceivePaymentNoticeWithNotice:(NSString *_Nullable)notice
{
    if (notice && self.tabViewController.selectedIndex == [ConstantsObjcBridge tabSend] && !LoadingViewPresenter.sharedInstance.isLoadingShown && !AuthenticationCoordinator.shared.pinEntryViewController && !self.tabViewController.presentedViewController) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:notice title:[LocalizationConstantsObjcBridge information] in:self handler: nil];
    }
}

- (void)didErrorWhileBuildingPaymentWithError:(NSString *)message
{
    [[AlertViewPresenter sharedInstance] standardErrorWithMessage:message title:[LocalizationConstantsObjcBridge error] in:self handler:nil];
}

#pragma mark - Eth Send

- (void)didFetchEthExchangeRate:(NSNumber *)rate
{
    self.latestEthExchangeRate = [NSDecimalNumber decimalNumberWithDecimal:[rate decimalValue]];

    [self.tabViewController didFetchEthExchangeRate];
    [_sendEtherViewController updateExchangeRate:self.latestEthExchangeRate];
}

#pragma mark - Wallet Send Ether Delegate

- (void)didSendEther
{
    [WalletActionEventBus.sharedInstance publishObjWithAction:WalletActionSendCrypto extras:nil];
    [self.sendEtherViewController reload];

    [[ModalPresenter sharedInstance] closeAllModals];

    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_PAYMENT_SENT_ETHER title:[LocalizationConstantsObjcBridge success] in:self handler:nil];

    [self showTransactionsAnimated:YES];

    [self didPushTransaction];
}

- (void)didGetEtherAddressWithSecondPassword
{
    // TODO: IOS-2193
}

- (void)didErrorDuringEtherSendWithError:(NSString * _Nonnull)error
{
    [[ModalPresenter sharedInstance] closeAllModals];

    [[AlertViewPresenter sharedInstance] standardErrorWithMessage:error title:[LocalizationConstantsObjcBridge error] in:self handler:nil];
}

- (void)didUpdateEthPaymentWithPayment:(NSDictionary * _Nonnull)payment
{
    [_sendEtherViewController didUpdatePayment:payment];
}

#pragma mark - Fiat at Time

- (void)didGetFiatAtTimeWithFiatAmount:(NSNumber * _Nonnull)fiatAmount currencyCode:(NSString * _Nonnull)currencyCode assetType:(AssetType)assetType
{
    NSArray *transactions;
    NSString *targetHash;

    if (assetType == AssetTypeBitcoin) {
        transactions = WalletManager.sharedInstance.latestMultiAddressResponse.transactions;
        targetHash = self.transactionsBitcoinViewController.detailViewController.transactionModel.myHash;
    } else if (assetType == AssetTypeEthereum) {
        transactions = WalletManager.sharedInstance.wallet.etherTransactions;
        targetHash = self.transactionsEtherViewController.detailViewController.transactionModel.myHash;
    } else if (assetType == AssetTypeBitcoinCash) {
        transactions = WalletManager.sharedInstance.wallet.bitcoinCashTransactions;
        targetHash = self.transactionsBitcoinCashViewController.detailViewController.transactionModel.myHash;
    }

    NSString *amount = [[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator] stringFromNumber:fiatAmount];
    NSDictionary *result = @{currencyCode : amount};
    
    for (Transaction *transaction in transactions) {
        if ([transaction.myHash isEqualToString:targetHash]) {
            [transaction.fiatAmountsAtTime setObject:amount forKey:currencyCode];
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[ConstantsObjcBridge notificationKeyGetFiatAtTime] object:result];
}

- (void)didErrorWhenGettingFiatAtTimeWithError:(NSString * _Nullable)error
{
    [[AlertViewPresenter sharedInstance] standardErrorWithMessage:BC_STRING_ERROR_GETTING_FIAT_AT_TIME title:BC_STRING_ERROR in:self handler:nil];
}

#pragma mark - Receive

- (void)showReceiveAnimated:(BOOL)animated
{
    int tabIndex = (int)[ConstantsObjcBridge tabReceive];

    switch (self.assetType) {
        case LegacyAssetTypeBitcoin: {
            if (!_receiveBitcoinViewController) {
                _receiveBitcoinViewController = [[ReceiveBitcoinViewController alloc] initWithNibName:NIB_NAME_RECEIVE_COINS bundle:[NSBundle mainBundle]];
            }
            
            [_tabViewController setActiveViewController:_receiveBitcoinViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeEther: {
            [self setReceiveControllerIfNeededForAssetType:self.assetType animated:animated];
            break;
        }
        case LegacyAssetTypeBitcoinCash: {
            if (!_receiveBitcoinCashViewController) {
                _receiveBitcoinCashViewController = [[ReceiveBitcoinViewController alloc] initWithNibName:NIB_NAME_RECEIVE_COINS bundle:[NSBundle mainBundle]];
                _receiveBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
            }
            
            [_tabViewController setActiveViewController:_receiveBitcoinCashViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeStellar: {
            [self setReceiveControllerIfNeededForAssetType:self.assetType animated:animated];
            break;
        }
        case LegacyAssetTypePax: {
            [self setReceiveControllerIfNeededForAssetType:self.assetType animated:animated];
            break;
        }
    }
}

- (void)setReceiveControllerIfNeededForAssetType:(LegacyAssetType)assetType animated:(BOOL)animated
{
    if ([_tabViewController.activeViewController isKindOfClass:[ReceiveCryptoViewController class]]) {
        ReceiveCryptoViewController *receive = (ReceiveCryptoViewController *) _tabViewController.activeViewController;
        if ([receive legacyAssetType] != assetType) {
            ReceiveCryptoViewController *receiveCryptoViewController = [ReceiveCryptoViewController makeFor:assetType];
            [_tabViewController setActiveViewController:receiveCryptoViewController animated:animated index:(int)[ConstantsObjcBridge tabReceive]];
        }
    } else {
        ReceiveCryptoViewController *receiveCryptoViewController = [ReceiveCryptoViewController makeFor:assetType];
        [_tabViewController setActiveViewController:receiveCryptoViewController animated:animated index:(int)[ConstantsObjcBridge tabReceive]];
    }
}

- (void)clearReceiveAmounts
{
    [self.receiveBitcoinViewController clearAmounts];
}

- (void)didSetDefaultAccount
{
    [self.receiveBitcoinViewController reloadMainAddress];
    [self.receiveBitcoinCashViewController reloadMainAddress];
}

- (void)paymentReceived:(uint64_t)amount showBackupReminder:(BOOL)showBackupReminder
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [_receiveBitcoinViewController paymentReceived:amount showBackupReminder:showBackupReminder];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [_receiveBitcoinCashViewController paymentReceived:amount showBackupReminder:showBackupReminder];
    }
}

- (NSDecimalNumber *)lastEthExchangeRate
{
    return self.latestEthExchangeRate;
}

#pragma mark - Dashboard

- (void)showDashboardAnimated:(BOOL)animated
{
    [_tabViewController setActiveViewController:self.dashboardContainer animated:animated index:[ConstantsObjcBridge tabDashboard]];

    if (self.dashboardContainer.dashboard != nil) {
        [self.dashboardContainer.dashboard setAssetType:self.assetType];
    }
}

#pragma mark - Transactions

- (void)showTransactionsAnimated:(BOOL)animated
{
    int tabIndex = (int)[ConstantsObjcBridge tabTransactions];
    
    switch (self.assetType) {
        case LegacyAssetTypeBitcoin: {
            if (!_transactionsBitcoinViewController) {
                _transactionsBitcoinViewController = [[[NSBundle mainBundle] loadNibNamed:NIB_NAME_TRANSACTIONS owner:self options:nil] firstObject];
            }
            
            [_tabViewController setActiveViewController:_transactionsBitcoinViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeEther: {
            if (!_transactionsEtherViewController) {
                _transactionsEtherViewController = [[TransactionsEthereumViewController alloc] init];
            }
            
            [_tabViewController setActiveViewController:_transactionsEtherViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeBitcoinCash: {
            if (!_transactionsBitcoinCashViewController) {
                _transactionsBitcoinCashViewController = [[TransactionsBitcoinCashViewController alloc] init];
            }
            
            [_tabViewController setActiveViewController:_transactionsBitcoinCashViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeStellar: {
            if (!_transactionsStellarViewController) {
                _transactionsStellarViewController = [TransactionsXlmViewController makeWith:XLMServiceProvider.sharedInstance];
            }
            [_transactionsStellarViewController reload];
            [_tabViewController setActiveViewController:_transactionsStellarViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypePax: {
            if (!_paxActivityViewController) {
                _paxActivityViewController = [PaxActivityViewController make];
            }
            [_tabViewController setActiveViewController:_paxActivityViewController animated:animated index:tabIndex];
            break;
        }
    }
}

- (void)setupBitcoinPaymentFromURLHandlerWithAmountString:(NSString *)amountString address:(NSString *)address
{
    if (!self.sendBitcoinViewController) {
        // really no reason to lazyload anymore...
        _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }

    [_sendBitcoinViewController setAmountStringFromUrlHandler:amountString withToAddress:address];
    [_sendBitcoinViewController reload];
}

- (void)filterTransactionsByAccount:(int)accountIndex filterLabel:(NSString *)filterLabel assetType:(LegacyAssetType)assetType
{
    _transactionsBitcoinViewController.clickedFetchMore = NO;
    _transactionsBitcoinViewController.filterIndex = accountIndex;
    [_transactionsBitcoinViewController changeFilterLabel:filterLabel];
    [_sendBitcoinViewController resetFromAddress];
    [_receiveBitcoinViewController reloadMainAddress];
}

- (void)filterTransactionsByImportedAddresses
{
    _transactionsBitcoinViewController.clickedFetchMore = NO;
    _transactionsBitcoinViewController.filterIndex = [ConstantsObjcBridge filterIndexImportedAddresses];
    [_transactionsBitcoinViewController changeFilterLabel:BC_STRING_IMPORTED_ADDRESSES];
}

- (void)removeTransactionsFilter
{
    _transactionsBitcoinViewController.clickedFetchMore = NO;
    _transactionsBitcoinViewController.filterIndex = [ConstantsObjcBridge filterIndexAll];
}

- (void)selectPayment:(NSString *)payment
{
    [self.transactionsBitcoinViewController selectPayment:payment];
}

- (void)showTransactionDetailForHash:(NSString *)hash
{
    [self.transactionsBitcoinViewController showTransactionDetailForHash:hash];
}

- (void)setTransactionsViewControllerMessageIdentifier:(NSString *)identifier
{
    self.transactionsBitcoinViewController.messageIdentifier = identifier;
}

- (void)selectorButtonClicked
{
    [_transactionsBitcoinViewController showFilterMenu];
}

#pragma mark - Reloading

- (void)reloadSymbols
{
    [self.dashboardContainer.dashboard reloadSymbols];
    [_sendBitcoinViewController reloadSymbols];
    [_sendBitcoinCashViewController reloadSymbols];
    [_transactionsBitcoinViewController reloadSymbols];
    [_transactionsEtherViewController reloadSymbols];
    [_transactionsBitcoinCashViewController reloadSymbols];
    [_tabViewController reloadSymbols];
}

- (void)reloadSendController
{
    [_sendBitcoinViewController reload];
}

- (void)clearSendToAddressAndAmountFields
{
    [self.sendBitcoinViewController clearToAddressAndAmountFields];
}

- (void)enableSendPaymentButtons
{
    [self.sendBitcoinViewController enablePaymentButtons];
}

- (BOOL)isSendViewControllerTransferringAll
{
    return _sendBitcoinViewController.transferAllMode;
}

- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address
{
    if (!_sendBitcoinViewController) {
        _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }

    [_sendBitcoinViewController transferFundsToDefaultAccountFromAddress:address];
}

- (void)hideSendAndReceiveKeyboards
{
    // Dismiss sendviewController keyboard
    if (_sendBitcoinViewController) {
        [_sendBitcoinViewController hideKeyboardForced];

        // Make sure the the send payment button on send screen is enabled (bug when second password requested and app is backgrounded)
        [_sendBitcoinViewController enablePaymentButtons];
    }

    // Dismiss receiveCoinsViewController keyboard
    if (_receiveBitcoinViewController) {
        [_receiveBitcoinViewController hideKeyboardForced];
    }
}

- (void)updateTransactionsViewControllerData:(MultiAddressResponse *)data
{
    [_transactionsBitcoinViewController updateData:data];
}

- (void)didSetLatestBlock:(LatestBlock *)block
{
    _transactionsBitcoinViewController.latestBlock = block;
    [_transactionsBitcoinViewController reload];
}

- (void)didGetMessagesOnFirstLoad
{
    if (_transactionsBitcoinViewController.messageIdentifier) {
        [_transactionsBitcoinViewController selectPayment:_transactionsBitcoinViewController.messageIdentifier];
    }
}

- (void)updateBadgeNumber:(NSInteger)number forSelectedIndex:(int)index
{
    [self.tabViewController updateBadgeNumber:number forSelectedIndex:index];
}

#pragma mark - Navigation

- (void)transitionToIndex:(NSInteger)index
{
    if (index == [ConstantsObjcBridge tabSend]) {
        [self sendCoinsClicked:nil];
    } else if (index == [ConstantsObjcBridge tabDashboard]) {
        [self dashBoardClicked:nil];
    } else if (index == [ConstantsObjcBridge tabTransactions]) {
        [self transactionsClicked:nil];
    } else if (index == [ConstantsObjcBridge tabReceive]) {
        [self receiveCoinClicked:nil];
    }
}

- (IBAction)menuButtonClicked:(UIButton *)sender
{
    if (self.sendBitcoinViewController) {
        [self hideSendKeyboard];
    }
}

- (void)dashBoardClicked:(UITabBarItem *)sender
{
    [self showDashboardAnimated:YES];
}

- (void)receiveCoinClicked:(UITabBarItem *)sender
{
    [self showReceiveAnimated:YES];
}

- (void)swapTapped:(nullable UITabBarItem *)sender
{
    [self.tabViewController setActiveViewController:self.exchangeContainerViewController animated:true index:[ConstantsObjcBridge tabSwap]];
}

- (void)showReceiveBitcoinCash
{
    [self changeAssetSelectorAsset:LegacyAssetTypeBitcoinCash];
    [self showReceiveAnimated:YES];
    [_receiveBitcoinCashViewController reload];
}

- (void)showTransactionsBitcoin
{
    [self changeAssetSelectorAsset:LegacyAssetTypeBitcoin];
    [self showTransactionsAnimated:YES];
    [_transactionsBitcoinViewController reload];
}

- (void)showTransactionsEther
{
    [self changeAssetSelectorAsset:LegacyAssetTypeEther];
    [self showTransactionsAnimated:YES];
    [_transactionsEtherViewController reload];
}

- (void)showTransactionsBitcoinCash
{
    [self changeAssetSelectorAsset:LegacyAssetTypeBitcoinCash];
    [self showTransactionsAnimated:YES];
    [_transactionsBitcoinCashViewController reload];
}

-(void)showTransactionsStellar
{
    [self changeAssetSelectorAsset:LegacyAssetTypeStellar];
    [self showTransactionsAnimated:YES];
    [_transactionsStellarViewController reload];
}

-(void)showTransactionsPax
{
    [self changeAssetSelectorAsset:LegacyAssetTypePax];
    [self showTransactionsAnimated:YES];
}

- (void)changeAssetSelectorAsset:(LegacyAssetType)assetType
{
    self.assetType = assetType;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.assetType] forKey:USER_DEFAULTS_KEY_ASSET_TYPE];
 
    [self.tabViewController selectAsset:assetType];
}

- (void)transactionsClicked:(UITabBarItem *)sender
{
    [self showTransactionsAnimated:YES];

    if (sender &&
        BlockchainSettings.sharedAppInstance.hasEndedFirstSession &&
        ![[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_HAS_SEEN_SURVEY_PROMPT]) {

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM dd, yyyy"];
        NSDate *endSurveyDate = [dateFormat dateFromString:DATE_SURVEY_END];

        if ([endSurveyDate timeIntervalSinceNow] > 0.0) {
            [self performSelector:@selector(showSurveyAlert) withObject:nil afterDelay:ANIMATION_DURATION];
        }
    }
}

- (void)showSurveyAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_SURVEY_ALERT_TITLE message:BC_STRING_SURVEY_ALERT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_YES style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsURL = [NSURL URLWithString:URL_SURVEY];

        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:settingsURL options:@{} completionHandler:nil];

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];

    [self.tabViewController presentViewController:alert animated:YES completion:nil];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_HAS_SEEN_SURVEY_PROMPT];
}

- (void)sendCoinsClicked:(UITabBarItem *)sender
{
    [self showSendCoinsAnimated:YES];
}

- (void)qrCodeButtonClicked
{
    if (_receiveBitcoinViewController) {
        [_receiveBitcoinViewController hideKeyboard];
    }

    UIViewController * _Nullable viewControllerToPresent;
    switch (self.assetType) {
        case LegacyAssetTypeBitcoin: {
            if (!_sendBitcoinViewController) {
                _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
            }
            [_sendBitcoinViewController QRCodebuttonClicked:nil];
            viewControllerToPresent = _sendBitcoinViewController;
            break;
        }
        case LegacyAssetTypeEther: {
            if (!_sendEtherViewController) {
                _sendEtherViewController = [[SendEtherViewController alloc] init];
            }
            [_sendEtherViewController QRCodebuttonClicked:nil];
            viewControllerToPresent = _sendEtherViewController;
            break;
        }
        case LegacyAssetTypeBitcoinCash: {
            if (!_sendBitcoinCashViewController) {
                _sendBitcoinCashViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
                _sendBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
            }
            [_sendBitcoinCashViewController QRCodebuttonClicked:nil];
            viewControllerToPresent = _sendBitcoinCashViewController;
            break;
        }
        case LegacyAssetTypeStellar: {
            // Always creating a new SendLumensViewController for stellar. This is because there is a layout issue
            // when reusing an existing SendLumensViewController wherein after you scan the QR code, the view occupies
            // the full frame, and not the adjusted frame.
            _sendLumensViewController = [SendLumensViewController makeWith:XLMServiceProvider.sharedInstance];
            [_sendLumensViewController scanQrCodeForDestinationAddress];
            viewControllerToPresent = _sendLumensViewController;
            break;
        }
        case LegacyAssetTypePax: {
            // TODO 
            break;
        }
    }
    if (viewControllerToPresent != nil) {
        [_tabViewController setActiveViewController:viewControllerToPresent animated:NO index:[ConstantsObjcBridge tabSend]];
    }
}

/// This callback happens when an Eth account is created. This happens when a user goes to
/// swap for the first time. This is a delegate callback from the JS layer. This needs to be
/// refactored so that it is in a completion handler and only in `ExchangeContainerViewController`
- (void)didCreateEthAccountForExchange
{
    [self.exchangeContainerViewController showExchange];
}

- (void)showGetAssetsAlert
{
    UIAlertController *showGetAssetsAlert = [UIAlertController alertControllerWithTitle:BC_STRING_NO_FUNDS_TO_EXCHANGE_TITLE message:BC_STRING_NO_FUNDS_TO_EXCHANGE_MESSAGE preferredStyle:UIAlertControllerStyleAlert];

    [showGetAssetsAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_GET_BITCOIN style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tabViewController dismissViewControllerAnimated:YES completion:^{
            if ([WalletManager.sharedInstance.wallet isBuyEnabled]) {
                [BuySellCoordinator.sharedInstance showBuyBitcoinView];
            } else {
                [[AppCoordinator sharedInstance] closeSideMenu];
                [self changeAssetSelectorAsset:LegacyAssetTypeBitcoin];
                [self receiveCoinClicked:nil];
            }
        }];
    }]];
    [showGetAssetsAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_GET_ETHER style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tabViewController dismissViewControllerAnimated:YES completion:^{
            [[AppCoordinator sharedInstance] closeSideMenu];
            [self changeAssetSelectorAsset:LegacyAssetTypeEther];
            [self receiveCoinClicked:nil];
        }];
    }]];
    [showGetAssetsAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_GET_BITCOIN_CASH style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tabViewController dismissViewControllerAnimated:YES completion:^{
            [[AppCoordinator sharedInstance] closeSideMenu];
            [self changeAssetSelectorAsset:LegacyAssetTypeBitcoinCash];
            [self receiveCoinClicked:nil];
        }];
    }]];
    [showGetAssetsAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[AppCoordinator sharedInstance] closeSideMenu];
        [self.tabViewController dismissViewControllerAnimated:YES completion:nil];
        [self showDashboardAnimated:YES];
    }]];

    [self.tabViewController.presentedViewController presentViewController:showGetAssetsAlert animated:YES completion:nil];
}

- (ExchangeContainerViewController *)exchangeContainerViewController {
    if (_exchangeContainerViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExchangeContainerViewController" bundle:[NSBundle mainBundle]];
        _exchangeContainerViewController = [storyboard instantiateInitialViewController];
    }
    return _exchangeContainerViewController;
}

- (DashboardContainerViewController *)dashboardContainer {
    if (_dashboardContainer == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DashboardContainerViewController" bundle:[NSBundle mainBundle]];
        _dashboardContainer = [storyboard instantiateInitialViewController];
    }
    return _dashboardContainer;
}

@end
