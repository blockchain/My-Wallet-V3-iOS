//
//  Invitation.m
//  Blockchain
//
//  Created by Kevin Wu on 12/2/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "Invitation.h"

@implementation Invitation

- (id)initWithIdentifier:(NSString *)identifier sharedInfo:(NSDictionary *)sharedInfo
{
    if (self = [super init]) {
        _identifier = identifier;
        _sharedInfo = sharedInfo;
    }
    return self;
}


@end
