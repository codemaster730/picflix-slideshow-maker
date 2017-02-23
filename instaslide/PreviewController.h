//
//  PreviewController.h
//  instaslide
//
//  Created by me on 14/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ANIMATION_REGULAR,
    ANIMATION_LINEAR,
    ANIMATION_STACK,
    ANIMATION_ROTATE
}
ANIMATION_TYPE;

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "MSImageMovieEncoder.h"

@interface PreviewController : UIViewController<MSImageMovieEncoderFrameProvider, MPMediaPickerControllerDelegate>
{
    MSImageMovieEncoder *encoder;
    BOOL mIsEncoding;
    NSTimer *recordingTimer;

    IBOutlet UIView* mPreview;
    IBOutlet UIScrollView* mEffectsScrollView;
    
    ANIMATION_TYPE mCurrentAnimType;
    
    NSMutableArray* mImageViews;
    
    float mGapInterval;
    
    int mImageCount;
    
    IBOutlet UIButton* mPlayButton;
    
    NSTimer* mAnimationTimer;
    
    BOOL isAnimating;
    
    UIImageView* mCurrentView;
    UIImageView* mNextView;
    
    NSDate* mRecordStartTime;
    int mRecordCurrentIndex;
    
    MPMediaPickerController* mMediaPicker;
    AVAudioPlayer* mAudioPlayer;
    
    IBOutlet UIButton* mCheckMusicButton;
    IBOutlet UIButton* mRemoveButton;
    IBOutlet UIButton* mMusicButton;
    IBOutlet UISlider* mStartTimeSlider;
    IBOutlet UILabel* mStartTimeLabel;
    IBOutlet UIButton* mMusicTitleButton;
    
    IBOutlet UIButton* mDefaultButton;
    IBOutlet UIButton* mLinearButton;
    IBOutlet UIButton* mStackButton;
    IBOutlet UIButton* mRotateButton;

    IBOutlet UIView* mSliderContainerView;
    
    IBOutlet UIImageView* mWaterMarkView;
    
    IBOutlet UIButton* mRemoveWatermarkButton;
    
    CGImageRef mWaterMarkCGImage;
}

@property(nonatomic, retain) NSMutableArray* mChosenImages;

-(void)onFailedTransaction;
-(void)onSucceededTransaction;

-(IBAction)onShare:(id)sender;
-(IBAction)onBack:(id)sender;

-(IBAction)onMusic:(id)sender;
-(IBAction)onRemove:(id)sender;
-(IBAction)onSlider:(id)sender;
-(IBAction)onRemoveWatermark:(id)sender;

-(void)onFailedTransaction;
-(void)onSucceededTransaction;

@end
