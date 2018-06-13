//
//  TransferAllFundsViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 10/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransferAllFundsViewController.h"
#import "TransferAllFundsBuilder.h"
#import "TransferAmountTableCell.h"
#import "BCAddressSelectionView.h"
#import "BCModalViewController.h"
#import "BCNavigationController.h"
#import "Blockchain-Swift.h"

@interface TransferAllFundsViewController () <TransferAllFundsDelegate, UITableViewDataSource, UITableViewDelegate, AddressSelectionDelegate>
@property (nonatomic) uint64_t amount;
@property (nonatomic) uint64_t fee;
@property (nonatomic) NSArray *addressesUsed;
@property (nonatomic) NSString *temporarySecondPassword;
@property (nonatomic) TransferAllFundsBuilder *transferPaymentBuilder;
@property (nonatomic) int selectedAccountIndex;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIButton *sendButton;
@property (nonatomic) UILabel *fromLabel;
@property (nonatomic) UILabel *toLabel;
@property (nonatomic) UILabel *amountLabel;
@end

@implementation TransferAllFundsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
    self.transferPaymentBuilder = [[TransferAllFundsBuilder alloc] initWithAssetType:LegacyAssetTypeBitcoin usingSendScreen:NO];
    
    __weak TransferAllFundsViewController *weakSelf = self;
    
    self.transferPaymentBuilder.on_before_send = ^() {
        BCNavigationController *navigationController = (BCNavigationController *)weakSelf.navigationController;
        navigationController.shouldHideBusyView = NO;
        NSString *text = [NSString stringWithFormat:BC_STRING_TRANSFER_ALL_FROM_ADDRESS_ARGUMENT_ARGUMENT, weakSelf.transferPaymentBuilder.transferAllAddressesInitialCount - [weakSelf.transferPaymentBuilder.transferAllAddressesToTransfer count] + 1, weakSelf.transferPaymentBuilder.transferAllAddressesInitialCount];
        LoadingViewPresenter *loadingViewPresenter = [LoadingViewPresenter sharedInstance];
        if ([loadingViewPresenter isLoadingShown]) {
            [loadingViewPresenter updateBusyViewLoadingTextWithText:text];
        } else {
            [loadingViewPresenter showBusyViewWithLoadingText:text];
        }
    };
    self.transferPaymentBuilder.delegate = self;
}

- (void)setupViews
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, DEFAULT_HEADER_HEIGHT + 182)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - 120, self.tableView.frame.origin.y + self.tableView.frame.size.height + 24, 240, 40)];
    self.sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.sendButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    [self.sendButton setTitle:BC_STRING_TRANSFER_FUNDS forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.enabled = NO;
    self.sendButton.clipsToBounds = YES;
    self.sendButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [self.view addSubview:self.sendButton];
}

- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed;
{
    self.amount = [amount longLongValue];
    self.fee = [fee longLongValue];
    self.addressesUsed = addressesUsed;
    
    [self.tableView reloadData];
    
    [self.transferPaymentBuilder setupFirstTransferWithAddressesUsed:addressesUsed];
}

- (void)showSummaryForTransferAll
{
    self.sendButton.enabled = YES;
}

- (void)send
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [self.transferPaymentBuilder transferAllFundsToAccountWithSecondPassword:nil];
}

- (void)sendDuringTransferAll:(NSString *)secondPassword
{
    [self.transferPaymentBuilder transferAllFundsToAccountWithSecondPassword:secondPassword];
}

- (void)didFinishTransferFunds:(NSString *)summary
{
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    navigationController.shouldHideBusyView = YES;

    NSString *message = [self.transferPaymentBuilder.transferAllAddressesTransferred count] > 0 ? [NSString stringWithFormat:@"%@\n\n%@", summary, BC_STRING_PAYMENT_ASK_TO_ARCHIVE_TRANSFERRED_ADDRESSES] : summary;
    
    UIAlertController *alertForPaymentsSent = [UIAlertController alertControllerWithTitle:BC_STRING_PAYMENTS_SENT message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if ([self.transferPaymentBuilder.transferAllAddressesTransferred count] > 0) {
        [alertForPaymentsSent addAction:[UIAlertAction actionWithTitle:BC_STRING_ARCHIVE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self archiveTransferredAddresses];
            [self.delegate showSyncingView];
        }]];
        [alertForPaymentsSent addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
    } else {
        [alertForPaymentsSent addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    }
    
    [self.delegate didTransferAll];
    
    [self.delegate showAlert:alertForPaymentsSent];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        NSInteger addressCount = [self.addressesUsed count];
        NSString *addressesString = @"";
        if (addressCount == 1) {
            addressesString = [NSString stringWithFormat:BC_STRING_ARGUMENT_ADDRESS, addressCount];
        } else if (addressCount > 1) {
            addressesString = [NSString stringWithFormat:BC_STRING_ARGUMENT_ADDRESSES, addressCount];
        }
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = BC_STRING_FROM;
        cell.textLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:cell.textLabel.font.pointSize];
        cell.textLabel.textColor = COLOR_TEXT_DARK_GRAY;
        cell.detailTextLabel.text = self.addressesUsed == nil ? @"" : addressesString;
        cell.detailTextLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:cell.detailTextLabel.font.pointSize];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = BC_STRING_TO;
        cell.textLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:cell.textLabel.font.pointSize];
        cell.textLabel.textColor = COLOR_TEXT_DARK_GRAY;
        cell.detailTextLabel.text = [self.transferPaymentBuilder getLabelForDestinationAccount];
        cell.detailTextLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:cell.detailTextLabel.font.pointSize];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    } else if (indexPath.row == 2) {
        TransferAmountTableCell *cell = [[TransferAmountTableCell alloc] init];
        cell.mainLabel.text = BC_STRING_TRANSFER_AMOUNT;
        cell.fiatLabel.text = [self.transferPaymentBuilder formatMoney:self.amount localCurrency:YES];
        cell.btcLabel.text = [self.transferPaymentBuilder formatMoney:self.amount localCurrency:NO];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        TransferAmountTableCell *cell = [[TransferAmountTableCell alloc] init];
        cell.mainLabel.text = BC_STRING_FEE;
        cell.fiatLabel.text = [self.transferPaymentBuilder formatMoney:self.fee localCurrency:YES];
        cell.btcLabel.text = [self.transferPaymentBuilder formatMoney:self.fee localCurrency:NO];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, CGRectGetWidth(cell.bounds)-15)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        BCAddressSelectionView *selectorView = [[BCAddressSelectionView alloc] initWithWallet:[self.transferPaymentBuilder wallet] selectMode:SelectModeTransferTo delegate:self];
        selectorView.frame = CGRectMake(0, DEFAULT_HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height);
        
        UIViewController *viewController = [UIViewController new];
        viewController.automaticallyAdjustsScrollViewInsets = NO;
        [viewController.view addSubview:selectorView];
    
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)archiveTransferredAddresses
{
    [self.transferPaymentBuilder archiveTransferredAddresses];
}

- (LegacyAssetType)getAssetType
{
    return LegacyAssetTypeBitcoin;
}

- (void)didSelectFromAccount:(int)account assetType:(LegacyAssetType)asset
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.transferPaymentBuilder setupTransfersToAccount:account];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didSelectToAccount:(int)account
{
    DLog(@"Error: Selected To Account!");
}

- (void)didSelectToAddress:(NSString *)address
{
    DLog(@"Error: Selected To Address!");
}

- (void)didSelectFromAddress:(NSString *)address
{
    DLog(@"Error: Selected From Address!");
}

@end
