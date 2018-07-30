//
//  SendEtherViewController.h
//  Blockchain
//
//  Created by kevinwu on 8/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EtherAmountInputViewController.h"

@interface SendEtherViewController : EtherAmountInputViewController
@property (nonatomic) NSString *addressToSet;
@property (nonatomic, readonly) DestinationAddressSource addressSource;
- (void)reload;
- (void)reloadAfterMultiAddressResponse;
- (void)getHistory;
- (void)keepCurrentPayment;
- (void)didUpdatePayment:(NSDictionary *)payment;
- (void)updateExchangeRate:(NSDecimalNumber *)rate;
- (void)clearFundsAvailable;
@end
