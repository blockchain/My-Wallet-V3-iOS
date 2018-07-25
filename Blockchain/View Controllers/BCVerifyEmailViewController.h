//
//  BCVerifyEmailViewController.h
//  Blockchain
//
//  Created by kevinwu on 2/14/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EmailDelegate
- (BOOL)isEmailVerified;
- (NSString *)getEmail;
- (void)changeEmail:(NSString *)emailString;
@end
@interface BCVerifyEmailViewController : UIViewController
@property (nonatomic) UIViewController<EmailDelegate> *delegate;
- (id)initWithEmailDelegate:(UIViewController<EmailDelegate>*)delegate;
@end
