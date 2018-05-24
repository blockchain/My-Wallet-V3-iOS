//
//  ExchangeConfirmViewController.m
//  Blockchain
//
//  Created by kevinwu on 10/31/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ExchangeConfirmViewController.h"
#import "BCLine.h"
#import "UILabel+CGRectForSubstring.h"
#import "ExchangeDetailView.h"
#import "BCNavigationController.h"
#import <SafariServices/SafariServices.h>
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

#define MARGIN_HORIZONTAL 20
#define SHAPESHIFT_TERMS_AND_CONDITIONS_URL @"https://info.shapeshift.io/sites/default/files/ShapeShift_Terms_Conditions%20v1.1.pdf"

@interface ExchangeConfirmViewController ()
@property (nonatomic) ExchangeTrade *trade;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) UISwitch *agreementSwitch;
@property (nonatomic) UIView *timerView;
@property (nonatomic) UILabel *timerLabel;
@end

@implementation ExchangeConfirmViewController

- (id)initWithExchangeTrade:(ExchangeTrade *)trade
{
    if (self == [super init]) {
        self.trade = trade;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat windowWidth = WINDOW_WIDTH;
    
    [self setupTimerView];
    
    ExchangeDetailView *detailView = [[ExchangeDetailView alloc] initWithFrame:CGRectMake(0, self.timerView.frame.origin.y + self.timerView.frame.size.height, windowWidth, 0) builtTrade:self.trade];
    [self.view addSubview:detailView];
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick:) userInfo: nil repeats: YES];
    
    [self setupAgreementViewsAtYPosition:detailView.frame.origin.y + detailView.frame.size.height + 16];
    
    [self setupConfirmButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    navigationController.headerTitle = BC_STRING_CONFIRM;
}

- (void)setupTimerView
{
    CGFloat windowWidth = WINDOW_WIDTH;
    BOOL isUsing4S = IS_USING_SCREEN_SIZE_4S;
    CGFloat offset = isUsing4S ? 0 : 16;
    CGFloat timerViewHeight = isUsing4S ? 36 : 40;

    UIView *timerView = [[UIView alloc] initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT + offset, windowWidth, timerViewHeight)];
    UILabel *timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    timerLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    timerLabel.textColor = COLOR_TEXT_GRAY;
    [timerView addSubview:timerLabel];
    self.timerLabel = timerLabel;
    [self.view addSubview:timerView];
    self.timerView = timerView;
}

- (void)setupAgreementViewsAtYPosition:(CGFloat)yPosition
{
    CGFloat horizontalMargin = MARGIN_HORIZONTAL;
    CGFloat windowWidth = WINDOW_WIDTH;
    
    UISwitch *agreementSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(horizontalMargin, yPosition, 0, 0)];
    agreementSwitch.onTintColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    [self.view addSubview:agreementSwitch];
    [agreementSwitch addTarget:self action:@selector(agreementSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    self.agreementSwitch = agreementSwitch;

    CGFloat agreementLabelOriginX = agreementSwitch.frame.origin.x + agreementSwitch.frame.size.width + 8;
    UILabel *agreementLabel = [[UILabel alloc] initWithFrame:CGRectMake(agreementLabelOriginX, 0, windowWidth - horizontalMargin - agreementLabelOriginX, 30)];
    agreementLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_EXTRA_EXTRA_SMALL];
    agreementLabel.center = CGPointMake(agreementLabel.center.x, agreementSwitch.center.y);
    
    NSAttributedString *attributedStringPrefix = [[NSAttributedString alloc] initWithString:BC_STRING_AGREE_TO_SHAPESHIFT];
    NSMutableAttributedString *termsAndConditionsText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedStringPrefix];
    [termsAndConditionsText addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_DARK_GRAY range:NSMakeRange(0, [attributedStringPrefix length])];
    
    NSAttributedString *attributedStringSpace = [[NSAttributedString alloc] initWithString:@" "];
    
    NSAttributedString *attributedStringSuffix = [[NSAttributedString alloc] initWithString:BC_STRING_TERMS_AND_CONDITIONS];
    NSMutableAttributedString *termsAndConditionsSuffix = [[NSMutableAttributedString alloc] initWithAttributedString:attributedStringSuffix];
    [termsAndConditionsSuffix addAttribute:NSForegroundColorAttributeName value:COLOR_BLOCKCHAIN_LIGHT_BLUE range:NSMakeRange(0, [attributedStringSuffix length])];
    
    [termsAndConditionsText appendAttributedString:attributedStringSpace];
    [termsAndConditionsText appendAttributedString:termsAndConditionsSuffix];
    
    [agreementLabel setAttributedText:termsAndConditionsText];
    
    NSString *originalString = [[NSString alloc] initWithFormat:@"%@%@%@", BC_STRING_AGREE_TO_SHAPESHIFT, @" ", BC_STRING_TERMS_AND_CONDITIONS];
    UILabel *measuringLabel = [[UILabel alloc] initWithFrame:agreementLabel.bounds];
    measuringLabel.font = agreementLabel.font;
    measuringLabel.text = originalString;
    
    CGRect tappableArea = [measuringLabel boundingRectForCharacterRange:[originalString rangeOfString:BC_STRING_TERMS_AND_CONDITIONS]];
    UIView *tappableView = [[UIView alloc] initWithFrame:tappableArea];
    tappableView.userInteractionEnabled = YES;
    agreementLabel.userInteractionEnabled = YES;
    [tappableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(handleTapView)]];
    [agreementLabel addSubview:tappableView];
    [self.view addSubview:agreementLabel];
}

