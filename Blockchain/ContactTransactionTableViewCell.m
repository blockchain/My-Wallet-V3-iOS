//
//  ContactTransactionTableViewCell.m
//  Blockchain
//
//  Created by kevinwu on 1/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ContactTransactionTableViewCell.h"
#import "NSNumberFormatter+Currencies.h"
#import "NSDateFormatter+TimeAgoString.h"
#import "TransactionDetailViewController.h"
#import "TransactionDetailNavigationController.h"
#import "Transaction.h"
#import "TransactionDetailViewModel.h"
#import "RootService.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface ContactTransactionTableViewCell()
@property (nonatomic) BOOL isSetup;
@end
@implementation ContactTransactionTableViewCell

- (void)configureWithTransaction:(ContactTransaction *)transaction contactName:(NSString *)name
{
    self.transaction = transaction;
    
    if (self.isSetup) {
        [self reloadWithTransaction:transaction contactName:name];
        return;
    }
    
    self.accessoryType = UITableViewCellAccessoryNone;
    
    self.statusLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
    
    self.iconImageView.image = nil;
    self.actionImageView.image = nil;
    
    [self reloadWithTransaction:transaction contactName:name];
    
    self.isSetup = YES;
}

- (void)reloadWithTransaction:(ContactTransaction *)transaction contactName:(NSString *)name
{
    NSString *amount = [NSNumberFormatter formatMoney:transaction.intendedAmount];
    [self.amountButton setTitle:amount forState:UIControlStateNormal];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:transaction.lastUpdated];
    NSString *dateString = [NSDateFormatter timeAgoStringFromDate:date];
    self.lastUpdatedLabel.text = dateString;
    
    self.toFromLabel.text = transaction.reason && transaction.reason.length > 0 ? [name stringByAppendingFormat:@" - %@", transaction.reason] : name;
    self.iconImageView.image = [UIImage imageNamed:@"icon_contact_small"];
    self.actionImageView.tintColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    
    if (transaction.transactionState == ContactTransactionStateSendWaitingForQR) {
        self.statusLabel.text = [BC_STRING_CONTACT_TRANSACTION_STATE_WAITING_FOR_QR uppercaseString];
        self.statusLabel.textColor = COLOR_TRANSACTION_SENT;
        self.amountButton.backgroundColor = COLOR_TRANSACTION_SENT;
        self.bottomRightLabel.text = BC_STRING_AWAITING_RESPONSE;
        self.bottomRightLabel.textColor = COLOR_LIGHT_GRAY;
        self.actionImageView.image = nil;
    } else if (transaction.transactionState == ContactTransactionStateReceiveAcceptOrDeclinePayment) {
        self.statusLabel.text = [BC_STRING_CONTACT_TRANSACTION_STATE_ACCEPT_OR_DECLINE_PAYMENT uppercaseString];
        self.statusLabel.textColor = COLOR_TRANSACTION_RECEIVED;
        self.amountButton.backgroundColor = COLOR_TRANSACTION_RECEIVED;
        self.bottomRightLabel.text = BC_STRING_ACCEPT_OR_DECLINE;
        self.bottomRightLabel.textColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
        self.actionImageView.image = [UIImage imageNamed:@"backup_blue_circle"];
    } else if (transaction.transactionState == ContactTransactionStateSendReadyToSend) {
        self.statusLabel.textColor = COLOR_TRANSACTION_SENT;
        self.amountButton.backgroundColor = COLOR_TRANSACTION_SENT;
        if ([transaction.role isEqualToString:TRANSACTION_ROLE_PR_RECEIVER]) {
            self.statusLabel.text = [BC_STRING_CONTACT_TRANSACTION_STATE_READY_TO_SEND_RECEIVER uppercaseString];
            self.bottomRightLabel.text = BC_STRING_PAY_OR_DECLINE;
        } else {
            self.statusLabel.text = [BC_STRING_CONTACT_TRANSACTION_STATE_READY_TO_SEND_INITIATOR uppercaseString];
            self.bottomRightLabel.text = BC_STRING_READY_TO_SEND;
        }
        self.bottomRightLabel.textColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
        self.actionImageView.image = [UIImage imageNamed:@"backup_blue_circle"];
    } else if (transaction.transactionState == ContactTransactionStateReceiveWaitingForPayment) {
        self.statusLabel.text = [transaction.role isEqualToString:TRANSACTION_ROLE_PR_INITIATOR] ?  [BC_STRING_CONTACT_TRANSACTION_STATE_WAITING_FOR_PAYMENT_PAYMENT_REQUEST uppercaseString] : [BC_STRING_CONTACT_TRANSACTION_STATE_WAITING_FOR_PAYMENT_REQUEST_PAYMENT_REQUEST uppercaseString];
        self.statusLabel.textColor = COLOR_TRANSACTION_RECEIVED;
        self.amountButton.backgroundColor = COLOR_TRANSACTION_RECEIVED;
        self.bottomRightLabel.text = [transaction.role isEqualToString:TRANSACTION_ROLE_PR_INITIATOR] ? BC_STRING_PAYMENT_REQUESTED : BC_STRING_WAITING_FOR_PAYMENT;
        self.bottomRightLabel.textColor = COLOR_LIGHT_GRAY;
        self.actionImageView.image = nil;
    } else if (transaction.transactionState == ContactTransactionStateCompletedSend) {
        self.toFromLabel.text = name;
        self.statusLabel.text = [transaction.role isEqualToString:TRANSACTION_ROLE_RPR_INITIATOR] ? [BC_STRING_SENT uppercaseString] : [BC_STRING_PAID uppercaseString];
        self.statusLabel.textColor = COLOR_TRANSACTION_SENT;
        self.amountButton.backgroundColor = COLOR_TRANSACTION_SENT;
        self.bottomRightLabel.text = transaction.reason;
        self.bottomRightLabel.textColor = COLOR_LIGHT_GRAY;
        self.actionImageView.image = nil;
    } else if (transaction.transactionState == ContactTransactionStateCompletedReceive) {
        self.toFromLabel.text = name;
        self.statusLabel.text = [BC_STRING_RECEIVED uppercaseString];
        self.statusLabel.textColor = COLOR_TRANSACTION_RECEIVED;
        self.amountButton.backgroundColor = COLOR_TRANSACTION_RECEIVED;
        self.bottomRightLabel.text = transaction.reason;
        self.bottomRightLabel.textColor = COLOR_LIGHT_GRAY;
        self.actionImageView.image = nil;
    } else if (transaction.transactionState == ContactTransactionStateDeclined) {
        if ([transaction.role isEqualToString:TRANSACTION_ROLE_PR_INITIATOR] || [transaction.role isEqualToString:TRANSACTION_ROLE_RPR_RECEIVER]) {
            self.statusLabel.text = [BC_STRING_RECEIVING uppercaseString];
            self.statusLabel.textColor = COLOR_TRANSACTION_RECEIVED;
            self.amountButton.backgroundColor = COLOR_TRANSACTION_RECEIVED;
        } else {
            self.statusLabel.text = [BC_STRING_SENDING uppercaseString];
            self.statusLabel.textColor = COLOR_TRANSACTION_SENT;
            self.amountButton.backgroundColor = COLOR_TRANSACTION_SENT;
        }
        self.bottomRightLabel.text = BC_STRING_DECLINED;
        self.bottomRightLabel.textColor = COLOR_BLOCKCHAIN_RED;
        self.actionImageView.image = nil;
    } else if (transaction.transactionState == ContactTransactionStateCancelled) {
        if ([transaction.role isEqualToString:TRANSACTION_ROLE_PR_INITIATOR] || [transaction.role isEqualToString:TRANSACTION_ROLE_RPR_RECEIVER]) {
            self.statusLabel.text = [BC_STRING_RECEIVING uppercaseString];
            self.statusLabel.textColor = COLOR_TRANSACTION_RECEIVED;
            self.amountButton.backgroundColor = COLOR_TRANSACTION_RECEIVED;
        } else {
            self.statusLabel.text = [BC_STRING_SENDING uppercaseString];
            self.statusLabel.textColor = COLOR_TRANSACTION_SENT;
            self.amountButton.backgroundColor = COLOR_TRANSACTION_SENT;
        }
        self.bottomRightLabel.text = BC_STRING_CANCELLED;
        self.bottomRightLabel.textColor = COLOR_BLOCKCHAIN_RED;
        self.actionImageView.image = nil;
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"state: %@ role: %@", transaction.state, transaction.role];
    }

    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)transactionClicked:(UIButton *)button
{
    Contact *contact = [app.wallet.contacts objectForKey:self.transaction.contactIdentifier];
    
    if (self.transaction.transactionState == ContactTransactionStateReceiveAcceptOrDeclinePayment) {
        [self.delegate acceptOrDeclinePayment:self.transaction forContact:contact];
    } else if (self.transaction.transactionState == ContactTransactionStateSendReadyToSend) {
        [self.delegate sendPayment:self.transaction toContact:contact];
    } else if (self.transaction.transactionState == ContactTransactionStateSendWaitingForQR) {
        [self.delegate promptCancelPayment:self.transaction forContact:contact];
    } else if (self.transaction.transactionState == ContactTransactionStateReceiveWaitingForPayment) {
        if ([self.transaction.role isEqualToString:TRANSACTION_ROLE_PR_INITIATOR]) {
            [self.delegate promptCancelPayment:self.transaction forContact:contact];
        } else {
            [self.delegate promptDeclinePayment:self.transaction forContact:contact];
        }
    } else if (self.transaction.transactionState == ContactTransactionStateCompletedSend || self.transaction.transactionState == ContactTransactionStateCompletedReceive) {
        
        TransactionDetailViewController *detailViewController = [TransactionDetailViewController new];
        detailViewController.transactionModel = [[TransactionDetailViewModel alloc] initWithTransaction:self.transaction];
        
        TransactionDetailNavigationController *navigationController = [[TransactionDetailNavigationController alloc] initWithRootViewController:detailViewController];

        TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;

        detailViewController.busyViewDelegate = navigationController;
        navigationController.onDismiss = ^() {
            tabControllerManager.transactionsBitcoinViewController.detailViewController = nil;
        };
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        tabControllerManager.transactionsBitcoinViewController.detailViewController = detailViewController;

        UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;
        [topViewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (IBAction)amountButtonClicked:(UIButton *)sender
{
    [self transactionClicked:nil];
}

@end
