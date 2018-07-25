//
//  UIView+ChangeFrameAttribute.h
//  Blockchain
//
//  Created by kevinwu on 4/20/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ChangeFrameAttribute)
- (void)increaseXPosition:(CGFloat)XOffset;
- (void)increaseYPosition:(CGFloat)YOffset;
- (void)changeXPosition:(CGFloat)newX;
- (void)changeYPosition:(CGFloat)newY;
- (void)changeYPositionAnimated:(CGFloat)newY completion:(void (^ __nullable)(BOOL finished))completion;
- (void)changeWidth:(CGFloat)newWidth;
- (void)changeHeight:(CGFloat)newHeight;
@end
