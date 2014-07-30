//
//  ConversationsViewController.m
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import "ConversationsViewController.h"
#import "ChatViewController.h"
#import "Conversation.h"
#import "Messages.h"
#import "User.h"

#import "NSDate+String.h"

#import "NSFNetSoul.h"

@interface ConversationsViewController ()

- (void)configureCell:(UITableViewCell *)cell atPos:(NSInteger)nPos;
- (void)newConversationAction:(id)sender;

@end

@implementation ConversationsViewController

#pragma mark - NSObject

- (id)init
{
    if ((self = [super init]))
    {
        _lConversations = [[NSMutableArray alloc] init];
        _user = [[User alloc] init];
        _currentChatView = nil;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        self.title = NSLocalizedString(@"Messages", nil);
    }
    return self;
}

- (void)dealloc
{
    [_lConversations release];
    _lConversations = nil;
    
    [_user dealloc];
    _user = nil;
    
    [_statusLabel dealloc];
    [_statusSwitch dealloc];
    
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidUnload {
    [super viewDidUnload];
    // Leave managedObjectContext since it's not recreated in viewDidLoad.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Creating the status view with switch and label
    UIView*     statusView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)] autorelease];
    UIView*     statusViewLimit = [[[UIView alloc] initWithFrame:CGRectMake(0, 48, self.tableView.frame.size.width, 2)] autorelease];
    statusViewLimit.backgroundColor = [UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1];
    _statusSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 10, 79, 27)];
    _statusSwitch.on = YES;
    [_statusSwitch addTarget:self action:@selector(connectionChangeAction:) forControlEvents:UIControlEventValueChanged];
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, self.tableView.frame.size.width - 90, 50)];
    _statusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    _statusLabel.text = @"Status : Autentification success";

    statusView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    statusViewLimit.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [statusView addSubview:_statusSwitch];
    [statusView addSubview:_statusLabel];
    [statusView addSubview:statusViewLimit];
    self.tableView.tableHeaderView = statusView;
    
    // Create edit button in upper left & compose button in upper right.
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self action:@selector(newConversationAction:)];
    self.navigationItem.rightBarButtonItem = composeButton;
    [composeButton release];
    
    // Adding contacts from the core data
    NSMutableArray* contacts = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"userContact"];
    for (NSString* contact in contacts) {
        [self addConversationWithLogin:contact addToFav:NO];
    }
    [self.netSoulConnection setUserList:contacts];
    [self.netSoulConnection setWatchLogList:contacts];
    
    [self.tableView reloadData];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (IS_IPHONE)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    NSLog(@"Rotate to : %d", toInterfaceOrientation);
    if (IS_IPHONE) return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    else
        return YES;
}

- (BOOL)shouldAutorotate
{
    return IS_IPAD;
}

- (void)viewWillAppear:(BOOL)animated
{
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName
           value:@"ConversationViewController"];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
    
    //
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    _currentChatView = nil;
}

#pragma mark - ConversationsViewController

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] >= 3 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;

    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    bool flag = NO;
    
    for (Conversation* conv in _lConversations) {
        if ([conv.title isEqualToString:inputText])
            flag = YES;
    }
    
    if (!flag)
    {
        [self addConversationWithLogin:inputText addToFav:YES];
        [self.tableView reloadData];
    }
}

- (void)newConversationAction:(id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Add contact :"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Continue", nil];
    
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message show];
    [message release];
}

- (void)configureCell:(UITableViewCell *)cell atPos:(NSInteger)nPos
{
    Conversation *conversation = [_lConversations objectAtIndex:nPos]; 
    cell.textLabel.text = conversation.title;
    
    UIImage *indicatorImage = [UIImage imageNamed:@"newMessages.png"];
    UIImageView* indicatorView = [[[UIImageView alloc] initWithImage:indicatorImage] autorelease];
    indicatorView.hidden = !(conversation.newMessages > 0);
    cell.accessoryView = indicatorView;
    
    [conversation addImageToConversationCell:cell onTableView:self.tableView];
    cell.imageView.alpha = (conversation.receiver.state == E_STATE_OFFLINE ? 0.5 : 1);
    
    NSString* sDetail = @"";
    if (conversation.lastMessage)
    {
        if (conversation.lastMessage.type == MessageSent)
            sDetail = @"Me : ";
        cell.detailTextLabel.text = [sDetail stringByAppendingString:conversation.lastMessage.text];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lConversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
    }

    return cell;
}

