//
//  BCConfirmPaymentView.m
//  Blockchain
//
//  Created by Kevin Wu on 10/2/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCConfirmPaymentView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"
#import "BCTotalAmountView.h"
#import "BCConfirmPaymentViewModel.h"

#define CELL_HEIGHT_DEFAULT 60
#define CELL_HEIGHT_SMALL 44

@interface BCConfirmPaymentView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic) BCSecureTextField *descriptionField;
@property (nonatomic) BCTotalAmountView *totalAmountView;
@property (nonatomic) BCConfirmPaymentViewModel *viewModel;
@property (nonatomic) NSMutableArray *rows;
@end
@implementation BCConfirmPaymentView

- (id)initWithFrame:(CGRect)frame viewModel:(BCConfirmPaymentViewModel *)viewModel sendButtonFrame:(CGRect)sendButtonFrame
{
    self = [super initWithFrame:frame];

    if (self) {
        
        self.frame = frame;

        self.viewModel = viewModel;
        
        BCTotalAmountView *totalAmountView = [[BCTotalAmountView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TOTAL_AMOUNT_VIEW_HEIGHT) color:COLOR_BLOCKCHAIN_RED amount:0];
        
        totalAmountView.btcAmountLabel.text = self.viewModel.btcTotalAmountText;
        totalAmountView.fiatAmountLabel.text = self.viewModel.fiatTotalAmountText;
        
        [self addSubview:totalAmountView];
        self.topView = totalAmountView;
        
        [self setupRows];
        
        CGFloat tableViewHeight = [self getCellHeight] * [self.rows count];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UITableView *summaryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, totalAmountView.frame.origin.y + totalAmountView.frame.size.height, frame.size.width, tableViewHeight)];
        summaryTableView.scrollEnabled = NO;
        summaryTableView.delegate = self;
        summaryTableView.dataSource = self;
        [self addSubview:summaryTableView];
        
        CGFloat lineWidth = 1.0/[UIScreen mainScreen].scale;
        
        summaryTableView.clipsToBounds = YES;
        
        CALayer *topBorder = [CALayer layer];
        topBorder.borderColor = [COLOR_LINE_GRAY CGColor];
        topBorder.borderWidth = 1;
        topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(summaryTableView.frame), lineWidth);
        [summaryTableView.layer addSublayer:topBorder];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [COLOR_LINE_GRAY CGColor];
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRectMake(0, CGRectGetHeight(summaryTableView.frame) - lineWidth, CGRectGetWidth(summaryTableView.frame), lineWidth);
        [summaryTableView.layer addSublayer:bottomBorder];
        
        self.tableView = summaryTableView;
        
        NSString *buttonTitle = BC_STRING_SEND;
        
        self.reallyDoPaymentButton = [[UIButton alloc] initWithFrame:sendButtonFrame];
        self.reallyDoPaymentButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
        [self.reallyDoPaymentButton changeYPosition:self.frame.size.height - 20 + 49];
        
        [self.reallyDoPaymentButton setTitle:buttonTitle forState:UIControlStateNormal];
        self.reallyDoPaymentButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
        self.reallyDoPaymentButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
        
        [self.reallyDoPaymentButton addTarget:self action:@selector(reallyDoPaymentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.reallyDoPaymentButton];

        if (viewModel.warningText) {
            UITextView *warning = [[UITextView alloc] initWithFrame:self.reallyDoPaymentButton.frame];
            warning.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
            warning.editable = NO;
            warning.scrollEnabled = NO;
            warning.selectable = NO;
            warning.backgroundColor = COLOR_BLOCKCHAIN_YELLOW;
            [self addSubview:warning];
            warning.attributedText = viewModel.warningText;
            CGSize fittedSize = [warning sizeThatFits:CGSizeMake(self.reallyDoPaymentButton.frame.size.width, CGFLOAT_MAX)];
            [warning changeWidth:self.reallyDoPaymentButton.frame.size.width];
            [warning changeHeight:fittedSize.height];
            [warning changeYPosition:self.reallyDoPaymentButton.frame.origin.y - warning.frame.size.height - 12];
        }
    }
    return self;
}

- (void)setupRows
{
    self.rows = [NSMutableArray new];
    if (self.viewModel.from) [self.rows addObject:@[BC_STRING_FROM, self.viewModel.from]];
    if (self.viewModel.to) [self.rows addObject:@[BC_STRING_TO, self.viewModel.to]];
    if (self.viewModel.showDescription) [self.rows addObject:@[BC_STRING_DESCRIPTION, self.viewModel.noteText ? : @""]];
    if (self.viewModel.btcWithFiatAmountText) [self.rows addObject:@[BC_STRING_AMOUNT, self.viewModel.btcWithFiatAmountText]];
    if (self.viewModel.btcWithFiatFeeText) [self.rows addObject:@[BC_STRING_FEE, self.viewModel.btcWithFiatFeeText]];
}

