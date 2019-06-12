//
//  TransactionTableCell.m
//  Blockchain
//
//  Created by Ben Reeves on 10/01/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionTableCell.h"
#import "Transaction.h"
#import "TransactionsBitcoinViewController.h"
#import "TransactionDetailViewController.h"
#import "TransactionDetailNavigationController.h"
#import "NSDateFormatter+TimeAgoString.h"
#import "Blockchain-Swift.h"
#import "NSNumberFormatter+Currencies.h"
#import "UIView+ChangeFrameAttribute.h"

@implementation TransactionTableCell

@synthesize transaction;

- (void)awakeFromNib
{
    [super awakeFromNib];
    amountButton.userInteractionEnabled = NO;

    // Accessibility labels
    amountButton.accessibilityIdentifier = AccessibilityIdentifiers_TransactionListItem.amount;
    dateLabel.accessibilityIdentifier = AccessibilityIdentifiers_TransactionListItem.date;
    infoLabel.accessibilityIdentifier = AccessibilityIdentifiers_TransactionListItem.info;
    actionLabel.accessibilityIdentifier = AccessibilityIdentifiers_TransactionListItem.action;
    warningImageView.accessibilityIdentifier = AccessibilityIdentifiers_TransactionListItem.warning;
}

- (void)reload
{
    if (transaction == NULL)
        return;
    
    if (transaction.time > 0)  {
        dateLabel.adjustsFontSizeToFitWidth = YES;
        dateLabel.hidden = NO;
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:transaction.time];
        
        dateLabel.text = [NSDateFormatter timeAgoStringFromDate:date];
    } else {
        dateLabel.hidden = YES;
    }
    
    amountButton.titleLabel.minimumScaleFactor =  0.75f;
    [amountButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [amountButton setTitle:[NSNumberFormatter formatMoney:ABS(transaction.amount)] forState:UIControlStateNormal];
    
    [self setTxType:transaction.txType];
    
    infoLabel.adjustsFontSizeToFitWidth = YES;
    infoLabel.layer.cornerRadius = 5;
    infoLabel.layer.borderWidth = 1;
    infoLabel.clipsToBounds = YES;
    infoLabel.customEdgeInsets = [ConstantsObjcBridge infoLabelEdgeInsets];
    infoLabel.hidden = NO;

    actionLabel.frame = CGRectMake(actionLabel.frame.origin.x, 20, actionLabel.frame.size.width, actionLabel.frame.size.height);
    dateLabel.frame = CGRectMake(dateLabel.frame.origin.x, 3, dateLabel.frame.size.width, dateLabel.frame.size.height);

    if ((([transaction.txType isEqualToString:TX_TYPE_RECEIVED] || [transaction.txType isEqualToString:TX_TYPE_TRANSFER]) && transaction.toWatchOnly) || ([transaction.txType isEqualToString:TX_TYPE_SENT] && transaction.fromWatchOnly)) {
        [self setInfoType:TransactionInfoTypeNonSpendable];
    } else if ([WalletManager.sharedInstance.wallet isDepositTransaction:transaction.myHash]) {
        [self setInfoType:TransactionInfoTypeShapeshiftSend];
    } else if ([WalletManager.sharedInstance.wallet isWithdrawalTransaction:transaction.myHash]) {
        [self setInfoType:TransactionInfoTypeShapeshiftReceive];
    } else {
        [self setInfoType:TransactionInfoTypeDefault];
    }
    
    [infoLabel sizeToFit];
    
    warningImageView.image = [warningImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [warningImageView setTintColor:UIColor.error];
    
    if ((transaction.doubleSpend || transaction.replaceByFee) && transaction.confirmations < 1) {
        warningImageView.hidden = NO;
        actionLabel.frame = CGRectMake(actionLabel.frame.origin.x, actionLabel.frame.origin.y, 152, actionLabel.frame.size.height);
        dateLabel.frame = CGRectMake(dateLabel.frame.origin.x, dateLabel.frame.origin.y, 152, dateLabel.frame.size.height);
    } else {
        warningImageView.hidden = YES;
        actionLabel.frame = CGRectMake(actionLabel.frame.origin.x, actionLabel.frame.origin.y, 172, actionLabel.frame.size.height);
        dateLabel.frame = CGRectMake(dateLabel.frame.origin.x, dateLabel.frame.origin.y, 172, dateLabel.frame.size.height);
    }
    
    if (transaction.confirmations >= kConfirmationBitcoinThreshold) {
        amountButton.alpha = 1;
        actionLabel.alpha = 1;
    } else {
        amountButton.alpha = 0.5;
        actionLabel.alpha = 0.5;
    }
    
    dateLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? [[NSNumber numberWithFloat:FONT_SIZE_EXTRA_SMALL] longLongValue] - [[NSNumber numberWithFloat:2.0] longLongValue] : FONT_SIZE_EXTRA_SMALL];
    actionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? [[NSNumber numberWithFloat:FONT_SIZE_MEDIUM_LARGE] longLongValue] - [[NSNumber numberWithFloat:2.0] longLongValue] : FONT_SIZE_MEDIUM_LARGE];
    amountButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size: IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? [[NSNumber numberWithFloat:FONT_SIZE_SMALL_MEDIUM] longLongValue] - [[NSNumber numberWithFloat:3.0] longLongValue] : FONT_SIZE_SMALL_MEDIUM];
    amountButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    
}

