//
//  BCContactRequestView.m
//  Blockchain
//
//  Created by kevinwu on 1/9/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCContactRequestView.h"
#import "Blockchain-Swift.h"
#import "BCLine.h"
#import "Contact.h"
#import "UIView+ChangeFrameAttribute.h"
#import "BCTotalAmountView.h"

#define CELL_HEIGHT 44

@interface BCContactRequestView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) Contact *contact;

@property (nonatomic) UIButton *requestButton;

@property (nonatomic) uint64_t amount;
@property (nonatomic) id accountOrAddress;

@end

@implementation BCContactRequestView

- (id)initWithContact:(Contact *)contact amount:(uint64_t)amount willSend:(BOOL)willSend accountOrAddress:(id)accountOrAddress
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self = [super initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT, window.frame.size.width, window.frame.size.height - DEFAULT_HEADER_HEIGHT)];
    
    if (self) {
        self.contact = contact;
        self.amount = amount;
        self.accountOrAddress = accountOrAddress;
        
        _willSend = willSend;
        self.backgroundColor = [UIColor whiteColor];

        BCTotalAmountView *totalAmountView = [[BCTotalAmountView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100) color:self.willSend ? COLOR_BLOCKCHAIN_RED : COLOR_BLOCKCHAIN_AQUA amount:self.amount];
        [self addSubview:totalAmountView];
        self.topView = totalAmountView;
        
        CGFloat tableViewHeight = CELL_HEIGHT * (self.willSend ? 3 : 4);
        
        UITableView *summaryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, totalAmountView.frame.origin.y + totalAmountView.frame.size.height, window.frame.size.width, tableViewHeight)];
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
        
        UILabel *tableViewFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, summaryTableView.frame.origin.y + summaryTableView.frame.size.height + 8, window.frame.size.width - 30, 0)];
        tableViewFooterLabel.numberOfLines = 0;
        tableViewFooterLabel.text = BC_STRING_TRANSACTIONS_MUST_BE_ACCEPTED_BY_YOUR_CONTACT_PRIOR_TO_SENDING;
        tableViewFooterLabel.textColor = COLOR_LIGHT_GRAY;
        tableViewFooterLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
        [tableViewFooterLabel sizeToFit];
        [tableViewFooterLabel changeXPosition:15];
        [self addSubview:tableViewFooterLabel];
        
        self.requestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.requestButton.frame = CGRectMake(0, self.frame.size.height - BUTTON_HEIGHT - 8, 240, BUTTON_HEIGHT);
        self.requestButton.center = CGPointMake(self.center.x, self.requestButton.center.y);
        self.requestButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
        self.requestButton.backgroundColor = COLOR_BUTTON_BLUE;
        [self.requestButton setTitle:BC_STRING_START_TRANSACTION forState:UIControlStateNormal];
        [self.requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.requestButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
        [self.requestButton addTarget:self action:@selector(completeRequest) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.requestButton];
        
        self.tableView = summaryTableView;
    }
    return self;
}

