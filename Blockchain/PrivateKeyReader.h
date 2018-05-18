//
//  PairingCodeDelegate.h
//  Blockchain
//
//  Created by Ben Reeves on 22/07/2014.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "Wallet.h"
#import <AVFoundation/AVFoundation.h>
#import "Assets.h"

@interface PrivateKeyReader : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, copy) void (^success)(NSString*);
@property(nonatomic, copy) void (^error)(NSString*);
@property (nonatomic) BOOL acceptsPublicKeys;
@property (nonatomic) NSString *busyViewText;

- (id)initWithAssetType:(LegacyAssetType)assetType success:(void (^)(NSString*))__success error:(void (^)(NSString*))__error acceptPublicKeys:(BOOL)acceptPublicKeys busyViewText:(NSString *)text;
@end
