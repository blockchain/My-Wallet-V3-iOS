//
//  BCRecoveryView.h
//  Blockchain
//
//  Created by Matt Tuzzolo on 10/2/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCModalContentView.h"

@interface BCRecoveryView : BCModalContentView


@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, strong) IBOutlet UITextField *recoveryPassphraseTextField;

@end
