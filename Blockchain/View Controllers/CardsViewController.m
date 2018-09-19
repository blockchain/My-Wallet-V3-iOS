//
//  DashboardViewController.m
//  Blockchain
//
//  Created by kevinwu on 8/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "CardsViewController.h"
#import "BCCardView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"
#import "NSNumberFormatter+Currencies.h"

#define ANNOUNCEMENT_CARD_HEIGHT 208

// TICKET: IOS-1249 - Refactor CardsViewController

@interface CardsViewController () <CardViewDelegate, UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *contentView;

// Onboarding cards
@property (nonatomic) BOOL showWelcomeCards;
@property (nonatomic) NSMutableArray *announcementCards;
@property (nonatomic) CGFloat cardsViewHeight;
@property (nonatomic) UIScrollView *cardsScrollView;
@property (nonatomic) CardsView *cardsView;
@property (nonatomic) BOOL isUsingPageControl;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIButton *startOverButton;
@property (nonatomic) UIButton *closeCardsViewButton;
@property (nonatomic) UIButton *skipAllButton;
@end

@implementation CardsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat safeAreaInsetTop = 20;
    CGFloat safeAreaInsetBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = window.rootViewController.view.safeAreaInsets.top;
        safeAreaInsetBottom = window.rootViewController.view.safeAreaInsets.bottom;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // TODO: store tab bar and navigation bar height as constants
    self.view.frame = CGRectMake(0,
                                 0,
                                 window.bounds.size.width,
                                 window.bounds.size.height - safeAreaInsetTop - safeAreaInsetBottom - 49 - 44);
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
}

- (void)reloadCards
{
    /**
      Temporary code to show KYC announcement card
      - SeeAlso: IOS-1249 - Refactor CardsViewController
     */

    BOOL shouldShowKYCAnnouncementCard = BlockchainSettings.sharedAppInstance.shouldShowKYCAnnouncementCard;
    self.cardsViewHeight = 0;

    if (shouldShowKYCAnnouncementCard) {
        TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
        AnnouncementCardViewModel *model = [[AnnouncementCardViewModel alloc]
                                            initWithTitle:[[LocalizationConstantsObjcBridge continueKYCCardTitle] uppercaseString]
                                            message:[LocalizationConstantsObjcBridge continueKYCCardDescription]
                                            actionButtonTitle:[LocalizationConstantsObjcBridge continueKYCActionButtonTitle]
                                            image:[UIImage imageNamed:@"identity_verification_card"]
                                            action:^{
                                                [[KYCCoordinator sharedInstance] startFrom:tabControllerManager];
                                            }
                                            onClose:^{
                                                BlockchainSettings.sharedAppInstance.shouldShowKYCAnnouncementCard = NO;
                                                [UIView animateWithDuration:.4f animations:^{
                                                    [self.cardsView changeYPosition:-self.cardsView.frame.size.height];
                                                    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.contentView.frame.size.height);
                                                    [self.contentView changeYPosition:0];
                                                } completion:^(BOOL finished) {
                                                    [self removeCardsView];
                                                }];
                                            }];
        AnnouncementCardView *card = [AnnouncementCardView createWithModel:model];
        self.cardsViewHeight = card.frame.size.height;
        self.cardsView = [self prepareCardsView];
        [self.cardsView addSubview:card];
        [self.scrollView addSubview:self.cardsView];
        [self.contentView changeYPosition:self.cardsViewHeight];
    } else {
        self.announcementCards = [NSMutableArray new];
        self.showWelcomeCards = !BlockchainSettings.sharedOnboardingInstance.hasSeenAllCards;

        if (!self.showWelcomeCards) {
            if (!BlockchainSettings.sharedOnboardingInstance.shouldHideBuySellCard && [WalletManager.sharedInstance.wallet canUseSfox]) {
                [self.announcementCards addObject:[NSNumber numberWithInteger:CardConfigurationBuySell]];
            }
        }

        if (!self.showWelcomeCards && self.announcementCards.count == 0) {
            self.cardsViewHeight = 0;
        } else if (self.announcementCards.count > 0) {
            self.cardsViewHeight = ANNOUNCEMENT_CARD_HEIGHT * self.announcementCards.count;
        } else {
            self.cardsViewHeight = 240;
        }

        if (self.showWelcomeCards && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local) {
            [self setupWelcomeCardsView];
        } else if (self.announcementCards.count > 0) {
            [self setupCardsViewWithConfigurations:self.announcementCards];
        } else if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local) {
            [self removeCardsView];
        }
    }

    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.contentView.frame.size.height + self.cardsViewHeight;
    self.scrollView.contentSize = CGSizeMake(width, height);
}

