//
//  PreviewController.m
//  instaslide
//
//  Created by me on 14/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import "PreviewController.h"
#import "MBProgressHUD.h"
#import "MKStoreManager.h"
#import "ShareController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Parse/Parse.h>
#import "UAAppReviewManager.h"

#define RATE_PHOTO_GAP 3.f
#define FRAMES_PER_SECOND 30

PreviewController* gPreviewController = nil;

@interface PreviewController ()

@end

@implementation PreviewController
@synthesize mChosenImages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initImageViewPositions
{
    float width = mPreview.frame.size.width;

    for (int i = 0; i < mImageCount; i++)
    {
        UIImageView* imageView = [mImageViews objectAtIndex:i];
        imageView.transform = CGAffineTransformIdentity;
        if (i == 0)
        {
            imageView.frame = CGRectMake(0, 0, width, width);
        }
        else
        {
            imageView.frame = CGRectMake(width, 0, width, width);
        }
        imageView.hidden = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [self loadViewContents];
    
    
}
-(void)loadViewContents
{
    gPreviewController = self;
    
    mCurrentAnimType = ANIMATION_REGULAR;
    mImageCount = [mChosenImages count];
    
    mImageViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < mImageCount; i++)
    {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[mChosenImages objectAtIndex:i]];
        [mImageViews addObject:imageView];
        [mPreview addSubview:imageView];
    }
    
    [mPreview bringSubviewToFront:mPlayButton];
    
    [self initImageViewPositions];
    
    mGapInterval = 15 / (mImageCount * RATE_PHOTO_GAP + mImageCount - 1);
    
    mAudioPlayer = nil;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FEATURE_AID])
    {
        mWaterMarkView.hidden = YES;
        mRemoveWatermarkButton.hidden = YES;
    }
    
    if (self.view.frame.size.height >  480)
    {
        mEffectsScrollView.center = CGPointMake(mEffectsScrollView.center.x, mEffectsScrollView.center.y - 25);
    }
    
    mDefaultButton.selected = YES;
    //mWaterMarkCGImage = CGImageRetain([[UIImage alloc]initWithContentsOfFile:@"watermark@2x.png"].CGImage);
    mWaterMarkCGImage = [UIImage imageNamed:@"watermark@2x.png"].CGImage;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewDidAppear:(BOOL)animated
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    BOOL isRemoveWaterMark = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeWaterMark"];
    if (isRemoveWaterMark) {
        mWaterMarkView.hidden = YES;
        mRemoveWatermarkButton.hidden = YES;
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"removeWaterMark"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)functionAfterDuration:(NSTimer*)timer
{
    NSNumber* numberIndex = timer.userInfo;
    
    NSLog(@"%@", NSStringFromClass(numberIndex.class));
    
    int index = numberIndex.integerValue;
    float width = mPreview.frame.size.width;
    
    if (index + 1 < mImageCount)
    {
        mCurrentView = [mImageViews objectAtIndex:index];
        mNextView = [mImageViews objectAtIndex:index + 1];
        
        switch (mCurrentAnimType) {
            case ANIMATION_REGULAR:
            {
                isAnimating = NO;
                
                mNextView.center = CGPointMake(mCurrentView.center.x, mCurrentView.center.y);
                mCurrentView.center = CGPointMake(mCurrentView.center.x - width, mCurrentView.center.y);
                
                [self animateForIndex:[NSNumber numberWithInt:index + 1]];
            }
                break;
                
            case ANIMATION_LINEAR:
            {
                isAnimating = YES;
                
                [UIView animateWithDuration:mGapInterval
                                 animations:
                 ^{
                     mNextView.center = CGPointMake(mCurrentView.center.x, mCurrentView.center.y);
                     mCurrentView.center = CGPointMake(mCurrentView.center.x - width, mCurrentView.center.y);
                 }
                                 completion:
                 ^(BOOL finished) {
                     isAnimating = NO;
                     [self animateForIndex:[NSNumber numberWithInt:index + 1]];
                 }];
            }
                break;
                
            case ANIMATION_STACK:
            {
                isAnimating = YES;

                [UIView animateWithDuration:mGapInterval
                                 animations:
                 ^{
                     mNextView.center = CGPointMake(mCurrentView.center.x, mCurrentView.center.y);
                 }
                                 completion:
                 ^(BOOL finished) {
                     isAnimating = NO;
                     [self animateForIndex:[NSNumber numberWithInt:index + 1]];
                 }];
            }
                break;
            case ANIMATION_ROTATE:
            {
                isAnimating = YES;

                mNextView.center = mCurrentView.center;
                mNextView.hidden = YES;
                [UIView animateWithDuration:mGapInterval / 2
                                 animations:
                 ^{
                     mCurrentView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(3.14), 5, 5);
                     mNextView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(3.14), 5, 5);
                 }
                                 completion:
                 ^(BOOL finished) {
                     mCurrentView.hidden = YES;
                     mNextView.hidden = NO;
                     [UIView animateWithDuration:mGapInterval / 2
                                      animations:^{
                                          mNextView.transform = CGAffineTransformIdentity;
                                      } completion:^(BOOL finished) {
                                          
                                          isAnimating = NO;

                                          [self animateForIndex:[NSNumber numberWithInt:index + 1]];
                                      }];
                     
                 }];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        [self initImageViewPositions];
        
        mPlayButton.hidden = NO;
        [mAudioPlayer stop];
        
        if (recordingTimer.isValid) {
            [recordingTimer invalidate];
        }
        recordingTimer = nil;
        
        return;
    }
}

