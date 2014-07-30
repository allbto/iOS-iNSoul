//
//  Defines.h
//  Breeze
//
//  Created by Allan Barbato on 7/31/12.
//  Copyright (c) 2012 Epitech. All rights reserved.
//

#ifndef Breeze_Defines_h
#define Breeze_Defines_h

#define __DEBUG YES
#define __STATUP_AD NO
#define __AUTO_LOGIN YES

#define FADE_ANIMATION_DURATION 0.5
#define DEVICE_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#pragma mark - Server

#define ServerAddressLite    @""
#define ServerAdressCompl   @""
#define ServerAddress       [NSString stringWithFormat:@"http://%@%@", ServerAddressLite, ServerAdressCompl]
#define ServerURL           [NSURL URLWithString:ServerAddress]
#define PictureForUser(USER) [NSString stringWithFormat:@"https://cdn.local.epitech.eu/userprofil/profilview/%@.jpg", USER]


#pragma mark - IS_IT ?

#define IS_IPHONE           ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPAD             ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_RETINA           ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] > 1.0)
#define IS_4INCH            (IS_RETINA && ([[UIScreen mainScreen] bounds].size.height * 2) == 1136)

#define CONNECTION_IS_REACHABLE ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)

#pragma mark - Meta func

#define ALERT(MSG)          [[[[UIAlertView alloc] initWithTitle:@"Alert" message:MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show]
#define URL(_STR)           [NSURL URLWithString:_STR]
#define LS(_STR)            NSLocalizedString(_STR, nil)
#define HomeDirectory(_STR) [NSHomeDirectory() stringByAppendingString:_STR]

#endif
