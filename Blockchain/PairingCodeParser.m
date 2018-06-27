//
//  PairingCodeDelegate.m
//  Blockchain
//
//  Created by Ben Reeves on 22/07/2014.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "PairingCodeParser.h"
#import "Blockchain-Swift.h"

@implementation PairingCodeParser
{
    UIView *topBar;
}

- (id)initWithSuccess:(void (^)(NSDictionary*))__success error:(void (^)(NSString*))__error
{
    self = [super init];
    
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        self.success = __success;
        self.error = __error;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:NO assetSelector:NO];

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInsetTop;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
    } else {
        safeAreaInsetTop = 20;
    }

    CGFloat topBarHeight = ConstantsObjcBridge.defaultNavigationBarHeight + safeAreaInsetTop;
    UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, topBarHeight)];
    topBarView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    [self.view addSubview:topBarView];
    topBar = topBarView;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, safeAreaInsetTop + 6, 200, 30)];
    headerLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_TOP_BAR_TEXT];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.text = BC_STRING_SCAN_PAIRING_CODE;
    headerLabel.center = CGPointMake(topBarView.center.x, headerLabel.center.y);
    [topBarView addSubview:headerLabel];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 80, 51)];
    closeButton.imageEdgeInsets = IMAGE_EDGE_INSETS_CLOSE_BUTTON_X;
    closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeButton.center = CGPointMake(closeButton.center.x, headerLabel.center.y);
    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topBarView addSubview:closeButton];
    
    [self startReadingQRCode];
}

- (void)closeButtonClicked:(id)sender
{
    [self stopReadingQRCode];
    
    [_videoPreviewLayer removeFromSuperlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startReadingQRCode
{
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        // This should never happen - all devices we support (iOS 7+) have cameras
        DLog(@"QR code scanner problem: %@", [error localizedDescription]);
        return;
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

    CGFloat topBarHeight = topBar.frame.size.height;
    CGRect frame = CGRectMake(0, topBarHeight, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height - topBarHeight);
    
    [_videoPreviewLayer setFrame:frame];
    
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
}

- (void)stopReadingQRCode
{
    [_captureSession stopRunning];
    _captureSession = nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // do something useful with results
            [self stopReadingQRCode];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [_videoPreviewLayer removeFromSuperlayer];
                
                [self dismissViewControllerAnimated:YES completion:nil];

                [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_PARSING_PAIRING_CODE];
            });
            
            [WalletManager.sharedInstance.wallet loadBlankWallet];
            
            WalletManager.sharedInstance.wallet.delegate = self;
            
            [WalletManager.sharedInstance.wallet parsePairingCode:[metadataObj stringValue]];
        }
    }
}

- (void)errorParsingPairingCode:(NSString *)message
{
    [[LoadingViewPresenter sharedInstance] hideBusyView];

    if (self.error) {
        if ([message containsString:ERROR_INVALID_PAIRING_VERSION_CODE]) {
            self.error(BC_STRING_INVALID_PAIRING_CODE);
        } else if ([message containsString:ERROR_TYPE_MUST_START_WITH_NUMBER] || [message containsString:ERROR_FIRST_ARGUMENT_MUST_BE_STRING]){
            self.error(BC_STRING_ERROR_PLEASE_REFRESH_PAIRING_CODE);
        } else {
            self.error(message);
        }
    }

    WalletManager.sharedInstance.wallet.delegate = WalletManager.sharedInstance;
}

-(void)didParsePairingCode:(NSDictionary *)dict
{
    WalletManager.sharedInstance.wallet.didPairAutomatically = YES;

    if (self.success) {
        self.success(dict);
    }

    WalletManager.sharedInstance.wallet.delegate = WalletManager.sharedInstance;
}

@end
