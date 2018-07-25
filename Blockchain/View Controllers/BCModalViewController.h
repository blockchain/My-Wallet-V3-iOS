//
//  BCModalViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 1/26/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCModalView.h"
@protocol CloseButtonDelegate
- (void)closeButtonClicked;
@end
@interface BCModalViewController : UIViewController <CloseButtonDelegate>
@property(nonatomic, strong) IBOutlet UIButton *closeButton;
@property(nonatomic, strong) IBOutlet UIButton *backButton;
@property(nonatomic, strong) UIView *myHolderView;

@property (nonatomic) ModalCloseType closeType;
- (id)initWithCloseType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText view:(UIView *)view;
@end
