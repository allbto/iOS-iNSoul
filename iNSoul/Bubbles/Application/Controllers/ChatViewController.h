//
//  ChatViewController.h
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "Conversation.h"
#import "NSFNetSoul.h"
#import "ChatInput.h"

@interface ChatViewController : GAITrackedViewController
<UICollectionViewDataSource, UICollectionViewDelegate, ChatInputDelegate>

// -- Public methods -- //

/*!
 Reload the wall of messages
 */
- (void)reloadData;

// -- Properties -- //

@property (nonatomic, retain) Conversation*     conversation;
@property (nonatomic, retain) NSFNetSoul*       netSoulConnection;
@property (nonatomic, assign) BOOL              isTyping;

@end
