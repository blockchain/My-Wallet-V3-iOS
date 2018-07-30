//
//  BCCardView.h
//  Blockchain
//
//  Created by kevinwu on 3/28/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CardConfiguration){
    CardConfigurationWelcome,
    CardConfigurationBuySell,
};

enum {
    ActionTypeBuySell,
    ActionTypeBuyBitcoin,
    ActionTypeShowReceive,
    ActionTypeScanQR,
};

typedef NSInteger ActionType;

@protocol CardViewDelegate
- (void)cardActionClicked:(ActionType)actionType;
@end
@interface BCCardView : UIView
@property (nonatomic) id<CardViewDelegate> delegate;
@property (nonatomic) UIButton *closeButton; // Must explictly call setupCloseButton to use
- (id)initWithContainerFrame:(CGRect)frame title:(NSString *)title description:(NSString *)description actionType:(ActionType)actionType imageName:(NSString *)imageName reducedHeightForPageIndicator:(BOOL)reducedHeightForPageIndicator delegate:(id<CardViewDelegate>)delegate;
- (void)setupCloseButton;
- (CGRect)frameFromContainer:(CGRect)containerFrame;
@end
