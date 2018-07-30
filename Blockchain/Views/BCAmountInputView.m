//
//  BCAmountView.m
//  Blockchain
//
//  Created by kevinwu on 8/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCAmountInputView.h"
#import "Blockchain-Swift.h"

@implementation BCAmountInputView

- (id)init
{
    if (self == [super init]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, AMOUNT_INPUT_VIEW_HEIGHT);
        
        CGFloat labelWidth = IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 48 : 42;
        self.btcLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, labelWidth, 21)];
        self.btcLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
        self.btcLabel.textColor = UIColor.gray5;
        [self addSubview:self.btcLabel];
        
        // Field width will be space remaining after subtracting widths of all other subviews and spacing in the row
        CGFloat fieldWidth = (self.frame.size.width - labelWidth*2 - 8*6)/2;
        self.btcField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(self.btcLabel.frame.origin.x + self.btcLabel.frame.size.width + 8, 10, fieldWidth, 30)];
        self.btcField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
        self.btcField.placeholder = [NSString stringWithFormat:BTC_PLACEHOLDER_DECIMAL_SEPARATOR_ARGUMENT, [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
        self.btcField.keyboardType = UIKeyboardTypeDecimalPad;
        self.btcField.textColor = UIColor.gray5;
        [self addSubview:self.btcField];
        
        self.fiatLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.btcField.frame.origin.x + self.btcField.frame.size.width + 8, 15, labelWidth, 21)];
        self.fiatLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
        self.fiatLabel.textColor = UIColor.gray5;
        self.fiatLabel.text = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.code;
        [self addSubview:self.fiatLabel];
        
        CGFloat receiveFiatFieldOriginX =  self.fiatLabel.frame.origin.x + self.fiatLabel.frame.size.width + 8;
        self.fiatField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(receiveFiatFieldOriginX, 10, fieldWidth, 30)];
        self.fiatField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
        self.fiatField.placeholder = [NSString stringWithFormat:FIAT_PLACEHOLDER_DECIMAL_SEPARATOR_ARGUMENT, [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
        self.fiatField.textColor = UIColor.gray5;
        self.fiatField.keyboardType = UIKeyboardTypeDecimalPad;
        [self addSubview:self.fiatField];
    }
    return self;
}

- (void)highlightInvalidAmounts
{
    self.btcField.textColor = UIColor.error;
    self.fiatField.textColor = UIColor.error;
}

- (void)removeHighlightFromAmounts
{
    self.btcField.textColor = UIColor.gray5;
    self.fiatField.textColor = UIColor.gray5;
}

- (void)clearFields
{
    self.btcField.text = nil;
    self.fiatField.text = nil;
}

- (void)hideKeyboard
{
    [self.btcField resignFirstResponder];
    [self.fiatField resignFirstResponder];
}

@end
