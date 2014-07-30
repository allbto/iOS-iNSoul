//
//  INViewController.h
//  iNSoul
//
//  Created by Allan Barbato on 10/15/12.
//  Copyright (c) 2012 Allan Barbato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "Netsoul/NSFNetSoul.h"
#import "ConversationsViewController.h"
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"

#define STATUS(msg) (self.statusLabel.text = msg); \
                    [_convViewController setStatus:msg]

#define kDisconnected   @"Disconnected"
#define kReconect       @"Reconnecting"
#define kErrorSocket    @"Socket failed to connect"
#define kConnecting     @"Connecting"
#define kAuthOk         @"Authentification success"
#define kAuthFail       @"Authentification failure"

@interface INViewController : GAITrackedViewController
<UITextFieldDelegate, GADBannerViewDelegate>
{
    NSFNetSoul* _netsoulConnection;
    BOOL        _isConnected;
    
    NSTimer*    _reconnectTimer;
    
    ConversationsViewController*    _convViewController;
}

- (IBAction)connectionChangeAction:(id)sender;
- (IBAction)conversationAction:(id)sender;
- (IBAction)settingsAction:(id)sender;

- (void)reconnect;
- (void)disconnect;
- (void)connect;

@property (retain, nonatomic) IBOutlet UISwitch *connectionSwitch;
@property (retain, nonatomic) IBOutlet UITextField *loginTextField;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UITextField *passTextField;
@property (retain, nonatomic) IBOutlet UIButton *conversationButton;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@interface INViewController (NSFNetSoulProtocol)

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