-(void)animateForIndex:(NSNumber*)numberIndex
{
    float delay;
    
    if (mCurrentAnimType == ANIMATION_REGULAR)
    {
        delay = 15.f/ mImageCount;
    }
    else
    {
        delay = mGapInterval * RATE_PHOTO_GAP;
    }
    
    mAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(functionAfterDuration:) userInfo:numberIndex repeats:NO];
}

- (void)setupEncoder
{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/1.mov"];
    NSLog(@"%@\n", path);
    
    NSURL *url = [NSURL fileURLWithPath:path];
    [[NSFileManager defaultManager] removeItemAtPath:url.path error:nil];
    
    int VIDEOWIDTH = mPreview.frame.size.width * 2;
    int VIDEOHEIGHT = mPreview.frame.size.height * 2;
    
    encoder = [[MSImageMovieEncoder alloc] initWithURL:url andFrameSize:CGSizeMake(VIDEOWIDTH, VIDEOHEIGHT) andFrameDuration:CMTimeMake(1, FRAMES_PER_SECOND)];
    encoder.frameDelegate = self;
    
    [encoder startRequestingFrames];
    
    mIsEncoding = YES;
    
    mRecordStartTime = [NSDate date];
    mRecordCurrentIndex = 0;
}

- (void)movieEncoderDidFailWithReason:(NSString*)reason
{
    NSLog(@"%@", reason);
    
    [recordingTimer invalidate];
}

- (void)movieEncoderDidFinishAddingFrames
{
    [recordingTimer invalidate];

    NSLog(@"Added");
}

- (void)movieEncoderDidFinishEncoding
{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/1.mov"];
    if (mAudioPlayer == nil)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        ShareController* shareController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareController"];
        [self.navigationController pushViewController:shareController animated:YES];
    }
    else
    {
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:mAudioPlayer.url options:nil];
        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:path] options:nil];
        
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        
        AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(mStartTimeSlider.value, 1), CMTimeMakeWithSeconds(15, 1))
                                                ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                                 atTime:kCMTimeZero error:nil];
        
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                       ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                        atTime:kCMTimeZero error:nil];
        
        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                              presetName:AVAssetExportPresetPassthrough];
        
        NSString* videoName = @"export.mov";
        
        NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
        NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
        }
        
        _assetExport.outputFileType = @"com.apple.quicktime-movie";
        NSLog(@"file type %@",_assetExport.outputFileType);
        _assetExport.outputURL = exportUrl;
        _assetExport.shouldOptimizeForNetworkUse = YES;
        
        [_assetExport exportAsynchronouslyWithCompletionHandler:
         ^(void )
         {
             dispatch_sync(dispatch_get_main_queue(), ^{

                 [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                 [[NSFileManager defaultManager] copyItemAtPath:exportPath toPath:path error:nil];

                 [MBProgressHUD hideHUDForView:self.view animated:YES];

                 ShareController* shareController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareController"];
                 [self.navigationController pushViewController:shareController animated:YES];
             });
         }];
    }
}

