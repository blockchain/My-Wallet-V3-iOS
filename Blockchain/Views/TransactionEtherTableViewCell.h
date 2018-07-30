//
//  TransactionEtherTableViewCell.h
//  Blockchain
//
//  Created by kevinwu on 8/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCInsetLabel.h"
@class EtherTransaction;
@interface TransactionEtherTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *actionLabel;
@property (strong, nonatomic) IBOutlet UIButton *ethButton;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet BCInsetLabel *infoLabel;
@property (nonatomic) EtherTransaction *transaction;
- (void)reload;
- (void)transactionClicked;
@end
