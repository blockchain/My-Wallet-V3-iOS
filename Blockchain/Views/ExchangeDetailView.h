//
//  ExchangeDetailView.h
//  Blockchain
//
//  Created by Maurice A. on 11/20/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExchangeTrade.h"

@protocol ExchangeDetailViewDelegate
- (void)orderIDTapped:(NSString *)orderID;
@end
@interface ExchangeDetailView : UIView
@property (nonatomic, weak) id <ExchangeDetailViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame fetchedTrade:(ExchangeTrade *)trade;
- (instancetype)initWithFrame:(CGRect)frame builtTrade:(ExchangeTrade *)trade;
@end
