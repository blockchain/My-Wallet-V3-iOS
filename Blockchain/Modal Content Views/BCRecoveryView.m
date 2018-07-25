//
//  BCRecoveryView.m
//  Blockchain
//
//  Created by Matt Tuzzolo on 10/2/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCRecoveryView.h"

@implementation BCRecoveryView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.instructionsLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    self.recoveryPassphraseTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
}

- (void)modalWasDismissed{
    
    self.recoveryPassphraseTextField.text = @"";
}

@end
