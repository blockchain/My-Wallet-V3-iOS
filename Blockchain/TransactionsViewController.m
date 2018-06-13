//
//  TransactionsViewController.m
//  Blockchain
//
//  Created by kevinwu on 9/9/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "TransactionsViewController.h"
#import "Assets.h"
#import "BCLine.h"
#import "Transaction.h"
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

@interface TransactionsViewController ()
@property (nonatomic) UILabel *noTransactionsTitle;
@property (nonatomic) UILabel *noTransactionsDescription;
@property (nonatomic) UIButton *getBitcoinButton;
@property (nonatomic) UIView *noTransactionsView;
@property (nonatomic) UIView *filterSelectorView;
@property (nonatomic) UILabel *filterSelectorLabel;
@property (nonatomic) NSString *balance;
@end

@implementation TransactionsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setupFilter
{
    self.filterIndex = FILTER_INDEX_ALL;
    
    self.filterSelectorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.filterSelectorView.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
    
    CGFloat padding = 8;
    CGFloat imageViewWidth = 10;
    self.filterSelectorLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, self.filterSelectorView.bounds.size.width - padding*3 - imageViewWidth, self.filterSelectorView.bounds.size.height)];
    self.filterSelectorLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    self.filterSelectorLabel.textColor = COLOR_TEXT_DARK_GRAY;
    self.filterSelectorLabel.text = BC_STRING_ALL_WALLETS;
    [self.filterSelectorView addSubview:self.filterSelectorLabel];
    
    UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.filterSelectorView.frame.size.width - imageViewWidth - padding, (self.filterSelectorView.frame.size.height - imageViewWidth)/2, imageViewWidth, imageViewWidth + 2)];
    chevronImageView.image = [[UIImage imageNamed:@"chevron_right_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    chevronImageView.tintColor = COLOR_DARK_GRAY;
    [self.filterSelectorView addSubview:chevronImageView];
    
    BCLine *lineAboveButtonsView = [[BCLine alloc] initWithYPosition:self.filterSelectorView.bounds.size.height - 1];
    [self.filterSelectorView addSubview:lineAboveButtonsView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterSelectorViewTapped)];
    [self.filterSelectorView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.filterSelectorView];
}

