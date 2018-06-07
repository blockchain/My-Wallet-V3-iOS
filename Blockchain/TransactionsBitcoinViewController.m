//
//  TransactionsViewController.m
//  Blockchain
//
//  Created by Ben Reeves on 10/01/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionsBitcoinViewController.h"
#import "Transaction.h"
#import "TransactionTableCell.h"
#import "MultiAddressResponse.h"
#import "TransactionDetailViewController.h"
#import "BCAddressSelectionView.h"
#import "TransactionDetailNavigationController.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"
#import "NSNumberFormatter+Currencies.h"

@interface TransactionsViewController ()
@property (nonatomic) UILabel *noTransactionsTitle;
@property (nonatomic) UILabel *noTransactionsDescription;
@property (nonatomic) UIButton *getBitcoinButton;
@property (nonatomic) UIView *noTransactionsView;
@property (nonatomic) UIView *filterSelectorView;
@property (nonatomic) UILabel *filterSelectorLabel;
@property (nonatomic) NSString *balance;
- (void)setupNoTransactionsViewInView:(UIView *)view assetType:(LegacyAssetType)assetType;
- (void)setupFilter;
- (uint64_t)getAmountForReceivedTransaction:(Transaction *)transaction;
@end

@interface TransactionsBitcoinViewController () <AddressSelectionDelegate, UIScrollViewDelegate>

@property (nonatomic) int sectionMain;

@property (nonatomic) UIView *bounceView;

@property (nonatomic) NSArray *transactions;
@property (nonatomic) BOOL receivedTransactionMessage;
@property (nonatomic) BOOL hasZeroTotalBalance;

@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) int lastNumberTransactions;
@end

@implementation TransactionsBitcoinViewController

@synthesize data;
@synthesize latestBlock;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self updateData:WalletManager.sharedInstance.latestMultiAddressResponse];
    
    [self reload];
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.sectionMain) {
        NSInteger transactionCount = [data.transactions count];
#ifdef ENABLE_TRANSACTION_FETCHING
        if (data != nil && transactionCount == 0 && !self.loadedAllTransactions && self.clickedFetchMore) {
            [WalletManager.sharedInstance.wallet fetchMoreTransactions];
        }
#endif
        return transactionCount;
    } else {
        DLog(@"Transactions view controller error: invalid section %lu", section);
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.sectionMain) {
        
        Transaction * transaction = [self.transactions objectAtIndex:[indexPath row]];

        TransactionTableCell * cell = (TransactionTableCell*)[tableView dequeueReusableCellWithIdentifier:@"transaction"];

        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:nil options:nil] objectAtIndex:0];
        }

        cell.transaction = transaction;

        [cell reload];

        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        cell.selectedBackgroundView = [self selectedBackgroundViewForCell:cell];

        return cell;
    } else {
        DLog(@"Invalid section %lu", indexPath.section);
        return nil;
    }
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.sectionMain) {
        TransactionTableCell *cell = (TransactionTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.assetType = LegacyAssetTypeBitcoin;
        [cell transactionClicked:nil];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        DLog(@"Invalid section %lu", indexPath.section);
    }
}

- (void)tableView:(UITableView *)_tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef ENABLE_TRANSACTION_FETCHING
    if (!self.loadedAllTransactions) {
        if (indexPath.row == (int)[data.transactions count] - 1) {
            // If user scrolled down at all or if the user clicked fetch more and the table isn't filled, fetch
            if (_tableView.contentOffset.y > 0 || (_tableView.contentOffset.y <= 0 && self.clickedFetchMore)) {
                [WalletManager.sharedInstance.wallet fetchMoreTransactions];
            } else {
                [self showMoreButton];
            }
        } else {
            [self hideMoreButton];
        }
    }
#endif
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)drawRect:(CGRect)rect
{
    //Setup
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 320, 15));
}

- (UITableView*)tableView
{
    return tableView;
}

