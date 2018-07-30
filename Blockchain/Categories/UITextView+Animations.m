//
//  UITextView+Animations.m
//  Blockchain
//
//  Created by kevinwu on 1/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "UITextView+Animations.h"

@implementation UITextView (Animations)

- (void)animateFromText:(NSString *)originalText toIntermediateText:(NSString *)intermediateText speed:(float)speed gestureReceiver:(UIView *)gestureReceiver
{
    gestureReceiver.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.text = intermediateText;
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(speed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    self.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                        self.text = originalText;
                        self.alpha = 1.0;
                        gestureReceiver.userInteractionEnabled = YES;
                    }];
                }];
            });
        }];
    }];
}

@end
