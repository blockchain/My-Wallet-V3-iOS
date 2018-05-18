//
//  GraphTimeFrame.h
//  Blockchain
//
//  Created by kevinwu on 10/4/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Assets.h"

typedef enum {
    TimeFrameAll,
    TimeFrameYear,
    TimeFrameMonth,
    TimeFrameWeek,
    TimeFrameDay
} TimeFrame;

@interface GraphTimeFrame : NSObject
@property (nonatomic, readonly) TimeFrame timeFrame;
@property (nonatomic, readonly) NSString *scale;
@property (nonatomic, readonly) NSInteger startDate;
@property (nonatomic, readonly) NSString *dateFormat;

+ (GraphTimeFrame *)timeFrameAll:(LegacyAssetType)assetType;
+ (GraphTimeFrame *)timeFrameYear;
+ (GraphTimeFrame *)timeFrameMonth;
+ (GraphTimeFrame *)timeFrameWeek;
+ (GraphTimeFrame *)timeFrameDay;

- (NSInteger)startDateBitcoin;
- (NSInteger)startDateEther;
- (NSInteger)startDateBitcoinCash;
@end
