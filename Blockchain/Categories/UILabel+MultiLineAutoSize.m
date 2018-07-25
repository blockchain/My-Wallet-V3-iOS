//
//  UILabel+MultiLineAutoSize.m
//  Blockchain
//
//  Created by Kevin Wu on 7/4/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "UILabel+MultiLineAutoSize.h"

@implementation UILabel (MultiLineAutoSize)

- (void)adjustFontSizeToFit
{
    UIFont *font = self.font;
    CGSize size = self.frame.size;
    
    for (CGFloat maxSize = self.font.pointSize; maxSize >= self.minimumScaleFactor * self.font.pointSize; maxSize -= 1.f)
    {
        font = [font fontWithSize:maxSize];
        CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
        
        CGRect textRect = [self.text boundingRectWithSize:constraintSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:font}
                                                  context:nil];
        
        CGSize labelSize = textRect.size;
        
        
        if(labelSize.height <= size.height)
        {
            self.font = font;
            [self setNeedsLayout];
            break;
        }
    }
    // set the font to the minimum size anyway
    self.font = font;
    [self setNeedsLayout]; }


@end
