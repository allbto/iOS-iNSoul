//
//  ConversationsViewController.h
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

@class User;
@class NSFNetSoul;
@class ChatViewController;

@interface ConversationsViewController : UITableViewController
<UIAlertViewDelegate>
{
    NSMutableArray* _lConversations;
    
    UISwitch*       _statusSwitch;
    UILabel*        _statusLabel;
    
    User*           _user;
}

@property (nonatomic, retain) User*         user;
@property (nonatomic, retain) NSFNetSoul*   netSoulConnection;
@property (nonatomic, assign) NSInteger     newMessages;

@property (nonatomic, readonly) ChatViewController* currentChatView;

- (void)setStatus:(NSString*)status;
- (void)setSwitchOn:(BOOL)on;

- (void)receivedMessage:(NSString*)message from:(NSString*)login;
- (void)userStartTyping:(NSString*)login;
- (void)userStopTyping:(NSString*)login;
- (void)userChangedState:(int)state from:(NSString *)login;
- (void)userInfoChanged:(int)state host:(NSString *)host loginSince:(NSString *)since workstation:(NSString *)workstation location:(NSString *)location userdata:(NSString *)userdate from:(NSString *)login;

@end
