//
//  User.m
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import "User.h"
#import "NSFProtocol.h"

@implementation User

+ (User*)user
{
    return [[[User alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.state = E_STATE_OFFLINE;
        self.login = @"";
        self.host = @"";
        self.location = @"";
        self.since = @"";
        self.workstation = @"";
        self.userdate = @"";
        self.avatar = nil;
    }
    return self;
}

- (void)dealloc
{
    self.login = nil;
    self.host = nil;
    self.location = nil;
    self.since = nil;
    self.workstation = nil;
    self.userdate = nil;
    self.avatar = nil;

    [super dealloc];
}

@end
