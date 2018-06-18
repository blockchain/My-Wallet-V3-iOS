//
//  StateSelectorViewController.m
//  Blockchain
//
//  Created by kevinwu on 12/5/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "StateSelectorViewController.h"
#import "BCNavigationController.h"
#import "Blockchain-Swift.h"
#import "UIView+ChangeFrameAttribute.h"

@interface StateSelectorViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *states;
@property (nonatomic) NSArray *statesToDisplay;
@property (nonatomic) NSArray *sections;
@end

@implementation StateSelectorViewController

- (id)initWithStates:(NSArray *)states
{
    if (self == [super init]) {
        self.states = states;
        self.statesToDisplay = states;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sections = [NSArray arrayWithObjects:@"",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",
                     @"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    navigationController.headerTitle = BC_STRING_SELECT_STATE;
}

- (void)setupTableView
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = BC_STRING_SEARCH;
    searchBar.layer.borderColor = [COLOR_BLOCKCHAIN_BLUE CGColor];
    searchBar.layer.borderWidth = 1;
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    searchBar.translucent = NO;
    searchBar.backgroundImage = [UIImage new];
    searchBar.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    searchBar.barTintColor = COLOR_BLOCKCHAIN_BLUE;
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
     setTitle:BC_STRING_CANCEL forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInsetTop;
    CGFloat safeAreaInsetBottom;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
        safeAreaInsetBottom = window.rootViewController.view.safeAreaInsets.bottom;
    } else {
        safeAreaInsetTop = 20;
        safeAreaInsetBottom = 0;
    }
    CGFloat topBarHeight = ConstantsObjcBridge.defaultNavigationBarHeight + safeAreaInsetTop;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, searchBar.frame.origin.y + searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - topBarHeight - searchBar.frame.size.height) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexColor = COLOR_BLOCKCHAIN_BLUE;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self statesForSection:section].count;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 22.0)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [self.sections objectAtIndex:section];
    [label sizeToFit];
    [label changeXPosition:20];
    label.center = CGPointMake(label.center.x, view.center.y);
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 22.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        
        NSArray *states = [self statesForSection:indexPath.section];
        NSDictionary *state = states[indexPath.row];
        
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = [state objectForKey:STATE_KEY_NAME];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *states = [self statesForSection:indexPath.section];
    NSDictionary *state = states[indexPath.row];
    
    [self.delegate didSelectState:state];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Helpers

- (NSArray *)statesForSection:(NSInteger)section
{
    NSArray *states = self.statesToDisplay;
    NSArray *sectionArray = [states filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.Name beginswith[c] %@", [self.sections objectAtIndex:section]]];
    
    return sectionArray;
}

#pragma mark - Search Bar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText && searchText.length > 0) {
        self.statesToDisplay = [self.states filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.Name beginswith[c] %@", searchText]];
    } else {
        self.statesToDisplay = self.states;
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

@end
