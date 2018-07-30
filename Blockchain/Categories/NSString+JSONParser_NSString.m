//
//  NSString+JSONParser_NSString.m
//  Blockchain
//
//  Created by Ben Reeves on 24/07/2014.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "NSString+JSONParser_NSString.h"

@implementation NSString (JSONParser_NSString)

-(id)getJSONObject {
    NSError * error = nil;
    
    id dict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingAllowFragments error: &error];
    
    if (error != NULL) {
        DLog(@"Error Parsing JSON %@", error);
        return nil;
    }
    
    return dict;
}


@end
