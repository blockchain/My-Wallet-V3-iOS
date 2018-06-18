/********************************************************************************
*                                                                               *
* Copyright (c) 2010 Vladimir "Farcaller" Pouzanov <farcaller@gmail.com>        *
*                                                                               *
* Permission is hereby granted, free of charge, to any person obtaining a copy  *
* of this software and associated documentation files (the "Software"), to deal *
* in the Software without restriction, including without limitation the rights  *
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     *
* copies of the Software, and to permit persons to whom the Software is         *
* furnished to do so, subject to the following conditions:                      *
*                                                                               *
* The above copyright notice and this permission notice shall be included in    *
* all copies or substantial portions of the Software.                           *
*                                                                               *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, *
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     *
* THE SOFTWARE.                                                                 *
*                                                                               *
********************************************************************************/

#import "PEPinEntryController.h"
#import "QRCodeGenerator.h"
#import "KeychainItemWrapper+SwipeAddresses.h"
#import "BCSwipeAddressViewModel.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

#define PS_VERIFY	0
#define PS_ENTER1	1
#define PS_ENTER2	2

static PEViewController *EnterController()
{

	PEViewController *c = [[PEViewController alloc] init];
	c.prompt = BC_STRING_PLEASE_ENTER_PIN;
	c.title = @"";

    c.versionLabel.text = [NSBundle applicationVersion];
    c.versionLabel.hidden = NO;
    
	return c;
}

static PEViewController *NewController()
{
	PEViewController *c = [[PEViewController alloc] init];
	c.prompt = BC_STRING_PLEASE_ENTER_NEW_PIN;
	c.title = @"";

    c.versionLabel.text = [NSBundle applicationVersion];

    return c;
}

static PEViewController *VerifyController()
{
	PEViewController *c = [[PEViewController alloc] init];
	c.prompt = BC_STRING_CONFIRM_PIN;
	c.title = @"";

    c.versionLabel.text = [NSBundle applicationVersion];

	return c;
}

@implementation PEPinEntryController

@synthesize pinDelegate, verifyOnly, verifyOptional, inSettings;

+ (PEPinEntryController *)pinVerifyController
{
	PEViewController *c = EnterController();
	PEPinEntryController *n = [[self alloc] initWithRootViewController:c];
	c.delegate = n;
    n->pinController = c;
	n->pinStage = PS_VERIFY;
	n->verifyOnly = YES;    
    [n setupQRCode];
	return n;
}

+ (PEPinEntryController *)pinVerifyControllerClosable
{
    PEViewController *c = EnterController();
    PEPinEntryController *n = [[self alloc] initWithRootViewController:c];
    c.delegate = n;
    c.cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    c.cancelButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 6);
    [c.cancelButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    c.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BC_STRING_CANCEL style:UIBarButtonItemStylePlain target:n action:@selector(cancelController)];
    n->pinController = c;
    n->pinStage = PS_VERIFY;
    n->verifyOptional = YES;
    n->inSettings = YES;
    return n;
}

+ (PEPinEntryController *)pinChangeController
{
	PEViewController *c = EnterController();
	PEPinEntryController *n = [[self alloc] initWithRootViewController:c];
	c.delegate = n;
    c.cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    c.cancelButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 6);
    [c.cancelButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    c.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BC_STRING_CANCEL style:UIBarButtonItemStylePlain target:n action:@selector(cancelController)];
    n->pinController = c;
	n->pinStage = PS_VERIFY;
	n->verifyOnly = NO;
    n->inSettings = YES;
	return n;
}

+ (PEPinEntryController *)pinCreateController
{
	PEViewController *c = NewController();
	PEPinEntryController *n = [[self alloc] initWithRootViewController:c];
	c.delegate = n;
    n->pinController = c;
	n->pinStage = PS_ENTER1;
	n->verifyOnly = NO;
	return n;
}

- (void)reset
{
    [pinController resetPin];
}

