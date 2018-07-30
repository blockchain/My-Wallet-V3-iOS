//
//  BCConfirmPaymentViewModel.h
//  Blockchain
//
//  Created by kevinwu on 8/29/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCConfirmPaymentViewModel : NSObject

- (id)initWithFrom:(NSString *)from
                  To:(NSString *)to
              amount:(uint64_t)amount
                 fee:(uint64_t)fee
               total:(uint64_t)total
               surge:(BOOL)surgePresent;

- (id)initWithTo:(NSString *)to
       ethAmount:(NSString *)ethAmount
          ethFee:(NSString *)ethFee
        ethTotal:(NSString *)ethTotal
      fiatAmount:(NSString *)fiatAmount
         fiatFee:(NSString *)fiatFee
       fiatTotal:(NSString *)fiatTotal;

- (id)initWithFrom:(NSString *)from
                To:(NSString *)to
            bchAmount:(uint64_t)amount
               fee:(uint64_t)fee
             total:(uint64_t)total
             surge:(BOOL)surgePresent;

@property (nonatomic) NSString *from;
@property (nonatomic) NSString *to;
@property (nonatomic) NSString *totalAmountText;
@property (nonatomic) NSString *fiatTotalAmountText;
@property (nonatomic) NSString *cryptoWithFiatAmountText;
@property (nonatomic) NSString *amountWithFiatFeeText;
@property (nonatomic) NSString *noteText;
@property (nonatomic) NSString *buttonTitle;
@property (nonatomic) BOOL showDescription;
@property (nonatomic) BOOL surgeIsOccurring;
@property (nonatomic) NSAttributedString *warningText;
@end
