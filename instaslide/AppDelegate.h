//
//  AppDelegate.h
//  instaslide
//
//  Created by me on 12/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@import GoogleMobileAds;


@interface AppDelegate : UIResponder <UIApplicationDelegate,GADInterstitialDelegate>
{
}
@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, strong) id<GAITracker> tracker;
@property (strong, nonatomic) UIWindow *window;
@end
