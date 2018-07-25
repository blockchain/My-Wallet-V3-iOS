//
//  ExchangeConfirmViewController.h
//  Blockchain
//
//  Created by kevinwu on 10/31/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ExchangeTrade;
@interface ExchangeConfirmViewController : UIViewController
- (id)initWithExchangeTrade:(ExchangeTrade *)trade;
@end