- (void)setupNoTransactionsViewInView:(UIView *)view assetType:(LegacyAssetType)assetType
{
    [self.noTransactionsView removeFromSuperview];
    
    NSString *descriptionText;
    NSString *buttonText;

    if (assetType == LegacyAssetTypeBitcoin) {
        descriptionText = BC_STRING_NO_TRANSACTIONS_TEXT_BITCOIN;
        buttonText = BC_STRING_GET_BITCOIN;
    } else if (assetType == LegacyAssetTypeEther) {
        descriptionText = BC_STRING_NO_TRANSACTIONS_TEXT_ETHER;
        buttonText = BC_STRING_REQUEST_ETHER;
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        descriptionText = BC_STRING_NO_TRANSACTIONS_TEXT_BITCOIN_CASH;
        buttonText = BC_STRING_REQUEST_BITCOIN_CASH;
    }

    self.noTransactionsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    
    // Title label Y origin will be above midpoint between end of cards view and table view height
    UILabel *noTransactionsTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    noTransactionsTitle.textAlignment = NSTextAlignmentCenter;
    noTransactionsTitle.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    noTransactionsTitle.text = BC_STRING_NO_TRANSACTIONS_TITLE;
    noTransactionsTitle.textColor = COLOR_BLOCKCHAIN_BLUE;
    [noTransactionsTitle sizeToFit];
    CGFloat noTransactionsViewCenterY = (view.frame.size.height - self.noTransactionsView.frame.origin.y)/2 - noTransactionsTitle.frame.size.height;
    noTransactionsTitle.center = CGPointMake(self.noTransactionsView.center.x, noTransactionsViewCenterY);
    [self.noTransactionsView addSubview:noTransactionsTitle];
    self.noTransactionsTitle = noTransactionsTitle;
    
    // Description label Y origin will be 8 points under title label
    UILabel *noTransactionsDescription = [[UILabel alloc] initWithFrame:CGRectZero];
    noTransactionsDescription.textAlignment = NSTextAlignmentCenter;
    noTransactionsDescription.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];
    noTransactionsDescription.numberOfLines = 0;
    noTransactionsDescription.text = descriptionText;
    noTransactionsDescription.textColor = COLOR_TEXT_DARK_GRAY;
    [noTransactionsDescription sizeToFit];
    CGSize labelSize = [noTransactionsDescription sizeThatFits:CGSizeMake(170, CGFLOAT_MAX)];
    CGRect labelFrame = noTransactionsDescription.frame;
    labelFrame.size = labelSize;
    noTransactionsDescription.frame = labelFrame;
    [self.noTransactionsView addSubview:noTransactionsDescription];
    noTransactionsDescription.center = CGPointMake(self.noTransactionsView.center.x, noTransactionsDescription.center.y);
    noTransactionsDescription.frame = CGRectMake(noTransactionsDescription.frame.origin.x, noTransactionsTitle.frame.origin.y + noTransactionsTitle.frame.size.height + 8, noTransactionsDescription.frame.size.width, noTransactionsDescription.frame.size.height);
    self.noTransactionsDescription = noTransactionsDescription;
    
    // Get bitcoin button Y origin will be 16 points under description label
    self.getBitcoinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, noTransactionsDescription.frame.origin.y + noTransactionsDescription.frame.size.height + 16, 240, 44)];
    self.getBitcoinButton.clipsToBounds = YES;
    self.getBitcoinButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    self.getBitcoinButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    self.getBitcoinButton.center = CGPointMake(self.noTransactionsView.center.x, self.getBitcoinButton.center.y);
    self.getBitcoinButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    [self.getBitcoinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getBitcoinButton setTitle:[buttonText uppercaseString] forState:UIControlStateNormal];
    [self.getBitcoinButton addTarget:self action:@selector(getAssetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.noTransactionsView addSubview:self.getBitcoinButton];
    
    [self centerNoTransactionSubviews];
    
    [view addSubview:self.noTransactionsView];
}

- (void)getAssetButtonClicked
{
    DLog(@"Warning! getAssetButtonClicked not overriden!");
}

- (void)centerNoTransactionSubviews
{
    // Reposition description label Y to center of screen, and reposition title and button Y origins around it
    self.noTransactionsDescription.center = CGPointMake(self.noTransactionsTitle.center.x, self.noTransactionsView.frame.size.height/2);
    self.noTransactionsTitle.center = CGPointMake(self.noTransactionsTitle.center.x, self.noTransactionsDescription.frame.origin.y - self.noTransactionsTitle.frame.size.height - 8 + self.noTransactionsTitle.frame.size.height/2);
    self.getBitcoinButton.center = CGPointMake(self.getBitcoinButton.center.x, self.noTransactionsDescription.frame.origin.y + self.noTransactionsDescription.frame.size.height + 16 + self.noTransactionsDescription.frame.size.height/2);
    self.getBitcoinButton.hidden = NO;
}

- (void)filterSelectorViewTapped
{
    // Overridden by subclass
}

- (void)changeFilterLabel:(NSString *)newText
{
    // Overridden by subclass
}

- (uint64_t)getAmountForReceivedTransaction:(Transaction *)transaction
{
    DLog(@"TransactionsViewController: getting amount for received transaction");
    return ABS(transaction.amount);
}

- (void)setBalance:(NSString *)balance
{
    _balance = balance;
    
    [self updateBalanceLabel];
}

- (void)updateBalanceLabel
{
    TabViewController *tabViewController = [AppCoordinator sharedInstance].tabControllerManager.tabViewController;
    if (tabViewController.activeViewController == self) {
        [tabViewController updateBalanceLabelText:self.balance];
    }
}

@end
