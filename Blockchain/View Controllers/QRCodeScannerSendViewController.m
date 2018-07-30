//
//  QRCodeScannerSendViewController.m
//  Blockchain
//
//  Created by kevinwu on 9/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "QRCodeScannerSendViewController.h"
#import "Blockchain-Swift.h"

@interface QRCodeScannerSendViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation QRCodeScannerSendViewController

- (IBAction)QRCodebuttonClicked:(id)sender
{
    if (!_captureSession) {
        [self startReadingQRCode];
    }
}

- (BOOL)startReadingQRCode
{
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputForQRScannerAndReturnError:&error];
    if (!input) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
            [AlertViewPresenter.sharedInstance showNeedsCameraPermissionAlert];
        } else {
            [AlertViewPresenter.sharedInstance standardNotifyWithMessage:[error localizedDescription] title:LocalizationConstantsObjcBridge.error in:self handler:nil];
        }
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    CGRect rootFrame = UIApplication.sharedApplication.keyWindow.rootViewController.view.frame;
    [_videoPreviewLayer setFrame:rootFrame];
    
    UIView *view = [[UIView alloc] initWithFrame:rootFrame];
    [view.layer addSublayer:_videoPreviewLayer];

    [[ModalPresenter sharedInstance] showModalWithContent:view closeType:ModalCloseTypeClose showHeader:YES headerText:[LocalizationConstantsObjcBridge scanQRCode] onDismiss:^{
        [self->_captureSession stopRunning];
        self->_captureSession = nil;
        [self->_videoPreviewLayer removeFromSuperlayer];
    } onResume:nil];
    
    [_captureSession startRunning];
    
    return YES;
}

- (void)stopReadingQRCode
{
    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
    
    // Go to the send screen if we are not already on it
    [AppCoordinator.sharedInstance.tabControllerManager showSendCoinsAnimated:YES];
}

@end
