//
//  TransactionRecipientsViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 9/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RecipientsDelegate
- (BOOL)isWatchOnlyLegacyAddress:(NSString *)addr;
- (void)toggleSymbol;
@end
@interface TransactionRecipientsViewController : UIViewController
@property (nonatomic) id<RecipientsDelegate> recipientsDelegate;
- (id)initWithRecipients:(NSArray *)recipients;
- (void)reloadTableView;
@end
