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

#import <UIKit/UIKit.h>
#import "PENumpadView.h"
#import "Assets.h"

@class PEViewController;

@protocol PEViewControllerDelegate

@required
- (void)pinEntryControllerDidEnteredPin:(PEViewController *)controller;
- (void)cancelController;
- (void)updatePage:(UIScrollView *)scrollView;
@end


@interface PEViewController : UIViewController <PENumpadViewDelegate>
{
@public
	IBOutlet UIImageView *pin0;
	IBOutlet UIImageView *pin1;
	IBOutlet UIImageView *pin2;
	IBOutlet UIImageView *pin3;
	IBOutlet UILabel *promptLabel;
	UIImageView *pins[4];
	NSString *pin;
	id <PEViewControllerDelegate> __weak delegate;
    IBOutlet PENumpadView *keyboard;
    IBOutlet UIView *containerView;
}
@property (nonatomic, readonly, strong) NSString *pin;
@property (nonatomic, readwrite, copy) NSString *prompt;
@property (nonatomic, readwrite, weak) id <PEViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *swipeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *swipeLabelImageView;

- (void)resetPin;
- (IBAction)cancelChangePin:(id)sender;
- (void)setPin:(int)p enabled:(BOOL)yes;

@end
