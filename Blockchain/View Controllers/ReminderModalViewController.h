//
//  ReminderModalViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 12/14/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    ReminderTypeEmail,
    ReminderTypeTwoFactor,
    ReminderTypeBackupJustReceivedBitcoin,
    ReminderTypeBackupHasBitcoin
};

typedef NSInteger ReminderType;

@protocol ReminderModalDelegate
- (void)showBackup;
- (void)showTwoStep;
@end

@interface ReminderModalViewController : UIViewController
@property (nonatomic) id <ReminderModalDelegate> delegate;
@property (nonatomic) NSString *displayString;
- (id)initWithReminderType:(ReminderType)reminderType;
@end
