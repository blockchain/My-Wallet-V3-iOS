//
//  UIFadeView.m
//  Blockchain
//
//  Created by Ben Reeves on 16/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCFadeView.h"

@implementation BCFadeView

+ (nonnull BCFadeView *)instanceFromNib
{
    UINib *nib = [UINib nibWithNibName:@"MainWindow" bundle:[NSBundle mainBundle]];
    NSArray *objs = [nib instantiateWithOwner:nil options:nil];
    for (id object in objs) {
        if ([object isKindOfClass:[BCFadeView class]]) {
            return (BCFadeView *) object;
        }
    }
    return (BCFadeView *) [objs objectAtIndex:0];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.labelBusy.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    self.containerView.layer.cornerRadius = 5;
}

- (void)fadeIn {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)fadeOut {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
