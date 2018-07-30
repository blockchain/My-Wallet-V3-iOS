//
//  BCDescriptionView.h
//  Blockchain
//
//  Created by kevinwu on 8/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCDescriptionView : UIScrollView
@property (nonatomic) UITableView *tableView;

@property (nonatomic) UITextView *descriptionTextView;
@property (nonatomic) NSString *note;
@property (nonatomic) BOOL isEditingDescription;
@property (nonatomic) CGFloat descriptionCellHeight;
@property (nonatomic) UIView *topView;
@property (nonatomic) CGFloat originalTableViewHeight;

- (void)beginEditingDescription;
- (void)endEditingDescription;
- (UITableViewCell *)configureDescriptionTextViewForCell:(UITableViewCell *)cell;
- (UITextView *)configureTextViewWithFrame:(CGRect)frame;
@end
