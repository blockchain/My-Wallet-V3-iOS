//
//  EtherAmountInputViewController.h
//  Blockchain
//
//  Created by kevinwu on 8/28/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeScannerSendViewController.h"
#import "DestinationAddressSource.h"

@interface EtherAmountInputViewController : QRCodeScannerSendViewController <UITextFieldDelegate>
@property (nonatomic, readonly) DestinationAddressSource addressSource;
@end
