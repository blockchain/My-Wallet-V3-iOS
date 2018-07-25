//
//  QRCodeGenerator.h
//  Blockchain
//
//  Created by Kevin Wu on 1/29/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRCodeGenerator : NSObject
- (UIImage *)qrImageFromAddress:(NSString *)address;
- (UIImage *)qrImageFromAddress:(NSString *)address amount:(double)amount;
- (UIImage *)createQRImageFromString:(NSString *)string;
@end