- (BOOL)nextFrameInBGRCGBitmapContext:(CGContextRef *)contextRef
{
    int quality = 2;
    double recordTick = (double)encoder.currentTime.value / FRAMES_PER_SECOND;
    
    encoder.currentTime = CMTimeAdd(encoder.currentTime, CMTimeMake(1, FRAMES_PER_SECOND));
    //    double recordTick = [[NSDate date] timeIntervalSinceDate:mRecordStartTime];
    
    CGContextRef context = *contextRef;
    
    int N = (int)[mChosenImages count];
    
    CGContextSaveGState(context);
    
    if (mIsEncoding)
    {
        if (mCurrentAnimType == ANIMATION_REGULAR)
        {
            float dur = 15.f / N;
            
            if (15.f <= recordTick)
            {
                mIsEncoding = NO;
                return NO;
            }
            else if (dur * (mRecordCurrentIndex + 1) < recordTick)
            {
                mRecordCurrentIndex++;
                
                UIImage* image = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                CGContextDrawImage(*contextRef, CGRectMake(0, 0, 306 * quality, 306*quality), image.CGImage);
                goto YESLABEL;
            }
            else
            {
                UIImage* image = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                CGContextDrawImage(context, CGRectMake(0, 0, 306 * quality, 306 * quality), image.CGImage);
                goto YESLABEL;
            }
        }
        else if (mCurrentAnimType == ANIMATION_ROTATE)
        {
            float dur = mGapInterval * RATE_PHOTO_GAP;
            
            if (15.f <= recordTick) {
                mIsEncoding = NO;
                return NO;
            }
            else if (dur * (mRecordCurrentIndex + 1) + mGapInterval * (mRecordCurrentIndex+1) < recordTick)
            {
                mRecordCurrentIndex++;
                
                UIImage* image = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                CGContextDrawImage(context, CGRectMake(0, 0, 306 * quality, 306 * quality), image.CGImage);
                goto YESLABEL;
            }
            else if (dur * (mRecordCurrentIndex + 1) + mGapInterval * mRecordCurrentIndex < recordTick)
            {
                float intervalSinceGapStart = recordTick - (dur * (mRecordCurrentIndex + 1) + mGapInterval * mRecordCurrentIndex);
                UIImage* currentImage = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                UIImage* nextImage = [mChosenImages objectAtIndex:mRecordCurrentIndex+1];
                
                float halfWidth = CGContextGetClipBoundingBox(context).size.width/2;
                float halfHeight = CGContextGetClipBoundingBox(context).size.height/2;
                
                CGContextTranslateCTM(context, halfWidth, halfHeight);
                
                
                if (intervalSinceGapStart <  mGapInterval / 2)
                {
                    float scaleFactor = 1 + intervalSinceGapStart * 2 * 4 / mGapInterval;
                    CGContextScaleCTM(context, scaleFactor, scaleFactor);
                    
                    CGContextRotateCTM(context, intervalSinceGapStart * 3.14 * 2 / mGapInterval);
                    CGContextDrawImage(context, CGRectMake(- halfWidth, - halfHeight, 306 * quality, 306 * quality), currentImage.CGImage);
                }
                else
                {
                    float scaleFactor = 1 + 4 * (2 - intervalSinceGapStart * 2/ mGapInterval);
                    CGContextScaleCTM(context, scaleFactor, scaleFactor);
                    
                    CGContextRotateCTM(context, (2 - intervalSinceGapStart * 2/ mGapInterval) * 3.14);
                    CGContextDrawImage(context, CGRectMake(- halfWidth, - halfHeight, 306 * quality, 306 * quality), nextImage.CGImage);
                }
                goto YESLABEL;
            }
            else
            {
                UIImage* image = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                CGContextDrawImage(context, CGRectMake(0, 0, 306 * quality, 306 * quality), image.CGImage);
                goto YESLABEL;
            }
        }
        else if (mCurrentAnimType == ANIMATION_LINEAR || mCurrentAnimType == ANIMATION_STACK)
        {
            float dur = mGapInterval * RATE_PHOTO_GAP;
            
            if (15.f <= recordTick) {
                mIsEncoding = NO;
                return NO;
            }
            else if (dur * (mRecordCurrentIndex + 1) + mGapInterval * (mRecordCurrentIndex+1) < recordTick)
            {
                mRecordCurrentIndex++;
                
                UIImage* image = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                CGContextDrawImage(context, CGRectMake(0, 0, 306 * quality, 306 * quality), image.CGImage);
                goto YESLABEL;
            }
            else if (dur * (mRecordCurrentIndex + 1) + mGapInterval * mRecordCurrentIndex < recordTick)
            {
                float intervalSinceGapStart = recordTick - (dur * (mRecordCurrentIndex + 1) + mGapInterval * mRecordCurrentIndex);
                UIImage* currentImage = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                UIImage* nextImage = [mChosenImages objectAtIndex:mRecordCurrentIndex+1];
                if (mCurrentAnimType == ANIMATION_LINEAR)
                {
                    CGContextDrawImage(context, CGRectMake(-306 * intervalSinceGapStart / mGapInterval * quality, 0, 306 * quality, 306 * quality), currentImage.CGImage);
                }
                else
                    CGContextDrawImage(context, CGRectMake(0, 0, 306 * 2, 306 * 2), currentImage.CGImage);
                
                CGContextDrawImage(context, CGRectMake(306 * quality * (1 - intervalSinceGapStart / mGapInterval), 0, 306 * quality, 306 * quality), nextImage.CGImage);
                goto YESLABEL;
            }
            else
            {
                UIImage* image = [mChosenImages objectAtIndex:mRecordCurrentIndex];
                CGContextDrawImage(context, CGRectMake(0, 0, 306 * quality, 306 * quality), image.CGImage);
                goto YESLABEL;
            }
        }
        else
        {
            return NO;
        }
    }
    else
        return NO;
    
YESLABEL:
    CGContextRestoreGState(context);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FEATURE_AID] == false)
    {
        if (!mWaterMarkView.hidden) {
            CGContextDrawImage(context, CGRectMake(208*quality - 32 , 5*quality, 109 * 2, 27 * 2), mWaterMarkCGImage);
        }
        
    }
    return YES;
}
-(void)updateRecording
{
//    encoder.currentTime = CMTimeAdd(encoder.currentTime, CMTimeMake(1, FRAMES_PER_SECOND));
//    NSLog(@"%lld\n", encoder.currentTime.value);
}

