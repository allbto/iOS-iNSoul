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

#import <CFNetwork/CFNetwork.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CFNetwork/CFHTTPStream.h>

@implementation Network

////////////////////////////////////
//
//          Initialisation
//
////////////////////////////////////

#pragma mark - Initialisation

-(id)init
{
    self.delegate = nil;

    _inputStream = nil;
    _outputStream = nil;
    _connected = NO;
    _port = 0;
    _ip = @"127.0.0.1";
    
    _sBuffer = [[NSMutableString string] retain];
    _lMessages = [[NSMutableArray array] retain];
    return self;
}

-(void)dealloc
{
    if ([self isValid])
        [self close];
    
    [_ip release];
    _ip = nil;
    
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

- (bool)connectWithIp:(NSString*)sIp andPort:(NSInteger)nPort timeout:(NSUInteger)nTimeOut
{
    _port = nPort;
    _ip = sIp;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)_ip, (int)_port, &readStream, &writeStream);
    _inputStream = (NSInputStream *)readStream;
    _outputStream = (NSOutputStream *)writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    //[_inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    //[_outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
    
    _connected = YES;
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
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkConnectionEnd)])
        [self.delegate performSelectorOnMainThread:@selector(networkConnectionEnd) withObject:nil waitUntilDone:NO];
    _port = 0;
    _ip = @"";
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
    if (![self isValid])
        return false;

	NSData *data = [[NSData alloc] initWithData:[sMessage dataUsingEncoding:NSASCIIStringEncoding]];
	[_outputStream write:[data bytes] maxLength:[data length]];
    
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

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %lu", streamEvent);

    switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == _inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([_inputStream hasBytesAvailable]) {
                    len = (int)[_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(networkReceiveMessage:)])
                            [self.delegate performSelectorOnMainThread:@selector(networkReceiveMessage:) withObject:output waitUntilDone:NO];
                        else if (output)
                            [_lMessages addObject:output];
                    }
                }
            }			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            if (self.delegate && [self.delegate respondsToSelector:@selector(networkConnectionEnd)])
                [self.delegate performSelectorOnMainThread:@selector(networkConnectionEnd) withObject:nil waitUntilDone:NO];
			break;
            
		default:
			NSLog(@"Unknown event");
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
//    if (_nSocket <= 0 || !_connected)
//        return false;
    return true;
}

@end
