//
//  BCCreateAccountView.h
//  Blockchain
//
//  Created by Mark Pfluger on 11/27/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BCSecureTextField;

@interface BCCreateAccountView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) BCSecureTextField *labelTextField;

@end
