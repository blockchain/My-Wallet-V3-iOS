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

@interface PEPinEntryController ()
@property (nonatomic) Pin *lastEnteredPIN;
@end

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
    UIViewController * viewController = self.viewControllers.firstObject;
    if ([viewController isKindOfClass:[PEViewController class]]) {
        [((PEViewController *) viewController) resetPin];
    }
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
        
        pinController.swipeLabel.alpha = 1;
        pinController.swipeLabel.hidden = NO;
        
        pinController.swipeLabelImageView.alpha = 1;
        pinController.swipeLabelImageView.hidden = NO;
        
        pinController.scrollView.backgroundColor = [UIColor clearColor];
        
        [pinController.scrollView setUserInteractionEnabled:YES];

        CGFloat windowWidth = self.view.frame.size.width;
        NSArray *assets = [self assets];

        [pinController.scrollView setContentSize:CGSizeMake(windowWidth * (assets.count + 1), self.view.frame.size.height)];
        [pinController.scrollView setPagingEnabled:YES];
        pinController.scrollView.delegate = self;
    } else {
        pinController.swipeLabel.hidden = YES;
        pinController.swipeLabelImageView.hidden = YES;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateSwipeToReceiveViews];
}

- (void)updateSwipeToReceiveViews
{
    CGFloat windowWidth = self.view.frame.size.width;
    NSArray *assets = [self assets];

    for (NSNumber *key in self.swipeViews) {
        SwipeToReceiveAddressView *swipeView = [self.swipeViews objectForKey:key];
        [swipeView removeFromSuperview];
    }

    for (int assetIndex = 0; assetIndex < assets.count; assetIndex++) {
        LegacyAssetType asset = [assets[assetIndex] integerValue];
        BCSwipeAddressViewModel *viewModel = [[BCSwipeAddressViewModel alloc] initWithAssetType:asset];
        SwipeToReceiveAddressView *swipeView = [SwipeToReceiveAddressView instanceFromNib];
        swipeView.onRequestAssetTapped = ^(NSString * _Nonnull address) {
            [self confirmCopyAddressToClipboard:address];
        };
        swipeView.frame = CGRectMake(windowWidth * (assetIndex + 1), 0, windowWidth, pinController.scrollView.frame.size.height);
        [swipeView layoutIfNeeded];
        swipeView.viewModel = viewModel;
        [self addAddressToSwipeToReceiveView:swipeView assetType:asset];
        [self.swipeViews setObject:swipeView forKey:[NSNumber numberWithInteger:asset]];
        [pinController.scrollView addSubview:swipeView];
    }
}

- (void)addAddressToSwipeToReceiveView:(SwipeToReceiveAddressView *)swipeView assetType:(LegacyAssetType)assetType
{
    AssetAddressRepository *assetAddressRepository = AssetAddressRepository.sharedInstance;
    if (assetType == LegacyAssetTypeBitcoin || assetType == LegacyAssetTypeBitcoinCash) {

        AssetType type = [AssetTypeLegacyHelper convertFromLegacy:assetType];

        NSString *nextAddress = [[assetAddressRepository swipeToReceiveAddressesFor:type] firstObject].address;

        if (nextAddress) {

            void (^error)(void) = ^() {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizationConstantsObjcBridge.noInternetConnection message:BC_STRING_SWIPE_TO_RECEIVE_NO_INTERNET_CONNECTION_WARNING preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    swipeView.address = LocalizationConstantsObjcBridge.requestFailedCheckConnection;
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [WalletManager.sharedInstance.wallet subscribeToSwipeAddress:nextAddress assetType:assetType];
                    swipeView.address = nextAddress;
                }]];
                self.errorAlert = alert;
            };

            void (^success)(NSString *, BOOL) = ^(NSString *address, BOOL isUnused) {

                if (isUnused) {
                    [WalletManager.sharedInstance.wallet subscribeToSwipeAddress:nextAddress assetType:assetType];
                    swipeView.address = address;
                    self.errorAlert = nil;
                } else {
                    [assetAddressRepository removeFirstSwipeAddressFor:type];
                    self.errorAlert = nil;
                }
            };
            [[AssetAddressRepository sharedInstance] checkForUnusedAddress:nextAddress
                                                            displayAddress:nextAddress
                                                                 assetType:[AssetTypeLegacyHelper convertFromLegacy:assetType]
                                                            successHandler:success
                                                              errorHandler:error];
        } else {
            swipeView.address = nextAddress;
        }
    } else if (assetType == LegacyAssetTypeEther) {
        NSString *etherAddress = [[assetAddressRepository swipeToReceiveAddressesFor:AssetTypeEthereum] firstObject].address;
        if (etherAddress) {
            swipeView.address = etherAddress;
        }
    }
}

- (void)paymentReceived:(LegacyAssetType)assetType
{
    AssetType type = [AssetTypeLegacyHelper convertFromLegacy:assetType];

    if (type != AssetTypeBitcoin && type != AssetTypeBitcoinCash) {
        return;
    }

    AssetAddressRepository *assetAddressRepository = AssetAddressRepository.sharedInstance;
    if ([assetAddressRepository swipeToReceiveAddressesFor:type].count <= 0) {
        return;
    }
    [assetAddressRepository removeFirstSwipeAddressFor:type];

    SwipeToReceiveAddressView *swipeView = [self.swipeViews objectForKey:[NSNumber numberWithInteger:assetType]];
    [self addAddressToSwipeToReceiveView:swipeView assetType:assetType];
}