- (CardsView *)prepareCardsView
{
    [self.cardsView removeFromSuperview];
    CardsView *view = [[CardsView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.cardsViewHeight)];
    return view;
}

- (void)setupWelcomeCardsView
{
    CardsView *cardsView = [self prepareCardsView];
    
    self.cardsView = [self configureCardsViewWelcome:cardsView];
    
    [self.scrollView addSubview:self.cardsView];
    
    [self.contentView changeYPosition:self.cardsViewHeight];
}

- (void)setupCardsViewWithConfigurations:(NSArray *)configurations
{
    CardsView *cardsView = [self prepareCardsView];

    for (int index = 0; index < configurations.count; index++) {
        CGRect cardFrame = CGRectMake(0, 0, self.scrollView.frame.size.width, ANNOUNCEMENT_CARD_HEIGHT);
        NSInteger configuration = [configurations[index] integerValue];
        NSString *title, *description, *imageName;
        ActionType actionType;
        Boolean reducedHeight = false;
        CGFloat verticalPadding = 8;

        switch (configuration) {
            case CardConfigurationBuySell:
                title = [[LocalizationConstantsObjcBridge buySellCardTitle] uppercaseString];
                description = [LocalizationConstantsObjcBridge buySellCardDescription];
                actionType = ActionTypeBuySell;
                imageName = @"buy_sell_partial";
                break;
            default: return;
        }

        BCCardView *card = [[BCCardView alloc]
                            initWithContainerFrame:cardFrame
                            title:title
                            description:description
                            actionType:actionType
                            imageName:imageName
                            reducedHeightForPageIndicator:reducedHeight delegate:self];
        [card setupCloseButton];
        [card.closeButton addTarget:self action:@selector(closeBuySellCard) forControlEvents:UIControlEventTouchUpInside];
        [card changeYPosition:ANNOUNCEMENT_CARD_HEIGHT * index + verticalPadding];
        [cardsView addSubview:card];
    }
    
    self.cardsView = cardsView;
    
    [self.scrollView addSubview:self.cardsView];
    
    [self.contentView changeYPosition:ANNOUNCEMENT_CARD_HEIGHT * configurations.count];
}

#pragma mark - New Wallet Cards

