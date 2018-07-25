//
//  TransactionsBitcoinCashViewController.h
//  Blockchain
//
//  Created by kevinwu on 2/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionsViewController.h"
@class TransactionDetailViewController;
@interface TransactionsBitcoinCashViewController : TransactionsViewController
@property(nonatomic) TransactionDetailViewController *detailViewController;
- (void)reload;
- (void)reloadSymbols;
- (void)didReceiveTransactionMessage;
@end
