//
//  StateSelectorViewController.h
//  Blockchain
//
//  Created by kevinwu on 12/5/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STATE_KEY_NAME @"Name"
#define STATE_KEY_CODE @"Code"

@protocol StateSelectorDelegate
- (void)didSelectState:(NSDictionary *)state;
@end
@interface StateSelectorViewController : UIViewController
@property (nonatomic, weak) id <StateSelectorDelegate> delegate;
- (id)initWithStates:(NSArray *)states;
@end
