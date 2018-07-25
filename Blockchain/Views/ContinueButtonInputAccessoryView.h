//
//  ContinueButtonInputAccessoryView.h
//  Blockchain
//
//  Created by kevinwu on 11/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ContinueButtonInputAccessoryViewDelegate
- (void)continueButtonClicked;
- (void)closeButtonClicked;
@end
@interface ContinueButtonInputAccessoryView : UIView
@property (nonatomic, weak) id <ContinueButtonInputAccessoryViewDelegate> delegate;
- (void)disableContinueButton;
- (void)enableContinueButton;
@end