- (void)tableView:(UITableView*)t willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:cell atPos:indexPath.row];    
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete contact from favorites
        NSMutableArray* contacts = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"userContact"];
        
        for (NSString* contact in contacts) {
            if ([contact isEqualToString:[[_lConversations objectAtIndex:indexPath.row] title]])
                [contacts removeObject:contact];
        }
        [[NSUserDefaults standardUserDefaults] setObject:contacts forKey:@"userContact"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.netSoulConnection setUserList:contacts];
        [self.netSoulConnection setWatchLogList:contacts];

        // Delete conversation
        [_lConversations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Conversation*       conversation = [_lConversations objectAtIndex:indexPath.row];
    
    if (!conversation/* || conversation.receiver.state == E_STATE_OFFLINE*/) return;
    
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    
    chatViewController.conversation = conversation;
    self.newMessages -= conversation.newMessages;
    conversation.newMessages = 0;
    chatViewController.netSoulConnection = self.netSoulConnection;
    _currentChatView = chatViewController;
    [self.navigationController pushViewController:chatViewController animated:YES];
    [chatViewController release];
}

#pragma mark - Netsoul Protocol

- (void)receivedMessage:(NSString*)message from:(NSString*)login
{
    Conversation*   conv = nil;
    
    for (Conversation* conversation in _lConversations)
    {
        if (conversation.title && [conversation.title isEqualToString:login])
            conv = conversation;    
    }
    if (!conv)
    {
        conv = [self addConversationWithLogin:login addToFav:YES];
    }
    
    Messages* newMessage = [[Messages alloc] initWithText:message];
    newMessage.sentDate = [NSDate date];
    newMessage.hidden = NO;
    newMessage.send = YES;
    newMessage.type = MessageReceived;
    
    [conv addMessage:newMessage];
    
    if (_currentChatView && _currentChatView.conversation == conv)
    {
        [_currentChatView reloadData];
        [self userStopTyping:login];
    }
    else
    {
        self.newMessages += 1;
        conv.newMessages += 1;
    }
    [self.tableView reloadData];
}

- (void)userStartTyping:(NSString*)login
{
    if (!_currentChatView || (_currentChatView && ![_currentChatView.conversation.title isEqualToString:login])) return;
    
    _currentChatView.isTyping = YES;
}

- (void)userStopTyping:(NSString*)login
{
    if (!_currentChatView || (_currentChatView && ![_currentChatView.conversation.title isEqualToString:login])) return;
    
    _currentChatView.isTyping = NO;
}

- (void)userChangedState:(int)state from:(NSString *)login
{
    Conversation*   conv = nil;
    
    if ((conv = [self conversationWithLogin:login]))
    {
        conv.receiver.state = state;
        [self.tableView reloadData];
    }
}

- (void) userInfoChanged: (int) state
					host: (NSString *) host
			  loginSince: (NSString *) since
			 workstation: (NSString *) workstation
				location: (NSString *) location
				userdata: (NSString *) userdate
					from: (NSString *) login
{
    Conversation*   conv = nil;

    if ((conv = [self conversationWithLogin:login]))
    {
        conv.receiver.state = state;
        conv.receiver.host = host;
        conv.receiver.since = since;
        conv.receiver.workstation = workstation;
        conv.receiver.location = location;
        conv.receiver.userdate = userdate;
    }
}

#pragma mark - Setter/Getter

- (void)setNewMessages:(NSInteger)newMessages
{
    _newMessages = newMessages;
    
    if (_newMessages > 0)
    {
        self.title = [@"Messages" stringByAppendingFormat:@" (%ld)", (long)_newMessages];
    }
    else self.title = @"Messages";
}

#pragma mark - Utilities

- (IBAction)connectionChangeAction:(id)sender
{
    if (_statusSwitch.on)
    {
        [_netSoulConnection connect];
    }
    else
    {
        [_netSoulConnection disconnect];
    }
}

- (void)setSwitchOn:(BOOL)on
{
    [_statusSwitch setOn:on animated:YES];
}

- (void)setStatus:(NSString *)status
{
    if (_statusLabel)
    {
        _statusLabel.text = [@"Status : " stringByAppendingString:status];
    }
}

- (Conversation*)conversationWithLogin:(NSString*)login
{
    Conversation*   conv = nil;
    for (Conversation* conversation in _lConversations)
    {
        if (conversation.title && [conversation.title isEqualToString:login])
            conv = conversation;
    }
    return conv;
}

- (Conversation*)addConversationWithLogin:(NSString*)login addToFav:(BOOL)add
{
    if (add)
    {
        NSMutableArray* contacts = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"userContact"];
        
        [contacts addObject:login];
        [[NSUserDefaults standardUserDefaults] setObject:contacts forKey:@"userContact"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.netSoulConnection setUserList:contacts];
        [self.netSoulConnection setWatchLogList:contacts];
    }
    
    User*           newUser = [User user];
    Conversation*   hConversation = [[[Conversation alloc] init] autorelease];

    newUser.login = login;
    hConversation.receiver = newUser;
    hConversation.title = login;
    [_lConversations addObject:hConversation];
    return hConversation;
}

@end
