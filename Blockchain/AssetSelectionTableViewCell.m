//
//  AssetSelectionTableViewCell.m
//  Blockchain
//
//  Created by kevinwu on 2/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AssetSelectionTableViewCell.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface AssetSelectionTableViewCell ()
@property (nonatomic, readwrite) LegacyAssetType assetType;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UILabel *label;
@property (nonatomic) UIImageView *assetImageView;
@end

@implementation AssetSelectionTableViewCell

- (id)initWithAsset:(LegacyAssetType)assetType
{
    if (self == [super init]) {
        
        self.assetType = assetType;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor clearColor];
        
        NSString *text;
        NSString *assetImage;
        
        if (assetType == LegacyAssetTypeBitcoin) {
            text = [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoin];
            assetImage = @"bitcoin_white";
        } else if (assetType == LegacyAssetTypeEther) {
            text = [AssetTypeLegacyHelper descriptionFor:AssetTypeEthereum];
            assetImage = @"ether_white";
        } else if (assetType == LegacyAssetTypeBitcoinCash) {
            text = [AssetTypeLegacyHelper descriptionFor:AssetTypeBitcoinCash];
            assetImage = @"bitcoin_cash_white";
        }
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
        self.label.textColor = [UIColor whiteColor];
        self.label.text = text;
        [self.label sizeToFit];
        
        CGFloat containerViewHeight = 26;
        
        CGFloat assetImageViewHeight = 20;
        self.assetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (containerViewHeight - assetImageViewHeight)/2, assetImageViewHeight, assetImageViewHeight)];
        self.assetImageView.image = [UIImage imageNamed:assetImage];
        
        CGFloat chevronImageViewHeight = 14;
        self.downwardChevron = [[UIImageView alloc] initWithFrame:CGRectMake(0, (containerViewHeight - chevronImageViewHeight)/2, chevronImageViewHeight, chevronImageViewHeight)];
        self.downwardChevron.image = [UIImage imageNamed:@"chevron_down_white"];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.assetImageView.bounds.size.width + 8 + self.label.bounds.size.width + 8 + self.downwardChevron.bounds.size.width, 26)];
        [self.containerView addSubview:self.label];
        [self.containerView addSubview:self.assetImageView];
        [self.containerView addSubview:self.downwardChevron];

        [self.assetImageView changeXPosition:0];
        self.label.frame = CGRectMake(self.assetImageView.bounds.size.width + 8, (containerViewHeight - self.label.bounds.size.height)/2, self.label.bounds.size.width, self.label.bounds.size.height);
        [self.downwardChevron changeXPosition:self.label.frame.origin.x + self.label.frame.size.width + 8];
        [self addSubview:self.containerView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.containerView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

@end
