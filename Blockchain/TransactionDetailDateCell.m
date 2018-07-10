//
//  TransactionDetailDateCell.m
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailDateCell.h"
#import "Blockchain-Swift.h"

@implementation TransactionDetailDateCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.mainLabel setText:nil];
    [self.accessoryLabel setText:nil];
    
    [self.accessoryButton setHidden:YES];
}

- (void)configureWithTransactionModel:(TransactionDetailViewModel *)transactionModel
{
    [super configureWithTransactionModel:transactionModel];

    NSString *dateString = transactionModel.dateString;
    
    if (self.isSetup) {
        self.mainLabel.text = BC_STRING_DATE;
        self.accessoryLabel.text = dateString;
        return;
    }
    
    self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.layoutMargins.left, 0, 70, self.frame.size.height)];
    self.mainLabel.adjustsFontSizeToFitWidth = YES;
    self.mainLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM_LARGE];
    self.mainLabel.text = BC_STRING_DATE;
    self.mainLabel.textColor = UIColor.gray5;
    [self.contentView addSubview:self.mainLabel];
    
    CGFloat accessoryLabelXPosition = self.mainLabel.frame.origin.x + self.mainLabel.frame.size.width + 8;
    self.accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(accessoryLabelXPosition, 0, self.frame.size.width - self.contentView.layoutMargins.right - accessoryLabelXPosition, self.frame.size.height)];
    self.accessoryLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM_LARGE];
    self.accessoryLabel.adjustsFontSizeToFitWidth = YES;
    self.accessoryLabel.textAlignment = NSTextAlignmentRight;
    self.accessoryLabel.text = dateString;
    self.accessoryLabel.textColor = UIColor.gray5;
    [self.contentView addSubview:self.accessoryLabel];
    
    self.isSetup = YES;
}

@end
