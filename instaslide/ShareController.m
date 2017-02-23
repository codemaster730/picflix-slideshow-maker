//
//  ShareController.m
//  instaslide
//
//  Created by axiom88 on 3/4/14.
//  Copyright (c) Created by Black Ace Media Inc. All rights reserved.
//

#import "ShareController.h"
#import "AppDelegate.h"
#import "Facebook.h"
#import "MBProgressHUD.h"
#import "ReadyPicFlixMsgView.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

extern Facebook* gFacebook;

@interface ShareController ()

@end

@implementation ShareController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/1.mov"];
    
    [self addVideoPlayer:path];
}

/*
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [mPlayer seekToTime:kCMTimeZero];
}
*/

-(void)addVideoPlayer:(NSString*) moviePath
{
    /*
    mPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:moviePath]];
    mPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:mPlayer];
    mPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[mPlayer currentItem]];
    mPlayerLayer.frame = CGRectMake(8, 72, 304, 304);
    [self.view.layer addSublayer: mPlayerLayer];
    [mPlayer play];
*/
    
     mPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:moviePath]];
     mPlayer.movieSourceType = MPMovieSourceTypeFile;
     [mPlayer prepareToPlay];
     [[mPlayer view] setFrame: CGRectMake(8, 72, 304, 304)];  // frame must match parent view
     [self.view insertSubview:[mPlayer view] atIndex:0];
     [mPlayer play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onFacebook:(id)sender
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Facebook"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    if (gFacebook.isSessionValid == false)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"posting video..";

        NSArray* permissions = [[NSArray alloc] initWithObjects:
                                @"publish_stream", nil];
        [gFacebook authorize:permissions delegate:self];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"posting video..";
        [self postVideoToFB];
    }
}

-(IBAction)onInstagram:(id)sender
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Instagram"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/1.mov"];
    UISaveVideoAtPathToSavedPhotosAlbum(path, nil, NULL, NULL);
    
    
    ReadyPicFlixMsgView* pickFlixmsgView = (ReadyPicFlixMsgView*)[[[NSBundle mainBundle] loadNibNamed:@"ReadyPicFlixMsgView" owner:self options:nil] objectAtIndex:0];
    [self.view addSubview:pickFlixmsgView];
    
    NSString * caption  = [NSString stringWithFormat:@"#PicFlix #Slideshow #Video made by @getpicflix"];
//    if (media.caption!=nil)
//    {
//        caption = [NSString stringWithFormat:@"%@\n%@",caption,media.caption.text];
//    }
    pickFlixmsgView.textView.text = caption;
    [pickFlixmsgView setDesign];
    pickFlixmsgView.parentViewController = self;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = caption;
    
    
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    pasteboard.string = @"#PicFLIX made with @picflixapp";
//    [[[UIAlertView alloc] initWithTitle:@"PLEASE READ BELOW to post your picflix" message:@"1. select your PicFlix video from camera roll inside instagram app. \n2.Use <Paste> to add the caption which has been copied to the clipboard: #PicFLIX made with @picflixapp" delegate:self cancelButtonTitle:@"Open Instagram" otherButtonTitles:nil] show];
}

-(IBAction)onLibrary:(id)sender
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Library"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/1.mov"];
    UISaveVideoAtPathToSavedPhotosAlbum(path, nil, NULL, NULL);
    
    [[[UIAlertView alloc] initWithTitle:@"PicFlix" message:@"Saved to photo library." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)postVideoToFB
{
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/1.mov"];
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   videoData, @"video.mov",
                                   @"video/quicktime", @"contentType",
                                   @"PicFlix", @"title",
                                   @"Awesome video from PicFlix!", @"description",
								   nil];
	[gFacebook requestWithGraphPath:@"me/videos"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
}

#pragma - mark FB delegate

- (void)fbDidLogin
{
    [self postVideoToFB];
}

-(void)fbDidNotLogin:(BOOL)cancelled
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"PicFlix" message:@"Login Failed"
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	NSLog(@"Result of API call: %@", result);
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    NSLog(@"Failed with error: %@", [error localizedDescription]);
    
    [[[UIAlertView alloc] initWithTitle:@"PicFlix" message:@"Failed to post video to Facebook"
                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

#pragma - mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}
-(void)sharePostOnInstagram
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}


@end