- (void)setText
{
    [self setupNoTransactionsViewInView:tableView assetType:self.assetType];
    
    UIColor *bounceViewBackgroundColor = [UIColor whiteColor];
    UIColor *refreshControlTintColor = [UIColor lightGrayColor];
    
    self.bounceView.backgroundColor = bounceViewBackgroundColor;
    self.refreshControl.tintColor = refreshControlTintColor;
    
    // Data not loaded yet
    if (!self.data) {
        self.noTransactionsView.hidden = YES;
        
        self.filterIndex = FILTER_INDEX_ALL;
        
        self.balance = @"";
        [self changeFilterLabel:@""];
    }
    // Data loaded, but no transactions yet
    else if (self.data.transactions.count == 0) {
        self.noTransactionsView.hidden = NO;
        
#ifdef ENABLE_TRANSACTION_FETCHING
        if (!self.loadedAllTransactions) {
            [self showMoreButton];
        } else {
            [self hideMoreButton];
        }
#endif
        // Balance
        self.balance = [NSNumberFormatter formatMoney:[self getBalance] localCurrency:BlockchainSettings.sharedAppInstance.symbolLocal];
        [self changeFilterLabel:[self getFilterLabel]];

    }
    // Data loaded and we have a balance - display the balance and transactions
    else {
        self.noTransactionsView.hidden = YES;
        
        // Balance
        self.balance = [NSNumberFormatter formatMoney:[self getBalance] localCurrency: BlockchainSettings.sharedAppInstance.symbolLocal
];
        [self changeFilterLabel:[self getFilterLabel]];
    }
}

- (void)showMoreButton
{
    self.moreButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    self.moreButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - self.moreButton.frame.size.height/2);
    self.moreButton.hidden = NO;
}

- (void)hideMoreButton
{
    self.moreButton.hidden = YES;
}

- (void)fetchMoreClicked
{
    self.clickedFetchMore = YES;
    [self reload];
}

- (void)setLatestBlock:(LatestBlock *)_latestBlock
{
    latestBlock = _latestBlock;
    
    if (latestBlock) {
        // TODO This only works if the unconfirmed transaction is included in the latest block, otherwise we would have to fetch history again to get the actual value
        // Update block index for new transactions
        for (int i = 0; i < self.data.transactions.count; i++) {
            if (((Transaction *) self.data.transactions[i]).block_height == 0) {
                ((Transaction *) self.data.transactions[i]).block_height = latestBlock.height;
            }
            else {
                break;
            }
        }
    }
}

- (void)didReceiveTransactionMessage
{
    self.receivedTransactionMessage = YES;
}

- (void)didGetMessages
{
    [self reload];
}

- (void)reload
{
    [self reloadData];
    
    [self.detailViewController didGetHistory];
}

- (void)reloadData
{
    self.sectionMain = 0;
    
    self.transactions = data.transactions;
    
    [self setText];
    
    [tableView reloadData];
    
    [self reloadNewTransactions];
    
    [self animateFirstCell];
    
    [self reloadLastNumberOfTransactions];
    
    // This should be done when request has finished but there is no callback
    if (self.refreshControl && self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)updateData:(MultiAddressResponse *)newData
{
    data = newData;
}

- (void)reloadSymbols
{
    [self setText];

    [self reloadData];
    
    [self.detailViewController reloadSymbols];
}

- (void)reloadNewTransactions
{
    if (data.n_transactions > self.lastNumberTransactions) {
        uint32_t numNewTransactions = data.n_transactions - self.lastNumberTransactions;
        // Max number displayed
        if (numNewTransactions > data.transactions.count) {
            numNewTransactions = (uint32_t) data.transactions.count;
        }
        // We only do this for the last five transactions at most
        if (numNewTransactions > 5) {
            numNewTransactions = 5;
        }
        
        NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity:numNewTransactions];
        for (int i = 0; i < numNewTransactions; i++) {
            [rows addObject:[NSIndexPath indexPathForRow:i inSection:self.sectionMain]];
        }
        
        [tableView reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)animateFirstCell
{
    if (data.transactions.count > 0 && self.receivedTransactionMessage) {
        
        self.receivedTransactionMessage = NO;

        [self performSelector:@selector(didGetNewTransaction) withObject:nil afterDelay:0.1f];
    } else {
        self.hasZeroTotalBalance = [WalletManager.sharedInstance.wallet getTotalActiveBalance] == 0;
    }
}

- (void)reloadLastNumberOfTransactions
{
    // If all the data is available, set the lastNumberTransactions - reload gets called once when wallet is loaded and once when latest block is loaded
    if (WalletManager.sharedInstance.latestMultiAddressResponse) {
        self.lastNumberTransactions = data.n_transactions;
    }
}

- (void)loadTransactions
{
    self.lastNumberTransactions = data.n_transactions;

#ifdef ENABLE_TRANSACTION_FETCHING
    if (self.loadedAllTransactions) {
        self.loadedAllTransactions = NO;
        self.clickedFetchMore = YES;
        [WalletManager.sharedInstance.wallet getHistory];
    } else {
        BOOL tableViewIsEmpty = [self.tableView numberOfRowsInSection:self.sectionMain] == 0;
        BOOL tableViewIsFilled = ![[self.tableView indexPathsForVisibleRows] containsObject:[NSIndexPath indexPathForRow:[data.transactions count] - 1 inSection:0]];
        
        if (tableViewIsEmpty) {
            [self fetchMoreClicked];
        } else if (tableViewIsFilled) {
            self.clickedFetchMore = YES;
           [WalletManager.sharedInstance.wallet getHistory];
        } else {
           [self fetchMoreClicked];
        }
    }
#else
    [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
    
    [WalletManager.sharedInstance.wallet performSelector:@selector(getHistory) withObject:nil afterDelay:0.1f];
#endif
}

- (void)didGetNewTransaction
{
    Transaction *transaction = [data.transactions firstObject];
    
    if ([transaction.txType isEqualToString:TX_TYPE_SENT]) {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:self.sectionMain]] withRowAnimation:UITableViewRowAnimationFade];
    } else if ([transaction.txType isEqualToString:TX_TYPE_RECEIVED]) {
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:self.sectionMain]] withRowAnimation:UITableViewRowAnimationFade];
        
        BOOL shouldShowBackupReminder = (self.hasZeroTotalBalance && [WalletManager.sharedInstance.wallet getTotalActiveBalance] > 0 &&
                                         ![WalletManager.sharedInstance.wallet isRecoveryPhraseVerified]);

        TabControllerManager *tabControllerManager = AppCoordinator.sharedInstance.tabControllerManager;
        if (tabControllerManager.tabViewController.selectedIndex == TAB_RECEIVE && ![tabControllerManager isSending]) {
            uint64_t amount = [self getAmountForReceivedTransaction:transaction];
            [tabControllerManager paymentReceived:amount showBackupReminder:shouldShowBackupReminder];
        } else if (shouldShowBackupReminder) {
            [ReminderPresenter.sharedInstance showBackupReminderWithFirstReceive:YES];
        }
    } else {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:self.sectionMain]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)showTransactionDetailForHash:(NSString *)hash
{
    for (Transaction *transaction in data.transactions) {
        if ([transaction.myHash isEqualToString:hash]) {
            [self showTransactionDetail:transaction];
            break;
        }
    }
}