- (CardsView *)configureCardsViewWelcome:(CardsView *)cardsView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:cardsView.bounds];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    
    NSInteger numberOfPages = 1;
    NSInteger numberOfCards = 0;
    
    // Cards setup
    if ([WalletManager.sharedInstance.wallet isBuyEnabled]) {
        
        NSString *tickerText = [NSString stringWithFormat:@"%@ = %@", [NSNumberFormatter formatBTC:[CURRENCY_CONVERSION_BTC longLongValue]], [NSNumberFormatter formatMoney:SATOSHI localCurrency:YES]];
        
        BCCardView *priceCard = [[BCCardView alloc] initWithContainerFrame:cardsView.bounds title:[NSString stringWithFormat:@"%@\n%@", BC_STRING_OVERVIEW_MARKET_PRICE_TITLE, tickerText] description:BC_STRING_OVERVIEW_MARKET_PRICE_DESCRIPTION actionType:ActionTypeBuyBitcoin imageName:@"btc_partial" reducedHeightForPageIndicator:YES delegate:self];
        [scrollView addSubview:priceCard];
        numberOfCards++;
        numberOfPages++;
    }
    
    BCCardView *receiveCard = [[BCCardView alloc] initWithContainerFrame:cardsView.bounds title:BC_STRING_OVERVIEW_REQUEST_FUNDS_TITLE description:BC_STRING_OVERVIEW_REQUEST_FUNDS_DESCRIPTION actionType:ActionTypeShowReceive imageName:@"receive_partial" reducedHeightForPageIndicator:YES delegate:self];
    receiveCard.frame = CGRectOffset(receiveCard.frame, [self getPageXPosition:cardsView.frame.size.width page:numberOfCards], 0);
    [scrollView addSubview:receiveCard];
    numberOfCards++;
    numberOfPages++;
    
    BCCardView *QRCard = [[BCCardView alloc] initWithContainerFrame:cardsView.bounds title:BC_STRING_OVERVIEW_QR_CODES_TITLE description:BC_STRING_OVERVIEW_QR_CODES_DESCRIPTION actionType:ActionTypeScanQR imageName:@"qr_partial" reducedHeightForPageIndicator:YES delegate:self];
    QRCard.frame = CGRectOffset(QRCard.frame, [self getPageXPosition:cardsView.frame.size.width page:numberOfCards], 0);
    [scrollView addSubview:QRCard];
    numberOfCards++;
    numberOfPages++;
    
    // Overview complete/last page setup
    CGFloat overviewCompleteCenterX = cardsView.frame.size.width/2 + [self getPageXPosition:cardsView.frame.size.width page:numberOfCards];
    
    UIImageView *checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 40, 40)];
    checkImageView.image = [[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    checkImageView.tintColor = UIColor.brandSecondary;
    checkImageView.center = CGPointMake(overviewCompleteCenterX, checkImageView.center.y);
    [scrollView addSubview:checkImageView];
    
    UILabel *doneTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, checkImageView.frame.origin.y + checkImageView.frame.size.height + 14, 150, 30)];
    doneTitleLabel.textAlignment = NSTextAlignmentCenter;
    doneTitleLabel.textColor = UIColor.brandPrimary;
    doneTitleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM_LARGE];
    doneTitleLabel.adjustsFontSizeToFitWidth = YES;
    doneTitleLabel.text = BC_STRING_OVERVIEW_COMPLETE_TITLE;
    doneTitleLabel.center = CGPointMake(overviewCompleteCenterX, doneTitleLabel.center.y);
    [scrollView addSubview:doneTitleLabel];
    
    UILabel *doneDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    doneDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    doneDescriptionLabel.numberOfLines = 0;
    doneDescriptionLabel.textColor = UIColor.gray5;
    doneDescriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];
    doneDescriptionLabel.adjustsFontSizeToFitWidth = YES;
    doneDescriptionLabel.text = BC_STRING_OVERVIEW_COMPLETE_DESCRIPTION;
    [doneDescriptionLabel sizeToFit];
    CGFloat maxDoneDescriptionLabelWidth = 170;
    CGFloat maxDoneDescriptionLabelHeight = 70;
    CGSize labelSize = [doneDescriptionLabel sizeThatFits:CGSizeMake(maxDoneDescriptionLabelWidth, maxDoneDescriptionLabelHeight)];
    CGRect labelFrame = doneDescriptionLabel.frame;
    labelFrame.size = labelSize;
    doneDescriptionLabel.frame = labelFrame;
    doneDescriptionLabel.frame = CGRectMake(0, doneTitleLabel.frame.origin.y + doneTitleLabel.frame.size.height, doneDescriptionLabel.frame.size.width, doneDescriptionLabel.frame.size.height);
    doneDescriptionLabel.center = CGPointMake(overviewCompleteCenterX, doneDescriptionLabel.center.y);
    [scrollView addSubview:doneDescriptionLabel];
    
    scrollView.contentSize = CGSizeMake(cardsView.frame.size.width * (numberOfPages), cardsView.frame.size.height);
    [cardsView addSubview:scrollView];
    self.cardsScrollView = scrollView;
    
    // Subviews that disappear/reappear setup
    CGRect cardRect = [receiveCard frameFromContainer:cardsView.bounds];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, cardRect.origin.y + cardRect.size.height + 8, 100, 30)];
    self.pageControl.center = CGPointMake(cardsView.center.x, self.pageControl.center.y);
    self.pageControl.numberOfPages = numberOfCards;
    self.pageControl.currentPageIndicatorTintColor = UIColor.brandPrimary;
    self.pageControl.pageIndicatorTintColor = UIColor.brandTertiary;
    [self.pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    [cardsView addSubview:self.pageControl];
    
    self.startOverButton = [[UIButton alloc] initWithFrame:CGRectInset(self.pageControl.frame, -40, -10)];
    [cardsView addSubview:self.startOverButton];
    [self.startOverButton setTitle:BC_STRING_START_OVER forState:UIControlStateNormal];
    [self.startOverButton setTitleColor:UIColor.brandSecondary forState:UIControlStateNormal];
    self.startOverButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    self.startOverButton.hidden = YES;
    [self.startOverButton addTarget:self action:@selector(showFirstCard) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat closeButtonHeight = 46;
    self.closeCardsViewButton = [[UIButton alloc] initWithFrame:CGRectMake(cardsView.frame.size.width - closeButtonHeight, 0, closeButtonHeight, closeButtonHeight)];
    self.closeCardsViewButton.imageEdgeInsets = UIEdgeInsetsMake(16, 20, 16, 12);
    [self.closeCardsViewButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.closeCardsViewButton.imageView.tintColor = UIColor.gray2;
    [self.closeCardsViewButton addTarget:self action:@selector(closeCardsView) forControlEvents:UIControlEventTouchUpInside];
    [cardsView addSubview:self.closeCardsViewButton];
    self.closeCardsViewButton.hidden = YES;
    
    CGFloat skipAllButtonWidth = 80;
    CGFloat skipAllButtonHeight = 30;
    self.skipAllButton = [[UIButton alloc] initWithFrame:CGRectMake(cardsView.frame.size.width - skipAllButtonWidth, self.pageControl.frame.origin.y, skipAllButtonWidth, skipAllButtonHeight)];
    self.skipAllButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    self.skipAllButton.backgroundColor = [UIColor clearColor];
    [self.skipAllButton setTitleColor:UIColor.brandTertiary forState:UIControlStateNormal];
    [self.skipAllButton setTitle:BC_STRING_SKIP_ALL forState:UIControlStateNormal];
    [self.skipAllButton addTarget:self action:@selector(closeCardsView) forControlEvents:UIControlEventTouchUpInside];
    [cardsView addSubview:self.skipAllButton];
    
    
    // Maintain last viewed page when a refresh is triggered
    CGFloat oldContentOffsetX = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_LAST_CARD_OFFSET] floatValue];
    if (oldContentOffsetX > scrollView.contentSize.width - scrollView.frame.size.width * 1.5) {
        self.startOverButton.hidden = NO;
        self.closeCardsViewButton.hidden = NO;
        self.pageControl.hidden = YES;
        self.skipAllButton.hidden = YES;
    }
    self.cardsScrollView.contentOffset = CGPointMake(oldContentOffsetX > self.cardsScrollView.contentSize.width ? self.cardsScrollView.contentSize.width - self.cardsScrollView.frame.size.width : oldContentOffsetX, self.cardsScrollView.contentOffset.y);
    
    return cardsView;
}

