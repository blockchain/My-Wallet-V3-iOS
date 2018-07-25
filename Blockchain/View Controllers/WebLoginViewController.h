//
//  WebLoginViewController.h
//  Blockchain
//
//  Created by Justin on 2/28/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wallet.h"

@interface WebLoginViewController : UIViewController<WalletDelegate> {
    IBOutlet UIImageView *qrCodeMainImageView;
}

@end
