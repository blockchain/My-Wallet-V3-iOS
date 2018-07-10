//
//  ExchangeModalView.m
//  Blockchain
//
//  Created by kevinwu on 10/31/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeModalView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@implementation ExchangeModalView

- (id)initWithFrame:(CGRect)frame description:(NSString *)description imageName:(NSString *)imageName bottomText:(NSString *)bottomText closeButtonText:(NSString *)closeButtonText
{
    self = [super initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT, frame.size.width, frame.size.height - DEFAULT_HEADER_HEIGHT)];
    
    if (self) {
        CGFloat windowWidth = frame.size.width - 50;
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, windowWidth, 100)];
        descriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.textColor = UIColor.gray5;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.text = description;
        [descriptionLabel sizeToFit];
        descriptionLabel.center = CGPointMake(self.center.x, descriptionLabel.center.y);
        [self addSubview:descriptionLabel];
        
        CGFloat imageWidth = 160;
        CGFloat imageHeight = imageWidth;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
        imageView.image = [UIImage imageNamed:imageName];
        imageView.center = CGPointMake(self.center.x, self.center.y - imageHeight);
        [self addSubview:imageView];
        
        CGRect imageFrameWithPadding = CGRectInset(imageView.frame, 0, -20);
        
        if (CGRectIntersectsRect(imageFrameWithPadding, descriptionLabel.frame)) {
            [imageView changeYPosition:descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 20];
        }
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, descriptionLabel.frame.size.width, 40)];
        bottomLabel.center = CGPointMake(self.center.x, bottomLabel.center.y);
        bottomLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
        bottomLabel.textColor = UIColor.gray5;
        bottomLabel.text = bottomText;
        [bottomLabel changeYPosition:imageView.frame.origin.y + imageView.frame.size.height + 16];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:bottomLabel];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, windowWidth - 40, BUTTON_HEIGHT)];
        closeButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
        closeButton.backgroundColor = UIColor.brandSecondary;
        closeButton.center = CGPointMake(self.center.x, closeButton.center.y);
        [closeButton setTitle:closeButtonText forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
        [closeButton changeYPosition:self.frame.size.height - BUTTON_HEIGHT - 16];
        [self addSubview:closeButton];
        
        [closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)closeButtonClicked
{
    [self.delegate closeButtonClicked];
}

@end