- (void)showFirstCard
{
    self.cardsScrollView.scrollEnabled = YES;
    [self.cardsScrollView setContentOffset:CGPointZero animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:0] forKey:USER_DEFAULTS_KEY_LAST_CARD_OFFSET];
}

- (CGFloat)getPageXPosition:(CGFloat)cardLength page:(NSInteger)page
{
    return cardLength * page;
}

- (void)closeBuySellCard
{
    BlockchainSettings.sharedOnboardingInstance.shouldHideBuySellCard = YES;
    [self closeAnnouncementCard:CardConfigurationBuySell];
}

- (void)closeAnnouncementCard:(CardConfiguration)cardConfiguration
{
    if (self.announcementCards.count == 1) {
        [self closeCardsView]; return;
    }
    [UIView animateWithDuration:ANIMATION_DURATION_LONG animations:^{
        CGFloat newY = ANNOUNCEMENT_CARD_HEIGHT * (self.announcementCards.count - 1);
        if ([self.announcementCards.firstObject integerValue] == cardConfiguration) {
            for (UIView *cardView in self.cardsView.subviews) {
                cardView.frame = CGRectOffset(cardView.frame, 0, -ANNOUNCEMENT_CARD_HEIGHT);
            }
        }
        [self.cardsView changeHeight:newY];
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.contentView ? self.contentView.frame.size.height : 0);
        [self.contentView changeYPosition:newY];
    } completion:^(BOOL finished) {
        [self reloadCards];
    }];
}

