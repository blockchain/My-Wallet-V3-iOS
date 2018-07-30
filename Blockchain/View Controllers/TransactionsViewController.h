//
//  TransactionsViewController.h
//  Blockchain
//
//  Created by kevinwu on 9/9/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionsViewController : UIViewController
@property (nonatomic) NSInteger filterIndex;
- (void)changeFilterLabel:(NSString *)newText;
@end
