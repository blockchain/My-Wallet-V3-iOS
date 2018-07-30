//
//  TransactionDetailFromCell.h
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionDetailTableCell.h"

@interface TransactionDetailFromCell : TransactionDetailTableCell
@property (nonatomic) UILabel *mainLabel;
@property (nonatomic) UILabel *accessoryLabel;
@property (nonatomic) UIButton *accessoryButton;
@end
