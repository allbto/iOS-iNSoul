//
//  NSFNetSoul.m
//
//  Created by Allan on Mon Oct 15 2012.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>
#include <errno.h>

#import "NSFProtocol.h"
#import "NSFNetSoul.h"

@interface NSFNetSoul (Private)

- (void) handleUserCmd: (NSString *) aMessage withHeader: (NSString *) head;
- (int) stateOf: (NSString *) state;

@end

@implementation NSFNetSoul

- (id) init
{
    if (self = [super init])
    {
		_login = [[NSString alloc] initWithString: @"login"];
		_pass = [[NSString alloc] initWithString: @"pass"];
		_location = [[NSString alloc] initWithString: @"iOS"];
		_userData = [[NSString alloc] initWithString: @"Behold the mighty iNSoul son of iNtra !"];
        _repConnected = FALSE;
		_connected = FALSE;
		_state = FALSE;
		_connection = [[Network alloc] init];
        _connection.delegate = self;
    }
    
    return self;
}

- (void) dealloc
{
    [_login release];
    [_pass release];
    [_location release];
    [_userData release];
    [_connection release];
    
    [super dealloc];
}

- (BOOL) connect
{
    return [_connection connectWithHostName:_server port:[_port integerValue] timeout:2];
}

- (void) authenticate
{
    NSString    *cmd = [NSFProtocol commandForStartingAuthentification];
    NETSOUL_SEND(cmd);
    [_connection send:cmd];
}

- (BOOL) disconnect
{
    _repConnected = NO;
    _connected = NO;
    if (!_connection.connected)
		return FALSE;

    NSString	    *rq = [NSFProtocol commandForExit];
    NETSOUL_SEND(rq);
    [_connection send:rq];
    [_connection close];
    return TRUE;
}

#pragma mark -
#pragma mark Actions

- (bool) sendMessage: (NSString *) aMsg to: (NSString *) aLogin
{
    if (_connected)
    {
		if ([aLogin rangeOfString: @"*"].location != NSNotFound)
		{
			[_controller errorOccured: @"Msg all not authorized"];
            NSLog(@"Msg all not authorized");
			return false;
		}
		
		NSRange     range;
		
		range.length = [aMsg length] > 256 ? 256 : [aMsg length];
		range.location = 0;
		
		while (YES)
		{
			NSString    *tmpMsg = [aMsg substringWithRange: range];
			NSString    *reste = [aMsg substringFromIndex: range.location + range.length];
			NSString    *cmd = [NSFProtocol commandForSendingMessage: tmpMsg
																  to: aLogin];
			
			if ([tmpMsg length] == 0)
				break;
			
			range.length = [reste length] > 256 ? 256 : [reste length];
			range.location += [tmpMsg length];
			
			NETSOUL_SEND(cmd);
			[_connection send:cmd];
		}
    }
    else
    {
        NSLog(@"Not connected");
        return false;
		[_controller errorOccured: @"Not Connected"];
    }
    return true;
}

- (void) sendTypingEvent: (BOOL) typing to: (NSString *) login_e
{
    NSString	*rq;
    
    if (typing)
		rq = [NSFProtocol commandForStartingTyping: login_e];
    else
		rq = [NSFProtocol commandForStoppingTyping: login_e];
    NETSOUL_SEND(rq);
    [_connection send:rq];
}

- (void) setAwayState
{
    NSString    *rq = [NSFProtocol commandForSettingState: @"away"];
	
    NETSOUL_SEND(rq);
    _state = FALSE;
    [_connection send:rq];
}

- (void) setActifState
{
    NSString    *rq = [NSFProtocol commandForSettingState: @"actif"];
    
    NETSOUL_SEND(rq);
    _state = FALSE;
    [_connection send:rq];    
}

- (void) setIdleState
{
    NSString    *rq = [NSFProtocol commandForSettingState: @"idle"];
    
    NETSOUL_SEND(rq);
    _state = FALSE;
    [_connection send:rq];
}

- (void) setUserList: (NSArray *) users
{
    NSString    *rq = [NSFProtocol commandForGettingStatusOfUsers: users];
	
    NETSOUL_SEND(rq);
    [_connection send:rq];
}

- (void) setWatchLogList: (NSArray *) users
{
    NSString    *rq = [NSFProtocol commandForWatchingLogsOfUsers: users];
    
    NETSOUL_SEND(rq);
    [_connection send:rq];
}

