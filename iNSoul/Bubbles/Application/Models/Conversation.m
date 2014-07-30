//
//  Conversation.m
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import "Conversation.h"
#import "Messages.h"
#import "User.h"
#import "Utils.h"

@implementation Conversation

@synthesize lastMessage;
@synthesize messages = _lMessages;

- (id)init
{
    if ((self = [super init]))
    {
        _lMessages = [[NSMutableArray alloc] init];
        self.receiver = nil;
        self.sender = nil;
        self.lastMessage = nil;
        self.title = @"New Message";
        _newMessages = 0;
    }
    return self;
}

- (void)dealloc
{
    [_lMessages release];
    _lMessages = nil;
    self.receiver = nil;
    self.lastMessage = nil;
    self.title = nil;
    
    [super dealloc];
}

- (void)addMessageWithText:(NSString *)value
{
    Messages* hMessage = [[Messages alloc] initWithText:value];
    hMessage.read = YES;
    hMessage.send = YES;

    [_lMessages addObject:hMessage];
    self.lastMessage = [_lMessages lastObject];
    
    [hMessage release];
}

- (void)addMessage:(Messages *)value
{
    [_lMessages addObject:value];
    self.lastMessage = [_lMessages lastObject];
}

- (void)removeMessage:(Messages *)value
{
    [_lMessages removeObject:value];
    
    if ([_lMessages count] > 0)
        self.lastMessage = [_lMessages lastObject];
    else self.lastMessage = nil;
}

- (void)removeMessageAtIndex:(NSUInteger)nPos
{
    [_lMessages removeObjectAtIndex:nPos];
    
    if ([_lMessages count] > 0)
        self.lastMessage = [_lMessages lastObject];
    else self.lastMessage = nil;
}

- (void)removeMessageWithID:(NSInteger)nID
{
    for (Messages* hMessage in _lMessages)
        if (hMessage.messageID == nID)
            [_lMessages removeObject:hMessage];

    if ([_lMessages count] > 0)
        self.lastMessage = [_lMessages lastObject];
    else self.lastMessage = nil;
}

- (void)addImageToConversationCell:(UITableViewCell*)cell onTableView:(UITableView*)tableView
{
    if (!self.receiver.avatar)
    {
        cell.imageView.image = [UIImage imageNamed:@"DefaultAvatar.jpg"];
        [UIImage imageWithURL:[NSURL URLWithString:PictureForUser(self.title)]
                 receiveBlock:^(UIImage *image) {
                     self.receiver.avatar = image;
                     cell.imageView.image = image;
                     [tableView reloadData];
                 } errorBlock:^{}];
    }
}

@end
