//
//  ExchangeProgressViewController.m
//  Blockchain
//
//  Created by Maurice A. on 11/20/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeProgressViewController.h"
#import "ExchangeDetailView.h"
#import "UIView+ChangeFrameAttribute.h"

@interface ExchangeProgressViewController () <ExchangeDetailViewDelegate>

@end

@implementation ExchangeProgressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;

    CGFloat windowWidth = self.view.frame.size.width;

    ExchangeDetailView *detailView = [[ExchangeDetailView alloc] initWithFrame:CGRectMake(0, 0, windowWidth, 0) fetchedTrade:self.trade];
    detailView.delegate = self;

    BOOL isUsingLargerScreen = IS_USING_SCREEN_SIZE_LARGER_THAN_5S;
    UIView *summaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowWidth, isUsingLargerScreen ? 220 : self.view.frame.size.height - detailView.frame.size.height - 24)];
    summaryView.backgroundColor = [UIColor whiteColor];

    UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, windowWidth - 16, 0)];
    descriptionTextView.font = [self descriptionFontForTrade:self.trade];
    descriptionTextView.textColor = [self descriptionTextColorForTrade:self.trade];
    descriptionTextView.text = [self descriptionStringForTrade:self.trade];
    descriptionTextView.textAlignment = NSTextAlignmentCenter;
    descriptionTextView.backgroundColor = [UIColor clearColor];
    descriptionTextView.editable = NO;
    descriptionTextView.selectable = NO;
    descriptionTextView.scrollEnabled = NO;
    [descriptionTextView sizeToFit];
    [descriptionTextView changeYPosition:summaryView.frame.size.height - descriptionTextView.frame.size.height - 8];
    descriptionTextView.center = CGPointMake(summaryView.frame.size.width/2, descriptionTextView.center.y);
    [summaryView addSubview:descriptionTextView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.text = [self titleStringForTrade:self.trade];
    titleLabel.textColor = [self titleTextColorForTrade:self.trade];
    titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_SMALL];
    [titleLabel sizeToFit];
    [titleLabel changeYPosition:descriptionTextView.frame.origin.y - titleLabel.frame.size.height];
    titleLabel.center = CGPointMake(summaryView.frame.size.width/2, titleLabel.center.y);
    [summaryView addSubview:titleLabel];
    
    CGFloat imageViewHeight = titleLabel.frame.origin.y - 32;
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 16, imageViewHeight, imageViewHeight)];
    iconImageView.center = CGPointMake(summaryView.frame.size.width/2, iconImageView.center.y);
    iconImageView.image = [self imageForTrade:self.trade];
    
    [summaryView addSubview:iconImageView];
    
    [self.view addSubview:summaryView];
    
    [detailView changeYPosition:summaryView.frame.origin.y + summaryView.frame.size.height + 16];
    
    [self.view addSubview:detailView];
}

- (UIColor *)titleTextColorForTrade:(ExchangeTrade *)trade
{
    return COLOR_TEXT_DARK_GRAY;
}

- (UIFont *)descriptionFontForTrade:(ExchangeTrade *)trade
{
    if ([trade.status isEqualToString:TRADE_STATUS_COMPLETE]) {
        return [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_SMALL];
    } else if ([trade.status isEqualToString:TRADE_STATUS_RECEIVED] || [trade.status isEqualToString:TRADE_STATUS_NO_DEPOSITS]) {
        return [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_SMALL];
    } else {
        return [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
    }
}

- (UIColor *)descriptionTextColorForTrade:(ExchangeTrade *)trade
{
    if ([trade.status isEqualToString:TRADE_STATUS_COMPLETE]) {
        return COLOR_LIGHT_GRAY;
    } else if ([trade.status isEqualToString:TRADE_STATUS_RECEIVED] || [trade.status isEqualToString:TRADE_STATUS_NO_DEPOSITS]) {
        return COLOR_LIGHT_GRAY;
    } else if ([trade.status isEqualToString:TRADE_STATUS_RESOLVED] || [trade.status isEqualToString:TRADE_STATUS_FAILED]) {
        return COLOR_TEXT_DARK_GRAY;
    }
    
    return COLOR_TEXT_DARK_GRAY;
}

- (UIImage *)imageForTrade:(ExchangeTrade *)trade
{
    if ([trade.status isEqualToString:TRADE_STATUS_COMPLETE]) {
        return [UIImage imageNamed:@"exchange_complete"];
    } else if ([trade.status isEqualToString:TRADE_STATUS_RECEIVED] || [trade.status isEqualToString:TRADE_STATUS_NO_DEPOSITS]) {
        return [UIImage imageNamed:@"exchange_in_progress"];
    } else if ([trade.status isEqualToString:TRADE_STATUS_RESOLVED] || [trade.status isEqualToString:TRADE_STATUS_FAILED]) {
        return [UIImage imageNamed:@"exchange_error"];
    }
    
    return nil;
}

- (NSString *)descriptionStringForTrade:(ExchangeTrade *)trade
{
    if ([trade.status isEqualToString:TRADE_STATUS_COMPLETE]) {
        return [NSString stringWithFormat:BC_STRING_STEP_ARGUMENT_OF_ARGUMENT, 3, 3];
    } else if ([trade.status isEqualToString:TRADE_STATUS_RECEIVED] || [trade.status isEqualToString:TRADE_STATUS_NO_DEPOSITS]) {
        return [NSString stringWithFormat:BC_STRING_STEP_ARGUMENT_OF_ARGUMENT, 2, 3];
    } else if ([trade.status isEqualToString:TRADE_STATUS_RESOLVED] || [trade.status isEqualToString:TRADE_STATUS_FAILED]) {
        return BC_STRING_EXCHANGE_DESCRIPTION_FAILED;
    }
    
    return nil;
}

- (NSString *)titleStringForTrade:(ExchangeTrade *)trade
{
    if ([trade.status isEqualToString:TRADE_STATUS_COMPLETE]) {
        return BC_STRING_EXCHANGE_COMPLETED;
    } else if ([trade.status isEqualToString:TRADE_STATUS_RECEIVED] || [trade.status isEqualToString:TRADE_STATUS_NO_DEPOSITS]) {
        return BC_STRING_EXCHANGE_IN_PROGRESS;
    } else if ([trade.status isEqualToString:TRADE_STATUS_RESOLVED] || [trade.status isEqualToString:TRADE_STATUS_FAILED]) {
        return BC_STRING_EXCHANGE_TITLE_REFUNDED;
    }
    
    return nil;
}

#pragma mark - Exchange Detail View Delegate

- (void)orderIDTapped:(NSString *)orderID
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:orderID message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:BC_STRING_COPY_TO_CLIPBOARD style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = orderID;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
