//
//  BCPricePreviewView.h
//  Blockchain
//
//  Created by kevinwu on 2/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCPricePreviewView : UIView

- (id)initWithFrame:(CGRect)frame assetName:(NSString *)name price:(NSString *)price assetImage:(NSString *)assetImage;
- (void)updatePrice:(NSString *)price;

@end
