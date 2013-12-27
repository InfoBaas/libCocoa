//
//  LCAAppDelegate.m
//  UserTrackPulling-iOS
//
//  Created by Tiago Rodrigues on 24/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAAppDelegate.h"

@interface LCAAppDelegate ()

@property (strong, nonatomic) UIView *waitscreen;

@end

static NSString *const _appid = @"com.infosistema.openbaas.libcocoa.apps.UserTrackPulling-iOS.appid";
static NSString *const _appKey = @"com.infosistema.openbaas.libcocoa.apps.UserTrackPulling-iOS.appkey";

@implementation LCAAppDelegate

- (NSString *)appId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_appid];
}

- (void)setAppId:(NSString *)appId
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (appId) {
        [standardUserDefaults setObject:appId forKey:_appid];
    } else {
        [standardUserDefaults removeObjectForKey:_appid];
    }
    [standardUserDefaults synchronize];
}

- (NSString *)appKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_appKey];
}

- (void)setAppKey:(NSString *)appKey
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (appKey) {
        [standardUserDefaults setObject:appKey forKey:_appKey];
    } else {
        [standardUserDefaults removeObjectForKey:_appKey];
    }
    [standardUserDefaults synchronize];
}

- (void)showWaitScreen
{
    [self.window addSubview:self.waitscreen];
}

- (void)hideWaitScreen
{
    [self.waitscreen removeFromSuperview];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [OBSSession forgetCurrentSession];

    UIView *waitscreen = [[UIView alloc] initWithFrame:self.window.bounds];
    [waitscreen setBackgroundColor:[UIColor colorWithWhite:.0 alpha:.5]];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    activityIndicator.center = CGPointMake(waitscreen.frame.size.width * .5, waitscreen.frame.size.height * .5);
    [waitscreen addSubview:activityIndicator];
    self.waitscreen = waitscreen;

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
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
