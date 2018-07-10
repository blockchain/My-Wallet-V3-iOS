//
//  TransactionDetailStatusCell.m
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailStatusCell.h"
#import "Blockchain-Swift.h"

@implementation TransactionDetailStatusCell

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
    
    if (self.isSetup) {
        self.mainLabel.text = BC_STRING_STATUS;
        self.accessoryButton.hidden = NO;
        return;
    }
    
    self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.layoutMargins.left, 0, 70, 60)];
    self.mainLabel.adjustsFontSizeToFitWidth = YES;
    self.mainLabel.text = BC_STRING_STATUS;
    self.mainLabel.textColor = UIColor.gray5;
    self.mainLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM_LARGE];
    [self.contentView addSubview:self.mainLabel];
    
    CGFloat accessoryButtonXPosition = self.mainLabel.frame.origin.x + self.mainLabel.frame.size.width + 8;
    self.accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(accessoryButtonXPosition, 0, self.frame.size.width - self.contentView.layoutMargins.right - accessoryButtonXPosition, 60)];
    NSString *buttonTitle = transactionModel.confirmed ? BC_STRING_CONFIRMED : [NSString stringWithFormat:BC_STRING_PENDING_ARGUMENT_CONFIRMATIONS, transactionModel.confirmations];
    
    self.accessoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.accessoryButton addTarget:self action:@selector(showWebviewDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.accessoryButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.accessoryButton.titleLabel setFont:[UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM_LARGE]];
    self.accessoryButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.accessoryButton setTitleColor:UIColor.brandSecondary forState:UIControlStateNormal];
    [self.contentView addSubview:self.accessoryButton];
    
    self.bannerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.accessoryButton.frame.origin.y + self.accessoryButton.frame.size.height + 32, self.contentView.frame.size.width - 60, 48)];
    self.bannerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24);
    self.bannerButton.titleLabel.textColor = [UIColor whiteColor];
    self.bannerButton.backgroundColor = UIColor.brandSecondary;
    self.bannerButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM_LARGE];
    self.bannerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.bannerButton setTitle:transactionModel.detailButtonTitle forState:UIControlStateNormal];
    self.bannerButton.layer.cornerRadius = 4;
    [self.bannerButton addTarget:self action:@selector(showWebviewDetail) forControlEvents:UIControlEventTouchUpInside];
    self.bannerButton.center = CGPointMake(self.contentView.center.x, self.bannerButton.center.y);
    [self.contentView addSubview:self.bannerButton];
    
    self.isSetup = YES;
}

- (void)showWebviewDetail
{
    [self.statusDelegate showWebviewDetail];
}

@end
