//
//  EtherTransactionsViewController.m
//  Blockchain
//
//  Created by kevinwu on 8/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionsEtherViewController.h"
#import "RootService.h"
#import "TransactionEtherTableViewCell.h"
#import "EtherTransaction.h"
#import "Blockchain-Swift.h"

@interface TransactionsViewController ()
@property (nonatomic) UILabel *noTransactionsTitle;
@property (nonatomic) UILabel *noTransactionsDescription;
@property (nonatomic) UIButton *getBitcoinButton;
@property (nonatomic) NSString *balance;
@property (nonatomic) UIView *noTransactionsView;

- (void)setupNoTransactionsViewInView:(UIView *)view assetType:(LegacyAssetType)assetType;
@end

@interface TransactionsEtherViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSArray *transactions;
@end

@implementation TransactionsEtherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0,
                                 DEFAULT_HEADER_HEIGHT_OFFSET,
                                 [UIScreen mainScreen].bounds.size.width,
                                 [UIScreen mainScreen].bounds.size.height - DEFAULT_HEADER_HEIGHT - DEFAULT_HEADER_HEIGHT_OFFSET - DEFAULT_FOOTER_HEIGHT);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    [self setupPullToRefresh];
    
    [self setupNoTransactionsViewInView:self.tableView assetType:LegacyAssetTypeEther];
    
    [self reload];
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
}

- (void)updateBalance
{
    NSString *balance = [WalletManager.sharedInstance.wallet getEthBalanceTruncated];

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    self.balance = BlockchainSettings.sharedAppInstance.symbolLocal ? [NSNumberFormatter formatEthToFiatWithSymbol:balance exchangeRate:tabControllerManager.latestEthExchangeRate] : [NSNumberFormatter formatEth:balance];
}

- (void)reloadSymbols
{
    [self updateBalance];
    
    [self.tableView reloadData];
    
    [self.detailViewController reloadSymbols];
}

- (void)setupPullToRefresh
{
    // Tricky way to get the refreshController to work on a UIViewController - @see http://stackoverflow.com/a/12502450/2076094
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                       action:@selector(getHistory)
             forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)getHistory
{
    [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
    
    [WalletManager.sharedInstance.wallet performSelector:@selector(getEthHistory) withObject:nil afterDelay:0.1f];
}

- (void)loadTransactions
{
    self.transactions = [WalletManager.sharedInstance.wallet getEthTransactions];
    
    self.noTransactionsView.hidden = self.transactions.count > 0;
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)getAssetButtonClicked
{
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    [tabControllerManager receiveCoinClicked:nil];
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionEtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"transaction"];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TransactionEtherCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    EtherTransaction *transaction = self.transactions[indexPath.row];

    cell.transaction = transaction;
    
    [cell reload];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TransactionEtherTableViewCell *cell = (TransactionEtherTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell transactionClicked];
}

@end
