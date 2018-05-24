//
//  SettingsTwoStepViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 12/4/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SettingsTwoStepViewController.h"
#import "Blockchain-Swift.h"

@implementation SettingsTwoStepViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.twoStepButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    self.twoStepButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.twoStepButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.twoStepButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
    
    self.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_SEMIBOLD size:FONT_SIZE_LARGE];
    self.descriptionLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SettingsNavigationController *navigationController = (SettingsNavigationController *)self.navigationController;
    navigationController.headerLabel.text = BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION;
    
    [self updateUI];
}

- (void)updateUI
{
    if ([WalletManager.sharedInstance.wallet hasEnabledTwoStep]) {
        [self.twoStepButton setTitle:BC_STRING_DISABLE forState:UIControlStateNormal];
    } else {
        [self.twoStepButton setTitle:BC_STRING_ENABLE_TWO_STEP_SMS forState:UIControlStateNormal];
    }
}

- (IBAction)twoStepTapped:(UIButton *)sender
{
    [self.settingsController changeTwoStepTapped];
}

@end
