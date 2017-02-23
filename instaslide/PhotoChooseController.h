//
//  PhotoChooseController.h
//  instaslide
//
//  Created by me on 14/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "HSImageSidebarView.h"

@interface PhotoChooseController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, ELCImagePickerControllerDelegate, HSImageSidebarViewDelegate, UIAlertViewDelegate>
{
    UIScrollView* mEditPhotoScrollView;
    UIImageView* mSelectedImageView;
    IBOutlet UILabel* mTitleLabel;
    IBOutlet UIButton* mTipBtn;
    NSMutableArray *mScrollViewArrays;
    
    HSImageSidebarView *_sidebar;
    
    IBOutlet UIButton* mClearBtn;
    IBOutlet UIButton* mAddphotoBtn;
    IBOutlet UIButton* mNextBtn;
    
    IBOutlet UIView* mContainerView;
}

@property(nonatomic, retain) NSMutableArray *mChosenImages;
@property(nonatomic, retain) NSString* mSlideName;
@property(nonatomic, retain)     UIImagePickerController *mPicker;

@property (nonatomic, strong) IBOutlet HSImageSidebarView *sidebar;

-(IBAction)onNext:(id)sender;
-(IBAction)onBack:(id)sender;
-(IBAction)onAdd:(id)sender;
-(IBAction)onDelete:(id)sender;


@end
