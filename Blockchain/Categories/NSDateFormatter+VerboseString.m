//
//  NSDateFormatter+VerboseString.m
//  Blockchain
//
//  Created by kevinwu on 12/11/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "NSDateFormatter+VerboseString.h"

@implementation NSDateFormatter (VerboseString)

+ (NSString *)verboseStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setAMSymbol:@"am"];
    [dateFormatter setPMSymbol:@"pm"];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy @ h:mmaa"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

@end
