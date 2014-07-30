//
//  Network.m
//  Joypad
//
//  Created by Allan Barbato on 5/14/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import "Network.h"

# include <netinet/in.h>
# include <sys/socket.h>
# include <netinet/in.h>
# include <arpa/inet.h>
# include <netdb.h>
# include <fcntl.h>
# include <sys/types.h>
# include <sys/stat.h>

@implementation Network

@synthesize blocking = _bBlocking;

////////////////////////////////////
//
//          Initialisation
//
////////////////////////////////////

#pragma mark - Initialisation

-(id)init
{
    _nSocket = 0;
    _nPort = 0;
    _sIp = @"";
    self.delegate = nil;
    
    _bBlocking = YES;
    _connected = NO;
    
    _sBuffer = [[NSMutableString string] retain];
    _lMessages = [[NSMutableArray array] retain];
    return self;
}

-(void)dealloc
{
    if ([self isValid])
        [self close];
    
    [_sIp release];
    _sIp = nil;
    
    [_sBuffer release];
    _sBuffer = nil;
    
    [_lMessages release];
    _lMessages = nil;
    
    [super dealloc];
}

+ (Network*)network
{
    return [[[Network alloc] init] autorelease];
}

////////////////////////////////////
//
//          Connect
//
////////////////////////////////////

#pragma mark - Connect

- (void)setBlocking:(bool)blocking
{
    _bBlocking = blocking;
    int Status = fcntl(_nSocket, F_GETFL);
    if (blocking)
        fcntl(_nSocket, F_SETFL, Status & ~O_NONBLOCK);
    else
        fcntl(_nSocket, F_SETFL, Status | O_NONBLOCK);
}

- (bool)connectWithIp:(NSString*)sIp andPort:(int)nPort timeout:(NSUInteger)nTimeOut
{
    struct  protoent*   hProto;
    struct  sockaddr_in hSin;
    
    _nPort = nPort;
    _sIp = sIp;
    
    if ((hProto = getprotobyname("TCP")) == NULL || !sIp || [sIp length] == 0)
        return false;

    hSin.sin_family = AF_INET;
    hSin.sin_port = htons(nPort);
    hSin.sin_addr.s_addr = inet_addr([sIp cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if ((_nSocket = socket(AF_INET, SOCK_STREAM, hProto->p_proto)) == -1)
        return false;
    
    if (nTimeOut <= 0)
    {
        if (connect(_nSocket, (const struct sockaddr *)&hSin, sizeof(hSin)) == -1)
        {
            perror("connect");
            close(_nSocket);
            return false;
        }
    }
    else
    {
        bool blocking = _bBlocking;
        
        if (blocking)
            [self setBlocking:false];
        
        if (connect(_nSocket, (const struct sockaddr *)&hSin, sizeof(hSin)) < 0)
        {
            if (!blocking)
                return false;
        
            // Setup the selector
            fd_set selector;
            FD_ZERO(&selector);
            FD_SET(_nSocket, &selector);
            
            // Setup the timeout
            struct timeval time;
            time.tv_sec  = (long)(nTimeOut);
            time.tv_usec = (long)((nTimeOut * 1000) % 1000) * 1000;
            
            if (select(_nSocket + 1, NULL, &selector, NULL, &time) > 0)
            {
                if (!FD_ISSET(_nSocket, &selector))
                    return false;
            }
            else
                return false;
        }
        
        [self setBlocking:true];
    }

    _connected = YES;
    _rcvThread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveMessage) object:nil];
    [_rcvThread start];
    
    return true;
}

- (bool)connectWithHostName:(NSString*)hostName port:(NSInteger)nPort timeout:(NSUInteger)nTimeOut
{
    struct hostent  *he;
	struct in_addr  **addr_list;
    NSString        *ip;
    
	if ( (he = gethostbyname( [hostName cStringUsingEncoding:NSUTF8StringEncoding] ) ) == NULL)
	{
		perror("gethostbyname");
		return false;
	}
    
	addr_list = (struct in_addr **) he->h_addr_list;
	
	for (int i = 0 ; addr_list[i] != NULL ; i++)
	{
        ip = [NSString stringWithCString:inet_ntoa(*addr_list[i]) encoding:NSUTF8StringEncoding];
        NSLog(@"IP : %@", ip);
		return [self connectWithIp:ip andPort:nPort timeout:nTimeOut];
	}
	
	return 1;
}

- (bool)close
{
    close(_nSocket);
    _nSocket = 0;
    _nPort = 0;
    _sIp = @"";
    _connected = NO;
    return true;
}

////////////////////////////////////
//
//          Send / Receive
//
////////////////////////////////////

#pragma mark - Send / Receive

- (bool)send:(NSString*)sMessage
{
    int nResult;

    if (![self isValid])
        return false;

    nResult = send(_nSocket, [sMessage cStringUsingEncoding:NSUTF8StringEncoding], [sMessage length], MSG_HAVEMORE);
    
    if (nResult == -1)
    {
        [self close];
    }
    return true;
}

- (NSString*)receive
{
    NSString* sElem;
    
    if ([_lMessages count] <= 0)
        return nil;
    sElem = [_lMessages objectAtIndex:0];
    [_lMessages removeObjectAtIndex:0];
    return [sElem autorelease];
}

- (void)receiveMessage
{
    int		ret;
    char	buff[2];

    bzero(buff, 2);
    ret = 0;
    while (ret != -1)
    {
        if ((ret = recv(_nSocket, buff, 1, MSG_HAVEMORE)) == -1)
        {
            [self close];
            [NSThread exit];
            NSLog(@"Recv Error :");
            perror("recv");
            continue;
        }
        else if (ret == 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(networkReceiveMessage:)])
                [self.delegate performSelectorOnMainThread:@selector(networkReceiveMessage:) withObject:nil waitUntilDone:NO];
            [self close];
            [NSThread exit];
            continue;
        }
        if (buff[0] == '\n')
        {
            NSString* sNew;
            sNew = [NSString stringWithString:_sBuffer];
            [_sBuffer setString:@""];
            if (self.delegate && [self.delegate respondsToSelector:@selector(networkReceiveMessage:)])
                [self.delegate performSelectorOnMainThread:@selector(networkReceiveMessage:) withObject:sNew waitUntilDone:NO];
            else
                [_lMessages addObject:sNew];
        }
        else [_sBuffer appendFormat:@"%s", buff];
    }
}

////////////////////////////////////
//
//          Other
//
////////////////////////////////////

#pragma mark - Other

- (bool)isValid
{
    if (_nSocket <= 0 || !_connected)
        return false;
    return true;
}

@end
