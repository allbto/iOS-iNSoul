//
//  INViewController.m
//  iNSoul
//
//  Created by Allan Barbato on 10/15/12.
//  Copyright (c) 2012 Allan Barbato. All rights reserved.
//

#import "INViewController.h"

// You should set this ad unit ID from your account before compiling.
// For new AdMob, this is ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN
// For DFP, this is /<networkCode>/<adUnitName>
// For Ad Exchange, this is <google_ad_client>/<google_ad_slot>
#define kSampleAdUnitID @"ca-app-pub-5062882757813950/9213417428"

#define BANNER_ON_IPAD_HEIGHT 40
#define STATUS_LABEL_AD_BANNER_HEIGHT (IS_IPAD ? BANNER_ON_IPAD_HEIGHT+40 : 40)

@interface INViewController ()
{
    BOOL _adIsOn;
}

@property (retain, nonatomic) IBOutlet UILabel *statusPreLabel;
@property(nonatomic, retain) GADBannerView *adBanner;

- (GADRequest *)requestAd;

@end

@implementation INViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.backgroundImageView setImage:[self.backgroundImageView.image applyLightEffect]];
    
    self.loginTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"userLogin"];
    self.passTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"userPass"];
    
    _netsoulConnection = [[NSFNetSoul alloc] init];
    _netsoulConnection.controller = self;
    _netsoulConnection.server = NS_SERVER;
    _netsoulConnection.port = NS_PORT;
    _netsoulConnection.login = self.loginTextField.text;
    _netsoulConnection.pass = self.passTextField.text;
    _isConnected = false;
    _adIsOn = false;
    _reconnectTimer = nil;
    
    _convViewController = [[ConversationsViewController alloc] init];
    _convViewController.netSoulConnection = _netsoulConnection;
    
    if (self.loginTextField.text.length > 0 && self.passTextField.text.length > 0)
        [self reconnect];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initialize the banner at the bottom of the screen.
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height -
                                 CGSizeFromGADAdSize((IS_IPAD ? kGADAdSizeSmartBannerLandscape : kGADAdSizeBanner)).height);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    self.adBanner = [[GADBannerView alloc] initWithAdSize:(IS_IPAD ? kGADAdSizeSmartBannerLandscape : kGADAdSizeBanner) origin:origin];
    
    // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID before compiling.
    self.adBanner.adUnitID = kSampleAdUnitID;
    self.adBanner.delegate = self;
    self.adBanner.rootViewController = self;
    self.adBanner.alpha = 0;
    [self.view addSubview:self.adBanner];
    [self.adBanner loadRequest:[self requestAd]];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Google analytics screen name
    self.screenName = @"Home Screen";

    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_connectionSwitch release];
    [_loginTextField release];
    [_passTextField release];
    [_statusLabel release];
    [_conversationButton release];
    [_backgroundImageView release];
    [_statusPreLabel release];
    [super dealloc];
}

- (void)reconnectTimerAction
{
    if (_isConnected)
    {
        [_reconnectTimer invalidate];
        _reconnectTimer = nil;
        return;
    }
    [self reconnect];
}

- (IBAction)connectionChangeAction:(id)sender
{
    NSLog(@"Is on ? %d", self.connectionSwitch.on);
    
//    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction" withAction:@"connectionChange" withLabel:@"connection" withValue:[NSNumber numberWithBool:self.connectionSwitch.on]];
    
    [_convViewController setSwitchOn:self.connectionSwitch.on];
    if (self.connectionSwitch.on)
    {
        _netsoulConnection.login = self.loginTextField.text;
        _netsoulConnection.pass = self.passTextField.text;
        _isConnected = [_netsoulConnection connect];
        STATUS((_isConnected ? kConnecting : kErrorSocket));
        NSLog(@"Is connected ? %d", _isConnected);

        if (!_isConnected)
            [_connectionSwitch setOn:NO animated:YES];

//        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction" withAction:@"isConnected" withLabel:[NSString stringWithFormat:@"connection (%@)", self.loginTextField.text] withValue:[NSNumber numberWithBool:_isConnected]];

        //if (!_isConnected && !_reconnectTimer)
            //_reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(reconnectTimerAction) userInfo:nil repeats:YES];
    }
    else
    {
        _conversationButton.enabled = NO;
        [_netsoulConnection disconnect];
        STATUS(kDisconnected);
    }
}

- (IBAction)conversationAction:(id)sender
{
    [self.navigationController pushViewController:_convViewController animated:YES];
}

- (IBAction)settingsAction:(id)sender
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1)
    {
        [self.passTextField becomeFirstResponder];
    }
    else if (textField.tag == 2)
    {
        [self.passTextField resignFirstResponder];
        [self connect];
    }
    return true;
}

- (void)reconnect
{
    STATUS(kReconect);
    [self disconnect];
    [self connect];
}

