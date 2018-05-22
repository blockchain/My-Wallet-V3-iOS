//
//  SettingsAboutUsViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 11/7/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SettingsAboutUsViewController.h"
#import "Blockchain-Swift.h"

@interface SettingsAboutUsViewController ()
@end

@implementation SettingsAboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 80, 51)];
    closeButton.imageEdgeInsets = IMAGE_EDGE_INSETS_CLOSE_BUTTON_X;
    closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    closeButton.imageView.tintColor = COLOR_BLOCKCHAIN_BLUE;
    closeButton.center = CGPointMake(closeButton.center.x, closeButton.center.y);
    [closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    CGFloat labelWidth = self.view.frame.size.width - 30;

    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 0, labelWidth, 90)];
    infoLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = COLOR_BLOCKCHAIN_BLUE;
    infoLabel.numberOfLines = 3;
    infoLabel.text = [NSString stringWithFormat:@"%@ %@\n%@\n%@", ABOUT_STRING_BLOCKCHAIN_WALLET, [NSBundle applicationVersion], [NSString stringWithFormat:@"%@ %@ %@", ABOUT_STRING_COPYRIGHT_LOGO, COPYRIGHT_YEAR, ABOUT_STRING_BLOCKCHAIN_LUXEMBOURG_SA], BC_STRING_BLOCKCHAIN_ALL_RIGHTS_RESERVED];
    infoLabel.center = self.view.center;
    [self.view addSubview:infoLabel];

    CGFloat imageWidth = labelWidth;
    CGFloat imageHeight = 60;
    
    UIImageView *logoAndBannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - imageWidth)/2, infoLabel.frame.origin.y - imageHeight, imageWidth, imageHeight)];
    logoAndBannerImageView.image = [UIImage imageNamed:@"logo_and_banner"];
    logoAndBannerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoAndBannerImageView];
    
    [self addButtonsWithWidth:labelWidth - 30 belowView:infoLabel];
}

- (void)addButtonsWithWidth:(CGFloat)buttonWidth belowView:(UIView *)aboveView
{
    UIButton *rateUsButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonWidth)/2, aboveView.frame.origin.y + aboveView.frame.size.height + 16, buttonWidth, 40)];
    rateUsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [rateUsButton setTitleColor:COLOR_BLOCKCHAIN_BLUE forState:UIControlStateNormal];
    rateUsButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    [rateUsButton setTitle:BC_STRING_RATE_US forState:UIControlStateNormal];
    [self.view addSubview:rateUsButton];
    [rateUsButton addTarget:self action:@selector(rateApp) forControlEvents:UIControlEventTouchUpInside];
}

- (void)rateApp
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate rateApp];
}

- (void)closeButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
