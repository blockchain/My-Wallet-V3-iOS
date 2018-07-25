//
//  GraphTimeFrame.m
//  Blockchain
//
//  Created by kevinwu on 10/4/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "GraphTimeFrame.h"
@interface GraphTimeFrame () <NSCoding>
@property (nonatomic, readwrite) TimeFrame timeFrame;
@property (nonatomic, readwrite) NSString *scale;
@property (nonatomic, readwrite) NSInteger startDate;
@property (nonatomic, readwrite) NSString *dateFormat;

#define ENTRY_TIME_BTC 1282089600
#define ENTRY_TIME_ETH 1438992000
#define ENTRY_TIME_BCH 1500854400

#define GRAPH_TIME_FRAME_DAY @"1day"
#define GRAPH_TIME_FRAME_WEEK @"1weeks"
#define GRAPH_TIME_FRAME_MONTH @"4weeks"
#define GRAPH_TIME_FRAME_YEAR @"52weeks"
#define GRAPH_TIME_FRAME_ALL @"all"

#define TIME_INTERVAL_DAY 86400.0
#define TIME_INTERVAL_WEEK 604800.0
#define TIME_INTERVAL_MONTH 2592000.0
#define TIME_INTERVAL_YEAR 31536000.0

#define STRING_SCALE_FIVE_DAYS @"432000"
#define STRING_SCALE_ONE_DAY @"86400"
#define STRING_SCALE_TWO_HOURS @"7200"
#define STRING_SCALE_ONE_HOUR @"3600"
#define STRING_SCALE_FIFTEEN_MINUTES @"900"

#define CODER_KEY_TIME_FRAME @"timeFrame"
#define CODER_KEY_START_DATE @"startDate"
#define CODER_KEY_SCALE @"scale"
#define CODER_KEY_DATE_FORMAT @"dateFormat"

@end

@implementation GraphTimeFrame

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithInteger:self.timeFrame] forKey:CODER_KEY_TIME_FRAME];
    [coder encodeObject:[NSNumber numberWithInteger:self.startDate] forKey:CODER_KEY_START_DATE];
    [coder encodeObject:self.scale forKey:CODER_KEY_SCALE];
    [coder encodeObject:self.dateFormat forKey:CODER_KEY_DATE_FORMAT];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.timeFrame = (TimeFrame)[[coder decodeObjectForKey:CODER_KEY_TIME_FRAME] integerValue];
        self.startDate = [[coder decodeObjectForKey:CODER_KEY_START_DATE] integerValue];
        self.scale = [coder decodeObjectForKey:CODER_KEY_SCALE];
        self.dateFormat = [coder decodeObjectForKey:CODER_KEY_DATE_FORMAT];
    }
    return self;
}

+ (GraphTimeFrame *)timeFrameAll:(LegacyAssetType)assetType
{
    GraphTimeFrame *timeFrame = [GraphTimeFrame new];
    timeFrame.timeFrame = TimeFrameAll;
    timeFrame.scale = STRING_SCALE_FIVE_DAYS;
    if (assetType == LegacyAssetTypeBitcoin) {
        timeFrame.startDate = ENTRY_TIME_BTC;
    } else if (assetType == LegacyAssetTypeEther) {
        timeFrame.startDate = ENTRY_TIME_ETH;
    }
    timeFrame.dateFormat = @"YYYY";
    return timeFrame;
}

+ (GraphTimeFrame *)timeFrameDay
{
    GraphTimeFrame *timeFrame = [GraphTimeFrame new];
    timeFrame.timeFrame = TimeFrameDay;
    timeFrame.scale = STRING_SCALE_FIFTEEN_MINUTES;
    timeFrame.startDate = (NSInteger)fabs([[[NSDate date] dateByAddingTimeInterval:-TIME_INTERVAL_DAY] timeIntervalSince1970]);
    timeFrame.dateFormat = @"HH:mm";
    return timeFrame;
}

+ (GraphTimeFrame *)timeFrameWeek
{
    GraphTimeFrame *timeFrame = [GraphTimeFrame new];
    timeFrame.timeFrame = TimeFrameWeek;
    timeFrame.scale = STRING_SCALE_ONE_HOUR;
    timeFrame.startDate = (NSInteger)fabs([[[NSDate date] dateByAddingTimeInterval:-TIME_INTERVAL_WEEK] timeIntervalSince1970]);
    timeFrame.dateFormat = @"dd.MMM";
    return timeFrame;
}

+ (GraphTimeFrame *)timeFrameYear
{
    GraphTimeFrame *timeFrame = [GraphTimeFrame new];
    timeFrame.timeFrame = TimeFrameYear;
    timeFrame.scale = STRING_SCALE_ONE_DAY;
    timeFrame.startDate = (NSInteger)fabs([[[NSDate date] dateByAddingTimeInterval:-TIME_INTERVAL_YEAR] timeIntervalSince1970]);
    timeFrame.dateFormat = @"MMM yy";
    return timeFrame;
}

+ (GraphTimeFrame *)timeFrameMonth
{
    GraphTimeFrame *timeFrame = [GraphTimeFrame new];
    timeFrame.timeFrame = TimeFrameMonth;
    timeFrame.scale = STRING_SCALE_TWO_HOURS;
    timeFrame.startDate = (NSInteger)fabs([[[NSDate date] dateByAddingTimeInterval:-TIME_INTERVAL_MONTH] timeIntervalSince1970]);
    timeFrame.dateFormat = @"dd.MMM";
    return timeFrame;
}

- (NSInteger)startDateEther
{
    return ENTRY_TIME_ETH;
}

- (NSInteger)startDateBitcoin
{
    return ENTRY_TIME_BTC;
}

- (NSInteger)startDateBitcoinCash
{
    return ENTRY_TIME_BCH;
}

@end
