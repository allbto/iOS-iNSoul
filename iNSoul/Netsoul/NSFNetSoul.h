//
//  NSFNetSoul.h
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
#import "NSFProtocol.h"
#import "Network.h"

#pragma mark -
#pragma mark Server informations

//#define NS_SERVER   @"10.42.1.59"
#define NS_SERVER   @"ns-server.epita.fr"
#define NS_PORT     @"4242"

#if 0
# define NETSOUL_SEND(Msg)
#else
# define NETSOUL_SEND(Msg) NSLog (@"\n\nNSF Send: \"%@\" at\n%s:%d\n\n", Msg, __FILE__, __LINE__)
#endif

#if 0
# define NETSOUL_RECEIVED(Msg)
#else
# define NETSOUL_RECEIVED(Msg) NSLog (@"\n\nNSF Received: \"%@\" at\n%s:%d\n\n", Msg, __FILE__, __LINE__)
#endif

@class INViewController;

//
// Protocol which let the netsoul class to notify events of netsoul
// Implements all this methods in order to access to message, contact events ...
//

@protocol NSFNetSoulEvent < NSObject >

// Notify the result of the authentification
- (void) notifyAuthentificationResult: (BOOL) state;

// Notify a new message
- (void) userRecieveMessage: (NSString *) msg from: (NSString *) login;

// Notify an error
- (void) errorOccured: (NSString *) error;

// Notify that user update
- (void) userInfoChanged: (int) state
					host: (NSString *) host
			  loginSince: (NSString *) since
			 workstation: (NSString *) workstation
				location: (NSString *) location
				userdata: (NSString *) userdate
					from: (NSString *) login;

// Notify that user login/logout
- (void) userLoggedEvent: (int) type from: (NSString *) login;

// Notify that user change State
- (void) userChangedState: (int) state from: (NSString *) login;
    
// Notify that user user recv mail
- (void) userRecieveMail: (NSString *) mail from: (NSString *) name;

// Notify that we were disconnected from the server
- (void) disconnectedEvent;

// Notify a typing event
- (void) userTypingEvent: (int) type from: (NSString *) login;

@end


@interface NSFNetSoul : NSObject <NetworkProtocol>
{
    // Connections informations
    Network*            _connection;
    BOOL				_repConnected;
    BOOL				_connected;
    BOOL				_state;
    
    // User's informations
    NSString		    *_location;
    NSString		    *_userData;
}

@property (nonatomic, retain) NSString* server;
@property (nonatomic, retain) NSString* port;
@property (nonatomic, retain) NSString* login;
@property (nonatomic, retain) NSString* pass;

@property (nonatomic, assign) INViewController* controller;

#pragma mark -
#pragma mark Initialisation

// Init
- (id) init;
// Connect to the server
- (BOOL) connect;
// Disconnect form server
- (BOOL) disconnect;
// Authenticate
- (void) authenticate;

#pragma mark - Actions

// Send the given message to "aLogin"
- (bool) sendMessage: (NSString *) aMsg to: (NSString *) aLogin;

// Change current state
- (void) setAwayState;
- (void) setActifState;
- (void) setIdleState;

// Send to the server to list the given users
- (void) setUserList: (NSArray *) users;
// Send to the server the list of users that we want him to notified changes
- (void) setWatchLogList: (NSArray *) users;

// Send typing events
- (void) sendTypingEvent: (BOOL) typing to: (NSString *) login;

@end 
