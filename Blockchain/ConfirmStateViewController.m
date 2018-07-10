//
//  ConfirmStateViewController.m
//  Blockchain
//
//  Created by kevinwu on 12/5/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ConfirmStateViewController.h"
#import "StateSelectorViewController.h"
#import "BCNavigationController.h"
#import "Blockchain-Swift.h"

@interface ConfirmStateViewController () <UITableViewDelegate, UITableViewDataSource, StateSelectorDelegate>
@property (nonatomic) NSArray *states;
@property (nonatomic) NSDictionary *selectedState;
@property (nonatomic) UITableView *tableView;
@end

@implementation ConfirmStateViewController

- (id)initWithStates:(NSArray *)states
{
    if (self == [super init]) {
        self.states = states;
        self.selectedState = [self.states firstObject];
    }
    
    return self;
}

- (void)viewDidLoad
{
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInsetTop;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
    } else {
        safeAreaInsetTop = 20;
    }
    CGFloat topBarHeight = ConstantsObjcBridge.defaultNavigationBarHeight + safeAreaInsetTop;

    UITableView *oneRowTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - topBarHeight) style:UITableViewStyleGrouped];
    oneRowTableView.dataSource = self;
    oneRowTableView.delegate = self;
    [self.view addSubview:oneRowTableView];
    self.tableView = oneRowTableView;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 32, BUTTON_HEIGHT)];
    button.backgroundColor = UIColor.brandSecondary;
    button.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    [button setTitle:BC_STRING_CONFIRM forState:UIControlStateNormal];
    button.center = CGPointMake(self.view.center.x, self.view.frame.size.height - topBarHeight - 24 - BUTTON_HEIGHT/2);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(confirmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    navigationController.headerTitle = BC_STRING_EXCHANGE;
}

#pragma mark - Actions

- (void)confirmButtonClicked
{
    NSString *stateCode = self.selectedState[STATE_KEY_CODE];
    if ([WalletManager.sharedInstance.wallet isStateWhitelistedForShapeshift:stateCode]) {
        [WalletManager.sharedInstance.wallet selectState:self.selectedState[STATE_KEY_NAME] code:stateCode];
        [self.delegate didConfirmState:self.navigationController];
    } else {
        UIAlertController *alertNotAvailable = [UIAlertController alertControllerWithTitle:BC_STRING_EXCHANGE_NOT_AVAILABLE_TITLE message:BC_STRING_EXCHANGE_NOT_AVAILABLE_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
        [alertNotAvailable addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
        [self.navigationController presentViewController:alertNotAvailable animated:YES completion:nil];
    }
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    cell.textLabel.text = self.selectedState[STATE_KEY_NAME];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat windowWidth = self.view.frame.size.width;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowWidth, 50)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, windowWidth, 30)];
    headerLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];;
    headerLabel.text = BC_STRING_SELECT_YOUR_STATE;
    [containerView addSubview:headerLabel];
    
    return containerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StateSelectorViewController *stateSelectorController = [[StateSelectorViewController alloc] initWithStates:self.states];
    stateSelectorController.delegate = self;
    [self.navigationController pushViewController:stateSelectorController animated:YES];
}

#pragma mark - State selector delegate

- (void)didSelectState:(NSDictionary *)state
{
    self.selectedState = state;
    [self.tableView reloadData];
}

@end
