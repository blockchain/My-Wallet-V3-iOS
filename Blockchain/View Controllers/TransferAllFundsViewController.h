//
//  TransferAllFundsViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 10/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TransferAllPromptDelegate
- (void)didTransferAll;
- (void)showAlert:(UIAlertController *)alert;
- (void)showSyncingView;
@end
@interface TransferAllFundsViewController : UIViewController
@property (nonatomic) id<TransferAllPromptDelegate> delegate;
- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed;
- (void)showSummaryForTransferAll;
- (void)sendDuringTransferAll:(NSString *)secondPassword;
@end
