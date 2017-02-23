//
//  ShareController.h
//  instaslide
//
//  Created by axiom88 on 3/4/14.
//  Copyright (c) Created by Black Ace Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "Facebook.h"

@interface ShareController : UIViewController<FBSessionDelegate, FBRequestDelegate, UIAlertViewDelegate>
{
//    AVPlayer *mPlayer;
//    AVPlayerLayer *mPlayerLayer;
    
    MPMoviePlayerController *mPlayer;
}
-(void)sharePostOnInstagram;
@end
