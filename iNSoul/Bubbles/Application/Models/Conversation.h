//
//  Conversation.h
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Messages;
@class User;

@interface Conversation : NSObject
{
    NSMutableArray*     _lMessages;
}

@property (nonatomic, retain) Messages*          lastMessage;
@property (nonatomic, readonly) NSMutableArray* messages;
@property (nonatomic, retain) User*             receiver;
@property (nonatomic, assign) User*             sender;
@property (nonatomic, retain) NSString*         title;
@property (nonatomic, assign) NSInteger         newMessages;

- (void)addMessage:(Messages *)value;
- (void)addMessageWithText:(NSString *)value;
- (void)removeMessage:(Messages *)value;
- (void)removeMessageAtIndex:(NSUInteger)nPos;
- (void)removeMessageWithID:(NSInteger)nID;

- (void)addImageToConversationCell:(UITableViewCell*)cell onTableView:(UITableView*)tableView;

@end
