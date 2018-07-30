//
//  UITextView+Animations.h
//  Blockchain
//
//  Created by kevinwu on 1/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Animations)
- (void)animateFromText:(NSString *)originalText toIntermediateText:(NSString *)intermediateText speed:(float)speed gestureReceiver:(UIView *)gestureReceiver;
@end
