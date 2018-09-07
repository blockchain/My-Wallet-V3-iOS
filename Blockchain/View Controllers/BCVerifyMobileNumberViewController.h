//
//  BCVerifyMobileNumberViewController.h
//  Blockchain
//
//  Created by kevinwu on 2/14/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCVerifyMobileNumberViewController;

@protocol MobileNumberDelegate
- (BOOL)isMobileVerified;
- (NSString *)getMobileNumber;
- (void)verifyMobileNumberViewController:(BCVerifyMobileNumberViewController * _Nullable)viewController changeMobileNumber:(NSString * _Nullable)numberString;
- (BOOL)verifyMobileNumberViewControllerShowVerifyAlertIfNeeded:(BCVerifyMobileNumberViewController * _Nullable)viewController;
- (void)verifyMobileNumberViewControllerAlertUserToVerifyMobileNumber:(BCVerifyMobileNumberViewController * _Nullable)viewController;
@end

@interface BCVerifyMobileNumberViewController : UIViewController
@property (nonatomic) UIViewController<MobileNumberDelegate> *delegate;
- (id)initWithMobileDelegate:(UIViewController<MobileNumberDelegate>*)delegate;
- (void)reload;
@end
