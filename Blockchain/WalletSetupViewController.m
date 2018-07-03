//
//  WalletSetupViewController.m
//  Blockchain
//
//  Created by kevinwu on 3/27/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "WalletSetupViewController.h"
#import "Blockchain-Swift.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface WalletSetupViewController ()
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UILabel *emailLabel;
@property (nonatomic) UIWindow *window;
@property (nonatomic) BiometricType *biometricType;
@end

@implementation WalletSetupViewController

- (id)initWithSetupDelegate:(UIViewController<SetupDelegate>*)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        _window = [UIApplication sharedApplication].keyWindow;
        _biometricType = UIDevice.currentDevice.supportedBiometricType;
    }
    return self;
}

- (void)loadView
{
    CGFloat safeAreaInsetBottom = [UIView rootViewSafeAreaInsets].bottom;
    CGRect frame = CGRectMake(0, 0, _window.frame.size.width, _window.frame.size.height - safeAreaInsetBottom);
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.view == nil) {
        [super loadView];
    }

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = NO;
    
    NSInteger numberOfPages = 2;
    
    if (_biometricType) {
        [scrollView addSubview:[self setupBiometricView]];
    } else {
        self.emailOnly = YES;
    }
    [scrollView addSubview:[self setupEmailView]];
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfPages, scrollView.frame.size.height);
    [self.view addSubview:scrollView];
    
    self.scrollView = scrollView;
    
    if (self.emailOnly) {
        [self goToSecondPage];
    }
}

#pragma mark - Biometrics

- (UIView *)setupBiometricView
{
    UIView *biometricView = [[UIView alloc] initWithFrame:self.view.frame];
    UIView *bannerView = [self setupBannerViewWithImageName:_biometricType.asset];

    [biometricView addSubview:bannerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bannerView.frame.size.height + 32, biometricView.frame.size.width - 50, 50)];
    titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_LARGE];
    titleLabel.textColor = COLOR_TEXT_DARK_GRAY;
    titleLabel.text = _biometricType.title;
    titleLabel.center = CGPointMake(biometricView.center.x, titleLabel.center.y);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [biometricView addSubview:titleLabel];
    
    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, biometricView.frame.size.width - 50, 100)];
    NSString *biometricInstructions = [NSString stringWithFormat:[LocalizationConstantsObjcBridge biometricInstructions], _biometricType.title];
    body.selectable = NO;
    body.editable = NO;
    body.scrollEnabled = NO;
    body.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    body.textColor = COLOR_TEXT_DARK_GRAY;
    body.text = biometricInstructions;
    body.center = CGPointMake(biometricView.center.x, body.center.y);
    body.textAlignment = NSTextAlignmentCenter;
    [biometricView addSubview:body];
    
    UIButton *enableBiometricButton = [self setupActionButton];
    NSString *buttonTitle = [NSString stringWithFormat:[LocalizationConstantsObjcBridge enableBiometrics], _biometricType.title];
    [enableBiometricButton setTitle:[buttonTitle uppercaseString] forState:UIControlStateNormal];
    [enableBiometricButton addTarget:self action:@selector(enableBiometrics:) forControlEvents:UIControlEventTouchUpInside];
    enableBiometricButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [biometricView addSubview:enableBiometricButton];
    
    UIButton *doneButton = [self setupDoneButton];
    doneButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [doneButton addTarget:self action:@selector(goToSecondPage) forControlEvents:UIControlEventTouchUpInside];
    [biometricView addSubview:doneButton];
    
    return biometricView;
}

