//
//  TransactionDetailViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 8/23/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "Transaction.h"
#import "TransactionDetailDescriptionCell.h"
#import "TransactionDetailToCell.h"
#import "TransactionDetailFromCell.h"
#import "TransactionDetailDateCell.h"
#import "TransactionDetailStatusCell.h"
#import "TransactionDetailValueCell.h"
#import "TransactionDetailTableCell.h"
#import "TransactionDetailDoubleSpendWarningCell.h"
#import "NSNumberFormatter+Currencies.h"
#import "RootService.h"
#import "TransactionDetailNavigationController.h"
#import "BCWebViewController.h"
#import "TransactionRecipientsViewController.h"
#import <SafariServices/SafariServices.h>

#ifdef DEBUG
#import "UITextView+AssertionFailureFix.h"
#endif

const CGFloat rowHeightDefault = 60;
const CGFloat rowHeightWarning = 44;
const CGFloat rowHeightValue = 100;
const CGFloat rowHeightValueReceived = 80;

@interface TransactionDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, DescriptionDelegate, ValueDelegate, StatusDelegate, RecipientsDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UITextView *textView;
@property (nonatomic) NSRange textViewCursorPosition;
@property (nonatomic) UIView *descriptionInputAccessoryView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isGettingFiatAtTime;
@property (nonatomic) NSMutableArray *rows;

@property (nonatomic) TransactionRecipientsViewController *recipientsViewController;

@end
@implementation TransactionDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rows = [NSMutableArray new];
    
    if (self.transactionModel.doubleSpend || self.transactionModel.replaceByFee) [self.rows addObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_WARNING];
    [self.rows addObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_VALUE];
    if (!self.transactionModel.hideNote) [self.rows addObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_DESCRIPTION];
    [self.rows addObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_TO];
    [self.rows addObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_FROM];
    [self.rows addObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_DATE];
    [self.rows addObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_STATUS];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[TransactionDetailDoubleSpendWarningCell class] forCellReuseIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_WARNING];
    [self.tableView registerClass:[TransactionDetailDescriptionCell class] forCellReuseIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_DESCRIPTION];
    [self.tableView registerClass:[TransactionDetailToCell class] forCellReuseIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_TO];
    [self.tableView registerClass:[TransactionDetailFromCell class] forCellReuseIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_FROM];
    [self.tableView registerClass:[TransactionDetailDateCell class] forCellReuseIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_DATE];
    [self.tableView registerClass:[TransactionDetailStatusCell class] forCellReuseIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_STATUS];
    [self.tableView registerClass:[TransactionDetailValueCell class] forCellReuseIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_VALUE];

    self.tableView.tableFooterView = [UIView new];
    
    [self setupPullToRefresh];
    [self setupTextViewInputAccessoryView];

    if (![self.transactionModel.fiatAmountsAtTime objectForKey:[self getCurrencyCode]]) {
        [self getFiatAtTime];
    }
}

- (void)setupTextViewInputAccessoryView
{
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, BUTTON_HEIGHT)];
    inputAccessoryView.backgroundColor = COLOR_WARNING_RED;
    
    UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, BUTTON_HEIGHT)];
    updateButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [updateButton.titleLabel setFont:[UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:updateButton.titleLabel.font.pointSize]];
    [updateButton setTitle:BC_STRING_UPDATE forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(saveNote) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:updateButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(updateButton.frame.size.width - 50, 0, 50, BUTTON_HEIGHT)];
    cancelButton.backgroundColor = COLOR_BUTTON_GRAY_CANCEL;
    [cancelButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelEditing) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:cancelButton];
    
    self.descriptionInputAccessoryView = inputAccessoryView;
}

- (void)getFiatAtTime
{
    [app.wallet getFiatAtTime:self.transactionModel.time value:self.transactionModel.decimalAmount currencyCode:[app.latestResponse.symbol_local.code lowercaseString] assetType:self.transactionModel.assetType];
    self.isGettingFiatAtTime = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataAfterGetFiatAtTime) name:NOTIFICATION_KEY_GET_FIAT_AT_TIME object:nil];
}

- (NSString *)getNotePlaceholder
{
    if (self.transactionModel.assetType == AssetTypeBitcoin) {
        NSString *label = [app.wallet getNotePlaceholderForTransactionHash:self.transactionModel.myHash];
        return label.length > 0 ? label : nil;
    } else {
        return nil;
    }
}

- (void)cancelEditing
{
    self.textViewCursorPosition = self.textView.selectedRange;

    [self.textView resignFirstResponder];
    self.textView.editable = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.rows indexOfObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_DESCRIPTION] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)saveNote
{
    self.textViewCursorPosition = self.textView.selectedRange;
    
    [self.textView resignFirstResponder];
    self.textView.editable = NO;
    
    if (self.transactionModel.assetType == AssetTypeBitcoin) {
        [self.busyViewDelegate showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];
        [app.wallet saveNote:self.textView.text forTransaction:self.transactionModel.myHash];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHistoryAfterSavingNote) name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
    } else if (self.transactionModel.assetType == AssetTypeEther) {
        [app.wallet saveEtherNote:self.textView.text forTransaction:self.transactionModel.myHash];
    }
}

