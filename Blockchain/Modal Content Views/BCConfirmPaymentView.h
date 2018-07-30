//
//  BCConfirmPaymentView.h
//  Blockchain
//
//  Created by Kevin Wu on 10/2/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCDescriptionView.h"
@class BCConfirmPaymentViewModel;

@protocol ConfirmPaymentViewDelegate
- (void)setupNoteForTransaction:(NSString *)note;
- (void)feeInformationButtonClicked;
@end
@interface BCConfirmPaymentView : BCDescriptionView

- (id)initWithFrame:(CGRect)frame viewModel:(BCConfirmPaymentViewModel *)viewModel sendButtonFrame:(CGRect)sendButtonFrame;

@property (nonatomic) UIButton *reallyDoPaymentButton;
@property (nonatomic) UIButton *feeInformationButton;

@property (weak, nonatomic) id <ConfirmPaymentViewDelegate> confirmDelegate;
@end