- (void)setupQRCode
{
    AppFeatureConfiguration *swipeToReceiveConfiguration = [AppFeatureConfigurator.sharedInstance configurationFor:AppFeatureSwipeToReceive];
    if (!swipeToReceiveConfiguration.isEnabled) {
        pinController.swipeLabel.hidden = YES;
        pinController.swipeLabelImageView.hidden = YES;
        return;
    }

    if (self.verifyOnly && BlockchainSettings.sharedAppInstance.swipeToReceiveEnabled) {
        
        for (NSNumber *key in self.swipeViews) {
            BCSwipeAddressView *swipeView = [self.swipeViews objectForKey:key];
            [swipeView removeFromSuperview];
        }
        
        pinController.swipeLabel.alpha = 1;
        pinController.swipeLabel.hidden = NO;
        
        pinController.swipeLabelImageView.alpha = 1;
        pinController.swipeLabelImageView.hidden = NO;
        
        pinController.scrollView.backgroundColor = [UIColor clearColor];
        
        [pinController.scrollView setUserInteractionEnabled:YES];
        
        NSArray *assets = [self assets];
        
        UIPageControl *backgroundViewPageControl = [self pageControlWithAssets:assets];
        [self.view addSubview:backgroundViewPageControl];
        backgroundViewPageControl.hidden = YES;
        self.backgroundViewPageControl = backgroundViewPageControl;

        CGRect rootFrame = UIApplication.sharedApplication.keyWindow.rootViewController.view.frame;
        CGFloat windowWidth = rootFrame.size.width;
        CGFloat windowHeight = rootFrame.size.height;

        [pinController.scrollView setContentSize:CGSizeMake(windowWidth * (assets.count + 1), windowHeight)];
        [pinController.scrollView setPagingEnabled:YES];
        pinController.scrollView.delegate = self;
        
        for (int assetIndex = 0; assetIndex < assets.count; assetIndex++) {
            LegacyAssetType asset = [assets[assetIndex] integerValue];
            BCSwipeAddressViewModel *viewModel = [[BCSwipeAddressViewModel alloc] initWithAssetType:asset];
            BCSwipeAddressView *swipeView = [[BCSwipeAddressView alloc] initWithFrame:CGRectMake(windowWidth * (assetIndex + 1), 0, windowWidth, windowHeight) viewModel:viewModel delegate:self];
            [self addAddressToSwipeView:swipeView assetType:asset];
            [self.swipeViews setObject:swipeView forKey:[NSNumber numberWithInteger:asset]];
            [pinController.scrollView addSubview:swipeView];
        }
    } else {
        pinController.swipeLabel.hidden = YES;
        pinController.swipeLabelImageView.hidden = YES;
    }
}

- (void)addAddressToSwipeView:(BCSwipeAddressView *)swipeView assetType:(LegacyAssetType)assetType
{
    AssetAddressRepository *assetAddressRepository = AssetAddressRepository.sharedInstance;
    if (assetType == LegacyAssetTypeBitcoin || assetType == LegacyAssetTypeBitcoinCash) {

        AssetType type = [self assetTypeFromLegacyAssetType:assetType];

        NSString *nextAddress = [[assetAddressRepository swipeToReceiveAddressesFor:type] firstObject].address;
        
        if (nextAddress) {
            
            void (^error)(void) = ^() {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizationConstantsObjcBridge.noInternetConnection message:BC_STRING_SWIPE_TO_RECEIVE_NO_INTERNET_CONNECTION_WARNING preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [swipeView updateAddress:[LocalizationConstantsObjcBridge requestFailedCheckConnection]];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [WalletManager.sharedInstance.wallet subscribeToSwipeAddress:nextAddress assetType:assetType];
                    [swipeView updateAddress:nextAddress];
                }]];
                self.errorAlert = alert;
            };
            
            void (^success)(NSString *, BOOL) = ^(NSString *address, BOOL isUnused) {
                
                if (isUnused) {
                    [WalletManager.sharedInstance.wallet subscribeToSwipeAddress:nextAddress assetType:assetType];
                    [swipeView updateAddress:address];
                    self.errorAlert = nil;
                } else {
                    [assetAddressRepository removeFirstSwipeAddressFor:type];
                    self.errorAlert = nil;
                }
            };
            [[AssetAddressRepository sharedInstance] checkForUnusedAddress:nextAddress
                                                            displayAddress:nextAddress
                                                                 assetType:[self assetTypeFromLegacyAssetType:assetType]
                                                            successHandler:success
                                                              errorHandler:error];
        } else {
            [swipeView updateAddress:nextAddress];
        }
    } else if (assetType == LegacyAssetTypeEther) {
        NSString *etherAddress = [[assetAddressRepository swipeToReceiveAddressesFor:AssetTypeEthereum] firstObject].address;
        if (etherAddress) {
            [swipeView updateAddress:etherAddress];
        }
    }
}

