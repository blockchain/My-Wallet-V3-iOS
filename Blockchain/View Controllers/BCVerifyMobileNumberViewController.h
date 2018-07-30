//
//  BCVerifyMobileNumberViewController.h
//  Blockchain
//
//  Created by kevinwu on 2/14/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MobileNumberDelegate
- (BOOL)isMobileVerified;
- (NSString *)getMobileNumber;
- (void)changeMobileNumber:(NSString *)numberString;
- (BOOL)showVerifyAlertIfNeeded;
- (void)alertUserToVerifyMobileNumber;
@end
@interface BCVerifyMobileNumberViewController : UIViewController
@property (nonatomic) UIViewController<MobileNumberDelegate> *delegate;
- (id)initWithMobileDelegate:(UIViewController<MobileNumberDelegate>*)delegate;
@end

