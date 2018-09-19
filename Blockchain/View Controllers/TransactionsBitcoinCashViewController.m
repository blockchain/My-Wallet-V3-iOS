//
//  TransactionsBitcoinCashViewController.m
//  Blockchain
//
//  Created by kevinwu on 2/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionsBitcoinCashViewController.h"
#import "NSNumberFormatter+Currencies.h"
#import "TransactionTableCell.h"
#import "Transaction.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface TransactionsViewController () <AddressSelectionDelegate>
@property (nonatomic) UILabel *noTransactionsTitle;
@property (nonatomic) UILabel *noTransactionsDescription;
@property (nonatomic) UIButton *getBitcoinButton;
@property (nonatomic) UIView *noTransactionsView;
@property (nonatomic) UILabel *filterSelectorView;
@property (nonatomic) UILabel *filterSelectorLabel;
@property (nonatomic) NSString *balance;
- (void)setupNoTransactionsViewInView:(UIView *)view assetType:(LegacyAssetType)assetType;
- (void)setupFilter;
- (uint64_t)getAmountForReceivedTransaction:(Transaction *)transaction;
@end

@interface TransactionsBitcoinCashViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSArray *transactions;
@end

@implementation TransactionsBitcoinCashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:YES assetSelector:YES];
    
    [self setupFilter];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.tableView changeYPosition:self.filterSelectorView.frame.origin.y + self.filterSelectorView.frame.size.height];
    [self.tableView changeHeight:self.tableView.frame.size.height - self.filterSelectorView.frame.size.height];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    
    [self setupPullToRefresh];

    [self setupNoTransactionsViewInView:self.tableView assetType:LegacyAssetTypeBitcoinCash];

    [self loadTransactions];
}

- (void)setupPullToRefresh
{
    // Tricky way to get the refreshController to work on a UIViewController - @see http://stackoverflow.com/a/12502450/2076094
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(getHistoryAndRates)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.balance = @"";
    
    [self reload];
}

- (void)reload
{
    [self loadTransactions];
    
    [self updateBalance];
    
    [self.detailViewController didGetHistory];
}

- (void)updateBalance
{
    self.balance = [NSNumberFormatter formatBchWithSymbol:[self getBalance]];
}

- (uint64_t)getBalance
{
    if (self.filterIndex == FILTER_INDEX_ALL) {
        return [WalletManager.sharedInstance.wallet getBchBalance];
    } else if (self.filterIndex == FILTER_INDEX_IMPORTED_ADDRESSES) {
        return [WalletManager.sharedInstance.wallet getTotalBalanceForActiveLegacyAddresses:LegacyAssetTypeBitcoinCash];
    } else {
        return [[WalletManager.sharedInstance.wallet getBalanceForAccount:(int)self.filterIndex assetType:LegacyAssetTypeBitcoinCash] longLongValue];
    }
}

- (void)loadTransactions
{
    self.transactions = [WalletManager.sharedInstance.wallet getBitcoinCashTransactions:self.filterIndex];
    
    self.noTransactionsView.hidden = self.transactions.count > 0;
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)reloadSymbols
{
    [self reload];
    
    [self.detailViewController reloadSymbols];
}

- (void)getHistoryAndRates
{
    [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];

    [WalletManager.sharedInstance.wallet performSelector:@selector(getBitcoinCashHistoryAndRates) withObject:nil afterDelay:0.1f];
}

- (void)didReceiveTransactionMessage
{
    [self performSelector:@selector(didGetNewTransaction) withObject:nil afterDelay:0.1f];
}

- (void)didGetNewTransaction
{
    Transaction *transaction = [self.transactions firstObject];
    
    if ([transaction.txType isEqualToString:TX_TYPE_SENT]) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else if ([transaction.txType isEqualToString:TX_TYPE_RECEIVED]) {
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

        TabControllerManager *tabControllerManager = AppCoordinator.sharedInstance.tabControllerManager;
        if (tabControllerManager.tabViewController.selectedIndex == TAB_RECEIVE && ![tabControllerManager isSending]) {
            uint64_t amount = [self getAmountForReceivedTransaction:transaction];
            [tabControllerManager paymentReceived:amount showBackupReminder:NO];
        }
    } else {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)getAssetButtonClicked
{
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    [tabControllerManager receiveCoinClicked:nil];
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionTableCell * cell = (TransactionTableCell*)[tableView dequeueReusableCellWithIdentifier:@"transaction"];
    
    Transaction * transaction = [self.transactions objectAtIndex:[indexPath row]];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:nil options:nil] objectAtIndex:0];
        cell.assetType = LegacyAssetTypeBitcoinCash;
    }
    
    cell.transaction = transaction;
    
    [cell reload];
    
    [cell changeBtcButtonTitleText:[NSNumberFormatter formatBchWithSymbol:ABS(transaction.amount)]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    cell.selectedBackgroundView = [self selectedBackgroundViewForCell:cell];
    
    return cell;
}

- (UIView *)selectedBackgroundViewForCell:(UITableViewCell *)cell
{
    // Selected cell color
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
    [v setBackgroundColor:UIColor.brandPrimary];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transactions.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TransactionTableCell *cell = (TransactionTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell bitcoinCashTransactionClicked];
}

#pragma mark - Filtering

- (void)filterSelectorViewTapped
{
    [self showFilterMenu];
}

- (void)showFilterMenu
{
    BCAddressSelectionView *filterView = [[BCAddressSelectionView alloc] initWithWallet:WalletManager.sharedInstance.wallet selectMode:SelectModeFilter delegate:self];
    [[ModalPresenter sharedInstance] showModalWithContent:filterView closeType:ModalCloseTypeBack showHeader:YES headerText:[LocalizationConstantsObjcBridge balances] onDismiss:nil onResume:nil];
}

#pragma mark - Address Selection Delegate

- (LegacyAssetType)getAssetType
{
    return LegacyAssetTypeBitcoinCash;
}

- (void)didSelectFilter:(int)filter
{
    self.filterIndex = filter;
    if (filter == FILTER_INDEX_ALL) {
        self.filterSelectorLabel.text = BC_STRING_ALL_WALLETS;
    } else if (self.filterIndex == FILTER_INDEX_IMPORTED_ADDRESSES) {
        self.filterSelectorLabel.text = BC_STRING_IMPORTED_ADDRESSES;
    } else {
        self.filterSelectorLabel.text = [WalletManager.sharedInstance.wallet getLabelForAccount:filter assetType:LegacyAssetTypeBitcoinCash];
    }
    [self reload];
}

@end