- (void)pinEntryControllerDidEnteredPin:(PEViewController *)controller
{
	switch (pinStage) {
		case PS_VERIFY: {
            self.lastEnteredPIN = [[Pin alloc] initWithCode:[controller.pin intValue]];
            [self validateWithPin:self.lastEnteredPIN];
			break;
        }
		case PS_ENTER1: {
            [self didEnter1Pin:controller];
			break;
		}
		case PS_ENTER2:
			if([controller.pin intValue] != pinEntry1) {
				PEViewController *c = NewController();
				c.delegate = self;
				self.viewControllers = [NSArray arrayWithObjects:c, [self.viewControllers objectAtIndex:0], nil];
				[self popViewControllerAnimated:NO];
                [AlertViewPresenter.sharedInstance standardErrorWithMessage:LocalizationConstantsObjcBridge.pinsDoNotMatch
                                                                      title:LocalizationConstantsObjcBridge.error
                                                                         in:self
                                                                    handler:nil];
			} else {
				[self.pinDelegate pinEntryController:self changedPin:[controller.pin intValue]];
			}
			break;
		default:
			break;
	}
}

- (void)didEnter1Pin:(PEViewController *)controller
{
    Pin *pin = [[Pin alloc] initWithCode: [controller.pin intValue]];

    // Check that the selected pin passes checks
    if (!pin.isValid) {
        [self errorAndResetWithMessage:[LocalizationConstantsObjcBridge chooseAnotherPin]];
        return;
    }

    if ([pin isEqual:self.lastEnteredPIN]) {
        [self errorAndResetWithMessage:[LocalizationConstantsObjcBridge newPinMustBeDifferent]];
        return;
    }

    if (pin.isCommon) {
        __weak PEPinEntryController *weakSelf = self;
        NSArray *actions = @[
            [UIAlertAction actionWithTitle:[LocalizationConstantsObjcBridge continueString]
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf goToEnter2Pin:controller];
            }],
            [UIAlertAction actionWithTitle:[LocalizationConstantsObjcBridge tryAgain]
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf reset];
            }],
        ];
        [AlertViewPresenter.sharedInstance standardNotifyWithMessage:[LocalizationConstantsObjcBridge pinCodeCommonMessage]
                                                               title:[LocalizationConstantsObjcBridge warning]
                                                             actions:actions
                                                                  in:self];
        return;
    }

    [self goToEnter2Pin:controller];
}

- (void)goToEnter1Pin
{
    PEViewController *c = NewController();
    c.delegate = self;
    pinStage = PS_ENTER1;
    [[self navigationController] pushViewController:c animated:NO];
    self.viewControllers = [NSArray arrayWithObject:c];
}

- (void)goToEnter2Pin:(PEViewController *)controller
{
    pinEntry1 = [controller.pin intValue];
    PEViewController *c = VerifyController();
    c.delegate = self;
    [[self navigationController] pushViewController:c animated:NO];
    self.viewControllers = [NSArray arrayWithObject:c];
    pinStage = PS_ENTER2;
}

- (void)errorAndResetWithMessage:(NSString *)errorMessage
{
    __weak PEPinEntryController *weakSelf = self;
    [AlertViewPresenter.sharedInstance standardErrorWithMessage:errorMessage
                                                          title:[LocalizationConstantsObjcBridge error]
                                                             in:self
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [weakSelf reset];
                                                        }];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pinPresenter = [[PinPresenter alloc] initWithView:self interactor:[PinInteractor sharedInstance] walletService: [WalletService sharedInstance]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#ifdef DEBUG
    if (self.verifyOnly) {
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        self.longPressGesture.minimumPressDuration = DURATION_LONG_PRESS_GESTURE_DEBUG;

        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat safeAreaInsetTop;
        if (@available(iOS 11.0, *)) {
            safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
        } else {
            safeAreaInsetTop = 20;
        }

        self.debugButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, safeAreaInsetTop, 80, 51)];
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
    if (!self.backgroundViewPageControl) {
        UIPageControl *backgroundViewPageControl = [self pageControlWithAssets:[self assets]];
        [self.view addSubview:backgroundViewPageControl];
        backgroundViewPageControl.hidden = YES;
        self.backgroundViewPageControl = backgroundViewPageControl;
    }

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
    SwipeToReceiveAddressView *swipeView;
    for (NSNumber *key in self.swipeViews) {
        swipeView = [[self swipeViews] objectForKey:key];
        break;
    }

    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, swipeView.pageIndicatorYOrigin, 100, 30)];
    pageControl.center = CGPointMake(self.view.bounds.size.width/2, pageControl.center.y);
    pageControl.pageIndicatorTintColor = COLOR_BLOCKCHAIN_LIGHTEST_BLUE;
    pageControl.currentPageIndicatorTintColor = COLOR_BLOCKCHAIN_DARK_BLUE;
    pageControl.numberOfPages = 1 + assets.count;
    return pageControl;
}

- (void)confirmCopyAddressToClipboard:(NSString *)address
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_COPY_ADDRESS message:BC_STRING_COPY_WARNING_TEXT preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_COPY_ADDRESS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = address;
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