- (void)reallyDoPaymentButtonClicked
{
    [self.confirmDelegate setupNoteForTransaction:self.note];
}

- (void)feeInformationButtonClicked
{
    [self.confirmDelegate feeInformationButtonClicked];
}

#pragma mark - Helpers

- (CGFloat)getCellHeight
{
    return IS_USING_SCREEN_SIZE_4S && (self.viewModel.warningText || self.rows.count > 4) ? CELL_HEIGHT_SMALL : CELL_HEIGHT_DEFAULT;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.hidden = YES;
    
    [self beginEditingDescription];
    
    return NO;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isEditingDescription ? self.descriptionCellHeight : [self getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isEditingDescription ? 1 : [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = [self getCellHeight];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textColor = COLOR_TEXT_DARK_GRAY;
    cell.textLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    cell.detailTextLabel.textColor = COLOR_TEXT_DARK_GRAY;
    cell.detailTextLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    
    if (self.isEditingDescription) {
        cell = [self configureDescriptionTextViewForCell:cell];
    } else {
        
        NSString *textLabel = [self.rows[indexPath.row] firstObject];
        NSString *detailTextLabel = [self.rows[indexPath.row] lastObject];

        cell.textLabel.text = textLabel;
        cell.detailTextLabel.text = detailTextLabel;
        
        cell.detailTextLabel.adjustsFontSizeToFitWidth = [textLabel isEqualToString:BC_STRING_FROM] || [textLabel isEqualToString:BC_STRING_TO];
        
        if ([textLabel isEqualToString:BC_STRING_FEE]) {
            UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            testLabel.textColor = COLOR_TEXT_DARK_GRAY;
            testLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
            testLabel.text = BC_STRING_FEE;
            [testLabel sizeToFit];
            
            CGFloat feeInformationButtonWidth = 19;
            self.feeInformationButton = [[UIButton alloc] initWithFrame:CGRectMake(15 + testLabel.frame.size.width + 8, cellHeight/2 - feeInformationButtonWidth/2, feeInformationButtonWidth, feeInformationButtonWidth)];
            [self.feeInformationButton setImage:[[UIImage imageNamed:@"help"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            self.feeInformationButton.tintColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
            [self.feeInformationButton addTarget:self action:@selector(feeInformationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:self.feeInformationButton];
            
            if (self.viewModel.surgeIsOccurring) cell.detailTextLabel.textColor = COLOR_WARNING_RED;
        } else if ([textLabel isEqualToString:BC_STRING_DESCRIPTION]) {
            cell.textLabel.text = nil;
            
            CGFloat leftMargin = IS_USING_6_OR_7_PLUS_SCREEN_SIZE ? 20 : 15;
            CGFloat labelHeight = 16;
            
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, cellHeight/2 - labelHeight/2, self.frame.size.width/2 - 8 - leftMargin, labelHeight)];
            descriptionLabel.text = BC_STRING_DESCRIPTION;
            descriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
            descriptionLabel.textColor = COLOR_TEXT_DARK_GRAY;
            
            [cell.contentView addSubview:descriptionLabel];
            
            CGFloat descriptionFieldHeight = 20;
            self.descriptionField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(self.frame.size.width/2 + 16, cellHeight/2 - descriptionFieldHeight/2, self.frame.size.width/2 - 16 - 15, descriptionFieldHeight)];
            self.descriptionField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
            self.descriptionField.textColor = COLOR_TEXT_DARK_GRAY;
            self.descriptionField.textAlignment = NSTextAlignmentRight;
            self.descriptionField.returnKeyType = UIReturnKeyDone;
            
            if (self.viewModel.noteText) {
                self.descriptionField.text = self.viewModel.noteText;
                self.descriptionField.userInteractionEnabled = NO;
                self.descriptionField.placeholder = BC_STRING_NO_DESCRIPTION;
            } else {
                // Text will be empty for regular (non-contacts-related) transactions - allow setting a note
                
                self.descriptionField.delegate = self;
                self.descriptionField.placeholder = BC_STRING_TRANSACTION_DESCRIPTION_PLACEHOLDER;
                self.descriptionField.text = self.note;
            }
            
            [cell.contentView addSubview:self.descriptionField];
        }
    }
    return cell;
}

@end
