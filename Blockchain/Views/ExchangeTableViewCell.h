//
//  ExchangeTableViewCell.h
//  Blockchain
//
//  Created by kevinwu on 11/13/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExchangeTrade.h"

@interface ExchangeTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *amountButton;
@property (strong, nonatomic) IBOutlet UILabel *actionLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

- (void)configureWithTrade:(ExchangeTrade *)trade;

@end
