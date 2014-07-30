//
//  NSDate+String.m
//  Breeze
//
//  Created by Allan BARBATO on 7/28/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)

+ (NSDate*)dateWithString:(NSString*)sDate format:(NSString*)sFormat
{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:sFormat];
    [df setLocale:[NSLocale currentLocale]];
    
    NSDate *newDate = [df dateFromString:sDate];
    return newDate;
}

+ (NSDate*)dateWithString:(NSString*)sDate
{
    return [NSDate dateWithString:sDate format:@"yyyy-MM-dd HH:mm:ss"];
}

- (NSString*)stringValueWithFormat:(NSString*)sFormat
{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:sFormat];
    [df setLocale:[NSLocale currentLocale]];
    
    return [df stringFromDate:self];
}

- (NSString*)stringValue
{
    return [self stringValueWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (NSString *)relativeStringValue
{
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [self timeIntervalSinceDate:now] * -1.0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:self toDate:now options:0];
    
    NSString *relativeString;
    
    if (delta < 0) {
        relativeString = @"!n the future!";
        
    } else if (delta < 1 * MINUTE) {
        relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%ld seconds ago",(long)components.second];
        
    } else if (delta < 2 * MINUTE) {
        relativeString =  @"a minute ago";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%ld minutes ago",(long)components.minute];
        
    } else if (delta < 90 * MINUTE) {
        relativeString = @"an hour ago";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%ld hours ago",(long)components.hour];
        
    } else if (delta < 48 * HOUR) {
        relativeString = @"yesterday";
        
    } else if (delta < 30 * DAY) {
        relativeString = [NSString stringWithFormat:@"%ld days ago",(long)components.day];
        
    } else if (delta < 12 * MONTH) {
        relativeString = (components.month <= 1) ? @"one month ago" : [NSString stringWithFormat:@"%ld months ago",(long)components.month];
        
    } else {
        relativeString = (components.year <= 1) ? @"one year ago" : [NSString stringWithFormat:@"%ld years ago",(long)components.year];
        
    }
    
    return relativeString;
}

- (NSDate*)addTimeInSeconds:(CGFloat)seconds minutes:(CGFloat)minutes hours:(CGFloat)hours days:(CGFloat)days years:(CGFloat)years
{
    CGFloat timeFromDate = 0.0;
    
    timeFromDate += seconds;
    timeFromDate += 60 * minutes;
    timeFromDate += (60 * 60) * hours;
    timeFromDate += (60 * 60 * 24) * days;
    timeFromDate += (60 * 60 * 24 * 365) * years;
    
    NSDate* newDate = [[NSDate alloc] initWithTimeInterval:timeFromDate sinceDate:self];
    
    return newDate;
}

- (NSDate*)removeTimeInSeconds:(CGFloat)seconds minutes:(CGFloat)minutes hours:(CGFloat)hours days:(CGFloat)days years:(CGFloat)years
{
    CGFloat timeFromDate = 0.0;
    
    timeFromDate -= seconds;
    timeFromDate -= 60 * minutes;
    timeFromDate -= (60 * 60) * hours;
    timeFromDate -= (60 * 60 * 24) * days;
    timeFromDate -= (60 * 60 * 24 * 365) * years;
    
    NSDate* newDate = [[NSDate alloc] initWithTimeInterval:timeFromDate sinceDate:self];
    
    return newDate;
}

@end
