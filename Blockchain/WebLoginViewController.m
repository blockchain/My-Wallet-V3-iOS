//
//  WebLoginViewController.m
//  Blockchain
//
//  Created by Justin on 2/28/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "WebLoginViewController.h"
#import "QRCodeGenerator.h"
#import "Blockchain-Swift.h"

@interface WebLoginViewController ()
@property (nonatomic) QRCodeGenerator *qrCodeGenerator;
@property (nonatomic) UILabel *stepOneLabel;
@property (nonatomic) UILabel *stepTwoLabel;
@property (nonatomic) UILabel *stepThreeLabel;
@property (nonatomic) UITextView *stepOneTextView;
@property (nonatomic) UITextView *stepTwoTextView;
@property (nonatomic) UITextView *stepThreeTextView;
@property (nonatomic) UILabel *QRInstructionLabel;
@property (nonatomic) UIButton *QRCodeButton;
@property (nonatomic) BOOL isShowingQRCode;
@property (nonatomic) CGPoint originalCenter;

@end

const float qrSize = 230;

@implementation WebLoginViewController

- (id)init
{
    if (self = [super init]) {
        self.qrCodeGenerator = [[QRCodeGenerator alloc] init];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGSize size = [UIApplication sharedApplication].keyWindow.frame.size;
    self.view.frame = CGRectMake(0, DEFAULT_HEADER_HEIGHT, size.width, size.height - DEFAULT_HEADER_HEIGHT);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupInstructions];

    [self setupQRCodeViews];

    WalletManager.sharedInstance.wallet.delegate = self;
    [WalletManager.sharedInstance.wallet makePairingCode];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SettingsNavigationController *navigationController = (SettingsNavigationController *)self.navigationController;
    navigationController.headerLabel.text = BC_STRING_LOG_IN_TO_WEB_WALLET;
}

- (void)setupInstructions
{
    CGFloat instructionTextViewHeight = 40;
    
    self.originalCenter = self.view.center;
    
    self.stepOneTextView = [WebLoginViewController textViewForInstruction:BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_ONE];
    self.stepOneTextView.frame = CGRectMake(0, DEFAULT_HEADER_HEIGHT + 20, self.view.frame.size.width - 70, instructionTextViewHeight);
    self.stepOneTextView.center = CGPointMake(self.view.center.x + 10, self.stepOneTextView.center.y);
    [self.view addSubview:self.stepOneTextView];
    
    self.stepOneLabel = [WebLoginViewController labelForInstructionStep:@"1."];
    self.stepOneLabel.frame = CGRectMake(self.stepOneTextView.frame.origin.x - 16, self.stepOneTextView.frame.origin.y, CGRectGetWidth(self.stepOneLabel.frame), CGRectGetHeight(self.stepOneLabel.frame));
    [self.view addSubview:self.stepOneLabel];
    
    self.stepTwoTextView = [WebLoginViewController textViewForInstruction:BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_TWO];
    self.stepTwoTextView.frame = CGRectOffset(self.stepOneTextView.frame, 0, self.stepOneTextView.contentSize.height + 20);
    [self.view addSubview:self.stepTwoTextView];
    
    self.stepTwoLabel = [WebLoginViewController labelForInstructionStep:@"2."];
    self.stepTwoLabel.frame = CGRectMake(self.stepTwoTextView.frame.origin.x - 16, self.stepTwoTextView.frame.origin.y, CGRectGetWidth(self.stepTwoLabel.frame), CGRectGetHeight(self.stepTwoLabel.frame));
    [self.view addSubview:self.stepTwoLabel];
    
    self.stepThreeTextView = [WebLoginViewController textViewForInstruction:BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_THREE];
    self.stepThreeTextView.frame = CGRectOffset(self.stepTwoTextView.frame, 0, self.stepTwoTextView.contentSize.height + 20);
    self.stepThreeTextView.frame = CGRectMake(self.stepThreeTextView.frame.origin.x, self.stepThreeTextView.frame.origin.y, self.stepThreeTextView.frame.size.width, self.stepThreeTextView.contentSize.height);
    [self.view addSubview:self.stepThreeTextView];
    
    self.stepThreeLabel = [WebLoginViewController labelForInstructionStep:@"3."];
    self.stepThreeLabel.frame = CGRectMake(self.stepThreeTextView.frame.origin.x - 16, self.stepThreeTextView.frame.origin.y, CGRectGetWidth(self.stepThreeLabel.frame), CGRectGetHeight(self.stepThreeLabel.frame));
    [self.view addSubview:self.stepThreeLabel];
}

