//
//  BCInsetLabel.m
//  Blockchain
//
//  Created by Kevin Wu on 2/25/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCInsetLabel.h"

@implementation BCInsetLabel

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.customEdgeInsets)];
}

- (void)sizeToFit
{
    [super sizeToFit];

    // When using a BCInsetLabel with custom edge inset values > 0, calling sizeToFit()
    // on it causes the frame to become smaller than it should be, truncating the text.
    // By manually changing the frame by its inset values, sizeToFit() gives the expected frame.
    CGFloat horizontalOffset = self.customEdgeInsets.left + self.customEdgeInsets.right;
    CGFloat verticalOffset = self.customEdgeInsets.top + self.customEdgeInsets.bottom;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width + horizontalOffset,
                            self.frame.size.height + verticalOffset);
}

@end
