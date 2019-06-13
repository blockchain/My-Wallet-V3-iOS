//
//  BCConfirmPaymentViewModel.h
//  Blockchain
//
//  Created by kevinwu on 8/29/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCConfirmPaymentViewModel : NSObject

- (instancetype)initWithFrom:(NSString *)from
                  To:(NSString *)to
              amount:(uint64_t)amount
                 fee:(uint64_t)fee
               total:(uint64_t)total
               surge:(BOOL)surgePresent;

- (instancetype)initWithTo:(NSString *)to
       ethAmount:(NSString *)ethAmount
          ethFee:(NSString *)ethFee
        ethTotal:(NSString *)ethTotal
      fiatAmount:(NSString *)fiatAmount
         fiatFee:(NSString *)fiatFee
       fiatTotal:(NSString *)fiatTotal;

- (instancetype)initWithFrom:(NSString *)from
                To:(NSString *)to
            bchAmount:(uint64_t)amount
               fee:(uint64_t)fee
             total:(uint64_t)total
             surge:(BOOL)surgePresent;

- (instancetype)initWithFrom:(NSString *_Nonnull)from
                          to:(NSString *_Nonnull)to
             totalAmountText:(NSString *_Nonnull)totalAmountText
         fiatTotalAmountText:(NSString *_Nonnull)fiatTotalAmountText
    cryptoWithFiatAmountText:(NSString *_Nonnull)cryptoWithFiatAmountText
       amountWithFiatFeeText:(NSString *_Nonnull)amountWithFiatFeeText
                 buttonTitle:(NSString *_Nonnull)buttonTitle
             showDescription:(BOOL)showDescription
            surgeIsOccurring:(BOOL)surgeIsOccurring
          showsFeeInformationButton:(BOOL)showsFeeInformationButton
                    noteText:(NSString *_Nullable)noteText
                 warningText:(NSAttributedString *_Nullable)warningText
            descriptionTitle:(NSString *_Nullable)descriptionTitle;

@property (nonatomic) NSString *from;
@property (nonatomic) NSString *to;
@property (nonatomic) NSString *totalAmountText;
@property (nonatomic) NSString *fiatTotalAmountText;
@property (nonatomic) NSString *cryptoWithFiatAmountText;
@property (nonatomic) NSString *amountWithFiatFeeText;
@property (nonatomic) NSString *noteText;
@property (nonatomic) NSString *buttonTitle;
@property (nonatomic, strong) NSString *descriptionTitle;
@property (nonatomic) BOOL showDescription;
@property (nonatomic) BOOL surgeIsOccurring;
@property (nonatomic) BOOL showsFeeInformationButton;
@property (nonatomic) NSAttributedString *warningText;
@end
