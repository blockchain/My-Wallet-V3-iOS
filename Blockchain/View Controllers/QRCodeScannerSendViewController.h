//
//  QRCodeScannerSendViewController.h
//  Blockchain
//
//  Created by kevinwu on 9/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class QRCodeScannerSendViewController;

@protocol QRCodeScannerViewControllerDelegate
- (void)qrCodeScannerViewController:(QRCodeScannerSendViewController *_Nonnull)qrCodeScannerViewController didScanString:(NSString *_Nullable)scannedString;
@end

/**
 A view controller that handles scanning a QR code. The scanned string will then be reported
 back to the set QRCodeScannerViewControllerDelegate.
 */
@interface QRCodeScannerSendViewController : UIViewController

@property (nonatomic) id <QRCodeScannerViewControllerDelegate> delegate;

- (IBAction)QRCodebuttonClicked:(id)sender;

@end
