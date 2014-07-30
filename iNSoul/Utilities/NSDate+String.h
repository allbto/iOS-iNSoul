//
//  NSDate+String.h
//  Breeze
//
//  Created by Allan BARBATO on 7/28/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (String)

+ (NSDate*)dateWithString:(NSString*)sDate format:(NSString*)sFormat;
+ (NSDate*)dateWithString:(NSString*)sDate;
- (NSString*)stringValueWithFormat:(NSString*)sFormat;
- (NSString*)stringValue;
- (NSString *)relativeStringValue;

- (NSDate*)addTimeInSeconds:(CGFloat)seconds minutes:(CGFloat)minutes hours:(CGFloat)hours days:(CGFloat)days years:(CGFloat)years;
- (NSDate*)removeTimeInSeconds:(CGFloat)seconds minutes:(CGFloat)minutes hours:(CGFloat)hours days:(CGFloat)days years:(CGFloat)years;

@end
