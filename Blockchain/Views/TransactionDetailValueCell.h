//
//  TransactionDetailValueCell.h
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionDetailTableCell.h"

@protocol ValueDelegate
- (NSString *)getCurrencyCode;
- (void)toggleSymbol;
@end
@interface TransactionDetailValueCell : TransactionDetailTableCell
@property (nonatomic) UIButton *amountButton;
@property (nonatomic) UILabel *fiatValueWhenSentLabel;
@property (nonatomic) UILabel *transactionFeeLabel;

@property (nonatomic) UILabel *mainLabel;
@property (nonatomic) UILabel *accessoryLabel;
@property (nonatomic) UIButton *accessoryButton;
@property (nonatomic) id<ValueDelegate> valueDelegate;

@end
