//
//  BCCreateAccountView.m
//  Blockchain
//
//  Created by Mark Pfluger on 11/27/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCCreateAccountView.h"
#import "RootService.h"
#import "Blockchain-Swift.h"

@implementation BCCreateAccountView

-(id)init
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self = [super initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT, window.frame.size.width, window.frame.size.height - DEFAULT_HEADER_HEIGHT)];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *labelLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, window.frame.size.width - 40, 25)];
        labelLabel.text = BC_STRING_NAME;
        labelLabel.textColor = [UIColor darkGrayColor];
        labelLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
        [self addSubview:labelLabel];
        
        _labelTextField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(20, 95, window.frame.size.width - 40, 30)];
        _labelTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:_labelTextField.font.pointSize];
        _labelTextField.borderStyle = UITextBorderStyleRoundedRect;
        _labelTextField.textColor = COLOR_TEXT_DARK_GRAY;
        _labelTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _labelTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _labelTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        [self addSubview:_labelTextField];
        
        [_labelTextField setReturnKeyType:UIReturnKeyDone];
        _labelTextField.delegate = self;
        
        UIButton *createAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        createAccountButton.frame = CGRectMake(0, 0, window.frame.size.width, 46);
        createAccountButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
        [createAccountButton setTitle:BC_STRING_SAVE forState:UIControlStateNormal];
        [createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        createAccountButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
        
        [createAccountButton addTarget:self action:@selector(createAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _labelTextField.inputAccessoryView = createAccountButton;
    }
    
    return self;
}

# pragma mark - Button actions

- (IBAction)createAccountClicked:(id)sender
{
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    // Remove whitespace
    NSString *label = [self.labelTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (label.length == 0) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_YOU_MUST_ENTER_A_LABEL title:BC_STRING_ERROR handler: nil];
        return;
    }

    if (label.length > 17) {
        // TODO i18n
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_LABEL_MUST_HAVE_LESS_THAN_18_CHAR title:BC_STRING_ERROR  handler: nil];
        return;
    }

    if (![WalletManager.sharedInstance.wallet isAccountNameValid:label]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_NAME_ALREADY_IN_USE title:BC_STRING_ERROR handler: nil];
        [LoadingViewPresenter.sharedInstance hideBusyView];
        return;
    }

    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];

    [WalletManager.sharedInstance.wallet createAccountWithLabel:label];
}

#pragma mark - Textfield Delegates

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [self createAccountClicked:nil];
    return YES;
}

@end
