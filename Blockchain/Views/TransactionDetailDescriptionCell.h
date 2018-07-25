//
//  TransactionDetailDescriptionCell.h
//  Blockchain
//
//  Created by Kevin Wu on 9/27/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionDetailTableCell.h"

@protocol DescriptionDelegate
@property (nonatomic, readonly) BOOL didSetTextViewCursorPosition;
- (void)textViewDidChange:(UITextView *)textView;
- (NSString *)getNotePlaceholder;
- (CGFloat)getDefaultRowHeight;
- (NSRange)getTextViewCursorPosition;
- (void)setDefaultTextViewCursorPosition:(NSUInteger)textLength;
- (UIView *)getDescriptionInputAccessoryView;
@end
@interface TransactionDetailDescriptionCell : TransactionDetailTableCell
@property (nonatomic) UITextView *textView;
@property (nonatomic) UILabel *mainLabel;
@property (nonatomic) UILabel *subtitleLabel;
@property (nonatomic) UILabel *textViewPlaceholderLabel;
@property (nonatomic) CGFloat defaultTextViewHeight;
@property (nonatomic) UIButton *editButton;
@property (nonatomic) id<DescriptionDelegate> descriptionDelegate;
- (void)addEditButton;

@end
