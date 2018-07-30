//
//  AssetSelectorView.h
//  Blockchain
//
//  Created by kevinwu on 2/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Assets.h"

#define ASSET_SELECTOR_ROW_HEIGHT 36
@protocol AssetSelectorViewDelegate
- (void)didSelectAsset:(LegacyAssetType)assetType;
- (void)didOpenSelector;
@end
@interface AssetSelectorView : UIView
@property (nonatomic) LegacyAssetType selectedAsset;
@property (nonatomic, readonly) NSArray *assets;
@property (nonatomic, readonly) BOOL isOpen;
- (id)initWithFrame:(CGRect)frame delegate:(id<AssetSelectorViewDelegate>)delegate;
- (id)initWithFrame:(CGRect)frame assets:(NSArray *)assets delegate:(id<AssetSelectorViewDelegate>)delegate;
- (void)close;
- (void)open;
- (void)hide;
- (void)show;
- (void)reload;
@end
