//
//  AppDelegate.m
//  instaslide
//
//  Created by me on 12/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import "AppDelegate.h"
#import "MKStoreManager.h"
#import "Facebook.h"
#import <Parse/Parse.h>
#import <RevMobAds/RevMobAds.h>
#import "UAAppReviewManager.h"
#import "Crittercism.h"
#import "iRate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FeedbackView.h"


static NSString *const kTrackingId = @"UA-40964440-13";
static NSString *const kAllowTracking = @"allowTracking";

Facebook* gFacebook;

@implementation AppDelegate
{
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [gFacebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [RevMobAds startSessionWithAppID:@"5282e7cb8ca356b8f9000005"];
    
    //[Crittercism enableWithAppID:@"56699f66cb99e10e00c7e9eb"];
    
    
    [MKStoreManager sharedManager];
    
    gFacebook = [[Facebook alloc] initWithAppId:@"740993939274257"];
    [UAAppReviewManager setAppID:@"843201980"];
    [Parse setApplicationId:@"Nd3gbnm1SeLk2UDrLMsg6VugTPqfRIy4Na1IQR8V"
                  clientKey:@"0nWentHvjUB33veYbAHrEGWcL7noMaoCUU4q6At5"];
    
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    [GAI sharedInstance].dispatchInterval = 120;
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"Post"
                                              trackingId:kTrackingId];
    
    [iRate sharedInstance].applicationBundleID = @"com.saeidarfan.instaslide";
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //[InstallTracker setApplicationID:@"f9f9592164bde9b0b7cc597810242530"];
    
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
    [FBSDKAppEvents activateApp];
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3515026979546906/7611689275"];
    self.interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[
//                            kGADSimulatorID  // Eric's iPod Touch
//                            ];
   
    
    int totalOpen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"totalOpen"] intValue];
    totalOpen = totalOpen+1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:totalOpen] forKey:@"totalOpen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (totalOpen == 4) {
        FeedbackView* feedbackView =[[[NSBundle mainBundle]loadNibNamed:@"FeedbackView" owner:self options:nil]lastObject];
        [self.window addSubview:feedbackView];
        [feedbackView setFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
        //NSLog(@"%@",NSStringFromCGRect(self.view.frame));
        [feedbackView setViewContents:self.window.center];
    }
    else
    {
         [self.interstitial loadRequest:request];
    }

}
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [self.interstitial presentFromRootViewController:self.window.rootViewController];
}
#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
}


@end
