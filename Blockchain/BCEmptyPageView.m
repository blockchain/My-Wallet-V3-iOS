//
//  BCEmptyPageView.m
//  Blockchain
//
//  Created by kevinwu on 7/13/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCEmptyPageView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@implementation BCEmptyPageView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor subtitle:(NSString *)subtitle imageView:(UIImageView *)imageView
{
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = title;
        titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
        titleLabel.textColor = titleColor;
        [titleLabel sizeToFit];
        [titleLabel changeYPosition:self.center.y];
        titleLabel.center = CGPointMake(self.center.x, titleLabel.center.y);
        [self addSubview:titleLabel];
        
        imageView.frame = CGRectMake(0, titleLabel.frame.origin.y - 16 - imageView.frame.size.height, imageView.frame.size.width, imageView.frame.size.height);
        imageView.center = CGPointMake(self.center.x, imageView.center.y);
        [self addSubview:imageView];
        
        UITextView *subtitleTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 80, 0)];
        subtitleTextView.text = subtitle;
        subtitleTextView.textAlignment = NSTextAlignmentCenter;
        subtitleTextView.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
        subtitleTextView.editable = NO;
        subtitleTextView.selectable = NO;
        subtitleTextView.scrollEnabled = NO;
        subtitleTextView.textColor = UIColor.gray2;
        subtitleTextView.textContainerInset = UIEdgeInsetsZero;
        subtitleTextView.frame = CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, subtitleTextView.frame.size.width, subtitleTextView.contentSize.height);
        [subtitleTextView sizeToFit];
        subtitleTextView.center = CGPointMake(self.center.x, subtitleTextView.center.y);
        subtitleTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:subtitleTextView];
    }
    
    return self;
}

@end