#pragma mark button interactions

- (IBAction)transactionClicked:(UIButton * _Nullable)button
{
    TransactionDetailViewController *detailViewController = [TransactionDetailViewController new];
    detailViewController.transactionModel = [[TransactionDetailViewModel alloc] initWithTransaction:transaction];
    
    TransactionDetailNavigationController *navigationController = [[TransactionDetailNavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.transactionHash = transaction.myHash;

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

- (void)bitcoinCashTransactionClicked
{
    TransactionDetailViewController *detailViewController = [TransactionDetailViewController new];
    detailViewController.transactionModel = [[TransactionDetailViewModel alloc] initWithBitcoinCashTransaction:transaction];
    
    TransactionDetailNavigationController *navigationController = [[TransactionDetailNavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.transactionHash = transaction.myHash;

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;

    detailViewController.busyViewDelegate = navigationController;
    navigationController.onDismiss = ^() {
        tabControllerManager.transactionsBitcoinCashViewController.detailViewController = nil;
    };
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    tabControllerManager.transactionsBitcoinCashViewController.detailViewController = detailViewController;

    UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Helpers

- (void)setDateLabelText:(NSString *)text
{
    dateLabel.text = text;
}

- (void)setButtonText:(NSString *)text
{
    [amountButton setTitle:text forState:UIControlStateNormal];
}

- (void)setInfoLabelText:(NSString *)text
{
    infoLabel.text = text;
}

- (void)setTxType:(NSString *)txType
{
    if([txType isEqualToString:TX_TYPE_TRANSFER]) {
        [amountButton setBackgroundColor:UIColor.grayBlue];
        actionLabel.text = [BC_STRING_TRANSFERRED uppercaseString];
        actionLabel.textColor = UIColor.grayBlue;
    } else if ([txType isEqualToString:TX_TYPE_RECEIVED]) {
        [amountButton setBackgroundColor:UIColor.aqua];
        actionLabel.text = [BC_STRING_RECEIVED uppercaseString];
        actionLabel.textColor = UIColor.aqua;
    } else {
        [amountButton setBackgroundColor:UIColor.red];
        actionLabel.text = [BC_STRING_SENT uppercaseString];
        actionLabel.textColor = UIColor.red;
    }
}

- (void)setInfoType:(TransactionInfoType)type
{
    switch (type) {
        case TransactionInfoTypeNonSpendable: {
            infoLabel.font = [UIFont fontWithName:[ConstantsObjcBridge montserratLight] size:infoLabel.font.pointSize];
            infoLabel.text = [LocalizationConstantsObjcBridge nonSpendable];
            infoLabel.textColor = UIColor.gray5;
            infoLabel.backgroundColor = UIColor.gray6;
            infoLabel.layer.borderColor = UIColor.gray2.CGColor;
            break;
        }
        case TransactionInfoTypeShapeshiftSend: {
            infoLabel.font = [UIFont fontWithName:[ConstantsObjcBridge montserratSemiBold] size:infoLabel.font.pointSize];
            infoLabel.text = BC_STRING_DEPOSITED_TO_SHAPESHIFT;
            infoLabel.textColor = [UIColor whiteColor];
            infoLabel.backgroundColor = UIColor.brandPrimary;
            infoLabel.layer.borderColor = [UIColor.brandPrimary CGColor];
            break;
        }
        case TransactionInfoTypeShapeshiftReceive: {
            infoLabel.font = [UIFont fontWithName:[ConstantsObjcBridge montserratSemiBold] size:infoLabel.font.pointSize];
            infoLabel.text = BC_STRING_RECEIVED_FROM_SHAPESHIFT;
            infoLabel.textColor = [UIColor whiteColor];
            infoLabel.backgroundColor = UIColor.brandPrimary;
            infoLabel.layer.borderColor = [UIColor.brandPrimary CGColor];
            break;
        }
        case TransactionInfoTypeDefault: {
            infoLabel.hidden = YES;
            actionLabel.frame = CGRectMake(actionLabel.frame.origin.x, 29, actionLabel.frame.size.width, actionLabel.frame.size.height);
            dateLabel.frame = CGRectMake(dateLabel.frame.origin.x, 11, dateLabel.frame.size.width, dateLabel.frame.size.height);
            break;
        }
    }
}

@end
