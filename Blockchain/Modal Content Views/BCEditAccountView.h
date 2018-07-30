//
//  BCEditAccountView.h
//  Blockchain
//
//  Created by Mark Pfluger on 12/1/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Assets.h"
@class BCSecureTextField;

@interface BCEditAccountView : UIView <UITextFieldDelegate>

@property int accountIdx;
@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic, strong) BCSecureTextField *labelTextField;
- (id)initWithAssetType:(LegacyAssetType)assetType;
@end
