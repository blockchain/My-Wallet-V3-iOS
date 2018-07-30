//
//  ExchangeModalView.h
//  Blockchain
//
//  Created by kevinwu on 10/31/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCModalViewController.h"

@interface ExchangeModalView : UIView
@property (nonatomic, weak) id <CloseButtonDelegate> delegate;
- (id)initWithFrame:(CGRect)frame description:(NSString *)description imageName:(NSString *)imageName bottomText:(NSString *)bottomText closeButtonText:(NSString *)closeButtonText;

@end
