//
//  ExchangeCreateViewController.h
//  Blockchain
//
//  Created by kevinwu on 10/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ExchangeRate;
@interface PartnerExchangeCreateViewController : UIViewController
- (void)didGetExchangeRate:(ExchangeRate *)result;
- (void)didGetAvailableEthBalance:(NSDictionary *)result;
- (void)didGetAvailableBtcBalance:(NSDictionary *)result;
- (void)didBuildExchangeTrade:(NSDictionary *)tradeInfo;
@end
