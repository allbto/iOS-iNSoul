//
//  Message.h
//  Breeze
//
//  Created by Allan BARBATO on 7/27/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
        MessageSent,
        MessageReceived
}       MessageType;

@interface Messages : NSObject

@property (nonatomic, assign) NSInteger     messageID;
@property (nonatomic, retain) NSDate*       sentDate;
@property (nonatomic, assign) BOOL          read;
@property (nonatomic, assign) BOOL          send;
@property (nonatomic, assign) BOOL          failed;
@property (nonatomic, assign) BOOL          hidden;
@property (nonatomic, assign) MessageType   type;
@property (nonatomic, retain) NSString*     text;
@property (nonatomic, retain) NSValue*      size;

@property (nonatomic, assign) UITableViewCell* cell;

- (id)initWithText:(NSString*)text;

@end
