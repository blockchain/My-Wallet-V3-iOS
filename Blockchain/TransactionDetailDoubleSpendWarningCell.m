//
//  TransactionDetailDoubleSpendWarningCell.m
//  Blockchain
//
//  Created by Kevin Wu on 11/28/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailDoubleSpendWarningCell.h"
#import "Blockchain-Swift.h"

@implementation TransactionDetailDoubleSpendWarningCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.warningLabel setText:nil];
    [self.warningImageView setHidden:YES];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)configureWithTransactionModel:(TransactionDetailViewModel *)transactionModel
{
    [super configureWithTransactionModel:transactionModel];

    if (self.isSetup) {
        self.warningLabel.text = BC_STRING_DOUBLE_SPEND_WARNING;
        self.warningImageView.hidden = NO;
        self.backgroundColor = UIColor.error;
        return;
    }
    
    self.warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320 - 40 - 54, 40)];
    [self.contentView addSubview:self.warningLabel];
    self.warningLabel.font = [UIFont systemFontOfSize:FONT_SIZE_SMALL_MEDIUM];
    self.warningLabel.adjustsFontSizeToFitWidth = YES;
    self.warningLabel.center = CGPointMake(self.contentView.center.x + 14, self.contentView.center.y);
    self.warningLabel.textAlignment = NSTextAlignmentCenter;
    self.warningLabel.textColor = [UIColor whiteColor];
    self.warningLabel.text = BC_STRING_DOUBLE_SPEND_WARNING;
    
    self.warningImageView = [UIImageView new];
    [self.contentView addSubview:self.warningImageView];
    self.warningImageView.image = [UIImage imageNamed:@"alert"];
    self.warningImageView.image = [self.warningImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.warningImageView setTintColor:[UIColor whiteColor]];
    self.warningImageView.frame = CGRectMake(0, 0, 20, 20);
    self.warningImageView.center = self.warningLabel.center;
    self.warningImageView.frame = CGRectMake(self.warningLabel.frame.origin.x - self.warningImageView.frame.size.width - 8, self.warningImageView.frame.origin.y, self.warningImageView.frame.size.width, self.warningImageView.frame.size.height);
    self.backgroundColor = UIColor.error;
    self.isSetup = YES;
}

@end
