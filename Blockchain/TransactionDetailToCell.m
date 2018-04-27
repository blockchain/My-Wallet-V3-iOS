//
//  TransactionDetailToCell.m
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailToCell.h"
#import "UIView+ChangeFrameAttribute.h"

@implementation TransactionDetailToCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.mainLabel setText:nil];
    [self.accessoryLabel setText:nil];
}

- (void)configureWithTransactionModel:(TransactionDetailViewModel *)transactionModel
{
    [super configureWithTransactionModel:transactionModel];

    if (self.isSetup) {
        if (transactionModel.to.count > 1) {
            self.detailTextLabel.text = [NSString stringWithFormat:BC_STRING_ARGUMENT_RECIPIENTS, transactionModel.to.count];
        } else {
            self.accessoryLabel.text = transactionModel.toString;
        }
        self.mainLabel.text = BC_STRING_TO;
        return;
    }
    
    self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, self.frame.size.height)];
    self.mainLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM_LARGE];
    self.mainLabel.adjustsFontSizeToFitWidth = YES;
    self.mainLabel.text = BC_STRING_TO;
    self.mainLabel.textColor = COLOR_TEXT_DARK_GRAY;
    [self.mainLabel sizeToFit];
    [self.mainLabel changeXPosition:self.contentView.layoutMargins.left];
    self.mainLabel.center = CGPointMake(self.mainLabel.center.x, self.contentView.center.y);
    [self.contentView addSubview:self.mainLabel];
    
    if (transactionModel.to.count > 1) {
        self.detailTextLabel.text = [NSString stringWithFormat:BC_STRING_ARGUMENT_RECIPIENTS, transactionModel.to.count];
        self.detailTextLabel.textColor = COLOR_TEXT_DARK_GRAY;
        self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        CGFloat accessoryLabelXPosition = self.mainLabel.frame.origin.x + self.mainLabel.frame.size.width + 8;
        self.accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(accessoryLabelXPosition, 0, self.frame.size.width - self.contentView.layoutMargins.right - accessoryLabelXPosition, 20.5)];
        self.accessoryLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_SMALL];
        self.accessoryLabel.textAlignment = NSTextAlignmentRight;
        self.accessoryLabel.text = transactionModel.toString;
        self.accessoryLabel.adjustsFontSizeToFitWidth = YES;
        self.accessoryLabel.center = CGPointMake(self.accessoryLabel.center.x, self.contentView.center.y);
        self.accessoryLabel.textColor = COLOR_TEXT_DARK_GRAY;
        [self.contentView addSubview:self.accessoryLabel];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.isSetup = YES;
}

@end
