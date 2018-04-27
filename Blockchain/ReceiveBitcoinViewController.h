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

#import "Wallet.h"
#import "BCDescriptionView.h"

@class BCTotalAmountView;
@interface ReceiveBitcoinViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UIImageView *qrCodeMainImageView;
    
    // Label Address
    IBOutlet UIView *labelAddressView;
    IBOutlet UITextField *labelTextField;
    IBOutlet UILabel *labelAddressLabel;
    
    // Amount buttons and field
    IBOutlet UITextField *entryField;

    UIButton *doneButton;
    // Keyboard accessory view
    UIView *amountKeyboardAccessoryView;
}
@property (nonatomic) AssetType assetType;

@property(nonatomic, strong) NSArray *activeKeys;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property(nonatomic, strong) NSString *clickedAddress;

@property(nonatomic) UIView *bottomContainerView;
@property(nonatomic) UILabel *receiveToLabel;
@property(nonatomic) UIButton *selectFromButton;
@property(nonatomic) UIButton *whatsThisButton;
@property(nonatomic) UIView *headerView;

- (IBAction)archiveAddressClicked:(id)sender;
- (IBAction)labelSaveClicked:(id)sender;

- (void)storeRequestedAmount;
- (void)paymentReceived:(uint64_t)amount showBackupReminder:(BOOL)showBackupReminder;

- (void)reload;
- (void)reloadMainAddress;
- (void)clearAmounts;

- (void)hideKeyboard;
- (void)hideKeyboardForced;

- (void)doCurrencyConversion;
@end