- (void)getHistoryAfterSavingNote
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
    [app.wallet getHistory];
}

- (void)didGetHistory
{
    if (self.isGettingFiatAtTime) return; // Multiple calls to didGetHistory will occur due to did_set_latest_block and did_multiaddr; prevent observer from being added twice
    [self getFiatAtTime];
}

- (void)reloadDataAfterGetFiatAtTime
{
    self.isGettingFiatAtTime = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_GET_FIAT_AT_TIME object:nil];
    [self reloadData];
}

- (void)reloadData
{
    [self.busyViewDelegate hideBusyView];
    
    NSArray *newTransactions;
    if (self.transactionModel.assetType == AssetTypeBitcoin) {
        newTransactions = app.latestResponse.transactions;
    } else if (self.transactionModel.assetType == AssetTypeEther) {
        newTransactions = app.wallet.etherTransactions;
    } else if (self.transactionModel.assetType == AssetTypeBitcoinCash) {
        newTransactions = app.wallet.bitcoinCashTransactions;
    }
    
    [self findAndUpdateTransaction:newTransactions];
    
    [self.tableView reloadData];
    
    if (self.refreshControl && self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)reloadEtherData
{
    [self.busyViewDelegate hideBusyView];
    
    [self.tableView reloadData];
    
    if (self.refreshControl && self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)findAndUpdateTransaction:(NSArray *)newTransactions
{
    BOOL didFindTransaction = NO;
    
    for (Transaction *transaction in newTransactions) {
        if ([transaction.myHash isEqualToString:self.transactionModel.myHash]) {
            if (self.transactionModel.assetType == AssetTypeBitcoin || self.transactionModel.assetType == AssetTypeEther) self.transactionModel.note = transaction.note;
            self.transactionModel.fiatAmountsAtTime = transaction.fiatAmountsAtTime;
            didFindTransaction = YES;
            break;
        }
    }

    if (!didFindTransaction) {
        [self dismissViewControllerAnimated:YES completion:^{
            [app standardNotify:[NSString stringWithFormat:BC_STRING_COULD_NOT_FIND_TRANSACTION_ARGUMENT, self.transactionModel.myHash]];
        }];
    }
}

- (CGSize)addVerticalPaddingToSize:(CGSize)size
{
    return CGSizeMake(size.width, size.height + 16);
}

- (void)reloadSymbols
{
    [self.recipientsViewController reloadTableView];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.rows indexOfObject:CELL_IDENTIFIER_TRANSACTION_DETAIL_VALUE] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowType = [self.rows objectAtIndex:indexPath.row];
    
    if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_WARNING]) {
        TransactionDetailDoubleSpendWarningCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_WARNING forIndexPath:indexPath];
        [cell configureWithTransactionModel:self.transactionModel];
        return cell;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_VALUE]) {
        TransactionDetailValueCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_VALUE forIndexPath:indexPath];
        cell.valueDelegate = self;
        [cell configureWithTransactionModel:self.transactionModel];
        return cell;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_DESCRIPTION]) {
        TransactionDetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_DESCRIPTION forIndexPath:indexPath];
        cell.descriptionDelegate = self;
        [cell configureWithTransactionModel:self.transactionModel];
        self.textView = cell.textView;
        cell.textView.inputAccessoryView = [self getDescriptionInputAccessoryView];
        return cell;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_TO]) {
        TransactionDetailToCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_TO forIndexPath:indexPath];
        [cell configureWithTransactionModel:self.transactionModel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToAddressOptions)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [cell.accessoryLabel addGestureRecognizer:tapGestureRecognizer];
        cell.accessoryLabel.userInteractionEnabled = YES;
        
        return cell;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_FROM]) {
        TransactionDetailFromCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_FROM forIndexPath:indexPath];
        [cell configureWithTransactionModel:self.transactionModel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFromAddressOptions)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [cell.accessoryLabel addGestureRecognizer:tapGestureRecognizer];
        cell.accessoryLabel.userInteractionEnabled = YES;
        
        return cell;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_DATE]) {
        TransactionDetailDateCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_DATE forIndexPath:indexPath];
        [cell configureWithTransactionModel:self.transactionModel];
        return cell;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_STATUS]) {
        TransactionDetailStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_DETAIL_STATUS forIndexPath:indexPath];
        cell.statusDelegate = self;
        [cell configureWithTransactionModel:self.transactionModel];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowType = [self.rows objectAtIndex:indexPath.row];
    
    if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_TO] && self.transactionModel.to.count > 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showRecipients];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowType = [self.rows objectAtIndex:indexPath.row];
    
    if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_WARNING]) {
        return rowHeightWarning;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_VALUE]) {
        return [self.transactionModel.txType isEqualToString:TX_TYPE_RECEIVED] ? rowHeightValueReceived : rowHeightValue;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_DESCRIPTION] && self.textView.text) {
        return UITableViewAutomaticDimension;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_TO]) {
        return rowHeightDefault;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_FROM]) {
        return rowHeightDefault/2 + 20.5/2;
    } else if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_STATUS]) {
        return rowHeightDefault + 80;
    }
    return rowHeightDefault;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeightDefault;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowType = [self.rows objectAtIndex:indexPath.row];

    if ([rowType isEqualToString:CELL_IDENTIFIER_TRANSACTION_DETAIL_TO]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, CGRectGetWidth(cell.bounds)-15)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *spacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    return spacer;
}