#pragma - mark IBActions

-(void)stopCurrentPreview
{
    if (mAnimationTimer != nil && [mAnimationTimer isValid])
    {
        [mAnimationTimer invalidate];
        mAnimationTimer = nil;
    }
    
    [self initImageViewPositions];
    
    mPlayButton.hidden = NO;

    [mAudioPlayer stop];
}

-(IBAction)onPlay:(id)sender
{
    mPlayButton.hidden = YES;

    [self animateForIndex:[NSNumber numberWithInt:0]];
    
    [mAudioPlayer play];
    
    mAudioPlayer.currentTime = mStartTimeSlider.value;
}

-(IBAction)onShare:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setupEncoder];
    });
    
    
//    [self updateRecording];
//
//    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f / FRAMES_PER_SECOND target:self selector:@selector(updateRecording) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:recordingTimer forMode:NSRunLoopCommonModes];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Exporting Video...";
}

-(IBAction)onChangeAnimation:(id)sender
{
    mDefaultButton.selected = NO;
    mLinearButton.selected = NO;
    mStackButton.selected = NO;
    mRotateButton.selected = NO;
    
    mCurrentAnimType = [sender tag];
    
    switch (mCurrentAnimType) {
        case 0:
            mDefaultButton.selected = YES;
            break;
        case 1:
            mLinearButton.selected = YES;
            break;
        case 2:
            mStackButton.selected = YES;
            break;
        case 3:
            mRotateButton.selected = YES;
            break;
        default:
            break;
    }
    
    [self stopCurrentPreview];
}

