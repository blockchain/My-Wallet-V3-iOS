//
//  FeeTableCell.m
//  Blockchain
//
//  Created by kevinwu on 5/8/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "FeeTableCell.h"
#import "Blockchain-Swift.h"

@implementation FeeTableCell

- (id)initWithFeeType:(FeeType)feeType
{
    if (self = [super init]) {
        _feeType = feeType;
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat leftLabelHeight = 22;
    CGFloat offset = IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 8 : 3;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.contentView.center.y - leftLabelHeight + offset, 100, leftLabelHeight)];
    self.nameLabel.textColor = UIColor.gray5;
    self.nameLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    [self.contentView addSubview:self.nameLabel];

    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.contentView.center.y + offset, 200, leftLabelHeight)];
    self.descriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    self.descriptionLabel.textColor = UIColor.gray2;
    [self.contentView addSubview:self.descriptionLabel];

    if (self.feeType != FeeTypeCustom) {
        
        NSString *nameLabelText;
        NSString *descriptionLabelText;
        
        if (self.feeType == FeeTypeRegular) {
            nameLabelText = BC_STRING_REGULAR;
            descriptionLabelText = BC_STRING_GREATER_THAN_ONE_HOUR;
        } else if (self.feeType == FeeTypePriority) {
            nameLabelText = BC_STRING_PRIORITY;
            descriptionLabelText = BC_STRING_LESS_THAN_ONE_HOUR;
        }
        
        self.nameLabel.text = nameLabelText;
        self.descriptionLabel.text = descriptionLabelText;
    } else {
        self.nameLabel.text = BC_STRING_CUSTOM;
        self.descriptionLabel.text = BC_STRING_ADVANCED_USERS_ONLY;
    }
}

@end