- (UIView *)setupEmailView
{
    UIView *emailView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIView *bannerView = [self setupBannerViewWithImageName:@"email"];
    [emailView addSubview:bannerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bannerView.frame.size.height + 32, emailView.frame.size.width - 50, 50)];
    titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_LARGE];
    titleLabel.textColor = COLOR_TEXT_DARK_GRAY;
    titleLabel.text = BC_STRING_REMINDER_CHECK_EMAIL_TITLE;
    titleLabel.center = CGPointMake(emailView.center.x - self.view.frame.size.width, titleLabel.center.y);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [emailView addSubview:titleLabel];
    
    self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, emailView.frame.size.width - 50, 30)];
    self.emailLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_SEMIBOLD size:FONT_SIZE_SMALL_MEDIUM];
    self.emailLabel.text = [WalletManager.sharedInstance.wallet getEmail];
    self.emailLabel.textColor = COLOR_TEXT_DARK_GRAY;
    self.emailLabel.center = CGPointMake(emailView.center.x - self.view.frame.size.width, self.emailLabel.center.y);
    self.emailLabel.textAlignment = NSTextAlignmentCenter;
    [emailView addSubview:self.emailLabel];
    
    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, self.emailLabel.frame.origin.y + self.emailLabel.frame.size.height + 8, emailView.frame.size.width - 50, 100)];
    body.selectable = NO;
    body.editable = NO;
    body.scrollEnabled = NO;
    body.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    body.textColor = COLOR_TEXT_DARK_GRAY;
    body.text = BC_STRING_REMINDER_CHECK_EMAIL_MESSAGE;
    body.center = CGPointMake(emailView.center.x - self.view.frame.size.width, body.center.y);
    body.textAlignment = NSTextAlignmentCenter;
    [emailView addSubview:body];
    
    UIButton *openMailButton = [self setupActionButton];
    openMailButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [openMailButton setTitle:[BC_STRING_OPEN_MAIL uppercaseString] forState:UIControlStateNormal];
    [openMailButton addTarget:self action:@selector(openMail) forControlEvents:UIControlEventTouchUpInside];
    [emailView addSubview:openMailButton];
    
    UIButton *doneButton = [self setupDoneButton];
    doneButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [emailView addSubview:doneButton];
    
    return emailView;
}

- (UIButton *)setupActionButton
{
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.frame = CGRectMake(0, self.view.frame.size.height - 60 - 30 - 16, self.view.frame.size.width - 100, 40);
    actionButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    actionButton.center = CGPointMake(self.view.frame.size.width/2, actionButton.center.y);
    actionButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return actionButton;
}

- (UIButton *)setupDoneButton
{
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width - 100, 40)];
    doneButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    doneButton.center = CGPointMake(self.view.frame.size.width/2, doneButton.center.y);
    [doneButton setTitleColor:COLOR_LIGHT_GRAY forState:UIControlStateNormal];
    [doneButton setTitle:BC_STRING_ILL_DO_THIS_LATER forState:UIControlStateNormal];
    return doneButton;
}

- (UIView *)setupBannerViewWithImageName:(NSString *)imageName
{
    CGFloat safeAreaInsetTop = 20;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = _window.rootViewController.view.safeAreaInsets.top;
    }

    CGFloat headerHeight = [ConstantsObjcBridge defaultNavigationBarHeight] + safeAreaInsetTop + 80;

    UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    bannerView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;

    CGFloat imageHeight = 72;
    CGFloat imageWidth = 72;
    CGFloat posX = (bannerView.frame.size.width / 2) - (imageWidth / 2);
    CGFloat posY = (bannerView.frame.size.height / 2) - (imageHeight / 2) + (safeAreaInsetTop / 2);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(posX, posY, imageWidth, imageHeight);
    
    [bannerView addSubview:imageView];
    return bannerView;
}

- (void)goToSecondPage
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
}

- (void)dismiss
{
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openMail
{
    [UIApplication.sharedApplication openMailApplication];
}

- (void)enableBiometrics:(UIButton *)sender
{
    [self.delegate enableTouchIDClicked:^(BOOL success) {
        if (success) {
            [sender setTitle:[BC_STRING_ENABLED_EXCLAMATION uppercaseString] forState:UIControlStateNormal];
            sender.backgroundColor = COLOR_BLOCKCHAIN_GREEN;

            [self performSelector:@selector(goToSecondPage) withObject:nil afterDelay:0.3f];
        }
    }];
}

@end
