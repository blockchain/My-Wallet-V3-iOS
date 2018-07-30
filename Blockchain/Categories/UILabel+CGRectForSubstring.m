//
//  UILabel+CGRectForSubstring.m
//  Blockchain
//
//  Created by kevinwu on 11/2/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "UILabel+CGRectForSubstring.h"

@implementation UILabel (CGRectForSubstring)
- (CGRect)boundingRectForCharacterRange:(NSRange)range
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[self attributedText]];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    
    // Convert the range for glyphs.
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    
    CGRect rect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
    CGRect rectMovedDown = CGRectOffset(rect, 0, self.font.ascender);
    return CGRectMake(rectMovedDown.origin.x, rectMovedDown.origin.y - 8, rectMovedDown.size.width, rectMovedDown.size.height + 16);
}
@end
