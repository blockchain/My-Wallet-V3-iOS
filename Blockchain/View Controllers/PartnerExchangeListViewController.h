//
//  PartnerExchangeListViewController.h
//  Blockchain
//
//  Created by kevinwu on 10/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartnerExchangeListViewController : UIViewController
+ (PartnerExchangeListViewController * _Nonnull)createWithCountryCode:(NSString *_Nonnull)countryCode;
- (void)reloadSymbols;
@end
