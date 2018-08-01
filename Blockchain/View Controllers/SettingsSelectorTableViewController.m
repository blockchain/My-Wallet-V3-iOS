//
//  SettingsSelectorTableViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 7/14/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SettingsSelectorTableViewController.h"
#import "Blockchain-Swift.h"

@interface SettingsSelectorTableViewController()
@property (nonatomic, copy) NSArray *keysArray;
@property (nonatomic, copy) NSArray *namesArray;
@property (nonatomic) CurrencySymbol *currentCurrencySymbol;
@property (nonatomic) NSString *selectedCurrencyCode;
@end

@implementation SettingsSelectorTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tintColor = UIColor.brandSecondary;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (CurrencySymbol *)getLocalSymbolFromLatestResponse
{
    return WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SettingsNavigationController *navigationController = (SettingsNavigationController *)self.navigationController;
    navigationController.headerLabel.text = BC_STRING_SETTINGS_LOCAL_CURRENCY;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self changeCurrencySymbol:self.selectedCurrencyCode];
}

- (void)changeCurrencySymbol:(NSString *)code
{
    [WalletManager.sharedInstance.wallet changeLocalCurrency:code];
}

- (void)setItemsDictionary:(NSDictionary *)itemsDictionary
{
    _itemsDictionary = itemsDictionary;
    self.keysArray = [_itemsDictionary allKeys];
    self.namesArray = [[_itemsDictionary allValues] sortedArrayUsingSelector:@selector(compare:)];
    
    self.currentCurrencySymbol = [self getLocalSymbolFromLatestResponse];
    
    self.selectedCurrencyCode = [self getLocalSymbolFromLatestResponse].code;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.keysArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_LOCAL_CURRENCY];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL_IDENTIFIER_LOCAL_CURRENCY];
        cell.textLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:cell.textLabel.font.pointSize];
    }
    
    cell.textLabel.text = self.namesArray[indexPath.row];
    NSString *currencyCode = [[self.itemsDictionary allKeysForObject:cell.textLabel.text] firstObject];
    cell.accessoryType = [currencyCode isEqualToString:self.selectedCurrencyCode] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *currencyCode = [[self.itemsDictionary allKeysForObject:self.namesArray[indexPath.row]] firstObject];
    
    self.selectedCurrencyCode = currencyCode;
    
    [self.tableView reloadData];
}

@end
