//
//  NSDictionary+Utils.m
//  IGS Portal
//
//  Created by Allan Barbato on 8/10/12.
//  Copyright (c) 2012 BSOM. All rights reserved.
//

#import "NSDictionary+Utils.h"

@implementation NSDictionary (Utils)

- (NSString*)joinedByString:(NSString*)sJoin betweenKeyAndValue:(NSString*)sBetween
{
    NSMutableString*    resultString = [NSMutableString string];
    
    for (NSString* key in [self allKeys])
    {
        if ([resultString length] > 0)
            [resultString appendString:sJoin];

        [resultString appendFormat:@"%@%@%@", key, sBetween, [self objectForKey:key]];
    }
    return resultString;
}

@end
