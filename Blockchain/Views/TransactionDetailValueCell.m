//
//  TransactionDetailValueCell.m
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailValueCell.h"
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

@implementation TransactionDetailValueCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.mainLabel setText:nil];
    [self.accessoryLabel setText:nil];
    [self.fiatValueWhenSentLabel setText:nil];
    [self.transactionFeeLabel setText:nil];
    
    [self.amountButton setHidden:YES];
    [self.accessoryButton setHidden:YES];
}

- (void)configureWithTransactionModel:(TransactionDetailViewModel *)transactionModel
{
    [super configureWithTransactionModel:transactionModel];
    
    if (self.isSetup) {
        [self setupTransactionTypeText:transactionModel];
        self.amountButton.hidden = NO;
        self.accessoryButton.hidden = NO;
        [self setupValueWhenSentLabelText:transactionModel];
        self.transactionFeeLabel.text = [NSString stringWithFormat:BC_STRING_TRANSACTION_FEE_ARGUMENT, [transactionModel getFeeString]];
        [self.amountButton setTitle:[transactionModel getAmountString] forState:UIControlStateNormal];
        return;
    }
    
    // Label for Sent, Transferred, or Received
    self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.layoutMargins.left, 16, self.frame.size.width/3 + 16, 32)];
    self.mainLabel.adjustsFontSizeToFitWidth = YES;
    self.mainLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM_LARGE];
    
    [self setupTransactionTypeText:transactionModel];
    [self.contentView addSubview:self.mainLabel];
    
    CGFloat XPositionForAccessoryViews = self.contentView.layoutMargins.left + self.mainLabel.frame.size.width;
    
    // Amount button
    self.amountButton = [[UIButton alloc] initWithFrame:CGRectMake(XPositionForAccessoryViews, self.mainLabel.frame.origin.y, self.frame.size.width - XPositionForAccessoryViews - self.contentView.layoutMargins.right, 32)];
    self.amountButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.amountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.amountButton setTitle:[transactionModel getAmountString] forState:UIControlStateNormal];
    self.amountButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM_LARGE];
    [self.amountButton addTarget:self action:@selector(toggleSymbol) forControlEvents:UIControlEventTouchUpInside];
    
    [self.amountButton setTitleColor:self.mainLabel.textColor forState:UIControlStateNormal];
    [self.contentView addSubview:self.amountButton];
    
    // Value when sent label
    self.fiatValueWhenSentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.layoutMargins.left, self.amountButton.frame.origin.y + self.amountButton.frame.size.height, self.frame.size.width - self.contentView.layoutMargins.right - self.contentView.layoutMargins.left, 18)];
    self.fiatValueWhenSentLabel.font =  [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_SMALL];
    
    [self setupValueWhenSentLabelText:transactionModel];
    
    self.fiatValueWhenSentLabel.adjustsFontSizeToFitWidth = YES;
    self.fiatValueWhenSentLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.fiatValueWhenSentLabel];
    
    // Transaction fee label
    if (![transactionModel.txType isEqualToString:TX_TYPE_RECEIVED]) {
        self.transactionFeeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.layoutMargins.left, self.fiatValueWhenSentLabel.frame.origin.y + self.fiatValueWhenSentLabel.frame.size.height, self.frame.size.width - self.contentView.layoutMargins.right - self.contentView.layoutMargins.left, 16)];
        self.transactionFeeLabel.font =  [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_SMALL];
        self.transactionFeeLabel.textColor = UIColor.gray2;
        self.transactionFeeLabel.text = [NSString stringWithFormat:BC_STRING_TRANSACTION_FEE_ARGUMENT, [transactionModel getFeeString]];
        self.transactionFeeLabel.adjustsFontSizeToFitWidth = YES;
        self.transactionFeeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.transactionFeeLabel];
    }
    
    self.isSetup = YES;
}

- (void)setupValueWhenSentLabelText:(TransactionDetailViewModel *)transactionModel
{
    NSString *currencyCode = [self.valueDelegate getCurrencyCode];
    NSString *sentOrReceived = [transactionModel.txType isEqualToString:TX_TYPE_RECEIVED] ? BC_STRING_VALUE_WHEN_RECEIVED_ARGUMENT: BC_STRING_VALUE_WHEN_SENT_ARGUMENT;
    
    if ([transactionModel.fiatAmountsAtTime objectForKey:[currencyCode lowercaseString]]) {
        self.fiatValueWhenSentLabel.attributedText = nil;
        self.fiatValueWhenSentLabel.textColor = UIColor.gray2;
        self.fiatValueWhenSentLabel.text = [NSString stringWithFormat:sentOrReceived, [NSNumberFormatter appendStringToFiatSymbol:[transactionModel.fiatAmountsAtTime objectForKey:[currencyCode lowercaseString]]]];
        self.fiatValueWhenSentLabel.hidden = NO;
    } else {
        self.fiatValueWhenSentLabel.hidden = YES;
        self.fiatValueWhenSentLabel.text = nil;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:sentOrReceived, @".........."]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColor.gray2 range:NSMakeRange(0, attributedString.length - 10)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(attributedString.length - 10, 10)];
        self.fiatValueWhenSentLabel.attributedText = attributedString;
    }
}

- (void)setupTransactionTypeText:(TransactionDetailViewModel *)transactionModel
{
    if ([transactionModel.txType isEqualToString:TX_TYPE_TRANSFER]) {
        self.mainLabel.text = [BC_STRING_TRANSFERRED uppercaseString];
        self.mainLabel.textColor = UIColor.grayBlue;
    } else if ([transactionModel.txType isEqualToString:TX_TYPE_RECEIVED]) {
        self.mainLabel.text = [BC_STRING_RECEIVED uppercaseString];
        self.mainLabel.textColor = UIColor.aqua;
    } else {
        self.mainLabel.text = [BC_STRING_SENT uppercaseString];
        self.mainLabel.textColor = UIColor.red;
    }
}

- (void)toggleSymbol
{
    [self.valueDelegate toggleSymbol];
}

@end
