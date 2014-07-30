//
//  NSFProtocol.m
//  NetSoulAdiumPlugin
//
//  Created by ReeB on Sun May 09 2004.
//

/*
 * Copyright (C) 2004 CUISSARD Vincent <cuissa_v@epita.fr>
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 675 
 * Mass Ave, Cambridge, MA 02139, USA.
 */

#import "NSFProtocol.h"
#import "NSFUtils.h"
#import "NSString.h"

@interface NSFProtocol (Private)

+ (NSString *) encodeMessage: (NSString *) aMsg;
+ (NSString *) decodeMessage: (NSString *) aMsg;

@end

@implementation NSFProtocol

static	NSString	*notification = nil;

+ (void) setNotification: (NSString *) not
{
    notification = [not retain];
}

+ (NSString *) messageByDecode: (NSString *) aMsg
{
    return [self decodeMessage: aMsg];
}

+ (NSString *) commandForPing
{
    return @"ping\n";
}

+ (NSString *) commandForSettingUserData: (NSString *) aComment
{
    return [NSString stringWithFormat: @"user_cmd user_data %@\n",
		[self encodeMessage: aComment]];
}

+ (NSString *) commandForStartingAuthentification
{
    return @"auth_ag ext_user none none\n";
}

+ (NSString *) commandForSendingUserAuthentification: (NSString *) infos 
											   login: (NSString *) login 
												pass: (NSString *) pass 
											location: (NSString *) location 
											userData: (NSString *) userData
{
    NSArray	    *infosServer = [infos componentsSeparatedByString: @" "];
    NSString	*enc_user_data;
    NSString	*pass_set;
    NSString    *password;
    
    pass_set = [NSString stringWithFormat: @"%@-%@/%@%@",
		[infosServer objectAtIndex: 2], 
		[infosServer objectAtIndex: 3],
		[infosServer objectAtIndex: 4],
		pass];
    
    password = [pass_set MD5];
    enc_user_data = [NSString stringWithFormat: @"%@", userData];
    
    return [NSString stringWithFormat: @"ext_user_log %@ %@ %@ %@\n",
		login, password,
		[self encodeMessage: location], [self encodeMessage: enc_user_data]];
}

+ (NSString *) commandForWatchingLogsOfUsers: (NSArray *) users
{
    NSEnumerator    *it = [users objectEnumerator];
    NSString	    *listUsers = @"";
    NSString	    *aUser;
    
    while (aUser = [it nextObject])
    {                                                                                                                             
		if (listUsers.length == 0)
			listUsers = [NSString stringWithString: aUser];                                                    
		else                                                                                                                      
			listUsers = [listUsers stringByAppendingString: 
			    [NSString stringWithFormat:@",%@", aUser]];           
    }                                                                                                                             
    
    return [NSString stringWithFormat: @"user_cmd watch_log_user {%@}\n", listUsers];
}

+ (NSString *) commandForGettingStatusOfUsers: (NSArray *) users
{
    NSEnumerator    *it = [users objectEnumerator];
    NSString	    *listUsers = @"";
    NSString	    *aUser;
    
    while (aUser = [it nextObject])
    {                                                                                                                             
		if (listUsers.length == 0)
			listUsers = [NSString stringWithString: aUser];                                                    
		else                                                                                                                      
			listUsers = [listUsers stringByAppendingString: 
				[NSString stringWithFormat:@",%@", aUser]];           
    }                                                                                                                             
    
    return [NSString stringWithFormat: @"list_users {%@}\n", listUsers]; 
}

+ (NSString *) commandForSendingMessage: (NSString *) aMsg to: (NSString *) aUser
{
    return [NSString stringWithFormat: @"user_cmd msg_user %@ msg %@\n",
		aUser, [self encodeMessage: aMsg]];
}

+ (NSString *) commandForSettingState: (NSString *) aState
{
    return [NSString stringWithFormat:@"user_cmd state %@:%li\n", aState, time(0)]; 
}

+ (NSString *) commandForExit
{
    return @"user_cmd exit\n";
}


+ (NSString *) commandForStartingTyping: (NSString *) user
{
    return [NSString stringWithFormat: @"user_cmd msg_user %@ dotnetSoul_UserTyping null\n", user];
}

+ (NSString *) commandForStoppingTyping: (NSString *) user
{
    return [NSString stringWithFormat: @"user_cmd msg_user %@ dotnetSoul_UserCancelledTyping null\n", user];
}

+ (NSString *) commandForSelfWhoing: (NSString *) login
{
    return [NSString stringWithFormat: @"user_cmd who %@", login];
}

@end

@implementation NSFProtocol (Private)

+ (NSString *) encodeMessage: (NSString *) aMsg
{
    char	*msg = strdup([aMsg cStringUsingEncoding:NSUTF8StringEncoding]);
    char	*ret;
    char	*res;
    NSString    *message;
    
    ret = backslash_return(msg);
    
    res = msg_2_spec((unsigned char *)ret);
    message = [NSString stringWithCString: res encoding:NSUTF8StringEncoding];
    
    free(ret);
    free(msg);
    
    return message;
}

+ (NSString *) decodeMessage: (NSString *) aMsg
{
    char	*msg = strdup([aMsg cStringUsingEncoding:NSUTF8StringEncoding]);
    char	*ret;
    char	*res;
    NSString    *message;
	
    ret = spec_2_msg (msg);
    res = strip_return(ret);
	
    message = [NSString stringWithCString: res encoding:NSUTF8StringEncoding];
    
    free(msg);
    
    return message;
}

@end
