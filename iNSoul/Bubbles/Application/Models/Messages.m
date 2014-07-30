//
//  Message.m
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import "Messages.h"

@implementation Messages

- (id)init
{
    if ((self = [super init]))
    {
        _messageID = -1;
        _sentDate = [[NSDate alloc] init];
        self.text = @"";
        self.type = MessageSent;
        self.read = NO;
        self.send = NO;
        self.failed = NO;
        self.hidden = NO;
        self.size = nil;
        
        self.cell = nil;
    }
    return self;
}

- (id)initWithText:(NSString*)text
{
    if ((self = [super init]))
    {
        self.text = text;
    }
    return self;
}

- (void)dealloc
{
    [_sentDate release];
    self.sentDate = nil;
    
    [_text release];
    self.text = nil;
    
    [_size release];
    self.size = nil;
    
    [super dealloc];
}

@end