- (AssetType)assetTypeFromLegacyAssetType:(LegacyAssetType)legacyAssetType
{
    switch (legacyAssetType) {
        case LegacyAssetTypeBitcoin:
            return AssetTypeBitcoin;
        case LegacyAssetTypeBitcoinCash:
            return AssetTypeBitcoinCash;
        case LegacyAssetTypeEther:
            return AssetTypeEthereum;
    }
}

- (void)paymentReceived:(LegacyAssetType)assetType
{
    AssetType type = [self assetTypeFromLegacyAssetType: assetType];

    if (type != AssetTypeBitcoin && type != AssetTypeBitcoinCash) {
        return;
    }

    AssetAddressRepository *assetAddressRepository = AssetAddressRepository.sharedInstance;
    if ([assetAddressRepository swipeToReceiveAddressesFor:type].count <= 0) {
        return;
    }
    [assetAddressRepository removeFirstSwipeAddressFor:type];

    BCSwipeAddressView *swipeView = [self.swipeViews objectForKey:[NSNumber numberWithInteger:assetType]];
    [self addAddressToSwipeView:swipeView assetType:assetType];
}

- (void)pinEntryControllerDidEnteredPin:(PEViewController *)controller
{
	switch (pinStage) {
		case PS_VERIFY: {
			[self.pinDelegate pinEntryController:self shouldAcceptPin:[controller.pin intValue] callback:^(BOOL yes) {
                if (yes) {
                    if(verifyOnly == NO) {
                        PEViewController *c = NewController();
                        c.delegate = self;
                        pinStage = PS_ENTER1;
                        [[self navigationController] pushViewController:c animated:NO];
                        self.viewControllers = [NSArray arrayWithObject:c];
                    }
                } else {
                    controller.prompt = LocalizationConstantsObjcBridge.incorrectPin;
                    [controller resetPin];
                }
            }];
			break;
        }
		case PS_ENTER1: {
			pinEntry1 = [controller.pin intValue];
			PEViewController *c = VerifyController();
			c.delegate = self;
			[[self navigationController] pushViewController:c animated:NO];
			self.viewControllers = [NSArray arrayWithObject:c];
			pinStage = PS_ENTER2;
            [self.pinDelegate pinEntryController:self willChangeToNewPin:[controller.pin intValue]];
			break;
		}
		case PS_ENTER2:
			if([controller.pin intValue] != pinEntry1) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:BC_PIN_NO_MATCH preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
				PEViewController *c = NewController();
				c.delegate = self;
				self.viewControllers = [NSArray arrayWithObjects:c, [self.viewControllers objectAtIndex:0], nil];
				[self popViewControllerAnimated:NO];
                [self presentViewController:alert animated:YES completion:nil];
			} else {
				[self.pinDelegate pinEntryController:self changedPin:[controller.pin intValue]];
			}
			break;
		default:
			break;
	}
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	pinStage = PS_ENTER1;
	return [super popViewControllerAnimated:animated];
}

