//
//  BuyBitcoinNavigationController.m
//  Blockchain
//
//  Created by kevinwu on 3/13/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BuyBitcoinNavigationController.h"
#import "Blockchain-Swift.h"

typedef enum {
    DismissStateDefault,
    DismissStateWillPreventExtraDismiss,
    DismissStateIsPreventingExtraDismiss,
}DismissState;

@interface BuyBitcoinNavigationController ()
@property (nonatomic) DismissState dismissState;
@end

@implementation BuyBitcoinNavigationController

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if ([viewControllerToPresent isMemberOfClass:[UIImagePickerController class]] && [(UIImagePickerController *)viewControllerToPresent sourceType] == UIImagePickerControllerSourceTypeCamera) {
        [super presentViewController:viewControllerToPresent animated:flag completion:^{

            NSError *error;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputForQRScannerAndReturnError:&error];
            if (!input) {
                if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
                    [AlertViewPresenter.sharedInstance showNeedsCameraPermissionAlert];
                } else {
                    [AlertViewPresenter.sharedInstance standardNotifyWithMessage:[error localizedDescription] title:LocalizationConstantsObjcBridge.error handler:nil];
                }
            }

            if (completion) completion();
        }];
    } else {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    
    // http://stackoverflow.com/questions/35999551/uiimagepickercontroller-view-is-not-in-the-window-hierarchy
    
    self.dismissState = [viewControllerToPresent isMemberOfClass:[UIDocumentMenuViewController class]] ? DismissStateWillPreventExtraDismiss : DismissStateDefault;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (self.dismissState == DismissStateWillPreventExtraDismiss) {
        if ([self.presentedViewController isMemberOfClass:[UIDocumentMenuViewController class]]) {
            // User selected an action - dismissViewControllerAnimated:completion: will be called an extra time, but the first time must be allowed otherwise the UIDocumentMenuViewController will not dismiss at all.
            [super dismissViewControllerAnimated:flag completion:completion];
            self.dismissState = DismissStateIsPreventingExtraDismiss;
            return;
        } else {
            // User selected cancel - UIDocumentMenuViewController has been dismissed from a separate dismiss method, but dismissViewControllerAnimated:completion: will be called an extra time.
            self.dismissState = DismissStateDefault;
            return;
        }
    } else if (self.dismissState == DismissStateIsPreventingExtraDismiss) {
        self.dismissState = DismissStateDefault;
        return;
    } else {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

@end
