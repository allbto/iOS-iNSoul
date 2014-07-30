//
//  INAppDelegate.m
//  iNSoul
//
//  Created by Allan Barbato on 10/15/12.
//  Copyright (c) 2012 Allan Barbato. All rights reserved.
//

#import "INAppDelegate.h"
#import "Utils.h"
#import "INViewController.h"
#import "GAI.h"

/******* Google Analytics tracking ID *******/
static NSString *const kTrackingId = @"UA-42111692-2";

@interface INAppDelegate ()

@property (nonatomic, assign) __block UIBackgroundTaskIdentifier backgroundIdenfier;

@end

@implementation INAppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.backgroundIdenfier = 0;
    
    // Configuring NSUserDefaults default values
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* appDefaults = @{
    @"userLogin" : @"",
    @"userPass" : @"",
    @"userContact" : @[]
    };
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];

    //
    // Initialize Google Analytics with a 60-second dispatch interval.
    // There is a tradeoff between battery usage and timely dispatch.
    //
    //[[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 60;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    // Initializing the window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[INViewController alloc] initWithNibName:@"INViewController_iPhone" bundle:nil] autorelease];
    //} else {
     //   self.viewController = [[[INViewController alloc] initWithNibName:@"INViewController_iPad" bundle:nil] autorelease];
    //}
    UINavigationController* navController = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*self.backgroundIdenfier = [application beginBackgroundTaskWithExpirationHandler:^{
        [Utils addLocalNotificationWithMessage:@"Server is disconnected"];
        [self.viewController disconnect];
    }];*/
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) { //Check if our iOS version supports multitasking I.E iOS 4
        if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
            UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
            self.backgroundIdenfier = [application beginBackgroundTaskWithExpirationHandler: ^ {
                [Utils addLocalNotificationWithMessage:@"Server is disconnected"];
                [application endBackgroundTask: self.backgroundIdenfier]; //Tell the system that we are done with the tasks
                self.backgroundIdenfier = UIBackgroundTaskInvalid; //Set the task to be invalid
                //System will be shutting down the app at any point in time now
            }];
        }
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    if (self.backgroundIdenfier != 0)
    {
        //Background tasks require you to use asyncrous tasks
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Perform your tasks that your application requires
            NSLog(@"\n\nRunning in the background!\n\n");
            [application endBackgroundTask: self.backgroundIdenfier]; //End the task so the system knows that you are done with what you need to perform
            self.backgroundIdenfier = UIBackgroundTaskInvalid; //Invalidate the background_task
        });
        //[application endBackgroundTask:self.backgroundIdenfier];
        self.backgroundIdenfier = 0;
    }
    //[self.viewController reconnect];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
