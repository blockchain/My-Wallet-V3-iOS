//
//  Invitation.h
//  Blockchain
//
//  Created by Kevin Wu on 12/2/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Invitation : NSObject
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSDictionary *sharedInfo;

- (id)initWithIdentifier:(NSString *)identifier sharedInfo:(NSDictionary *)sharedInfo;

@end