- (void)showTransactionDetail:(Transaction *)transaction
{
    TransactionDetailViewController *detailViewController = [TransactionDetailViewController new];
    detailViewController.transactionModel = [[TransactionDetailViewModel alloc] initWithTransaction:transaction];
    
    TransactionDetailNavigationController *navigationController = [[TransactionDetailNavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.transactionHash = transaction.myHash;

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;

    detailViewController.busyViewDelegate = navigationController;
    navigationController.onDismiss = ^() {
        tabControllerManager.transactionsBitcoinViewController.detailViewController = nil;
    };
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    tabControllerManager.transactionsBitcoinViewController.detailViewController = detailViewController;

    UIViewController *topViewController = UIApplication.sharedApplication.keyWindow.rootViewController.topMostViewController;
    [topViewController presentViewController:navigationController animated:YES completion:nil];
}

- (uint64_t)getBalance
{
    if (self.filterIndex == FILTER_INDEX_ALL) {
        return [WalletManager.sharedInstance.wallet getTotalActiveBalance];
    } else if (self.filterIndex == FILTER_INDEX_IMPORTED_ADDRESSES) {
        return [WalletManager.sharedInstance.wallet getTotalBalanceForActiveLegacyAddresses:LegacyAssetTypeBitcoin];
    } else {
        return [[WalletManager.sharedInstance.wallet getBalanceForAccount:(int)self.filterIndex assetType:self.assetType] longLongValue];
    }
}

- (NSString *)getFilterLabel
{
    if (self.filterIndex == FILTER_INDEX_ALL) {
        return BC_STRING_ALL_WALLETS;
    } else if (self.filterIndex == FILTER_INDEX_IMPORTED_ADDRESSES) {
        return BC_STRING_IMPORTED_ADDRESSES;
    } else {
        return [WalletManager.sharedInstance.wallet getLabelForAccount:(int)self.filterIndex assetType:self.assetType];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (UIView *)selectedBackgroundViewForCell:(UITableViewCell *)cell
{
    // Selected cell color
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
    [v setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
    return v;
}

#pragma mark - Table View Helpers

- (int)sectionCountForIndex:(int)sectionNumber
{
    return sectionNumber < 0 ? 0 : 1;
}

#pragma mark - Filtering

- (void)changeFilterLabel:(NSString *)newText
{
    self.filterSelectorLabel.text = newText;
}

- (void)filterSelectorViewTapped
{
    [self showFilterMenu];
}

- (void)showFilterMenu
{
    BCAddressSelectionView *filterView = [[BCAddressSelectionView alloc] initWithWallet:WalletManager.sharedInstance.wallet selectMode:SelectModeFilter delegate:self];
    [[ModalPresenter sharedInstance] showModalWithContent:filterView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_BALANCES onDismiss:nil onResume:nil];
}

#pragma mark - Address Selection Delegate

- (LegacyAssetType)getAssetType
{
    return self.assetType;
}

- (void)didSelectFilter:(int)filter
{
    TabControllerManager *tabControllerManager = AppCoordinator.sharedInstance.tabControllerManager;

    if (filter == FILTER_INDEX_IMPORTED_ADDRESSES) {
        [tabControllerManager filterTransactionsByImportedAddresses];
    } else {
        NSString *filterLabel = [WalletManager.sharedInstance.wallet getLabelForAccount:filter assetType:self.assetType];
        [tabControllerManager filterTransactionsByAccount:filter filterLabel:filterLabel assetType:self.assetType];
    }

    [WalletManager.sharedInstance.wallet reloadFilter];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFilter];
    
    [self.tableView changeYPosition:self.filterSelectorView.frame.origin.y + self.filterSelectorView.frame.size.height];
    [self.tableView changeHeight:self.tableView.frame.size.height - self.filterSelectorView.frame.size.height];
    
    self.lastNumberTransactions = INT_MAX;
    
    self.loadedAllTransactions = NO;
    
    self.view.frame = CGRectMake(0,
                                 DEFAULT_HEADER_HEIGHT_OFFSET,
                                 [UIScreen mainScreen].bounds.size.width,
                                 [UIScreen mainScreen].bounds.size.height - DEFAULT_HEADER_HEIGHT - DEFAULT_HEADER_HEIGHT_OFFSET - DEFAULT_FOOTER_HEIGHT);
    
    headerView.clipsToBounds = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.scrollsToTop = YES;
    
    [balanceBigButton.titleLabel setMinimumScaleFactor:.5f];
    [balanceBigButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [balanceBigButton addTarget:self action:@selector(toggleSymbol) forControlEvents:UIControlEventTouchUpInside];
    
#ifdef ENABLE_TRANSACTION_FETCHING
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.moreButton setTitle:BC_STRING_LOAD_MORE_TRANSACTIONS forState:UIControlStateNormal];
    self.moreButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.moreButton.backgroundColor = [UIColor whiteColor];
    [self.moreButton setTitleColor:COLOR_BLOCKCHAIN_BLUE forState:UIControlStateNormal];
    [self.view addSubview:self.moreButton];
    [self.moreButton addTarget:self action:@selector(fetchMoreClicked) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.hidden = YES;
#endif
    
    [self setupBlueBackgroundForBounceArea];
    
    [self setupPullToRefresh];
    
    [self reload];
}

- (void)toggleSymbol
{
    BlockchainSettings.sharedAppInstance.symbolLocal = !BlockchainSettings.sharedAppInstance.symbolLocal;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.balance = @"";
    [self setText];
    [self reloadData];
    
    balanceBigButton.center = CGPointMake(headerView.center.x, balanceBigButton.center.y);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    WalletManager.sharedInstance.wallet.isFetchingTransactions = NO;
}

#pragma mark - Setup

- (void)setupBlueBackgroundForBounceArea
{
    // Blue background for bounce area
    CGRect frame = self.view.bounds;
    frame.origin.y = -frame.size.height;
    self.bounceView = [[UIView alloc] initWithFrame:frame];
    [self.tableView addSubview:self.bounceView];
    // Make sure the refresh control is in front of the blue area
    self.bounceView.layer.zPosition -= 1;
}

- (void)setupPullToRefresh
{
    // Tricky way to get the refreshController to work on a UIViewController - @see http://stackoverflow.com/a/12502450/2076094
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                       action:@selector(loadTransactions)
             forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)getAssetButtonClicked
{
    if ([WalletManager.sharedInstance.wallet isBuyEnabled]) {
        [BuySellCoordinator.sharedInstance showBuyBitcoinView];
    } else {
        TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
        [tabControllerManager receiveCoinClicked:nil];
    }
}

@end
