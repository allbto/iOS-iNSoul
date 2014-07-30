//
//  Network.h
//  Joypad
//
//  Created by Allan Barbato on 5/14/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//
//  The Network class allow to easly handle network socket
//

#import <UIKit/UIKit.h>

@class Network;

@protocol NetworkProtocol <NSObject>

- (void)networkReceiveMessage:(NSString*)message;

@end

@interface Network : NSObject
{
    int         _nSocket;
    int         _nPort;
    NSString*   _sIp;
    
    bool        _bBlocking;
    
    NSThread*   _rcvThread;
    
    NSMutableString*   _sBuffer;
    NSMutableArray*    _lMessages;
}

@property (nonatomic, assign) bool blocking;
@property (nonatomic, assign) id delegate;

@property (nonatomic, readonly, getter = isConnected) bool connected;

// Returns an allocated, initialized, an autoreleased instance of Network
//TODO: Protocol en mode propre
+ (Network*)network;

// Connects the socket with the given ip and port
// The timeout is used to setup a timeout on the connect() function
// The timeout is in seconds
// 0 for no timeout
// If the delegate is set and it respond to selector in the protocol
// then every received message will be send to this protocol method
- (bool)connectWithIp:(NSString*)sIp andPort:(int)nPort timeout:(NSUInteger)nTimeOut;

// Same as connectWithIp except it fetch the ip from an hostname
// Ex: google.com
- (bool)connectWithHostName:(NSString*)hostName port:(NSInteger)nPort timeout:(NSUInteger)nTimeOut;

// Close the connection and the socket
- (bool)close;

// Allow to send message to the connection
- (bool)send:(NSString*)sMessage;

// If the target isn't set
// every received message will be add to an array of message
// and by calling -(NSString*)receive you will get the first message of the array.
// And the message will be removed from the array
//TODO: Check si ca marche
- (NSString*)receive;

// Check if the socket is open and valid
- (bool)isValid;

@end
