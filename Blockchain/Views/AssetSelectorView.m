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

@interface AssetSelectorView () <UITableViewDataSource, UITableViewDelegate, AssetTypeCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, readwrite) BOOL isOpen;
@property (nonatomic, readwrite) NSArray<NSNumber *> *assets;

@end

@implementation AssetSelectorView

+ (NSArray<NSNumber *> *)availableAssets {
    return @[
        @(LegacyAssetTypeBitcoin),
        @(LegacyAssetTypeEther),
        @(LegacyAssetTypeBitcoinCash)
    ];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupInParent:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame parentView:(UIView *)parentView
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInParent:parentView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray<NSNumber *> *)assets parentView:(UIView *)parentView
{
    self = [self initWithFrame:frame parentView:parentView];
    if (self) {
        self.assets = assets;
    }
    return self;
}

- (void)setupInParent:(UIView *)parentView
{
    self.assets = [AssetSelectorView availableAssets];
    self.clipsToBounds = YES;

    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.bounces = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"AssetTypeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[AssetTypeCell identifier]];
    [self addSubview:self.tableView];

    self.tableView.separatorColor = [UIColor navigationBarBackground];
    self.tableView.backgroundColor = [UIColor navigationBarBackground];
    self.backgroundColor = [UIColor navigationBarBackground];

    self.tableView.translatesAutoresizingMaskIntoConstraints = false;

    CGFloat height = [ConstantsObjcBridge assetTypeCellHeight] * self.assets.count;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.tableView.heightAnchor constraintEqualToConstant:height]
    ]];

    if (parentView != nil) {
        [self constraintToParent:parentView];
    }
}

- (void)constraintToParent:(UIView *)parentView {
    self.translatesAutoresizingMaskIntoConstraints = false;

    if (self.superview == nil) {
        [parentView addSubview:self];
    }

    CGFloat height = [ConstantsObjcBridge assetTypeCellHeight];
    self.heightConstraint = [self.heightAnchor constraintEqualToConstant:height];
    [NSLayoutConstraint activateConstraints:@[
        [parentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [parentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [parentView.topAnchor constraintEqualToAnchor:self.topAnchor],
        self.heightConstraint
    ]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LegacyAssetType legacyAsset = self.isOpen ? [self.assets[indexPath.row] integerValue] : self.selectedAsset;
    BOOL showChevron = indexPath.row == 0;

    AssetTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:[AssetTypeCell identifier] forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0);
    [cell configureWith:legacyAsset showChevronButton:showChevron];
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
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.heightConstraint.constant = 0;
        [self.superview layoutIfNeeded];
    }];
}

- (void)show
{
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.heightConstraint.constant = [ConstantsObjcBridge assetTypeCellHeight];
        [self.superview layoutIfNeeded];
    }];
}

- (void)open
{
    [self reportOpen];
    
    self.isOpen = YES;

    [self.tableView reloadData];
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.heightConstraint.constant = [ConstantsObjcBridge assetTypeCellHeight] * self.assets.count;
        [self.superview layoutIfNeeded];
    } completion:nil];
}

- (void)close
{
    if (self.isOpen) {
        
        [self reportClose];
    
        self.isOpen = NO;
        
        [self.tableView reloadData];
        [self.superview layoutIfNeeded];
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.heightConstraint.constant = [ConstantsObjcBridge assetTypeCellHeight];
            [self.superview layoutIfNeeded];
        } completion:nil];
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