- (void)showRecipients
{
    self.recipientsViewController = [[TransactionRecipientsViewController alloc] initWithRecipients:self.transactionModel.to];
    self.recipientsViewController.recipientsDelegate = self;
    [self.navigationController pushViewController:self.recipientsViewController animated:YES];
}

- (void)setupPullToRefresh
{
    // Tricky way to get the refreshController to work on a UIViewController - @see http://stackoverflow.com/a/12502450/2076094
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor grayColor]];
    [self.refreshControl addTarget:self
                       action:@selector(refreshControlActivated)
             forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)refreshControlActivated
{
    [self.busyViewDelegate showBusyViewWithLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
    [app.wallet performSelector:@selector(getHistory) withObject:nil afterDelay:0.1f];
}

- (void)showToAddressOptions
{
    [self showAddressOptionsFrom:NO];
}

- (void)showFromAddressOptions
{
    [self showAddressOptionsFrom:YES];
}

- (void)showAddressOptionsFrom:(BOOL)willSelectFrom
{
    NSString *address;
    NSString *labelString;
    
    if (willSelectFrom) {
        if (self.transactionModel.hasFromLabel) return;
        address = self.transactionModel.fromAddress;
        labelString = self.transactionModel.fromString;
    } else {
        if (self.transactionModel.hasToLabel) return;
        id toObject = [self.transactionModel.to firstObject];
        address = [toObject isKindOfClass:[NSString class]] ? toObject : [toObject objectForKey:DICTIONARY_KEY_ADDRESS];
        labelString = self.transactionModel.toString;
    }
    
    if (self.transactionModel.assetType == AssetTypeBitcoinCash && [app.wallet isValidAddress:address assetType:AssetTypeBitcoinCash]) {
        address = [app.wallet toBitcoinCash:address includePrefix:NO];
    }
    
    UIAlertController *copyAddressController = [UIAlertController alertControllerWithTitle:labelString message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [copyAddressController addAction:[UIAlertAction actionWithTitle:BC_STRING_COPY_ADDRESS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (address) {
            [UIPasteboard generalPasteboard].string = address;
        } else {
            [app standardNotify:BC_STRING_ERROR_COPYING_TO_CLIPBOARD];
        }
    }]];
    [copyAddressController addAction:[UIAlertAction actionWithTitle:BC_STRING_SEND_TO_ADDRESS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [app setupSendToAddress:address];
        }];
    }]];
    [copyAddressController addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:copyAddressController animated:YES completion:nil];
}

#pragma mark - Detail Delegate

- (void)toggleSymbol
{
    [app toggleSymbol];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGPoint currentOffset = self.tableView.contentOffset;
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    self.tableView.contentOffset = currentOffset;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect keyboardAccessoryRect = [self.descriptionInputAccessoryView.superview convertRect:self.descriptionInputAccessoryView.frame toView:self.tableView];
        CGRect keyboardPlusAccessoryRect = CGRectMake(keyboardAccessoryRect.origin.x, keyboardAccessoryRect.origin.y, keyboardAccessoryRect.size.width, self.view.frame.size.height - keyboardAccessoryRect.origin.y);
        
        UITextRange *selectionRange = [textView selectedTextRange];
        CGRect selectionEndRect = [textView convertRect:[textView caretRectForPosition:selectionRange.end] toView:self.tableView];
        
        if (CGRectIntersectsRect(keyboardPlusAccessoryRect, selectionEndRect)) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + selectionEndRect.origin.y + selectionEndRect.size.height - keyboardAccessoryRect.origin.y + 15) animated:NO];
        }
    });
}

- (void)showWebviewDetail
{
    NSURL *url = [NSURL URLWithString:self.transactionModel.detailButtonLink];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        if (safariViewController) {
            [self presentViewController:safariViewController animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (NSString *)getCurrencyCode
{
    return [app.latestResponse.symbol_local.code lowercaseString];
}

- (CGFloat)getDefaultRowHeight
{
    return rowHeightDefault;
}

- (NSRange)getTextViewCursorPosition
{
    return self.textViewCursorPosition;
}

- (void)setDefaultTextViewCursorPosition:(NSUInteger)textLength
{
    self.textViewCursorPosition = NSMakeRange(textLength, 0);
    _didSetTextViewCursorPosition = YES;
}

- (UIView *)getDescriptionInputAccessoryView
{
    return self.textView.isEditable ? self.descriptionInputAccessoryView : nil;
}

#pragma mark - Recipients Delegate

- (BOOL)isWatchOnlyLegacyAddress:(NSString *)addr
{
    return [app.wallet isWatchOnlyLegacyAddress:addr];
}

@end
