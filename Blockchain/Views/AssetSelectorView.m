//
//  AssetSelectorView.m
//  Blockchain
//
//  Created by kevinwu on 2/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AssetSelectorView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

#define CELL_IDENTIFIER_ASSET_SELECTOR @"assetSelectorCell"

@interface AssetSelectorView () <UITableViewDataSource, UITableViewDelegate, AssetTypeCellDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic, readwrite) BOOL isOpen;
@property (nonatomic, weak) id <AssetSelectorViewDelegate> delegate;
@property (nonatomic, readwrite) NSArray *assets;
@end

@implementation AssetSelectorView

- (id)initWithFrame:(CGRect)frame delegate:(id<AssetSelectorViewDelegate>)delegate
{
    if (self == [super initWithFrame:frame]) {

        self.assets = @[[NSNumber numberWithInteger:LegacyAssetTypeBitcoin],
                        [NSNumber numberWithInteger:LegacyAssetTypeEther],
                        [NSNumber numberWithInteger:LegacyAssetTypeBitcoinCash],
                        [NSNumber numberWithInteger:LegacyAssetTypeStellar]];
        
        self.clipsToBounds = YES;
        
        self.delegate = delegate;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerNib:[UINib nibWithNibName:@"AssetTypeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[AssetTypeCell identifier]];
        [self addSubview:self.tableView];

        self.tableView.backgroundColor = UIColor.darkBlue;
        self.backgroundColor = [UIColor clearColor];

        [self.tableView changeHeight:[ConstantsObjcBridge assetTypeCellHeight] * self.assets.count];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame assets:(NSArray *)assets delegate:(id<AssetSelectorViewDelegate>)delegate
{
    AssetSelectorView *assetSelectorView = [self initWithFrame:frame delegate:delegate];
    assetSelectorView.assets = assets;
    return assetSelectorView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LegacyAssetType legacyAsset = self.isOpen ? [self.assets[indexPath.row] integerValue] : self.selectedAsset;
    BOOL showChevron = indexPath.row == 0;
    AssetType asset = [AssetTypeLegacyHelper convertFromLegacy:legacyAsset];

    AssetTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:[AssetTypeCell identifier]];
    [cell configureWith:asset showChevronButton:showChevron];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isOpen ? self.assets.count : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOpen) {
        AssetTypeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.selectedAsset = cell.legacyAssetType;
        [self.delegate didSelectAsset:cell.legacyAssetType];
        [self close];
    } else {
        [self open];
        [self.delegate didOpenSelector];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ConstantsObjcBridge assetTypeCellHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssetTypeCell *assetTypeCell = (AssetTypeCell *)cell;
    Direction direction = self.isOpen ? DirectionUp : DirectionDown;
    [assetTypeCell pointChevronButton:direction];
}

- (void)hide
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self changeHeight:0];
    }];
}

- (void)show
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self changeHeight:[ConstantsObjcBridge assetTypeCellHeight]];
    }];
}

- (void)open
{
    self.isOpen = YES;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self.tableView reloadData];
        [self changeHeight:[ConstantsObjcBridge assetTypeCellHeight] * self.assets.count];
    }];
}

- (void)close
{
    if (self.isOpen) {
        self.isOpen = NO;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self.tableView reloadData];
            [self changeHeight:[ConstantsObjcBridge assetTypeCellHeight]];
        }];
    }
}

- (void)reload
{
    [self.tableView reloadData];
}

#pragma mark - AssetTypeCellDelegate

- (void)didTapChevronButton
{
    if (self.isOpen) {
        [self.delegate didSelectAsset:self.selectedAsset];
        [self close];
    } else {
        [self open];
        [self.delegate didOpenSelector];
    }
}

@end
