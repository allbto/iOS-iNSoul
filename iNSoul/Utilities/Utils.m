//
//  UsefullMethod.m
//  Magenta
//
//  Created by Allan on 7/20/11.
//  Copyright 2011 Aides. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (bool)eraseTemporaryFiles
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *contentOfDir = [manager contentsOfDirectoryAtPath:NSHomeDirectory() error:NULL];
    
    for (NSString *filename in contentOfDir)
    {
        /*if ([filename isEqualToString:@"Documents"])
         {
         NSArray *contentOfDoc = [manager contentsOfDirectoryAtPath:DeviceDirectory(@"Documents") error:NULL];
         for (NSString *filenameDoc in contentOfDoc)
         [manager removeItemAtPath:[DeviceDirectory(@"Documents") stringByAppendingFormat:@"/%@", filenameDoc] error:NULL];
         }
         
         else */if ([filename isEqualToString:@"tmp"])
         {
             NSArray *contentOfTmp = [manager contentsOfDirectoryAtPath:HomeDirectory(@"/tmp") error:NULL];
             
             if (!contentOfTmp) return NO;
             
             for (NSString *filenameDoc in contentOfTmp)
                 [manager removeItemAtPath:[HomeDirectory(@"/tmp") stringByAppendingFormat:@"/%@", filenameDoc] error:NULL];
             return YES;
         }
    }
    return NO;
}

+ (void)addLocalNotificationWithMessage:(NSString*)message
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = message;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [localNotification release];
}


- (void)toRunBlock:(void (^)(void))block
{
    block();
}

+ (void)runBlock:(void (^)(void))block afterDelay:(NSTimeInterval)interval
{
    Utils* utils = [[[Utils alloc] init] autorelease];
    void (^block_)() = [[block copy] autorelease];
    
    [utils performSelector:@selector(toRunBlock:) withObject:block_ afterDelay:interval];
}

- (void)toRunBlockMultipleTime:(NSTimer *)timer
{
    void (^block)(NSTimer* timer) = [[timer userInfo] objectForKey:@"block"];
    
    block(timer);
}

+ (void)runBlock:(void (^)(NSTimer* timer))block every:(NSTimeInterval)every
{
    Utils* utils = [[[Utils alloc] init] autorelease];
    void (^block_)(NSTimer* timer) = [[block copy] autorelease];
    
    [NSTimer scheduledTimerWithTimeInterval:every target:utils selector:@selector(toRunBlockMultipleTime:) userInfo:@{ @"block" : block_ } repeats:YES];
}

+ (NSURL*)serverURLWithComplement:(NSString*)sComplement getValues:(NSDictionary*)getValues
{
    NSMutableString*   sURL = [NSMutableString string];
    
    [sURL appendString:ServerAddress];
    [sURL appendFormat:@"%@", sComplement];
    [sURL appendString:@"?"];
    [sURL appendString:[getValues joinedByString:@"&" betweenKeyAndValue:@"="]];
    
    return [NSURL URLWithString:[sURL stringByAddingPercentEscapesUsingEncoding:
                                 NSASCIIStringEncoding]];
}

+ (NSURL*)serverURLWithScheme:(NSString*)sScheme host:(NSString*)sHost path:(NSString*)sPath getValues:(NSDictionary*)getValues
{
    NSString*   sArgs = nil;
    
    sArgs = [sPath stringByAppendingFormat:@"?%@", [getValues joinedByString:@"&" betweenKeyAndValue:@"="]];
    return [[[NSURL alloc] initWithScheme:sScheme host:sHost path:sArgs] autorelease];
}

//
//  Method to make a popup with message formated
//

//+ (void)say:(NSString*)title withMessage:(id)formatstring,...
//{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertSwitch"])
//    {
//        va_list arglist;
//        va_start(arglist, formatstring);
//        id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
//        va_end(arglist);
//        [[[[UIAlertView alloc] initWithTitle:title message:statement delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
//        [statement release];
//    }
//}
//
//+ (void)say:(NSString*)title block:(BOOL)b withMessage:(id)formatstring,...
//{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertSwitch"])
//    {
//        va_list arglist;
//        va_start(arglist, formatstring);
//        id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
//        va_end(arglist);
//        if (b)
//            [ModalAlert ask:title withMessage:statement withCancel:@"OK" withButtons:nil];
//        else [[[[UIAlertView alloc] initWithTitle:title message:statement delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
//        [statement release];
//    }
//}
//
////
////  Method to make a popup with title formated
////
//
//+ (void)say: (id)formatstring,...
//{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertSwitch"])
//    {
//        va_list arglist;
//        va_start(arglist, formatstring);
//        id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
//        va_end(arglist);
//        [ModalAlert ask:statement withMessage:nil withCancel:@"OK" withButtons:nil];
//        [statement release];
//    }
//}
//
////
////  Ask a question with title formated and [Yes, No] response
////
////  Return a boolean if it's Yes or No
////
//
//+ (BOOL)ask:(id)formatstring,...
//{
//	va_list arglist;
//	va_start(arglist, formatstring);
//	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
//	va_end(arglist);
//	BOOL answer = ([ModalAlert ask:statement withMessage:nil withCancel:nil withButtons:[NSArray arrayWithObjects:kYes, kNo, nil]] == 0);
//	[statement release];
//	return answer;
//}
//
////
////  Ask a question with title formated and [Yes, No] response
////
////  Return a boolean if it's Yes or No
////
//
//+ (BOOL)ask:(NSString*)title withMessage:(id)formatstring,...
//{
//	va_list arglist;
//	va_start(arglist, formatstring);
//	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
//	va_end(arglist);
//	BOOL answer = ([ModalAlert ask:title  withMessage:statement withCancel:nil withButtons:[NSArray arrayWithObjects:kYes, kNo, nil]] == 0);
//	[statement release];
//	return answer;
//}


@end
