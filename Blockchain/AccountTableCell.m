//
//  AccountTableCell.m
//  Blockchain
//
//  Created by Mark Pfluger on 12/2/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AccountTableCell.h"
#import "RootService.h"
#import "ECSlidingViewController.h"
#import "BCEditAccountView.h"
#import "Blockchain-Swift.h"

@implementation AccountTableCell

- (id)init
{
    self = [super init];
    
    if (self) {
        ECSlidingViewController *sideMenu = [AppCoordinator sharedInstance].slidingViewController;
        
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(18, 10, 22, 22)];
        [self addSubview:_iconImage];
        
        _labelLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 10, self.frame.size.width - sideMenu.anchorLeftPeekAmount - 100, 18)];
        _labelLabel.minimumScaleFactor = 0.75f;
        [_labelLabel setAdjustsFontSizeToFitWidth:YES];
        _labelLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM_LARGE];
        _labelLabel.textColor = [UIColor whiteColor];
        [self addSubview:_labelLabel];
        
        _amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 24, self.frame.size.width - sideMenu.anchorLeftPeekAmount - 100, 30)];
        _amountLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM_LARGE];
        _amountLabel.textColor = [UIColor whiteColor];
        [self addSubview:_amountLabel];
        
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - sideMenu.anchorLeftPeekAmount - 30 - 12, 0, 40, 40)];
        [_editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonclicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_editButton];
    }
    
    return self;
}

- (IBAction)editButtonclicked:(id)sender
{
    BCEditAccountView *editAccountView = [[BCEditAccountView alloc] init];
    
    editAccountView.accountIdx = self.accountIdx;
    editAccountView.labelTextField.text = [app.wallet getLabelForAccount:self.accountIdx assetType:self.assetType];
    
    [app showModalWithContent:editAccountView closeType:ModalCloseTypeClose headerText:BC_STRING_EDIT onDismiss:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    } onResume:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [editAccountView.labelTextField becomeFirstResponder];
    });
}

@end
