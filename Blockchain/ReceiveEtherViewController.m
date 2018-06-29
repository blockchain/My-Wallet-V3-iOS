//
//  ReceiveEtherViewController.m
//  Blockchain
//
//  Created by kevinwu on 8/31/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ReceiveEtherViewController.h"
#import "QRCodeGenerator.h"
#import "UIView+ChangeFrameAttribute.h"
#import "UITextView+Animations.h"
#import "Blockchain-Swift.h"

@interface ReceiveEtherViewController ()
@property (nonatomic) QRCodeGenerator *qrCodeGenerator;
@property (nonatomic) UIImageView *qrCodeImageView;
@property (nonatomic) UITextView *addressTextView;
@property (nonatomic) UILabel *instructionsLabel;
@property (nonatomic) NSString *address;
@property (nonatomic) CGFloat safeAreaInsetTop;
@end

@implementation ReceiveEtherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _safeAreaInsetTop = [UIView rootViewSafeAreaInsets].top;
    CGRect frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:YES assetSelector:YES];
    CGFloat offsetY = [ConstantsObjcBridge defaultNavigationBarHeight];
    self.view.frame = CGRectOffset(frame, 0, offsetY);

    CGFloat topOffset = IS_USING_SCREEN_SIZE_4S ? 10 : 20;
    if (_safeAreaInsetTop == 44) {
        topOffset = (self.view.frame.size.height / 2) - 180;
    }
    UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topOffset, self.view.frame.size.width - 40, 0)];
    instructionsLabel.textColor = COLOR_TEXT_DARK_GRAY;
    instructionsLabel.textAlignment = NSTextAlignmentCenter;
    instructionsLabel.numberOfLines = 0;
    instructionsLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_SMALL];
    instructionsLabel.text = BC_STRING_RECEIVE_SCREEN_INSTRUCTIONS;
    [instructionsLabel sizeToFit];
    instructionsLabel.center = CGPointMake(self.view.center.x, instructionsLabel.center.y);
    [self.view addSubview:instructionsLabel];
    self.instructionsLabel = instructionsLabel;

    CGFloat imageWidth = IS_USING_SCREEN_SIZE_4S ? 170 : 200;
    CGFloat qrCodeImageViewPosX = (self.view.frame.size.width / 2) - (imageWidth / 2);
    CGFloat qrCodeImageViewPosY = instructionsLabel.frame.origin.y + instructionsLabel.frame.size.height + 10;
    UIImageView *qrCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(qrCodeImageViewPosX, qrCodeImageViewPosY, imageWidth, imageWidth)];
    [self.view addSubview:qrCodeImageView];

    UITapGestureRecognizer *tapMainQRGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainQRClicked)];
    [qrCodeImageView addGestureRecognizer:tapMainQRGestureRecognizer];
    qrCodeImageView.userInteractionEnabled = YES;
    self.qrCodeImageView = qrCodeImageView;
    
    UITextView *addressTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 50)];
    addressTextView.textColor = COLOR_TEXT_DARK_GRAY;
    addressTextView.textAlignment = NSTextAlignmentCenter;
    addressTextView.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
    [addressTextView changeYPosition:qrCodeImageView.frame.origin.y + qrCodeImageView.frame.size.height];
    addressTextView.scrollEnabled = NO;
    addressTextView.editable = NO;
    addressTextView.selectable = NO;
    addressTextView.center = CGPointMake(self.view.center.x, addressTextView.center.y);
    [self.view addSubview:addressTextView];
    
    UITapGestureRecognizer *tapGestureForAddressLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainQRClicked)];
    [addressTextView addGestureRecognizer:tapGestureForAddressLabel];
    addressTextView.userInteractionEnabled = YES;
    self.addressTextView = addressTextView;
    
    CGFloat requestButtonOriginY = self.view.frame.size.height - BUTTON_HEIGHT - 20;
    UIButton *requestButton = [[UIButton alloc] initWithFrame:CGRectMake(0, requestButtonOriginY, self.view.frame.size.width - 40, BUTTON_HEIGHT)];
    requestButton.center = CGPointMake(self.view.center.x, requestButton.center.y);
    [requestButton setTitle:BC_STRING_REQUEST_PAYMENT forState:UIControlStateNormal];
    requestButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    requestButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    requestButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    [requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestButton addTarget:self action:@selector(requestButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestButton];
}

- (void)reload
{
    [self showEtherAddress];
}

- (void)showEtherAddress
{
    NSString *etherAddress = [WalletManager.sharedInstance.wallet getEtherAddress];
    self.instructionsLabel.text = etherAddress == nil ? BC_STRING_RECEIVE_ETHER_REENTER_SECOND_PASSWORD_INSTRUCTIONS : BC_STRING_RECEIVE_SCREEN_INSTRUCTIONS;
    self.address = etherAddress;
    self.addressTextView.text = self.address;
    
    self.qrCodeImageView.image = [self.qrCodeGenerator createQRImageFromString:self.address];
}

- (QRCodeGenerator *)qrCodeGenerator
{
    if (!_qrCodeGenerator) {
        _qrCodeGenerator = [[QRCodeGenerator alloc] init];
    }
    return _qrCodeGenerator;
}

- (void)mainQRClicked
{
    if (self.address) {
        [self.addressTextView animateFromText:self.address toIntermediateText:BC_STRING_COPIED_TO_CLIPBOARD speed:1 gestureReceiver:self.addressTextView];
        [UIPasteboard generalPasteboard].string = self.address;
    }
}

- (void)requestButtonClicked
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access share button when not initialized!");
        return;
    }

    NSString *message = [NSString stringWithFormat:BC_STRING_PAYMENT_REQUEST_ETHER_ARGUMENT, self.address];
    
    NSArray *activityItems = @[message, self];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePostToFacebook];
    
    [activityViewController setValue:BC_STRING_PAYMENT_REQUEST_ETHER_SUBJECT forKey:@"subject"];

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:activityViewController animated:YES completion:nil];
}

@end
