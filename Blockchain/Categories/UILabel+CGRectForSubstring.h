//
//  UILabel+CGRectForSubstring.h
//  Blockchain
//
//  Created by kevinwu on 11/2/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CGRectForSubstring)
- (CGRect)boundingRectForCharacterRange:(NSRange)range;
@end
