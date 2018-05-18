//
//  TabControllerManager.m
//  Blockchain
//
//  Created by kevinwu on 8/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TabControllerManager.h"
#import "BCNavigationController.h"
#import "Transaction.h"
#import "Blockchain-Swift.h"

@interface TabControllerManager () <WalletSettingsDelegate>
@end
@implementation TabControllerManager

- (instancetype)init
{
    if (self == [super init]) {
        self.tabViewController = [[[NSBundle mainBundle] loadNibNamed:NIB_NAME_TAB_CONTROLLER owner:self options:nil] firstObject];
        self.tabViewController.assetDelegate = self;
        
        NSInteger assetType = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_ASSET_TYPE] integerValue];
        self.assetType = assetType;
        [self.tabViewController.assetSelectorView setSelectedAsset:assetType];
        
        [WalletManager sharedInstance].settingsDelegate = self;
    }
    return self;
}

- (void)didSetAssetType:(LegacyAssetType)assetType
{
    self.assetType = assetType;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.assetType] forKey:USER_DEFAULTS_KEY_ASSET_TYPE];
    
    BOOL animated = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tabViewController.selectedIndex == TAB_SEND) {
            [self showSendCoinsAnimated:animated];
        } else if (self.tabViewController.selectedIndex == TAB_DASHBOARD) {
            [self showDashboardAnimated:animated];
        } else if (self.tabViewController.selectedIndex == TAB_TRANSACTIONS) {
            [self showTransactionsAnimated:animated];
        } else if (self.tabViewController.selectedIndex == TAB_RECEIVE) {
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

#pragma mark - Reloading

- (void)reload
{
    [_dashboardViewController reload];
    [_sendBitcoinViewController reload];
    [_sendEtherViewController reload];
    [_sendBitcoinCashViewController reload];
    [_transactionsBitcoinViewController reload];
    [_transactionsEtherViewController reload];
    [_transactionsBitcoinCashViewController reload];
    [_receiveBitcoinViewController reload];
    [_receiveEtherViewController reload];
    [_receiveBitcoinCashViewController reload];
}

- (void)reloadAfterMultiAddressResponse
{
    [_dashboardViewController reload];
    [_sendBitcoinViewController reloadAfterMultiAddressResponse];
    [_sendEtherViewController reloadAfterMultiAddressResponse];
    [_sendBitcoinCashViewController reloadAfterMultiAddressResponse];
    [_transactionsBitcoinViewController reload];
    [_receiveBitcoinViewController reload];
    [_receiveEtherViewController reload];
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
    
    [self dashBoardClicked:nil];
}

- (void)forgetWallet
{
    self.receiveBitcoinViewController = nil;
    self.receiveEtherViewController = nil;
    self.receiveBitcoinCashViewController = nil;
    [_transactionsBitcoinViewController setData:nil];
}

#pragma mark - BTC Send

- (BOOL)isSending
{
    return self.sendBitcoinViewController.isSending;
}

- (void)showSendCoinsAnimated:(BOOL)animated
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        if (!_sendBitcoinViewController) {
            _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
        }
        
        [_tabViewController setActiveViewController:_sendBitcoinViewController animated:animated index:TAB_SEND];
    } else if (self.assetType == LegacyAssetTypeEther) {
        if (!_sendEtherViewController) {
            _sendEtherViewController = [[SendEtherViewController alloc] init];
        }
        
        [_tabViewController setActiveViewController:_sendEtherViewController animated:animated index:TAB_SEND];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        if (!_sendBitcoinCashViewController) {
            _sendBitcoinCashViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
            _sendBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
        }
        
        [_tabViewController setActiveViewController:_sendBitcoinCashViewController animated:animated index:TAB_SEND];
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

- (void)sendFromWatchOnlyAddress
{
    [_sendBitcoinViewController sendFromWatchOnlyAddress];
}

- (void)didCheckForOverSpending:(NSNumber *)amount fee:(NSNumber *)fee
{
    [_sendBitcoinViewController didCheckForOverSpending:amount fee:fee];
}

- (void)didGetMaxFee:(NSNumber *)fee amount:(NSNumber *)amount dust:(NSNumber *)dust willConfirm:(BOOL)willConfirm
{
    [_sendBitcoinViewController didGetMaxFee:fee amount:amount dust:dust willConfirm:willConfirm];
}

- (void)didUpdateTotalAvailable:(NSNumber *)sweepAmount finalFee:(NSNumber *)finalFee
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [_sendBitcoinViewController didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [_sendBitcoinCashViewController didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
    }
}

- (void)didGetFee:(NSNumber *)fee dust:(NSNumber *)dust txSize:(NSNumber *)txSize
{
    [_sendBitcoinViewController didGetFee:fee dust:dust txSize:txSize];
}

- (void)didChangeSatoshiPerByte:(NSNumber *)sweepAmount fee:(NSNumber *)fee dust:(NSNumber *)dust updateType:(FeeUpdateType)updateType
{
    [_sendBitcoinViewController didChangeSatoshiPerByte:sweepAmount fee:fee dust:dust updateType:updateType];
}

- (void)didGetSurgeStatus:(BOOL)surgeStatus
{
    _sendBitcoinViewController.surgeIsOccurring = surgeStatus;
}

- (void)updateSendBalance:(NSNumber *)balance fees:(NSDictionary *)fees
{
    [_sendBitcoinViewController updateSendBalance:balance fees:fees];
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

- (void)updateLoadedAllTransactions:(NSNumber *)loadedAll
{
    _transactionsBitcoinViewController.loadedAllTransactions = [loadedAll boolValue];
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
            Transaction *transaction = [[WalletManager.sharedInstance.wallet getBitcoinCashTransactions:FILTER_INDEX_ALL] firstObject];
            [_receiveBitcoinCashViewController paymentReceived:ABS(transaction.amount) showBackupReminder:NO];
        }
    }
}