- (void)disconnect
{
    [self.connectionSwitch setOn:NO animated:NO];
    [self connectionChangeAction:nil];
}

- (void)connect
{
    [self.connectionSwitch setOn:YES animated:YES];
    [self connectionChangeAction:nil];
}

- (void)viewDidUnload {
    [self setLoginTextField:nil];
    [self setPassTextField:nil];
    [self setStatusLabel:nil];
    [self setConversationButton:nil];
    [self setBackgroundImageView:nil];
    [self setStatusPreLabel:nil];
    [super viewDidUnload];
}


#pragma mark - Admob Delegate methods

- (GADRequest *)requestAd {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as well as any devices
    // you want to receive test ads.
    request.testDevices = @[
                            // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
                            // the console when the app is launched.
                            GAD_SIMULATOR_ID,
                            @"16d6a62157b46a7245a95f7799c6f0c4"
                            ];
    return request;
}

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
    // Initialize the banner at the bottom of the screen.
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height -
                                 CGSizeFromGADAdSize((IS_IPAD ? kGADAdSizeSmartBannerLandscape : kGADAdSizeBanner)).height);
    [adView setViewOrigin:origin];
    [UIView animateWithDuration:1.0 animations:^{
        if (!_adIsOn)
        {
            _statusPreLabel.y -= STATUS_LABEL_AD_BANNER_HEIGHT;
            _statusLabel.y -= STATUS_LABEL_AD_BANNER_HEIGHT;
        }
        adView.alpha = 1;
    } completion:^(BOOL finished) {
        _adIsOn = true;
    }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
    NSLog(@"Ad Error : %@", [error description]);
    [UIView animateWithDuration:0.5 animations:^{
        if (_adIsOn)
        {
            _statusPreLabel.y += STATUS_LABEL_AD_BANNER_HEIGHT;
            _statusLabel.y += STATUS_LABEL_AD_BANNER_HEIGHT;
        }
        view.alpha = 0;
    } completion:^(BOOL finished) {
        _adIsOn = false;
    }];
}

@end

@implementation INViewController (NSFNetSoulProtocol)

- (void) notifyAuthentificationResult: (BOOL) state
{
    STATUS((state ? kAuthOk : kAuthFail));
    if (state)
    {
        self.connectionSwitch.on = YES;
        _conversationButton.enabled = YES;
        [_netsoulConnection setActifState];

        // Save users credentials
        [[NSUserDefaults standardUserDefaults] setValue:self.loginTextField.text forKey:@"userLogin"];
        [[NSUserDefaults standardUserDefaults] setValue:self.passTextField.text forKey:@"userPass"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // Request or re-request add if user is connected
        [self.adBanner loadRequest:[self requestAd]];
    }
    else
    {
        [_connectionSwitch setOn:NO animated:YES];

        // Delete users credentials
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"userLogin"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"userPass"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) userRecieveMessage: (NSString *) msg from: (NSString *) login
{
    // Receiving a msg from login
    NSLog(@"Receiving from %@ : %@", login, msg);
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
    {
        NSLog(@"Receiving and notifying");
        [Utils addLocalNotificationWithMessage:[NSString stringWithFormat:@"%@ says : %@", login, msg]];
    }
    [_convViewController receivedMessage:msg from:login];
}

- (void) errorOccured: (NSString *) error
{
    NSString* e = [NSString stringWithFormat:@"Error : %@", error];
    STATUS(e);
}

- (void) userInfoChanged: (int) state
					host: (NSString *) host
			  loginSince: (NSString *) since
			 workstation: (NSString *) workstation
				location: (NSString *) location
				userdata: (NSString *) userdate
					from: (NSString *) login
{
    // An user has changed his informations
    [_convViewController userInfoChanged:state host:host loginSince:since workstation:workstation location:location userdata:userdate from:login];
    NSLog(@"%@ has changed his informations", login);
}

- (void) userLoggedEvent: (int) type from: (NSString *) login
{
    // An user just logged
    NSLog(@"%@ just logged", login);
}

- (void) userChangedState: (int) state from: (NSString *) login
{
    // An user change of state
    NSLog(@"%@ just changed to %d", login, state);
}

- (void) userRecieveMail: (NSString *) mail from: (NSString *) name
{
    // Receiving a mail from login
    NSLog(@"Receiving mail from %@ : %@", name, mail);
}

- (void) disconnectedEvent
{
    [_netsoulConnection disconnect];
    [_connectionSwitch setOn:NO animated:YES];
    [self connectionChangeAction:nil];
    STATUS(kDisconnected);
}

- (void) userTypingEvent: (int) type from: (NSString *) login
{
    if (type == E_TYPING_START)
        [_convViewController userStartTyping:login];
    else
        [_convViewController userStopTyping:login];
    NSLog(@"%@ as typed : %d", login, type);
}

@end
