//
//  EtherTransactionsViewController.h
//  Blockchain
//
//  Created by kevinwu on 8/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionsViewController.h"
@class TransactionDetailViewController;
@interface TransactionsEtherViewController : TransactionsViewController
@property(nonatomic) TransactionDetailViewController *detailViewController;
- (void)reload;
- (void)reloadSymbols;
@end