#pragma mark - Eth Send

- (void)didUpdateEthPayment:(NSDictionary *)ethPayment
{
    [_sendEtherViewController didUpdatePayment:ethPayment];
}

- (void)didSendEther
{
    [self.sendEtherViewController reload];
    [self.tabViewController didSendEther];
    [self showTransactionsAnimated:YES];
}

- (void)didErrorDuringEtherSend:(NSString *)error
{
    [self.tabViewController didErrorDuringEtherSend:error];
}

- (void)didFetchEthExchangeRate:(NSNumber *)rate
{
    self.latestEthExchangeRate = [NSDecimalNumber decimalNumberWithDecimal:[rate decimalValue]];

    [self.tabViewController didFetchEthExchangeRate];
    [_sendEtherViewController updateExchangeRate:self.latestEthExchangeRate];
    [_dashboardViewController updateEthExchangeRate:self.latestEthExchangeRate];
}

#pragma mark - Receive

- (void)showReceiveAnimated:(BOOL)animated
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        if (!_receiveBitcoinViewController) {
            _receiveBitcoinViewController = [[ReceiveBitcoinViewController alloc] initWithNibName:NIB_NAME_RECEIVE_COINS bundle:[NSBundle mainBundle]];
        }
        
        [_tabViewController setActiveViewController:_receiveBitcoinViewController animated:animated index:TAB_RECEIVE];
    } else if (self.assetType == LegacyAssetTypeEther) {
        if (!_receiveEtherViewController) {
            _receiveEtherViewController = [[ReceiveEtherViewController alloc] init];
        }
        
        [_tabViewController setActiveViewController:_receiveEtherViewController animated:animated index:TAB_RECEIVE];
        [_receiveEtherViewController showEtherAddress];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        if (!_receiveBitcoinCashViewController) {
            _receiveBitcoinCashViewController = [[ReceiveBitcoinViewController alloc] initWithNibName:NIB_NAME_RECEIVE_COINS bundle:[NSBundle mainBundle]];
            _receiveBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
        }
        
        [_tabViewController setActiveViewController:_receiveBitcoinCashViewController animated:animated index:TAB_RECEIVE];
    }
}

