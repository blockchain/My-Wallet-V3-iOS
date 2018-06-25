//
//  ReminderModalViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 12/14/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ReminderModalViewController.h"
#import "Blockchain-Swift.h"

@interface ReminderModalViewController ()
@property (nonatomic, readonly) ReminderType reminderType;
@end

@implementation ReminderModalViewController

- (id)initWithReminderType:(ReminderType)reminderType
{
    if (self = [super init]) {
        _reminderType = reminderType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat centerX = self.view.center.x;
    CGFloat centerY = self.view.center.y;
    
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
    continueButton.center = CGPointMake(centerX, self.view.frame.size.height - 90);
    continueButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    continueButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    continueButton.layer.cornerRadius = 4;
    [self.view addSubview:continueButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
    cancelButton.center = CGPointMake(centerX, self.view.frame.size.height - 40);
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitleColor:COLOR_TEXT_GRAY forState:UIControlStateNormal];
    [cancelButton setTitle:BC_STRING_ILL_DO_THIS_LATER forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    cancelButton.layer.cornerRadius = 4;
    [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 56, 24, 40, 40)];
    [closeButton setImage:[UIImage imageNamed:@"close_large"] forState:UIControlStateNormal];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    closeButton.imageView.image = [closeButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [closeButton setTintColor:COLOR_BLOCKCHAIN_BLUE];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    iconImageView.center = CGPointMake(centerX, centerY - 150);
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconImageView.frame.origin.y + iconImageView.frame.size.height + 16, self.view.frame.size.width - 100, 30)];
    titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_LARGE];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.center = CGPointMake(iconImageView.center.x, titleLabel.center.y);
    titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:titleLabel];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, 270, 200)];
    detailLabel.numberOfLines = 0;
    detailLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    detailLabel.textColor = [UIColor darkGrayColor];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:detailLabel];
    
    NSString *detailLabelString;
    
    if (self.reminderType == ReminderTypeEmail) {
        titleLabel.text = BC_STRING_REMINDER_CHECK_EMAIL_TITLE;
        detailLabelString = BC_STRING_REMINDER_CHECK_EMAIL_MESSAGE;
        iconImageView.image = [UIImage imageNamed:@"email_square"];
        [continueButton setTitle:BC_STRING_CONTINUE_TO_MAIL forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(openMail) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *emailLabel = [[UILabel alloc] initWithFrame:titleLabel.frame];
        emailLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_SEMIBOLD size:FONT_SIZE_SMALL_MEDIUM];
        emailLabel.text = self.displayString;
        emailLabel.textAlignment = NSTextAlignmentCenter;
        emailLabel.frame = CGRectOffset(emailLabel.frame, 0, 38);
        emailLabel.textColor = [UIColor darkGrayColor];
        
        [self.view addSubview:emailLabel];
        
        detailLabel.frame = CGRectOffset(emailLabel.frame, 0, 38);
    } else if (self.reminderType == ReminderTypeBackupHasBitcoin || self.reminderType == ReminderTypeBackupJustReceivedBitcoin) {
        titleLabel.text = BC_STRING_REMINDER_BACKUP_TITLE;
        detailLabelString = self.reminderType == ReminderTypeBackupJustReceivedBitcoin ? [LocalizationConstantsObjcBridge reminderBackupMessageFirstBitcoin] : [LocalizationConstantsObjcBridge reminderBackupMessageHasFunds];
        iconImageView.image = [UIImage imageNamed:@"lock_large"];
        [continueButton setTitle:BC_STRING_REMINDER_BACKUP_NOW forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(showBackup) forControlEvents:UIControlEventTouchUpInside];
    } else if (self.reminderType == ReminderTypeTwoFactor) {
        titleLabel.text = BC_STRING_REMINDER_TWO_FACTOR_TITLE;
        detailLabelString = BC_STRING_REMINDER_TWO_FACTOR_MESSAGE;
        iconImageView.image = [UIImage imageNamed:@"mobile_large"];
        [continueButton setTitle:BC_STRING_ENABLE_TWO_STEP forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(showTwoStep) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:detailLabelString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 4;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailLabelString.length)];
    
    detailLabel.attributedText = attributedString;
    
    [detailLabel sizeToFit];
    detailLabel.center = CGPointMake(iconImageView.center.x, detailLabel.center.y);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)openMail
{
    [UIApplication.sharedApplication openMailApplication];
}

- (void)showBackup
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate showBackup];
    }];
}

- (void)showTwoStep
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate showTwoStep];
    }];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