- (void)cardActionClicked:(ActionType)actionType
{
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;

    switch (actionType) {
        case ActionTypeBuyBitcoin:
            [BuySellCoordinator.sharedInstance showBuyBitcoinView];
            break;
        case ActionTypeShowReceive:
            [tabControllerManager receiveCoinClicked:nil];
            break;
        case ActionTypeScanQR:
            [tabControllerManager qrCodeButtonClicked];
            break;
        case ActionTypeBuySell:
            [BuySellCoordinator.sharedInstance showBuyBitcoinView];
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.cardsScrollView) {
        
        BOOL didSeeAllCards = scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width * 1.5;
        if (didSeeAllCards) {
            BlockchainSettings.sharedOnboardingInstance.hasSeenAllCards = YES;
        }
        
        if (!self.isUsingPageControl) {
            CGFloat pageWidth = scrollView.frame.size.width;
            float fractionalPage = scrollView.contentOffset.x / pageWidth;
            
            if (!didSeeAllCards) {
                if (self.skipAllButton.hidden && self.pageControl.hidden) {
                    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                        self.skipAllButton.alpha = 1;
                        self.pageControl.alpha = 1;
                        self.startOverButton.alpha = 0;
                        self.closeCardsViewButton.alpha = 0;
                    } completion:^(BOOL finished) {
                        self.skipAllButton.hidden = NO;
                        self.pageControl.hidden = NO;
                        self.startOverButton.hidden = YES;
                        self.closeCardsViewButton.hidden = YES;
                    }];
                }
            } else {
                if (!self.skipAllButton.hidden && !self.pageControl.hidden) {
                    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                        self.skipAllButton.alpha = 0;
                        self.pageControl.alpha = 0;
                        self.startOverButton.alpha = 1;
                        self.closeCardsViewButton.alpha = 1;
                    } completion:^(BOOL finished) {
                        self.skipAllButton.hidden = YES;
                        self.pageControl.hidden = YES;
                        self.startOverButton.hidden = NO;
                        self.closeCardsViewButton.hidden = NO;
                    }];
                }
            }
            
            NSInteger page = lround(fractionalPage);
            self.pageControl.currentPage = page;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.cardsScrollView) {
        if (scrollView.contentSize.width - scrollView.frame.size.width <= scrollView.contentOffset.x) {
            scrollView.scrollEnabled = NO;
        }
        
        // Save last viewed page since cards view can be reinstantiated when app is still open
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:scrollView.contentOffset.x] forKey:USER_DEFAULTS_KEY_LAST_CARD_OFFSET];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.cardsScrollView) {
        self.isUsingPageControl = NO;
    }
}

- (void)pageControlChanged:(UIPageControl *)pageControl
{
    self.isUsingPageControl = YES;
    
    NSInteger page = pageControl.currentPage;
    CGRect frame = self.cardsScrollView.frame;
    frame.origin.x = self.cardsScrollView.frame.size.width * page;
    [self.cardsScrollView scrollRectToVisible:frame animated:YES];
}

- (void)closeCardsView
{
    [UIView animateWithDuration:ANIMATION_DURATION_LONG animations:^{
        [self.cardsView changeHeight:0];
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.contentView ? self.contentView.frame.size.height : 0);
        [self.contentView changeYPosition:0];
    } completion:^(BOOL finished) {
        [self removeCardsView];
    }];

    BlockchainSettings.sharedOnboardingInstance.hasSeenAllCards = YES;
}

- (void)removeCardsView
{
    [self.cardsView removeFromSuperview];
    self.cardsView = nil;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.contentView ? self.contentView.frame.size.height : 0);
    [self.contentView changeYPosition:0];
}

@end
