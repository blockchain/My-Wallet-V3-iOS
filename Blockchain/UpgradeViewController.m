//
//  UpgradeViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 7/1/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "UpgradeViewController.h"
#import "LocalizationConstants.h"
#import "UILabel+MultiLineAutoSize.h"
#import "Blockchain-Swift.h"

@interface UpgradeViewController () <WalletUpgradeDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIButton *upgradeWalletButton;
@property (weak, nonatomic) IBOutlet UIButton *askMeLaterButton;

@property (nonatomic) NSMutableArray *pageViewsMutableArray;
@property (nonatomic) NSArray *captionLabelAttributedStringsArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upgradeButtonToPageControlConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *askLaterButtonToBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewToPageControlConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionLabelToTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewToCaptionLabelConstraint;

@end

@implementation UpgradeViewController

- (IBAction)upgradeTapped:(UIButton *)sender
{
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    [LoadingViewPresenter.sharedInstance showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_V3_WALLET];

    [WalletManager.sharedInstance.wallet upgradeToV3Wallet];
}

- (NSArray *)imageNamesArray
{
    return @[@"ImageUpgradeFeature1", @"ImageUpgradeFeature2", @"ImageUpgradeFeature3"];
}

- (NSArray *)captionLabelStringsArray
{
    return @[[LocalizationConstantsObjcBridge upgradeFeatureOne], [LocalizationConstantsObjcBridge upgradeFeatureTwo], [LocalizationConstantsObjcBridge upgradeFeatureThree]];
}

- (NSAttributedString *)createBlueAttributedStringWithWideLineSpacingFromString:(NSString *)string
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3;
    style.alignment = NSTextAlignmentCenter;
    
    UIFont *font = [UIFont fontWithName:FONT_HELVETICA_NUEUE size:FONT_SIZE_MEDIUM];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjects:@[COLOR_BLOCKCHAIN_BLUE, style, font] forKeys:@[NSForegroundColorAttributeName, NSParagraphStyleAttributeName, NSFontAttributeName]];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributesDictionary];
    return attributedString;
}

- (void)loadPage:(NSInteger)page
{
    if (page < 0 || page >= [self imageNamesArray].count) {
        return;
    }
    
    UIView *pageView = [self.pageViewsMutableArray objectAtIndex:page];
    
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        UIImage *image = [UIImage imageNamed:[[self imageNamesArray] objectAtIndex:page]];
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:image];

        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        [self.scrollView addSubview:newPageView];
        [self.pageViewsMutableArray replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    
    if (page < 0 || page >= [self imageNamesArray].count) {
        return;
    }
    
    UIView *pageView = [self.pageViewsMutableArray objectAtIndex:page];
    
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViewsMutableArray replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadVisiblePages
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    self.pageControl.currentPage = page;
    
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    for (NSInteger i = 0; i < firstPage; i++) {
        [self purgePage:i];
    }
    
    for (NSInteger i = firstPage; i <= lastPage; i++) {
        [self loadPage:i];
    }
    
    for (NSInteger i = lastPage+1; i < [self pageViewsMutableArray].count; i++) {
        [self purgePage:i];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_BLOCKCHAIN_UPGRADE_BLUE;
    
    [self setupCaptionLabels];
    
    [self.upgradeWalletButton setTitle:BC_STRING_CONTINUE forState:UIControlStateNormal];
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [[self imageNamesArray] count];
    
    self.pageViewsMutableArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [[self imageNamesArray] count]; i++) {
        [self.pageViewsMutableArray addObject:[NSNull null]];
    }
    
    [self setTextForCaptionLabel];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

    WalletManager.sharedInstance.upgradeWalletDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if (!(IS_USING_SCREEN_SIZE_4S))
        {
            // Not iphone 4s
            self.upgradeButtonToPageControlConstraint.constant = 35;
            self.askLaterButtonToBottomConstraint.constant = 15;
            self.scrollViewToPageControlConstraint.constant = 8;
            self.captionLabelToTopConstraint.constant = 12;
            self.scrollViewToCaptionLabelConstraint.constant = 16;
            [self.view layoutIfNeeded];
        }
    }
    
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * [self pageViewsMutableArray].count, pagesScrollViewSize.height);
    self.upgradeWalletButton.clipsToBounds = YES;
    self.upgradeWalletButton.layer.cornerRadius = 20;
    
    [self loadVisiblePages];
}

- (void)setupCaptionLabels
{
    NSMutableArray *temporaryMutableArray = [[NSMutableArray alloc] init];
    
    for (NSString *captionString in [self captionLabelStringsArray]) {
        [temporaryMutableArray addObject:[self createBlueAttributedStringWithWideLineSpacingFromString:captionString]];
    }
    
    self.captionLabelAttributedStringsArray = [[NSArray alloc] initWithArray:temporaryMutableArray];
}

- (void)setTextForCaptionLabel
{
    [UIView transitionWithView:self.captionLabel duration:0.25f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.captionLabel.attributedText = self.captionLabelAttributedStringsArray[self.pageControl.currentPage];
    } completion:nil];
    
    [self.captionLabel adjustFontSizeToFit];
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self loadVisiblePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setTextForCaptionLabel];
}

#pragma mark - WalletUpgradeDelegate

- (void)onWalletUpgraded
{
    __weak UpgradeViewController *weakSelf = self;
    [AlertViewPresenter.sharedInstance standardErrorWithMessage:LocalizationConstantsObjcBridge.upgradeSuccess
                                                          title:LocalizationConstantsObjcBridge.upgradeSuccessTitle
                                                             in:self
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                        }];
}

@end
