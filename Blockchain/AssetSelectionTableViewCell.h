//
//  AssetSelectionTableViewCell.h
//  Blockchain
//
//  Created by kevinwu on 2/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Assets.h"

@interface AssetSelectionTableViewCell : UITableViewCell
@property (nonatomic, readonly) LegacyAssetType assetType;
@property (nonatomic) UIImageView *downwardChevron;
- (id)initWithAsset:(LegacyAssetType)assetType;
@end
