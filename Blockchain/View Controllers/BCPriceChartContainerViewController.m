//
//  BCPriceChartContainerViewController.m
//  Blockchain
//
//  Created by kevinwu on 2/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCPriceChartContainerViewController.h"
#import "UIView+ChangeFrameAttribute.h"

#define DICTIONARY_KEY_BITCOIN @"bitcoin"
#define DICTIONARY_KEY_ETHER @"ether"
#define DICTIONARY_KEY_BITCOIN_CASH @"bitcoinCash"

@class ChartAxisBase;
@interface BCPriceChartContainerViewController () <UIScrollViewDelegate>
@property (nonatomic) BCPriceChartView *priceChartView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableDictionary *addedCharts;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) BOOL isUsingPageControl;
@property (nonatomic) CGFloat closeButtonOriginX;
@property (nonatomic) UIButton *scrollViewCloseButton;
@end

@implementation BCPriceChartContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:BUSY_VIEW_LABEL_ALPHA];
    
    self.addedCharts = [NSMutableDictionary new];
}

- (void)closeButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPriceChartView:(BCPriceChartView *)priceChartView atIndex:(NSInteger)pageIndex
{
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.scrollView.center = CGPointMake(self.scrollView.center.x, self.view.frame.size.height/2);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width*3, priceChartView.frame.size.height);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.isUsingPageControl = YES;
        [self.scrollView setContentOffset:CGPointMake(pageIndex * self.scrollView.frame.size.width, 0) animated:NO];
        self.isUsingPageControl = NO;
        [self.view addSubview:self.scrollView];
        
        priceChartView.center = CGPointMake(pageIndex * self.scrollView.frame.size.width + self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
        
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, priceChartView.frame.origin.y + priceChartView.frame.size.height + 16, 100, 30)];
        pageControl.numberOfPages = 3;
        [pageControl setCurrentPage:pageIndex];
        [pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
        pageControl.center = CGPointMake(self.view.frame.size.width/2, pageControl.center.y);
        self.pageControl = pageControl;
        [self.view addSubview:pageControl];
        
        CGFloat buttonWidth = 50;
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(pageIndex*self.view.frame.size.width + self.view.frame.size.width - 8 - buttonWidth, 30, buttonWidth, buttonWidth)];
        self.closeButtonOriginX = self.view.frame.size.width - 8 - buttonWidth;
        [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.scrollViewCloseButton = closeButton;
        [self.scrollView addSubview:closeButton];
    }

    priceChartView.center = CGPointMake(pageIndex * self.scrollView.frame.size.width + self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
    self.priceChartView = priceChartView;
    [self.scrollView addSubview:priceChartView];
    
    [self.addedCharts setObject:priceChartView forKey:[self dictionaryKeyForPage:pageIndex]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isUsingPageControl) {
        CGFloat pageWidth = scrollView.frame.size.width;
        float fractionalPage = scrollView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        if (self.pageControl.currentPage != page) {
            self.pageControl.currentPage = page;
            [self pageControlChanged:self.pageControl];
        }
    }

    [self.scrollViewCloseButton changeXPosition:scrollView.contentOffset.x + self.closeButtonOriginX];
}

- (void)pageControlChanged:(UIPageControl *)pageControl
{
    self.isUsingPageControl = YES;
    [self.scrollView setContentOffset:CGPointMake(pageControl.currentPage * self.scrollView.frame.size.width, 0) animated:YES];
    
    BCPriceChartView *priceChartView = [self.addedCharts objectForKey:[self dictionaryKeyForPage:pageControl.currentPage]];
    if (!priceChartView) {
        [self.delegate addPriceChartView:pageControl.currentPage];
    } else {
        self.priceChartView = priceChartView;
        [self.delegate reloadPriceChartView:pageControl.currentPage];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isUsingPageControl = NO;
}

- (void)clearChart
{
    [self.priceChartView clear];
}

- (void)updateChartWithValues:(NSArray *)values
{
    [self.priceChartView updateWithValues:values];
}

- (ChartAxisBase *)leftAxis
{
    return [self.priceChartView leftAxis];
}

- (ChartAxisBase *)xAxis
{
    return [self.priceChartView xAxis];
}

- (void)updateTitleContainer
{
    [self.priceChartView updateTitleContainer];
}

- (void)updateTitleContainerWithChartDataEntry:(ChartDataEntry *)entry
{
    [self.priceChartView updateTitleContainerWithChartDataEntry:entry];
}

- (void)updateEthExchangeRate:(NSDecimalNumber *)rate
{
    [self.priceChartView updateEthExchangeRate:rate];
}

- (NSString *)dictionaryKeyForPage:(NSInteger)pageIndex
{
    switch (pageIndex) {
        case LegacyAssetTypeBitcoin: return DICTIONARY_KEY_BITCOIN;
        case LegacyAssetTypeEther: return DICTIONARY_KEY_ETHER;
        case LegacyAssetTypeBitcoinCash: return DICTIONARY_KEY_BITCOIN_CASH;
        default: return nil;
    }
}

@end
