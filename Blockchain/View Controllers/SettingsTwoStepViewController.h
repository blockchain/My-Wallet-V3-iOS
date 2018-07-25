//
//  SettingsTwoStepViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 12/4/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsTableViewController.h"
@interface SettingsTwoStepViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *twoStepButton;
@property (nonatomic) SettingsTableViewController *settingsController;

- (void)updateUI;

@end