-(IBAction)onBack:(id)sender
{
    mIsEncoding = NO;
    if (recordingTimer.isValid) {
        [recordingTimer invalidate];
    }
    recordingTimer = nil;
    
    [self stopCurrentPreview];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    gPreviewController = nil;
}

-(IBAction)onMusic:(id)sender
{
    [self stopCurrentPreview];
    
    mMediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mMediaPicker.delegate = self;
    mMediaPicker.allowsPickingMultipleItems = NO;
    [self presentViewController:mMediaPicker animated:YES completion:^{
        
    }];
}

-(IBAction)onCheck:(id)sender
{
    mRemoveWatermarkButton.hidden = NO;
    mEffectsScrollView.hidden = NO;
    mMusicButton.hidden = NO;
    mSliderContainerView.hidden = YES;
}


-(IBAction)onRemove:(id)sender
{
    mRemoveWatermarkButton.hidden = NO;
    mEffectsScrollView.hidden = NO;
    mMusicButton.hidden = NO;
    mAudioPlayer = nil;
    mSliderContainerView.hidden = YES;
}

-(NSString*)formattedTime:(int)value
{
    return [NSString stringWithFormat:@"%02d:%02d", value / 60, value %60];
}

-(IBAction)onSlider:(id)sender
{
    NSString* startTimeString = [self formattedTime:mStartTimeSlider.value];
    
    int endTime = (mAudioPlayer.duration > mStartTimeSlider.value+15)?(mStartTimeSlider.value+15) :(mAudioPlayer.duration);
    
    NSString* endTimeString = [self formattedTime:endTime];
    mStartTimeLabel.text = [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];
    mAudioPlayer.currentTime = mStartTimeSlider.value;
    
    [self stopCurrentPreview];
}

#pragma - mark Media Picker Delegate Methods

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem* selectedItem = [mediaItemCollection representativeItem];
    NSURL* assetURL = [selectedItem valueForProperty:MPMediaItemPropertyAssetURL];
    NSString* title = [selectedItem valueForProperty:MPMediaItemPropertyTitle];
    
    NSLog(@"title : %@ - %@\n", title, assetURL);
    
    mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:nil];
    
    mSliderContainerView.hidden = NO;
    mRemoveWatermarkButton.hidden = YES;
    mEffectsScrollView.hidden = YES;
    mMusicButton.hidden = YES;
    mStartTimeSlider.maximumValue = mAudioPlayer.duration;
    
    [mMusicTitleButton setTitle:title forState:UIControlStateNormal];
    
    mStartTimeSlider.value = 0;
    mStartTimeLabel.text = @"00:00 - 00:15";
    
    [mMediaPicker dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)onMusicTitle:(id)sender
{
    [self onMusic:nil];
}

-(IBAction)onRemoveWatermark:(id)sender
{
    [[MKStoreManager sharedManager] buyFeatureA];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [mMediaPicker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma - mark In App Manager Delegates

-(void)onFailedTransaction
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Remove Watermark" message:@"Failed to purchase, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)onSucceededTransaction
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    mWaterMarkView.hidden = YES;
    mRemoveWatermarkButton.hidden = YES;
}

@end