- (void)didGetEtherAddressWithSecondPassword
{
    [_receiveEtherViewController showEtherAddress];
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
    if (!_dashboardViewController) {
        DashboardViewController *dashboardViewController = [DashboardViewController new];
        self.dashboardViewController = dashboardViewController;
    }
    
    [_tabViewController setActiveViewController:self.dashboardViewController animated:animated index:TAB_DASHBOARD];
    
    self.dashboardViewController.assetType = self.assetType;
}

#pragma mark - Transactions

- (void)showTransactionsAnimated:(BOOL)animated
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        if (!_transactionsBitcoinViewController) {
            _transactionsBitcoinViewController = [[[NSBundle mainBundle] loadNibNamed:NIB_NAME_TRANSACTIONS owner:self options:nil] firstObject];
        }
        
        [_tabViewController setActiveViewController:_transactionsBitcoinViewController animated:animated index:TAB_TRANSACTIONS];
    } else if (self.assetType == LegacyAssetTypeEther) {
        if (!_transactionsEtherViewController) {
            _transactionsEtherViewController = [[TransactionsEtherViewController alloc] init];
        }
        
        [_tabViewController setActiveViewController:_transactionsEtherViewController animated:animated index:TAB_TRANSACTIONS];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        if (!_transactionsBitcoinCashViewController) {
            _transactionsBitcoinCashViewController = [[TransactionsBitcoinCashViewController alloc] init];
        }
        
        [_tabViewController setActiveViewController:_transactionsBitcoinCashViewController animated:animated index:TAB_TRANSACTIONS];
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

- (NSInteger)getFilterIndex
{
    return _transactionsBitcoinViewController.filterIndex;
}

- (void)filterTransactionsByImportedAddresses
{
    _transactionsBitcoinViewController.clickedFetchMore = NO;
    _transactionsBitcoinViewController.filterIndex = FILTER_INDEX_IMPORTED_ADDRESSES;
    [_transactionsBitcoinViewController changeFilterLabel:BC_STRING_IMPORTED_ADDRESSES];
}

- (void)removeTransactionsFilter
{
    _transactionsBitcoinViewController.clickedFetchMore = NO;
    _transactionsBitcoinViewController.filterIndex = FILTER_INDEX_ALL;
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
    [_sendBitcoinViewController reloadSymbols];
    [_sendBitcoinCashViewController reloadSymbols];
    [_transactionsBitcoinViewController reloadSymbols];
    [_transactionsEtherViewController reloadSymbols];
    [_transactionsBitcoinCashViewController reloadSymbols];
    [_tabViewController reloadSymbols];
    [_exchangeOverviewViewController reloadSymbols];
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
    if (index == TAB_SEND) {
        [self sendCoinsClicked:nil];
    } else if (index == TAB_DASHBOARD) {
        [self dashBoardClicked:nil];
    } else if (index == TAB_TRANSACTIONS) {
        [self transactionsClicked:nil];
    } else if (index == TAB_RECEIVE) {
        [self receiveCoinClicked:nil];
    }
}

- (IBAction)menuButtonClicked:(UIButton *)sender
{
    if (self.sendBitcoinViewController) {
        [self hideSendKeyboard];
    }
    
    [self.delegate toggleSideMenu];
}

- (void)dashBoardClicked:(UITabBarItem *)sender
{
    [self showDashboardAnimated:YES];
}

- (void)receiveCoinClicked:(UITabBarItem *)sender
{
    [self showReceiveAnimated:YES];
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

- (void)changeAssetSelectorAsset:(LegacyAssetType)assetType
{
    self.assetType = assetType;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.assetType] forKey:USER_DEFAULTS_KEY_ASSET_TYPE];
    
    self.tabViewController.assetSelectorView.selectedAsset = self.assetType;
    [self.tabViewController.assetSelectorView reload];
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
        [[UIApplication sharedApplication] openURL:settingsURL];
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
    
    if (self.assetType == LegacyAssetTypeBitcoin) {
        if (!_sendBitcoinViewController) {
            _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
        }
        
        [_sendBitcoinViewController QRCodebuttonClicked:nil];
        
        [_tabViewController setActiveViewController:_sendBitcoinViewController animated:NO index:TAB_SEND];
    } else if (self.assetType == LegacyAssetTypeEther) {
        if (!_sendEtherViewController) {
            _sendEtherViewController = [[SendEtherViewController alloc] init];
        }
        
        [_sendEtherViewController QRCodebuttonClicked:nil];
        
        [_tabViewController setActiveViewController:_sendEtherViewController animated:NO index:TAB_SEND];
    } else {
        if (!_sendBitcoinCashViewController) {
            _sendBitcoinCashViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
            _sendBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
        }
        
        [_sendBitcoinCashViewController QRCodebuttonClicked:nil];
        
        [_tabViewController setActiveViewController:_sendBitcoinCashViewController animated:NO index:TAB_SEND];
    }
}

