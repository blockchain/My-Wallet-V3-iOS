//
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

#ifdef PINENTRY_KEYBOARD_SENDS_NOTIFICATIONS
extern NSString *kPinEntryKeyboardEvent;
extern NSString *kPinEntryKeyboardCode;
#endif


@protocol PENumpadViewDelegate

@required
- (void)keyboardViewDidEnteredNumber:(int)num;
- (void)keyboardViewDidBackspaced;
@optional
- (void)keyboardViewDidOptKey;

@end


#define PEKeyboardDetailNone	0
#define PEKeyboardDetailDone	1
#define PEKeyboardDetailNext	2
#define PEKeyboardDetailDot		3
#define PEKeyboardDetailEdit	4


@interface PENumpadView : UIView
{
	int activeClip;
	id <PENumpadViewDelegate> __weak delegate;
	NSString *detail;
}
@property (nonatomic, readwrite, weak) IBOutlet id <PENumpadViewDelegate> delegate;
@property (nonatomic, readwrite, assign) NSUInteger detailButon;
@property (nonatomic, assign) BOOL isEnabled;

- (id)init;

@end
