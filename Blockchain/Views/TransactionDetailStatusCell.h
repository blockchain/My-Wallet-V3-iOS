//
//  TransactionDetailStatusCell.h
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionDetailTableCell.h"

@protocol StatusDelegate
- (void)showWebviewDetail;
@end
@interface TransactionDetailStatusCell : TransactionDetailTableCell
@property (nonatomic) UILabel *mainLabel;
@property (nonatomic) UILabel *accessoryLabel;
@property (nonatomic) UIButton *accessoryButton;
@property (nonatomic) UIButton *bannerButton;
@property (nonatomic) id<StatusDelegate> statusDelegate;

@end
