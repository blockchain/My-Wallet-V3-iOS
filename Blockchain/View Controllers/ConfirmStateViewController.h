//
//  ConfirmStateViewController.h
//  Blockchain
//
//  Created by kevinwu on 12/5/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ConfirmStateDelegate
- (void)didConfirmState:(UINavigationController *)navigationController;
@end
@interface ConfirmStateViewController : UIViewController
@property (nonatomic, weak) id <ConfirmStateDelegate> delegate;
- (id)initWithStates:(NSArray *)states;
@end
