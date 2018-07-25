//
//  ReceiveTableCell.m
//  Blockchain
//
//  Created by Ben Reeves on 19/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ReceiveTableCell.h"
#import "Blockchain-Swift.h"

@implementation ReceiveTableCell

@synthesize balanceLabel;
@synthesize labelLabel;
@synthesize addressLabel;
@synthesize watchLabel;
@synthesize balanceButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.labelLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL_MEDIUM];
    self.balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL_MEDIUM];
    self.addressLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL_MEDIUM];
    
    self.balanceLabel.adjustsFontSizeToFitWidth = YES;
    self.watchLabel.adjustsFontSizeToFitWidth = YES;
    self.watchLabel.text = [LocalizationConstantsObjcBridge nonSpendable];
}

@end
