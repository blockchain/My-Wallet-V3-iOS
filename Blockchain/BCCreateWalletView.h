/*
 * 
 * Copyright (c) 2012, Ben Reeves. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

#import <UIKit/UIKit.h>
#import "BCModalContentView.h"
#import "BCRecoveryView.h"
#import "Wallet.h"

@interface BCCreateWalletView : BCModalContentView <UITextFieldDelegate, WalletDelegate> {
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *password2TextField;
    IBOutlet UILabel *passwordFeedbackLabel;
    IBOutlet UIProgressView *passwordStrengthMeter;
    IBOutlet UILabel *termsOfServiceLabel;
    IBOutlet UIButton *termsOfServiceButton;
}

+ (nonnull BCCreateWalletView *)instanceFromNib;

- (IBAction)termsOfServiceClicked:(id)sender;

- (void)createBlankWallet;
- (void)showPassphraseTextField;
- (void)didRecoverWallet;
- (void)hideKeyboard;

@property(nonatomic) IBOutlet BCRecoveryView *recoveryPhraseView;
@property(nonatomic, strong) NSString *tmpPassword;
@property(nonatomic) float passwordStrength;
@property(nonatomic) BOOL isRecoveringWallet;
@property(nonatomic) UIButton *createButton;
@end
