//
//  QRCodeGenerator.m
//  Blockchain
//
//  Created by Kevin Wu on 1/29/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "QRCodeGenerator.h"
#import "Blockchain-Swift.h"

@implementation QRCodeGenerator

- (UIImage *)qrImageFromAddress:(NSString *)address
{
    NSString *addressURL = [NSString stringWithFormat:@"%@%@", [ConstantsObjcBridge bitcoinUriPrefix], address];
    
    return [self createQRImageFromString:addressURL];
}

- (UIImage *)qrImageFromAddress:(NSString *)address amount:(double)amount
{
    NSString *amountString = [[NSNumberFormatter assetFormatterWithUSLocale] stringFromNumber:[NSNumber numberWithDouble:amount]];
    
    NSString *addressURL = [NSString stringWithFormat:@"%@%@?amount=%@", [ConstantsObjcBridge bitcoinUriPrefix], address, amountString];
    
    return [self createQRImageFromString:addressURL];
}

- (UIImage *)createQRImageFromString:(NSString *)string
{
    return [self createNonInterpolatedUIImageFromCIImage:[self createQRFromString:string] withScale:10*[[UIScreen mainScreen] scale]];
}

- (CIImage *)createQRFromString:(NSString *)qrString
{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage = [UIImage imageWithCGImage:[scaledImage CGImage]
                                           scale:[scaledImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    
    return qrImage;
}

@end
