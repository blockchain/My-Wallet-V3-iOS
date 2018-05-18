//
//  TransactionEtherTableViewCell.m
//  Blockchain
//
//  Created by kevinwu on 8/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionEtherTableViewCell.h"
#import "EtherTransaction.h"
#import "NSDateFormatter+TimeAgoString.h"
#import "TransactionDetailViewController.h"
#import "TransactionDetailNavigationController.h"
#import "RootService.h"
#import "Blockchain-Swift.h"

@implementation TransactionEtherTableViewCell

- (void)reload
{
    if (self.transaction == NULL) return;
    
    if (self.transaction.time > 0) {
        self.dateLabel.adjustsFontSizeToFitWidth = YES;
        self.dateLabel.hidden = NO;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.transaction.time];
        self.dateLabel.text = [NSDateFormatter timeAgoStringFromDate:date];
    } else {
        self.dateLabel.hidden = YES;
    }
    
    if (self.transaction.confirmations >= kConfirmationEtherThreshold) {
        self.ethButton.alpha = 1;
        self.actionLabel.alpha = 1;
    } else {
        self.ethButton.alpha = 0.5;
        self.actionLabel.alpha = 0.5;
    }

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    self.ethButton.titleLabel.minimumScaleFactor = 0.75f;
    self.ethButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.ethButton setTitle:BlockchainSettings.sharedAppInstance.symbolLocal ? [NSNumberFormatter formatEthToFiatWithSymbol:self.transaction.amount exchangeRate:tabControllerManager.latestEthExchangeRate] : [NSNumberFormatter formatEth: self.transaction.amountTruncated] forState:UIControlStateNormal];
    [self.ethButton addTarget:self action:@selector(ethButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.transaction.txType isEqualToString:TX_TYPE_TRANSFER]) {
        [self.ethButton setBackgroundColor:COLOR_TRANSACTION_TRANSFERRED];
        self.actionLabel.text = [BC_STRING_TRANSFERRED uppercaseString];
        self.actionLabel.textColor = COLOR_TRANSACTION_TRANSFERRED;
    } else if ([self.transaction.txType isEqualToString:TX_TYPE_RECEIVED]) {
        [self.ethButton setBackgroundColor:COLOR_TRANSACTION_RECEIVED];
        self.actionLabel.text = [BC_STRING_RECEIVED uppercaseString];
        self.actionLabel.textColor = COLOR_TRANSACTION_RECEIVED;
    } else {
        [self.ethButton setBackgroundColor:COLOR_TRANSACTION_SENT];
        self.actionLabel.text = [BC_STRING_SENT uppercaseString];
        self.actionLabel.textColor = COLOR_TRANSACTION_SENT;
    }
    
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
    self.infoLabel.layer.cornerRadius = 5;
    self.infoLabel.clipsToBounds = YES;
    self.infoLabel.customEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    self.infoLabel.hidden = NO;
    
    self.actionLabel.frame = CGRectMake(self.actionLabel.frame.origin.x, 20, self.actionLabel.frame.size.width, self.actionLabel.frame.size.height);
    self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, 3, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
    
    if ([WalletManager.sharedInstance.wallet isDepositTransaction:self.transaction.myHash]) {
        self.infoLabel.text = BC_STRING_DEPOSITED_TO_SHAPESHIFT;
        self.infoLabel.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    } else if ([WalletManager.sharedInstance.wallet isWithdrawalTransaction:self.transaction.myHash]) {
        self.infoLabel.text = BC_STRING_RECEIVED_FROM_SHAPESHIFT;
        self.infoLabel.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    } else {
        self.infoLabel.hidden = YES;
        self.actionLabel.frame = CGRectMake(self.actionLabel.frame.origin.x, 29, self.actionLabel.frame.size.width, self.actionLabel.frame.size.height);
        self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, 11, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
    }
    
    [self.infoLabel sizeToFit];
}

- (void)transactionClicked
{
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    TransactionDetailViewController *detailViewController = [TransactionDetailViewController new];
    TransactionDetailViewModel *model = [[TransactionDetailViewModel alloc] initWithEtherTransaction:self.transaction exchangeRate:tabControllerManager.latestEthExchangeRate defaultAddress:[WalletManager.sharedInstance.wallet getEtherAddress]];
    detailViewController.transactionModel = model;

    TransactionDetailNavigationController *navigationController = [[TransactionDetailNavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.transactionHash = model.myHash;
    
    detailViewController.busyViewDelegate = navigationController;
    navigationController.onDismiss = ^() {
        tabControllerManager.transactionsEtherViewController.detailViewController = nil;
    };
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    tabControllerManager.transactionsEtherViewController.detailViewController = detailViewController;

    UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)ethButtonClicked
{
    [self transactionClicked];
}

@end
