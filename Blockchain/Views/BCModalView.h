//
//  BCModalView.h
//  Blockchain
//
//  Created by Ben Reeves on 19/07/2014.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCModalContentView.h"

//	Modal close codes
typedef enum {
    ModalCloseTypeClose = 100,
    ModalCloseTypeBack = 200,
    ModalCloseTypeNone = 300
}ModalCloseType;

@interface BCModalView : UIView

@property(nullable, nonatomic, copy) void (^onDismiss)();
@property(nullable, nonatomic, copy) void (^onResume)();
@property(nonatomic, strong) IBOutlet UIView *myHolderView;
@property(nonatomic, strong) IBOutlet UIButton *closeButton;
@property(nonatomic, strong) IBOutlet UIButton *backButton;

@property(nonatomic) ModalCloseType closeType;

- (id)initWithCloseType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText;
- (IBAction)closeModalClicked:(id)sender;

@end
