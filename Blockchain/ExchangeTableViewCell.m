//
//  ExchangeTableViewCell.m
//  Blockchain
//
//  Created by kevinwu on 11/13/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeTableViewCell.h"
#import "NSDateFormatter+TimeAgoString.h"
#import "RootService.h"
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

@implementation ExchangeTableViewCell

- (void)configureWithTrade:(ExchangeTrade *)trade
{
    NSString *status = trade.status;
    
    NSString *displayStatus;
    UIColor *statusColor;
    if ([status isEqualToString:TRADE_STATUS_COMPLETE]) {
        statusColor = COLOR_BLOCKCHAIN_GREEN;
        displayStatus = BC_STRING_COMPLETE;
    } else if ([status isEqualToString:TRADE_STATUS_NO_DEPOSITS] ||
               [status isEqualToString:TRADE_STATUS_RECEIVED]) {
        statusColor = COLOR_BLOCKCHAIN_GRAY_BLUE;
        displayStatus = BC_STRING_IN_PROGRESS;
    } else if ([status isEqualToString:TRADE_STATUS_CANCELLED] ||
               [status isEqualToString:TRADE_STATUS_FAILED] ||
               [status isEqualToString:TRADE_STATUS_EXPIRED] ||
               [status isEqualToString:TRADE_STATUS_RESOLVED]) {
        statusColor = COLOR_BLOCKCHAIN_RED;
        displayStatus = BC_STRING_EXCHANGE_TITLE_REFUNDED;
    }
    
    self.actionLabel.textColor = statusColor;
    
    self.actionLabel.text = [displayStatus uppercaseString];
    self.amountButton.backgroundColor = statusColor;
    
    NSString *toAsset = [[trade.pair componentsSeparatedByString:@"_"] lastObject];
    NSString *amountString;
    
    self.actionLabel.frame = CGRectMake(self.actionLabel.frame.origin.x, 29, self.actionLabel.frame.size.width, self.actionLabel.frame.size.height);
    self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, 11, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
    
    if (app->symbolLocal) {
        NSString *lowercaseWithdrawalCurrencySymbol = [[trade withdrawalCurrency] lowercaseString];
        if ([lowercaseWithdrawalCurrencySymbol isEqualToString:[CURRENCY_SYMBOL_BTC lowercaseString]]) {
            amountString = [NSNumberFormatter formatMoney:ABS([NSNumberFormatter parseBtcValueFromString:[trade.withdrawalAmount stringValue]])];
        } else if ([lowercaseWithdrawalCurrencySymbol isEqualToString:[CURRENCY_SYMBOL_ETH lowercaseString]]) {
            TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
            amountString = [NSNumberFormatter formatEthWithLocalSymbol:[trade.withdrawalAmount stringValue] exchangeRate:tabControllerManager.latestEthExchangeRate];
        } else if ([lowercaseWithdrawalCurrencySymbol isEqualToString:[CURRENCY_SYMBOL_BCH lowercaseString]]) {
            amountString = [NSNumberFormatter formatBchWithSymbol:ABS([NSNumberFormatter parseBtcValueFromString:[trade.withdrawalAmount stringValue]])];
        } else {
            DLog(@"Warning: unsupported withdrawal currency for trade: %@", [trade withdrawalCurrency]);
        }
    } else {
        amountString = [NSString stringWithFormat:@"%@ %@", [NSNumberFormatter localFormattedString:[trade.withdrawalAmount stringValue]], [toAsset uppercaseString]];
    }
    
    [self.amountButton setTitle:amountString forState:UIControlStateNormal];
    self.dateLabel.text = [NSDateFormatter timeAgoStringFromDate:trade.date];
}

- (IBAction)amountButtonClicked:(id)sender
{
    BlockchainSettings.sharedAppInstance.symbolLocal = !BlockchainSettings.sharedAppInstance.symbolLocal;
}

@end