- (void)setupConfirmButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, BUTTON_HEIGHT)];
    button.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    button.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:17.0];
    [button setTitle:BC_STRING_CONFIRM forState:UIControlStateNormal];
    button.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 24 - BUTTON_HEIGHT/2);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(confirmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton = button;
    
    [self disableConfirmButton];
}

- (void)enableConfirmButton
{
    self.confirmButton.enabled = YES;
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundColor:COLOR_BLOCKCHAIN_LIGHT_BLUE];
}

- (void)disableConfirmButton
{
    self.confirmButton.enabled = NO;
    [self.confirmButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.confirmButton setBackgroundColor:COLOR_BUTTON_KEYPAD_GRAY];
}

- (void)confirmButtonClicked
{
    if ([[self.trade.depositCurrency uppercaseString] isEqualToString:CURRENCY_SYMBOL_ETH] && [[WalletManager sharedInstance].wallet isWaitingOnEtherTransaction]) {
        [[AlertViewPresenter sharedInstance] showWaitingForEtherPaymentAlert];
        return;
    }
    
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    [navigationController showBusyViewWithLoadingText:BC_STRING_CONFIRMING];
    
    [self performSelector:@selector(shiftPayment) withObject:nil afterDelay:ANIMATION_DURATION];
}

- (void)agreementSwitchChanged:(UISwitch *)agreementSwitch
{
    if (agreementSwitch.on) {
        [self enableConfirmButton];
    } else {
        [self disableConfirmButton];
    }
}

- (void)handleTapView
{
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:SHAPESHIFT_TERMS_AND_CONDITIONS_URL]];
    [self.navigationController presentViewController:safariViewController animated:YES completion:nil];
}

- (void)handleTimerTick:(NSTimer *)timer
{
    NSTimeInterval interval = [self.trade.expirationDate timeIntervalSinceNow];
    int secondsInAnHour = 3600;
    int hours = interval / secondsInAnHour;
    int minutesInAnHour = 60;
    int minutes = (interval - hours * secondsInAnHour) / minutesInAnHour;
    int secondsInAMinute = 60;
    int seconds = interval - hours * secondsInAnHour - minutes * secondsInAMinute;
    
    NSString *hoursString = [NSString stringWithFormat:@"%02d", hours];
    NSString *minutesString = minutes > 9 ? [NSString stringWithFormat:@"%02d", minutes] : [NSString stringWithFormat:@"%d", minutes];
    NSString *secondsString = [NSString stringWithFormat:@"%02d", seconds];
    NSString *secondsFormattedString = seconds < 10 ? [[NSNumberFormatter localFormattedString:@"0"] stringByAppendingString:[NSNumberFormatter localFormattedString:secondsString]] : [NSNumberFormatter localFormattedString:secondsString];
    NSString *timeString = hours > 0 ? [NSString stringWithFormat:@"%@:%@:%@", [NSNumberFormatter localFormattedString:hoursString], [NSNumberFormatter localFormattedString:minutesString], secondsFormattedString] : [NSString stringWithFormat:@"%@:%@", [NSNumberFormatter localFormattedString:minutesString], secondsFormattedString];
    
    self.timerLabel.text = [NSString stringWithFormat:BC_STRING_QUOTE_EXIRES_IN_ARGUMENT, timeString];
    [self.timerLabel sizeToFit];
    self.timerLabel.frame = CGRectMake(self.timerView.frame.size.width - self.timerLabel.frame.size.width - 16, 0, self.timerLabel.frame.size.width, self.timerLabel.frame.size.height);
    self.timerLabel.center = CGPointMake(self.timerLabel.center.x, self.timerView.frame.size.height/2);
    
    if (hours == 0 && minutes < 5) {
        self.timerLabel.textColor = COLOR_WARNING_RED;
    }
    
    if (hours + minutes + seconds <= 0) {
        [timer invalidate];
        [self showExpiredAlert];
    }
}

- (void)showExpiredAlert
{
    UIAlertController *expiredAlert = [UIAlertController alertControllerWithTitle:BC_STRING_TRADE_EXPIRED_TITLE message:BC_STRING_TRADE_EXPIRED_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    [expiredAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self.navigationController presentViewController:expiredAlert animated:YES completion:nil];
}

- (void)shiftPayment
{
    [WalletManager.sharedInstance.wallet shiftPayment];
}

@end
