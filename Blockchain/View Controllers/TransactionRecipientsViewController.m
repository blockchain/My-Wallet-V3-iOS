//
//  TransactionRecipientsViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 9/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionRecipientsViewController.h"
#import "ReceiveTableCell.h"
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

@interface TransactionRecipientsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSArray *recipients;
@property (nonatomic) UITableView *tableView;
@end

@implementation TransactionRecipientsViewController

- (id)initWithRecipients:(NSArray *)recipients
{
    self = [super init];
    if (self) {
        self.recipients = recipients;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)toggleSymbol
{
    [self.recipientsDelegate toggleSymbol];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recipients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReceiveTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_RECIPIENT];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReceiveCell" owner:nil options:nil] objectAtIndex:0];
        cell.backgroundColor = UIColor.lightGray;
        
        cell.labelLabel.frame = CGRectMake(20, 11, 155, 21);
        cell.balanceLabel.frame = CGRectMake(247, 11, 90, 21);
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 217, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
        cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);
        [cell.balanceButton addTarget:self action:@selector(toggleSymbol) forControlEvents:UIControlEventTouchUpInside];
        
        cell.watchLabel.text = BC_STRING_WATCH_ONLY;
        cell.watchLabel.textColor = UIColor.error;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *recipient = self.recipients[indexPath.row];
    
    NSString *label = recipient[DICTIONARY_KEY_LABEL];
    uint64_t amount = [recipient[DICTIONARY_KEY_AMOUNT] longLongValue];
    cell.labelLabel.text = label && label.length > 0 ? label : recipient[DICTIONARY_KEY_ADDRESS];
    cell.balanceLabel.text = [NSString stringWithFormat:@"%@", [NSNumberFormatter formatMoneyWithLocalSymbol:amount]];
    
    NSString *address = recipient[DICTIONARY_KEY_ADDRESS];
    cell.addressLabel.text = address;
    
    cell.labelLabel.hidden = [address isEqualToString:label];
    
    BOOL isWatchOnlyLegacyAddress = [self.recipientsDelegate isWatchOnlyLegacyAddress:address];
    if (isWatchOnlyLegacyAddress) {
        // Show the watch only tag and resize the label and balance labels so there is enough space
        cell.labelLabel.frame = CGRectMake(20, 11, 148, 21);
        
        cell.balanceLabel.frame = CGRectMake(254, 11, 83, 21);
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 254, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
        cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);
        
        [cell.watchLabel setHidden:FALSE];
    }
    else {
        // Don't show the watch only tag and resize the label and balance labels to use up the freed up space
        cell.labelLabel.frame = CGRectMake(20, 11, 185, 21);
        
        cell.balanceLabel.frame = CGRectMake(217, 11, 120, 21);
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 217, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
        cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);
        
        [cell.watchLabel setHidden:TRUE];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

@end