- (void)setupQRCodeViews
{
    CGFloat verticalOffset = IS_USING_SCREEN_SIZE_4S ? 25 : 0;

    self.QRCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 240, BUTTON_HEIGHT)];
    [self.QRCodeButton setTitle:[BC_STRING_SHOW_QR_CODE uppercaseString] forState:UIControlStateNormal];
    self.QRCodeButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    self.QRCodeButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    self.QRCodeButton.center = CGPointMake(self.view.center.x, self.view.center.y + verticalOffset);
    self.QRCodeButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [self.QRCodeButton addTarget:self action:@selector(toggleQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.QRCodeButton];
    
    self.QRInstructionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.QRInstructionLabel.text = BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_HIDDEN;
    self.QRInstructionLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
    self.QRInstructionLabel.textColor = COLOR_TEXT_DARK_GRAY;
    self.QRInstructionLabel.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, 50);
    self.QRInstructionLabel.textAlignment = NSTextAlignmentCenter;
    self.QRInstructionLabel.numberOfLines = 2;
    self.QRInstructionLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 50 + verticalOffset);
    [self.view addSubview:self.QRInstructionLabel];
    
    qrCodeMainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, qrSize, qrSize)];
    qrCodeMainImageView.center = CGPointMake(self.view.center.x, self.view.center.y - DEFAULT_HEADER_HEIGHT + verticalOffset);
    qrCodeMainImageView.contentMode = UIViewContentModeScaleAspectFit;
    qrCodeMainImageView.hidden = YES;
    [self.view addSubview:qrCodeMainImageView];
}

- (void)toggleQRCode
{
    BOOL isShowingQRCode = self.isShowingQRCode;
    
    if (isShowingQRCode) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self fadeInInstructions];
            
            qrCodeMainImageView.alpha = 0.0;
            
            self.QRInstructionLabel.text = BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_HIDDEN;
            
            CGFloat verticalOffset = IS_USING_SCREEN_SIZE_4S ? 25 : 0;

            self.QRInstructionLabel.center = CGPointMake(self.view.center.x, self.originalCenter.y - 50 + verticalOffset);
            
            self.QRCodeButton.center = CGPointMake(self.view.center.x, self.originalCenter.y + verticalOffset);
            [self.QRCodeButton setTitle:BC_STRING_SHOW_QR_CODE forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            qrCodeMainImageView.hidden = YES;
            [self showInstructions];
        }];
    } else {
        qrCodeMainImageView.alpha = 0.0;
        qrCodeMainImageView.hidden = NO;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self fadeOutInstructions];
            
            qrCodeMainImageView.alpha = 1.0;
            
            self.QRInstructionLabel.alpha = 0.0;
            self.QRInstructionLabel.center = CGPointMake(self.view.center.x, qrCodeMainImageView.frame.origin.y - 30);
            
            self.QRCodeButton.center = CGPointMake(self.view.center.x, qrCodeMainImageView.frame.origin.y + qrCodeMainImageView.frame.size.height + 16 + self.QRCodeButton.frame.size.height/2);
            [self.QRCodeButton setTitle:BC_STRING_HIDE_QR_CODE forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                self.QRInstructionLabel.text = [BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_SHOWN_ONE stringByAppendingFormat:@"\n%@", BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_SHOWN_TWO];
                self.QRInstructionLabel.alpha = 1.0;
            }];
            [self hideInstructions];
        }];
    }
    
    self.isShowingQRCode = !isShowingQRCode;
}

- (void)showInstructions
{
    self.stepOneLabel.hidden = NO;
    self.stepTwoLabel.hidden = NO;
    self.stepThreeLabel.hidden = NO;
    
    self.stepOneTextView.hidden = NO;
    self.stepTwoTextView.hidden = NO;
    self.stepThreeTextView.hidden = NO;
}

- (void)fadeInInstructions
{
    self.stepOneLabel.alpha = 1.0;
    self.stepTwoLabel.alpha = 1.0;
    self.stepThreeLabel.alpha = 1.0;
    
    self.stepOneTextView.alpha = 1.0;
    self.stepTwoTextView.alpha = 1.0;
    self.stepThreeTextView.alpha = 1.0;
}

- (void)fadeOutInstructions
{
    self.stepOneLabel.alpha = 0.0;
    self.stepTwoLabel.alpha = 0.0;
    self.stepThreeLabel.alpha = 0.0;
    
    self.stepOneTextView.alpha = 0.0;
    self.stepTwoTextView.alpha = 0.0;
    self.stepThreeTextView.alpha = 0.0;
}

- (void)hideInstructions
{
    self.stepOneLabel.hidden = YES;
    self.stepTwoLabel.hidden = YES;
    self.stepThreeLabel.hidden = YES;
    
    self.stepOneTextView.hidden = YES;
    self.stepTwoTextView.hidden = YES;
    self.stepThreeTextView.hidden = YES;
}

- (void)didMakePairingCode:(NSString *)code
{
    DLog(@"Made pairing code: %@", code);
    [self setQR:code];
}

- (void)errorMakingPairingCode:(NSString *)message
{
    DLog(@"Error making pairing code: %@", message);
}

- (void)setQR:(NSString *)data
{
    UIImage *qr = [self.qrCodeGenerator createQRImageFromString:data];
    qrCodeMainImageView.image = qr;
    qrCodeMainImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewWillDisappear:(BOOL)animated {
    WalletManager.sharedInstance.wallet.delegate = WalletManager.sharedInstance;
    [super viewWillDisappear:animated];
}

+ (UITextView *)textViewForInstruction:(NSString *)instruction
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textColor = COLOR_TEXT_DARK_GRAY;
    textView.editable = NO;
    textView.selectable = NO;
    textView.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
    textView.text = instruction;
    return textView;
}

+ (UILabel *)labelForInstructionStep:(NSString *)stepNumber
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = COLOR_TEXT_DARK_GRAY;
    label.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
    label.text = stepNumber;
    [label sizeToFit];
    return label;
}

@end
