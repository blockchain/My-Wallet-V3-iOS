//
//  AssetSelectorView.m
//  Blockchain
//
//  Created by kevinwu on 2/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AssetSelectorView.h"
#import "AssetSelectionTableViewCell.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

#define CELL_IDENTIFIER_ASSET_SELECTOR @"assetSelectorCell"

@interface AssetSelectorView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic, readwrite) BOOL isOpen;
@property (nonatomic, weak) id <AssetSelectorViewDelegate> delegate;
@property (nonatomic, readwrite) NSArray *assets;
@end

@implementation AssetSelectorView

- (id)initWithFrame:(CGRect)frame delegate:(id<AssetSelectorViewDelegate>)delegate
{
    if (self == [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        
        self.delegate = delegate;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        
        [self.tableView changeHeight:ASSET_SELECTOR_ROW_HEIGHT * 3];
        
        self.tableView.backgroundColor = UIColor.brandPrimary;
        self.backgroundColor = [UIColor clearColor];
        
        self.assets = @[[NSNumber numberWithInteger:LegacyAssetTypeBitcoin],
                        [NSNumber numberWithInteger:LegacyAssetTypeEther],
                        [NSNumber numberWithInteger:LegacyAssetTypeBitcoinCash]];
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
    LegacyAssetType asset = self.isOpen ? [self.assets[indexPath.row] integerValue] : self.selectedAsset;
    AssetSelectionTableViewCell *cell = [[AssetSelectionTableViewCell alloc] initWithAsset:asset];
    cell.downwardChevron.hidden = indexPath.row != 0;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isOpen ? self.assets.count : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOpen) {
        AssetSelectionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.selectedAsset = cell.assetType;
        [self.delegate didSelectAsset:cell.assetType];
        [self close];
    } else {
        [self open];
        [self.delegate didOpenSelector];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ASSET_SELECTOR_ROW_HEIGHT;
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
        [self changeHeight:ASSET_SELECTOR_ROW_HEIGHT];
    }];
}

- (void)open
{
    self.isOpen = YES;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self.tableView reloadData];
        [self changeHeight:ASSET_SELECTOR_ROW_HEIGHT * self.assets.count];
    }];
}

- (void)close
{
    if (self.isOpen) {
        self.isOpen = NO;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self.tableView reloadData];
            [self changeHeight:ASSET_SELECTOR_ROW_HEIGHT];
        }];
    }
}

- (void)reload
{
    [self.tableView reloadData];
}

@end
