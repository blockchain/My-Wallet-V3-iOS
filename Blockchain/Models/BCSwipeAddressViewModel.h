//
//  BCSwipeAddressViewModel.h
//  Blockchain
//
//  Created by kevinwu on 3/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Assets.h"

@interface BCSwipeAddressViewModel : NSObject
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *textAddress;
@property (nonatomic) NSString *action;
@property (nonatomic) NSString *assetImageViewName;
@property (nonatomic) LegacyAssetType assetType;
- (id)initWithAssetType:(LegacyAssetType)assetType;
@end
