//
//  UILabel+Animations.h
//  Blockchain
//
//  Created by kevinwu on 9/1/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Animations)
- (void)animateFromText:(NSString *)originalText toIntermediateText:(NSString *)intermediateText speed:(float)speed gestureReceiver:(UIView *)gestureReceiver;

@end