- (void) handleUserCmd: (NSString *) aMessage withHeader: (NSString *) head
{
    NSArray		    *header = [head componentsSeparatedByString: @":"];
    NSArray		    *body = [aMessage componentsSeparatedByString: @" "];
	
    if ([aMessage hasPrefix: @"msg "])
    {
		NSRange range = [[header objectAtIndex: 3] rangeOfString: @"@"];
		NSArray *msg = [aMessage componentsSeparatedByString: @" "];
		
		[_controller userRecieveMessage: [NSFProtocol messageByDecode: [msg objectAtIndex: 1]] from: [[header objectAtIndex: 3] substringToIndex: range.location]];
    }
    else if ([aMessage hasPrefix: @"new_mail "])
    {
		[_controller userRecieveMail: [NSFProtocol messageByDecode: [body objectAtIndex: 3]] from: [body objectAtIndex: 2]];
    }
    else if ([aMessage hasPrefix: @"login "])
    {
		NSRange range = [[header objectAtIndex: 3] rangeOfString: @"@"];
		
		[_controller userLoggedEvent: E_USER_LOGIN from: [[header objectAtIndex: 3] substringToIndex: range.location]];
    }
    else if ([aMessage hasPrefix: @"logout "])
    {
		NSRange range = [[header objectAtIndex: 3] rangeOfString: @"@"];
		
		[_controller userLoggedEvent: E_USER_LOGOUT from: [[header objectAtIndex: 3] substringToIndex: range.location]];
		
    }
    else if ([aMessage hasPrefix: @"state "])
    {
		NSRange range = [[header objectAtIndex: 3] rangeOfString: @"@"];
		NSArray *msg = [aMessage componentsSeparatedByString: @" "];
		
		[_controller userChangedState: [self stateOf: [[[msg objectAtIndex: 1] componentsSeparatedByString: @":"] objectAtIndex: 0]] from: [[header objectAtIndex: 3] substringToIndex: range.location]];
    }
    else if ([aMessage hasPrefix: @"dotnetSoul_UserTyping"])
    {
		NSRange range = [[header objectAtIndex: 3] rangeOfString: @"@"];
		//NSArray *msg = [aMessage componentsSeparatedByString: @" "];
		
		[_controller userTypingEvent: E_TYPING_START from: [[header objectAtIndex: 3] substringToIndex: range.location]];
    }
    else if ([aMessage hasPrefix: @"dotnetSoul_UserCancelledTyping"])
    {
		NSRange range = [[header objectAtIndex: 3] rangeOfString: @"@"];
		//NSArray *msg = [aMessage componentsSeparatedByString: @" "];
		
		[_controller userTypingEvent: E_TYPING_STOP from: [[header objectAtIndex: 3] substringToIndex: range.location]];
    }
    else
		NETSOUL_SEND(@"Unkown User Command");
}

- (int) stateOf: (NSString *) st
{
    if ([st isEqualToString: @"actif"])
		return E_STATE_ONLINE;
    
    if ([st isEqualToString: @"idle"])
		return E_STATE_LOCK;
    
    if ([st isEqualToString: @"away"])
		return E_STATE_AWAY;
    
    if ([st isEqualToString: @"server"])
		return E_STATE_SERVER;
    
    return E_STATE_OFFLINE;
}

#pragma mark - Network Protocols

- (void)networkReceiveMessage:(NSString *)str
{
    if (!str)
    {
        NETSOUL_RECEIVED(@"MESSAGE (null)");
        [_controller disconnectedEvent];
        return;
    }
    
    NSMutableArray  *answers = [NSMutableArray arrayWithArray: [str componentsSeparatedByString: @"\n"]];
    NSString	    *message;
    
    /*if ([str rangeOfString: @"\n" options: NSBackwardsSearch].location != [str length])
     {
     [answers removeLastObject];
     }*/
	
    NSEnumerator    *eAnswer = [answers objectEnumerator];
    
    while (message = [eAnswer nextObject])
    {
		NSString    *command = [[message componentsSeparatedByString: @" "] objectAtIndex: 0];
		
		if ([message length] == 0 || [command length] == 0)
		{
			break;
		}
		
		NETSOUL_RECEIVED(message);
		// If authentification was required
		if ([command isEqualToString: @"salut"])
		{
			NSString    *rq = [NSFProtocol commandForSendingUserAuthentification: message
																		   login: _login
																			pass: _pass
																		location: _location
																		userData: _userData];
			[self authenticate];
            NETSOUL_SEND(rq);
			[_connection send:rq];
		}
		// Answer to ping
		else if ([command isEqualToString: @"ping"])
		{
			NSString    *rq = [NSFProtocol commandForPing];
			
			[_connection send:rq];
		}
		// User Command
		else if ([command isEqualToString: @"user_cmd"])
		{
			NSRange     range = [message rangeOfString: @" | "];
			NSString    *head = [message substringToIndex: range.location - 1];
			NSString    *msg = [message substringFromIndex: range.location + 3];
			
			[self handleUserCmd: msg withHeader: head];
		}
		// Answer of the authentification
		else if ([command isEqualToString: @"rep"])
		{
            if ([message rangeOfString: @"-- cmd end"].location != NSNotFound)
            {
                if (_repConnected)
                    _connected = YES;
                else
                    _repConnected = YES;
            }
            else if ([message rangeOfString: @"-- no such cmd"].location == NSNotFound)
            {
                _repConnected = NO;
                _connected = NO;
            }
            NSLog(@"Notification authentification result : %@", message);
            if ((_repConnected && _connected) || (!_repConnected && !_connected))
                [_controller notifyAuthentificationResult:_connected];
		}
		// If list users
		else
		{
			NSArray		    *answer = [message componentsSeparatedByString: @" "];

			if ([answer count] < 12)
			{
				NETSOUL_SEND(@"Bad Update");
                return;
			}
			
			NSArray		    *stateA = [[answer objectAtIndex: 10] componentsSeparatedByString: @":"];
			
			[_controller userInfoChanged: [self stateOf: [stateA objectAtIndex: 0]]
									host: [answer objectAtIndex: 2]
							  loginSince: [answer objectAtIndex: 3]
							 workstation: [answer objectAtIndex: 7]
								location: [NSFProtocol messageByDecode: [answer objectAtIndex: 8]]
								userdata: [NSFProtocol messageByDecode: [answer objectAtIndex: 11]]
									from: [answer objectAtIndex: 1]];
		}
    }
}

- (void)networkConnectionEnd
{
    [_controller disconnectedEvent];
}

@end