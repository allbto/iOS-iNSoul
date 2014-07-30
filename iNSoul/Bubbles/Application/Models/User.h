//
//  User.h
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, assign) NSInteger     state;

@property (nonatomic, retain) NSString*     login;
@property (nonatomic, retain) NSString*     host;
@property (nonatomic, retain) NSString*     since;
@property (nonatomic, retain) NSString*     workstation;
@property (nonatomic, retain) NSString*     location;
@property (nonatomic, retain) NSString*     userdate;

@property (nonatomic, retain) UIImage*      avatar;

+ (User*)user;

@end
