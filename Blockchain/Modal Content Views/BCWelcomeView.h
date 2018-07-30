//
//  WelcomeView.h
//  Blockchain
//
//  Created by Mark Pfluger on 9/23/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCModalContentView.h"

@protocol BCWelcomeViewDelegate
- (void) showCreateWallet;
- (void) showPairWallet;
- (void) showRecoverWallet;
@end

@interface BCWelcomeView : BCModalContentView

@property (weak, nonatomic) id <BCWelcomeViewDelegate> delegate;
@property (nonatomic, strong) UIButton *createWalletButton, *existingWalletButton, *recoverWalletButton;


@end
