//
//  NSDateFormatter+VerboseString.h
//  Blockchain
//
//  Created by kevinwu on 12/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (VerboseString)
+ (NSString *)verboseStringFromDate:(NSDate *)date;
@end
