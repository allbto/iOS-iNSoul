//
//  NSFProtocol.h
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

#import <Foundation/Foundation.h>

enum	e_state
{
    E_STATE_SERVER,
    E_STATE_LOCK,
    E_STATE_AWAY,
    E_STATE_ONLINE,
    E_STATE_OFFLINE
};

enum	e_user
{
    E_USER_LOGIN,
    E_USER_LOGOUT
};

enum	e_typing
{
    E_TYPING_START,
    E_TYPING_STOP
};

// All these functions return the wanted text request
// All data will be correctly "url_encoding" so don't do this manualy
// 
// messageByDecode: decode a recv message

@interface NSFProtocol : NSObject 
{

}

+ (void) setNotification: (NSString *) aNot;

#pragma mark -
#pragma mark Ping

+ (NSString *) commandForPing;

#pragma mark -
#pragma mark Authentification

+ (NSString *) commandForStartingAuthentification;
+ (NSString *) commandForSendingUserAuthentification: (NSString *) infos
					       login: (NSString *) login 
						pass: (NSString *) pass 
					    location: (NSString *) location 
					    userData: (NSString *) userData;

#pragma mark -
#pragma mark Setting infos

+ (NSString *) commandForSettingUserData: (NSString *) aComment;
+ (NSString *) commandForSettingState: (NSString *) aState;

#pragma mark -
#pragma mark Get infos of ?

+ (NSString *) commandForWatchingLogsOfUsers: (NSArray *) users;
+ (NSString *) commandForGettingStatusOfUsers: (NSArray *) users;

#pragma mark -
#pragma mark Notification

+ (NSString *) commandForStartingTyping: (NSString *) user;
+ (NSString *) commandForStoppingTyping: (NSString *) user;

#pragma mark -
#pragma mark Messages stuff

+ (NSString *) commandForSendingMessage: (NSString *) aMsg to: (NSString *) aUser;
+ (NSString *) messageByDecode: (NSString *) aMsg;
+ (NSString *) commandForSelfWhoing: (NSString *) login;

+ (NSString *) commandForExit;

@end
