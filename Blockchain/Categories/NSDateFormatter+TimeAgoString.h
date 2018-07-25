//
//  NSDateFormatter+TimeAgoString.h
//  Blockchain
//
//  Created by kevinwu on 2/10/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (TimeAgoString)
+ (NSString *)timeAgoStringFromDate:(NSDate *)date;
@end
