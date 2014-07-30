//
//  UsefullMethod.h
//  Magenta
//
//  Created by Allan on 7/20/11.
//  Copyright 2011 Aides. All rights reserved.
//
//////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <stdarg.h>

#import "UIImage+Utils.h"
#import "NSDictionary+Utils.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationItem+Utils.h"
#import "NSDate+String.h"
#import "NSString+Additions.h"
#import "FrameAccessor.h"
#import "UINavigationController+Rotate.h"

static inline CGFloat width(UIView *view) { return view.frame.size.width; }
static inline CGFloat height(UIView *view) { return view.frame.size.height; }
static inline int ScreenHeight(){ return [UIScreen mainScreen].bounds.size.height; }
static inline int ScreenWidth(){ return [UIScreen mainScreen].bounds.size.width; }

static inline NSString * TimeStamp() {return [NSString stringWithFormat:@"%f",[[NSDate new] timeIntervalSince1970] * 1000];}

@interface Utils : NSObject

//+ (void)say:(NSString*)title withMessage:(id)formatstring,...;
//+ (void)say:(NSString*)title block:(BOOL)b withMessage:(id)formatstring,...;
//+ (void)say: (id)formatstring,...;
//+ (BOOL)ask: (id)formatstring,...;
//+ (BOOL)ask:(NSString*)title withMessage:(id)formatstring,...;
//
//+(NSString*)descriptionForArray:(NSArray*)array;
//+(UIImage *)rotateImageUIImage:(UIImage*)image;
//+(UIImage *)resizeImage:(UIImage *)image;

+ (void)addLocalNotificationWithMessage:(NSString*)message;

+ (void)runBlock:(void (^)(void))block afterDelay:(NSTimeInterval)interval;
+ (void)runBlock:(void (^)(NSTimer* timer))block every:(NSTimeInterval)every;

+ (bool)eraseTemporaryFiles;

+ (NSURL*)serverURLWithComplement:(NSString*)sComplement getValues:(NSDictionary*)getValues;
+ (NSURL*)serverURLWithScheme:(NSString*)sScheme host:(NSString*)sHost path:(NSString*)sPath getValues:(NSDictionary*)getValues;


@end