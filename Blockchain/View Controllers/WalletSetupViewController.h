//
//  WalletSetupViewController.h
//  Blockchain
//
//  Created by kevinwu on 3/27/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetupDelegate
- (void)enableTouchIDClicked:(void (^_Nonnull)(BOOL success))completion;
@end

@interface WalletSetupViewController : UIViewController
@property (nonatomic) id<SetupDelegate> delegate;
@property (nonatomic) BOOL emailOnly;
- (id)initWithSetupDelegate:(id<SetupDelegate>)delegate;
@end