- (void)completeRequest
{
    if (self.willSend) {
        [self.delegate createSendRequestForContact:self.contact withReason:self.note amount:self.amount lastSelectedField:self.descriptionField accountOrAddress:self.accountOrAddress];
    } else {
        [self.delegate createReceiveRequestForContact:self.contact withReason:self.note amount:self.amount lastSelectedField:self.descriptionField];
    }
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
    return self.isEditingDescription ? self.descriptionCellHeight : CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isEditingDescription) {
        return 1;
    } else {
        return self.willSend ? 3 : 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textColor = COLOR_TEXT_DARK_GRAY;
    cell.textLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    cell.detailTextLabel.textColor = COLOR_TEXT_DARK_GRAY;
    cell.detailTextLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];

    if (self.isEditingDescription) {
        cell = [self configureDescriptionTextViewForCell:cell];
    } else {
        int rowAmount = 0;
        int rowTo = 1;
        int rowFrom = 2;
        int rowDescription = 3;
        
        if (self.willSend) {
            rowAmount = -1;
            rowTo = 1;
            rowFrom = 0;
            rowDescription = 2;
        }
        
        NSString *accountOrAddressString = [self.accountOrAddress isKindOfClass:[NSString class]] ? self.accountOrAddress : [app.wallet getLabelForAccount:[self.accountOrAddress intValue] assetType:AssetTypeBitcoin];
        
        if (indexPath.row == rowTo) {
            cell.textLabel.text = BC_STRING_TO;
            cell.detailTextLabel.text = self.willSend ? self.contact.name : accountOrAddressString;
        } else if (indexPath.row == rowFrom) {
            cell.textLabel.text = BC_STRING_FROM;
            cell.detailTextLabel.text = self.willSend ? accountOrAddressString : self.contact.name;
        } else if (indexPath.row == rowDescription) {
            cell.textLabel.text = nil;
            
            CGFloat leftMargin = IS_USING_6_OR_7_PLUS_SCREEN_SIZE ? 20 : 15;
            CGFloat labelHeight = 16;
            
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, 14, self.frame.size.width/2 - 8 - leftMargin, labelHeight)];
            descriptionLabel.text = BC_STRING_DESCRIPTION;
            descriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
            descriptionLabel.textColor = COLOR_TEXT_DARK_GRAY;
            
            [cell.contentView addSubview:descriptionLabel];
            
            self.descriptionField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(self.frame.size.width/2 + 16, 0, self.frame.size.width/2 - 16 - 15, 20)];
            self.descriptionField.center = CGPointMake(self.descriptionField.center.x, cell.contentView.center.y);
            self.descriptionField.placeholder = [NSString stringWithFormat:BC_STRING_SHARED_WITH_CONTACT_NAME_ARGUMENT, self.contact.name];
            self.descriptionField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
            self.descriptionField.textColor = COLOR_TEXT_DARK_GRAY;
            self.descriptionField.textAlignment = NSTextAlignmentRight;
            self.descriptionField.returnKeyType = UIReturnKeyDone;
            self.descriptionField.delegate = self;
            self.descriptionField.text = self.note;
            [cell.contentView addSubview:self.descriptionField];
        } else if (indexPath.row == rowAmount) {
            CGFloat labelWidth = IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 48 : 42;
            
            UILabel *btcLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, labelWidth, 21)];
            btcLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
            btcLabel.textColor = COLOR_TEXT_DARK_GRAY;
            btcLabel.text = app.latestResponse.symbol_btc.symbol;
            btcLabel.center = CGPointMake(btcLabel.center.x, cell.contentView.center.y);
            [cell.contentView addSubview:btcLabel];
            
            UILabel *fiatLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width/2 + 15, 0, labelWidth, 21)];
            fiatLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
            fiatLabel.textColor = COLOR_TEXT_DARK_GRAY;
            fiatLabel.text = app.latestResponse.symbol_local.code;
            fiatLabel.center = CGPointMake(fiatLabel.center.x, cell.contentView.center.y);
            [cell.contentView addSubview:fiatLabel];
            
            CGFloat btcAmountLabelOriginX = btcLabel.frame.origin.x + btcLabel.frame.size.height + 24;
            UILabel *btcAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(btcAmountLabelOriginX, 0, fiatLabel.frame.origin.x - btcAmountLabelOriginX - 15, 21)];
            btcAmountLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
            btcAmountLabel.textColor = COLOR_TEXT_DARK_GRAY;
            btcAmountLabel.text = [NSNumberFormatter formatAmount:self.amount localCurrency:NO];
            btcAmountLabel.center = CGPointMake(btcAmountLabel.center.x, cell.contentView.center.y);
            [cell.contentView addSubview:btcAmountLabel];
            
            CGFloat fiatAmountLabelOriginX = fiatLabel.frame.origin.x + fiatLabel.frame.size.height + 24;
            UILabel *fiatAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(fiatAmountLabelOriginX, 0, cell.contentView.frame.size.width - fiatAmountLabelOriginX - 15, 21)];
            fiatAmountLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
            fiatAmountLabel.textColor = COLOR_TEXT_DARK_GRAY;
            fiatAmountLabel.text = [NSNumberFormatter formatMoney:self.amount localCurrency:YES];
            fiatAmountLabel.center = CGPointMake(fiatAmountLabel.center.x, cell.contentView.center.y);
            [cell.contentView addSubview:fiatAmountLabel];
        }
    }
    return cell;
}

@end
