//
//  TransferAmountTableCell.m
//  Blockchain
//
//  Created by Kevin Wu on 10/16/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransferAmountTableCell.h"
#import "Blockchain-Swift.h"

@implementation TransferAmountTableCell

- (id)init
{
    if (self = [super init]) {
        self.mainLabel = [UILabel new];
        self.btcLabel = [UILabel new];
        self.fiatLabel = [UILabel new];
        
        [self.contentView addSubview:self.mainLabel];
        [self.contentView addSubview:self.btcLabel];
        [self.contentView addSubview:self.fiatLabel];
        
        self.mainLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.btcLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.fiatLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat fontSize = 13;
        
        self.mainLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:fontSize];
        self.btcLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:fontSize];
        self.fiatLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:fontSize];
        
        self.mainLabel.textColor = UIColor.gray5;
        self.btcLabel.textColor = UIColor.gray5;
        self.fiatLabel.textColor = UIColor.gray5;
        
        self.mainLabel.adjustsFontSizeToFitWidth = YES;
        self.btcLabel.adjustsFontSizeToFitWidth = YES;
        self.fiatLabel.adjustsFontSizeToFitWidth = YES;

        self.btcLabel.textAlignment = NSTextAlignmentRight;
        self.fiatLabel.textAlignment = NSTextAlignmentRight;
        
        // Vertical positions
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.f constant:0.f]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fiatLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.f constant:0.f]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.btcLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.f constant:0.f]];
        
        // Heights
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.f constant:20.5]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fiatLabel
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.f constant:20.5]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.btcLabel
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.f constant:20.5]];
        
        
        // Widths
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.f constant:100]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fiatLabel
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:0.3 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.btcLabel
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:0.3 constant:0]];
        
        // Horizontal positions
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.f constant:15]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.btcLabel
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.f constant:-8]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.btcLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.fiatLabel
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.f constant:-8]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fiatLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.f constant:-15]];
    }
    return self;
}

@end
