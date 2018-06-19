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

#import "PEViewController.h"

@interface PEViewController ()

- (void)setPin:(int)pin enabled:(BOOL)yes;
- (void)redrawPins;

@property (nonatomic, readwrite, strong) NSString *pin;

@end


@implementation PEViewController

@synthesize pin, delegate;

- (void)viewDidLoad
{
	[super viewDidLoad];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    CGFloat safeAreaInsetBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetBottom = window.rootViewController.view.safeAreaInsets.bottom;
    }
    
    pins[0] = pin0;
	pins[1] = pin1;
	pins[2] = pin2;
	pins[3] = pin3;
	self.pin = @"";
    
    CGFloat containerViewHeight;
    
    if (IS_USING_SCREEN_SIZE_4S) {
        CGFloat offsetY = 60;
        pin0.frame = CGRectOffset(pin0.frame, 0, offsetY);
        pin1.frame = CGRectOffset(pin1.frame, 0, offsetY);
        pin2.frame = CGRectOffset(pin2.frame, 0, offsetY);
        pin3.frame = CGRectOffset(pin3.frame, 0, offsetY);
        promptLabel.frame = CGRectOffset(promptLabel.frame, 0, offsetY);
        containerViewHeight = 380;
    } else {
        if (IS_USING_SCREEN_SIZE_LARGER_THAN_5S) {
            CGFloat actualScreenHeight = window.bounds.size.height;
            CGFloat additionalOffsetForEvenLargerDevices = 0;
            if (actualScreenHeight > HEIGHT_IPHONE_6_PLUS) {
                additionalOffsetForEvenLargerDevices = actualScreenHeight - HEIGHT_IPHONE_6_PLUS;
            }
            CGFloat offsetY = (IS_USING_6_OR_7_PLUS_SCREEN_SIZE ? -80 : -60) - safeAreaInsetBottom;
            offsetY -= (additionalOffsetForEvenLargerDevices / 2);
            pin0.frame = CGRectOffset(pin0.frame, 0, offsetY);
            pin1.frame = CGRectOffset(pin1.frame, 0, offsetY);
            pin2.frame = CGRectOffset(pin2.frame, 0, offsetY);
            pin3.frame = CGRectOffset(pin3.frame, 0, offsetY);
            promptLabel.frame = CGRectOffset(promptLabel.frame, 0, offsetY);
        }
        containerViewHeight = [[UIScreen mainScreen] bounds].size.height/HEIGHT_IPHONE_5S * 380;
    }
    
    promptLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
    self.versionLabel.textColor = COLOR_BLOCKCHAIN_BLUE;
    self.versionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];

    containerView.frame = CGRectMake(0, 480 - containerViewHeight - safeAreaInsetBottom, window.rootViewController.view.frame.size.width, containerViewHeight);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;

    //: If the the safe area has a bottom inset, add filler view
    //: Must use window's frame because view's frame is hardcoded
    if (safeAreaInsetBottom > 0) {
        CGFloat height = safeAreaInsetBottom;
        CGFloat width = window.frame.size.width;
        CGFloat posY = window.frame.size.height - height;
        UIView *fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, posY, width, height)];
        fillerView.userInteractionEnabled = NO;
        if (@available(iOS 11.0, *)) {
            fillerView.backgroundColor = [UIColor colorNamed:@"ColorBrandPrimary"];
        } else {
            fillerView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
        }
        [self.scrollView addSubview:fillerView];
    }
    
    self.swipeLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    self.swipeLabel.text = BC_STRING_SETTINGS_PIN_SWIPE_TO_RECEIVE;
    self.swipeLabelImageView.image = [UIImage imageNamed:@"arrow_downward"];
    self.swipeLabelImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.swipeLabelImageView.image = [self.swipeLabelImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.swipeLabelImageView setTintColor:COLOR_BLOCKCHAIN_BLUE];

    [self setupTapActionForSwipeQR];
}

- (IBAction)cancelChangePin:(id)sender
{
    [self.delegate cancelController];
}

- (void)setPin:(int)p enabled:(BOOL)yes
{
	pins[p].image = yes ? [UIImage imageNamed:@"PEPin-on.png"] : [UIImage imageNamed:@"PEPin-off.png"];
}

- (void)redrawPins
{
	for(int i=0; i<4; ++i) {
		[self setPin:i enabled:[self.pin length]>i];
	}
}

- (void)keyboardViewDidEnteredNumber:(int)num
{
	if([self.pin length] < 4) {
		self.pin = [NSString stringWithFormat:@"%@%d", self.pin, num];
		[self redrawPins];
        if([self.pin length] == 4) {
            // Short delay so the UI can update the PIN view before we go to the next page
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [delegate pinEntryControllerDidEnteredPin:self];
            });
        }
	}
}

- (void)keyboardViewDidBackspaced
{
	if([self.pin length] > 0) {
		self.pin = [self.pin substringToIndex:[self.pin length]-1];
		[self redrawPins];
		keyboard.detailButon = PEKeyboardDetailNone;
	}
}

- (void)keyboardViewDidOptKey
{
	[delegate pinEntryControllerDidEnteredPin:self];
}

- (void)setPrompt:(NSString *)p
{
	[self view];
	promptLabel.text = p;
}

- (NSString *)prompt
{
	return promptLabel.text;
}

- (void)resetPin
{
	self.pin = @"";
	keyboard.detailButon = PEKeyboardDetailNone;
	[self redrawPins];
}

- (void)setupTapActionForSwipeQR
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSwipeQR)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    CGFloat windowWidth = self.view.frame.size.width;
    CGFloat actionViewOriginX = self.swipeLabelImageView.frame.origin.x - self.swipeLabel.intrinsicContentSize.width - 8;
    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(actionViewOriginX, self.swipeLabel.frame.origin.y, windowWidth - actionViewOriginX, self.swipeLabel.frame.size.height)];
    [containerView addSubview:actionView];
    [actionView addGestureRecognizer:tapGestureRecognizer];
    actionView.userInteractionEnabled = YES;
}

- (void)showSwipeQR
{
    if (!self.swipeLabel.hidden) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, self.scrollView.contentOffset.y) animated:YES];
    }
}

@end