- (void)exchangeClicked
{
    if ([WalletManager.sharedInstance.wallet hasEthAccount]) {
        self.exchangeOverviewViewController = [ExchangeOverviewViewController new];
        BCNavigationController *navigationController = [[BCNavigationController alloc] initWithRootViewController:self.exchangeOverviewViewController title:BC_STRING_EXCHANGE];
        [self.tabViewController presentViewController:navigationController animated:YES completion:nil];
    } else {
        if ([WalletManager.sharedInstance.wallet needsSecondPassword]) {
            [AuthenticationCoordinator.shared showPasswordConfirmWithDisplayText:BC_STRING_ETHER_ACCOUNT_SECOND_PASSWORD_PROMPT headerText:LocalizationConstantsObjcBridge.secondPasswordRequired validateSecondPassword:YES confirmHandler:^(NSString * _Nonnull secondPassword) {
                [WalletManager.sharedInstance.wallet createEthAccountForExchange:secondPassword];
            }];
        } else {
            [WalletManager.sharedInstance.wallet createEthAccountForExchange:nil];
        }
    }
}

- (void)didCreateEthAccountForExchange
{
    [self exchangeClicked];
}

- (void)didGetExchangeTrades:(NSArray *)trades
{
    [self.exchangeOverviewViewController didGetExchangeTrades:trades];
}

- (void)didGetExchangeRate:(NSDictionary *)result
{
    [self.exchangeOverviewViewController didGetExchangeRate:result];
}

- (void)didGetAvailableEthBalance:(NSDictionary *)result
{
    [self.exchangeOverviewViewController didGetAvailableEthBalance:result];
}

- (void)didGetAvailableBtcBalance:(NSDictionary *)result
{
    [self.exchangeOverviewViewController didGetAvailableBtcBalance:result];
}

- (void)didBuildExchangeTrade:(NSDictionary *)tradeInfo
{
    [self.exchangeOverviewViewController didBuildExchangeTrade:tradeInfo];
}

- (void)didShiftPayment:(NSDictionary *)info
{
    [self.exchangeOverviewViewController didShiftPayment:info];
}

- (void)showGetAssetsAlert
{
    UIAlertController *showGetAssetsAlert = [UIAlertController alertControllerWithTitle:BC_STRING_NO_FUNDS_TO_EXCHANGE_TITLE message:BC_STRING_NO_FUNDS_TO_EXCHANGE_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    
    [showGetAssetsAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_GET_BITCOIN style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.tabViewController dismissViewControllerAnimated:YES completion:^{
            if ([WalletManager.sharedInstance.wallet isBuyEnabled]) {
                [AppCoordinator.sharedInstance showBuyBitcoinView];
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

@end
