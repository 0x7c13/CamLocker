//
//  CLAppDelegate.m
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "TestFlight.h"
#import "NSString+Random.h"
#import "CLAppDelegate.h"
#import "CLMarkerManager.h"

@implementation CLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"73277e89-0014-4d1e-9209-85f4593c61f7"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString randomAlphanumericStringWithLength:kLengthOfKey] forKey:@"CamLockerMarkersKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
    }
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    
    /*
     // Test methods
     if ([CLMarkerManager sharedManager].markers.count == 0) {
     
     [[CLMarkerManager sharedManager] addImageMarkerWithMarkerImage:[UIImage imageNamed:@"Markers/target_1.jpg"] hiddenImages:@[[UIImage imageNamed:@"Markers/target_6.jpg"]]];
     [[CLMarkerManager sharedManager] addTextMarkerWithMarkerImage:[UIImage imageNamed:@"Markers/target_2.jpg"] hiddenText:@"hello"];
     }
     */
    
    // Override point for customization after application launch.
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
    [[CLMarkerManager sharedManager] deactivateMarkers];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