- (void)cancelController
{
	[self.pinDelegate pinEntryControllerDidCancel:self];
}

- (NSMutableDictionary *)swipeViews
{
    if (!_swipeViews) _swipeViews = [[NSMutableDictionary alloc] init];
    return _swipeViews;
}

- (NSArray *)assets
{
    return @[[NSNumber numberWithInteger:LegacyAssetTypeBitcoin], [NSNumber numberWithInteger:LegacyAssetTypeEther], [NSNumber numberWithInteger:LegacyAssetTypeBitcoinCash]];
}

#pragma mark Debug Menu

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#ifdef DEBUG
    if (self.verifyOnly) {
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        self.longPressGesture.minimumPressDuration = DURATION_LONG_PRESS_GESTURE_DEBUG;
        self.debugButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 80, 51)];
        self.debugButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.debugButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.debugButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)];
        [self.debugButton setTitle:DEBUG_STRING_DEBUG forState:UIControlStateNormal];
        [self.debugButton setTitleColor:COLOR_BLOCKCHAIN_BLUE forState:UIControlStateNormal];
        [self.view addSubview:self.debugButton];
        [self.debugButton addGestureRecognizer:self.longPressGesture];
    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.longPressGesture = nil;
    [self.debugButton removeFromSuperview];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [[AppCoordinator sharedInstance] showDebugViewWithPresenter:DEBUG_PRESENTER_PIN_VERIFY];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 0 && self.errorAlert) {
        [self presentViewController:self.errorAlert animated:YES completion:nil];
        self.errorAlert = nil;
    }
    
    if (scrollView.contentOffset.x > self.view.frame.size.width - 1) {
        self.backgroundViewPageControl.hidden = NO;
        self.scrollViewPageControl.hidden = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.scrollViewPageControl) {
        CGFloat windowWidth = self.view.frame.size.width;
        UIPageControl *scrollViewPageControl = [self pageControlWithAssets:[self assets]];
        [scrollViewPageControl changeXPosition:scrollViewPageControl.frame.origin.x + windowWidth];
        [pinController.scrollView addSubview:scrollViewPageControl];
        scrollViewPageControl.hidden = YES;
        scrollViewPageControl.currentPage = 1;
        self.scrollViewPageControl = scrollViewPageControl;
    }
    
    [self updatePage:scrollView];
    
    if (scrollView.contentOffset.x > self.view.frame.size.width - 1) {
        if (!self.didScrollToQRCode) {
            self.didScrollToQRCode = YES;
            [self reset];
        }
        self.backgroundViewPageControl.hidden = NO;
        self.scrollViewPageControl.hidden = YES;
    } else {
        self.backgroundViewPageControl.hidden = YES;
        self.scrollViewPageControl.hidden = NO;
        self.didScrollToQRCode = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > self.view.frame.size.width - 1) {
        self.backgroundViewPageControl.hidden = NO;
    }
    [self updatePage:scrollView];
}

#pragma mark - Page Control

- (void)updatePage:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.backgroundViewPageControl.currentPage = page;
}

- (UIPageControl *)pageControlWithAssets:(NSArray *)assets
{
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, [BCSwipeAddressView pageIndicatorYOrigin], 100, 30)];
    pageControl.center = CGPointMake(self.view.bounds.size.width/2, pageControl.center.y);
    pageControl.pageIndicatorTintColor = COLOR_BLOCKCHAIN_LIGHTEST_BLUE;
    pageControl.currentPageIndicatorTintColor = COLOR_BLOCKCHAIN_DARK_BLUE;
    pageControl.numberOfPages = 1 + assets.count;
    return pageControl;
}

#pragma mark - Swipe View Delegate

- (void)requestButtonClickedForAddress:(NSString *)address
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_COPY_ADDRESS message:BC_STRING_COPY_WARNING_TEXT preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_COPY_ADDRESS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = address;
    }]];

    [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
