//
//  AppDelegate.m
//  CloverGoSample
//
//  Created by Raghu Vamsi on 11/8/15.
//  Copyright © 2015 First Data Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "MediaPlayer/MPVolumeView.h"
#import "KVNProgress.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    // pre-load keyboard so that it would load faster later - makes the user happy
    [self preLoadKeyboard];
    
   return YES;
}

- (void)resetUserDefaults{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    BOOL userACK = [[NSUserDefaults standardUserDefaults] boolForKey:@"user-headphonejack-connectivity-acknowledged"];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] setBool:userACK forKey:@"user-headphonejack-connectivity-acknowledged"];
    [[NSUserDefaults standardUserDefaults] synchronize]; // not sure if needed, but never hurts
}

- (void)preLoadKeyboard{
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
}


- (BOOL)applicationIsCurrentlyActive{
    return ([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self releaseReaderWhenAppIsPushedToBackground];
}

- (void)releaseReaderWhenAppIsPushedToBackground{
    __block UIApplication * app = [UIApplication sharedApplication];
    
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        NSLog(@"Multitasking Supported");
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [app beginBackgroundTaskWithExpirationHandler:^ {
            //Clean up code. Tell the system that we are done.
            [app endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
        //To make the code block asynchronous
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //### background task starts
            NSLog(@"Running in the background\n");
            [[CloverGo sharedInstance] releaseCardReader:^(BOOL success) {
                //Clean up code. Tell the system that we are done.                
                MPVolumeView* volumeView = [[MPVolumeView alloc] init];
                for (UIView*view in volumeView.subviews) {
                    if ([NSStringFromClass(view.classForCoder)  isEqual: @"MPVolumeSlider"]) {
                        UISlider* slider = (UISlider*)view;
                        [slider setValue:1.0 animated:NO];
                    }
                }
                
                [app endBackgroundTask: background_task];
                background_task = UIBackgroundTaskInvalid;
            }];
            //#### background task ends
        });
    }
    else
    {
        NSLog(@"Multitasking Not Supported");
    }
}

- (BOOL)headsetPluggedIn{
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    
    BOOL headphonesLocated = NO;
    for( AVAudioSessionPortDescription *portDescription in route.outputs )
    {
        headphonesLocated |= ( [portDescription.portType isEqualToString:AVAudioSessionPortHeadphones] );
    }
    return headphonesLocated;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    if ([self headsetPluggedIn]) {
            // check if audio device is already connected
    }
    // this delay is to ensure that the device is properly released.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[CloverGo sharedInstance] initCardReader:CloverGoCardReaderType450 shouldAutoReset:YES];
        
    });}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self releaseCurrentDevice];
}

- (void)releaseCurrentDevice
{
    [[CloverGo sharedInstance] releaseCardReader:^(BOOL success) {
        
        MPVolumeView* volumeView = [[MPVolumeView alloc] init];
        for (UIView*view in volumeView.subviews) {
            if ([NSStringFromClass(view.classForCoder)  isEqual: @"MPVolumeSlider"]) {
                UISlider* slider = (UISlider*)view;
                [slider setValue:1.0 animated:NO];
            }
        }
        if (success){
            NSLog(@"***************************************************\nReader released successfully post Audio Interrupt Began\n***************************************************\n");
        } else {
        NSLog(@"***************************************************\nReader released failed post Audio Interrupt Began\n***************************************************\n");
        }
        
    }];
}

@end
