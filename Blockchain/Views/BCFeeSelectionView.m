//
//  BCFeeSelectionView.m
//  Blockchain
//
//  Created by kevinwu on 5/8/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCFeeSelectionView.h"
#import "FeeTableCell.h"
#import "Blockchain-Swift.h"

int rowRegular = 0;
int rowPriority = 1;
int rowCustom = 2;

@interface BCFeeSelectionView()
@property (nonatomic) UITableView *tableView;
@end

@implementation BCFeeSelectionView

- (id)initWithFrame:(CGRect)rect
{
    if (self = [super initWithFrame:rect]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.tableView = [[UITableView alloc] initWithFrame:self.frame];
    self.tableView.tableFooterView = [UIView new];
    [self addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"feeOption"];
    if (cell == nil) {
        FeeType feeType = indexPath.row;
        cell = [[FeeTableCell alloc] initWithFeeType:feeType];
        cell.accessoryType = feeType == [self.delegate selectedFeeType] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.tintColor = UIColor.brandSecondary;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IS_USING_SCREEN_SIZE_LARGER_THAN_5S ? 60.0f : 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate didSelectFeeType:indexPath.row];
}

@end
