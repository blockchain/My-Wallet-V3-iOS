//
//  FeeTableCell.h
//  Blockchain
//
//  Created by kevinwu on 5/8/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeeTypes.h"

@interface FeeTableCell : UITableViewCell
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic, readonly) FeeType feeType;

- (id)initWithFeeType:(FeeType)feeType;

@end
