//
//  BCDescriptionView.m
//  Blockchain
//
//  Created by kevinwu on 8/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCDescriptionView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "BCLine.h"
#import "Blockchain-Swift.h"

@implementation BCDescriptionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.descriptionCellHeight = 132;
        self.scrollEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void)endEditingDescription
{
    self.note = self.descriptionTextView.text;
    
    self.isEditingDescription = NO;
    
    [self.descriptionTextView resignFirstResponder];
    
    if (self.tableView) {
        [self.tableView changeHeight:self.originalTableViewHeight];
        [self moveViewsDownForSmallScreens];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)beginEditingDescription
{
    self.isEditingDescription = YES;
    
    if (self.tableView) {
        self.originalTableViewHeight = self.tableView.frame.size.height;
        [self.tableView changeHeight:self.descriptionCellHeight];
        [self moveViewsUpForSmallScreens];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.descriptionTextView becomeFirstResponder];
    }
}

- (void)moveViewsUpForSmallScreens
{
    if (IS_USING_SCREEN_SIZE_4S) {
        
        self.topView.hidden = YES;
        
        [UIView animateWithDuration:ANIMATION_DURATION_LONG animations:^{
            [self.tableView changeYPosition:0];
        }];
    }
}

- (void)moveViewsDownForSmallScreens
{
    if (IS_USING_SCREEN_SIZE_4S) {
        
        self.topView.alpha = 0;
        self.topView.hidden = NO;
        
        [UIView animateWithDuration:ANIMATION_DURATION_LONG animations:^{
            [self.tableView changeYPosition:self.topView.frame.origin.y + self.topView.frame.size.height];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                self.topView.alpha = 1;
            }];
        }];
    }
}

#pragma mark - View Helpers

- (UIView *)getTextViewInputAccessoryView
{
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, BUTTON_HEIGHT)];
    inputAccessoryView.backgroundColor = [UIColor whiteColor];;
    
    BCLine *topLine = [[BCLine alloc] initWithYPosition:0];
    [inputAccessoryView addSubview:topLine];
    
    BCLine *bottomLine = [[BCLine alloc] initWithYPosition:BUTTON_HEIGHT];
    [inputAccessoryView addSubview:bottomLine];
    
    UIButton *doneDescriptionButton = [[UIButton alloc] initWithFrame:CGRectMake(inputAccessoryView.frame.size.width - 68, 0, 60, BUTTON_HEIGHT)];
    doneDescriptionButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:13.0];
    [doneDescriptionButton setTitleColor:UIColor.brandSecondary forState:UIControlStateNormal];
    [doneDescriptionButton setTitle:BC_STRING_DONE forState:UIControlStateNormal];
    [doneDescriptionButton addTarget:self action:@selector(endEditingDescription) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:doneDescriptionButton];
    
    return inputAccessoryView;
}

- (UITextView *)configureTextViewWithFrame:(CGRect)frame
{
    UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:frame];
    descriptionTextView.textColor = UIColor.gray5;
    descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    descriptionTextView.textAlignment = NSTextAlignmentRight;
    descriptionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    descriptionTextView.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    descriptionTextView.inputAccessoryView = [self getTextViewInputAccessoryView];
    descriptionTextView.text = self.note;
    
    return descriptionTextView;
}

- (UITableViewCell *)configureDescriptionTextViewForCell:(UITableViewCell *)cell
{
    CGFloat leftMargin = IS_USING_6_OR_7_PLUS_SCREEN_SIZE ? 20 : 15;
    CGFloat labelHeight = 16;
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, 14, self.frame.size.width/2 - 8 - leftMargin, labelHeight)];
    descriptionLabel.text = BC_STRING_DESCRIPTION;
    descriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    descriptionLabel.textColor = UIColor.gray5;
    
    [cell.contentView addSubview:descriptionLabel];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;

    self.descriptionTextView = [self configureTextViewWithFrame:CGRectMake(width/2 + 8, 8, width/2 - 16, self.descriptionCellHeight - 16)];

    [cell.contentView addSubview:self.descriptionTextView];
    
    [self.descriptionTextView becomeFirstResponder];
    
    return cell;
}

@end
