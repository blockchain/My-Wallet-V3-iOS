//
//  TransactionDetailDoubleSpendWarningCell.h
//  Blockchain
//
//  Created by Kevin Wu on 11/28/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailTableCell.h"

@interface TransactionDetailDoubleSpendWarningCell : TransactionDetailTableCell
@property (nonatomic) UILabel *warningLabel;
@property (nonatomic) UIImageView *warningImageView;
@end
