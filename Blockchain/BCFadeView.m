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
}

- (void)fadeIn {
    self.containerView.layer.cornerRadius = 5;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)fadeOut {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(removeModalView)];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)removeModalView {
    [self removeFromSuperview];
}

@end
