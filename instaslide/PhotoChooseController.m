//
//  PhotoChooseController.m
//  instaslide
//
//  Created by me on 14/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import "PhotoChooseController.h"
#import "ELCImagePickerController.h"
#import "PreviewController.h"

#import <QuartzCore/QuartzCore.h>
#import <RevMobAds/RevMobAds.h>

#import "Crittercism.h"

@interface PhotoChooseController ()

@end

@implementation PhotoChooseController
@synthesize mSlideName;
@synthesize mPicker;
@synthesize mChosenImages;

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
    
//    mChosenImages = [[NSMutableArray alloc] init];
    
    for (UIImage *image in mChosenImages) {
        [self addScrollViewForImage:image];
	}
    
    _sidebar.delegate = self;
    [self sidebar:_sidebar didTapImageAtIndex:0];
    self.sidebar.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addScrollViewForImage:(UIImage*) image
{
    if (mScrollViewArrays == nil)
        mScrollViewArrays = [[NSMutableArray alloc] init];

    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, mContainerView.frame.size.width, mContainerView.frame.size.height)];
    scrollView.delegate = self;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = scrollView.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView];
    [mScrollViewArrays addObject:scrollView];
    
    scrollView.zoomScale = 1;
    CGSize orgSize = image.size;
    CGSize bound = mContainerView.frame.size;
    
    float ratio = MAX(bound.width / orgSize.width, bound.height / orgSize.height);
    float width = ratio * orgSize.width;
    float height = ratio * orgSize.height;
    scrollView.contentSize = bound;
    
    if (height > width) {
        scrollView.frame = CGRectMake(0, -(height - width)/2, width, height);
        scrollView.minimumZoomScale = width/height;
        scrollView.contentInset = UIEdgeInsetsMake((height - width)/2, 0, (height - width)/2, 0);
    }
    else
    {
        scrollView.frame = CGRectMake(-(width - height)/2, 0, width, height);
        scrollView.minimumZoomScale = height/width;
        scrollView.contentInset = UIEdgeInsetsMake(0, (width - height)/2, 0, (width - height)/2);
    }
    
    imageView.frame = CGRectMake(0, 0, width, height);
    scrollView.maximumZoomScale = 1 ;
}

#pragma choose photo using UIImagePickerController
-(void)onCamera
{
	UIImagePickerController *con = [[UIImagePickerController alloc] init];

	self.mPicker = con;
    self.mPicker.allowsEditing = YES;
    [self.mPicker setDelegate:self];
    
    self.mPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    self.mPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [self presentViewController:self.mPicker animated:YES completion:^{
        
    }];
}

-(void)onPhotoLibrary
{
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] init];
    elcPicker.maximumImagesCount = 50 - mChosenImages.count;
	elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[RevMobAds session] showBanner];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[RevMobAds session] showBanner];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage*    pImage;
    pImage = ( UIImage* )[ info valueForKey : UIImagePickerControllerEditedImage ] ;
    
    if (mChosenImages.count == 0)
    {
        mSelectedImageView.image = pImage;
    }
    
    [mChosenImages addObject:pImage];
    [self addScrollViewForImage:pImage];
    
    [self sidebar:_sidebar didTapImageAtIndex:mChosenImages.count - 1];
    _sidebar.selectedIndex = mChosenImages.count - 1;
    
    [self.sidebar reloadData];
    [[RevMobAds session] showBanner];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self onCamera];

            [[RevMobAds session] hideBanner];
            
            break;
        case 1:
            [self onPhotoLibrary];

            [[RevMobAds session] hideBanner];
            break;
        default:
            return;
    }
}

#pragma - mark IBActions

-(NSMutableArray*) setupImagesForImage
{
    NSMutableArray* retArray = [[NSMutableArray alloc] init];
    
    UIView* dummyContainer;
    dummyContainer = [[UIView alloc] initWithFrame:mContainerView.frame];
    dummyContainer.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < mChosenImages.count; i++)
    {
        for (UIView *view in dummyContainer.subviews)
        {
            [view removeFromSuperview];
        }
        
        UIScrollView* scrollView = [mScrollViewArrays objectAtIndex:i];
        
        UIView* previousSuperView = [scrollView superview];
        
        [dummyContainer addSubview:scrollView];
        dummyContainer.clipsToBounds = YES;
        
        // IMPORTANT: using weak link on UIKit
        if(UIGraphicsBeginImageContextWithOptions != NULL)
        {
            UIGraphicsBeginImageContextWithOptions(dummyContainer.frame.size, NO, 0.0);
        } else {
            UIGraphicsBeginImageContext(dummyContainer.frame.size);
        }
        
        [dummyContainer.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        [retArray addObject:image];
        UIGraphicsEndImageContext();
        
        [previousSuperView addSubview:scrollView];
    }
    
    return  retArray;
}

-(IBAction)onNext:(id)sender
{
    if (mChosenImages.count == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Choose Photo" message:@"Please choose more than one photo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    PreviewController* previewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewController"];
    previewController.mChosenImages = [self setupImagesForImage];
    [self.navigationController pushViewController:previewController animated:YES];
}

-(IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onAdd:(id)sender
{
    if (mChosenImages.count >= 50)
    {
        [[[UIAlertView alloc] initWithTitle:@"PicFlix" message:@"You've selected a maximum of 50 photos per Slide Show." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Take a photo?" delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.navigationController.view];
}

-(IBAction)onDelete:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"PicFlix" message:@"Do you want to start over?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];
}

#pragma mark UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [mChosenImages removeAllObjects];
            [mScrollViewArrays removeAllObjects];
            [_sidebar reloadData];
            
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    
    if (info.count == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Choose Photo" message:@"Please choose more than one photo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];

    for (NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        [images addObject:image];
        [self addScrollViewForImage:image];
	}
    
    [mChosenImages addObjectsFromArray:images];

    [self.sidebar reloadData];
    
    [self sidebar:_sidebar didTapImageAtIndex:mChosenImages.count - images.count];
    _sidebar.selectedIndex = mChosenImages.count - images.count;
    
    [[RevMobAds session] showBanner];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [[RevMobAds session] showBanner];
}

#pragma mark ELCImagePickerControllerDelegate Methods

-(NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar
{
    int retValue = [mChosenImages count];

    if (retValue == 0) {
        mTipBtn.hidden = NO;
        mAddphotoBtn.hidden = mNextBtn.hidden = mClearBtn.hidden = YES;
        mSelectedImageView.image = nil;
        sidebar.selectedIndex = -1;
    }
    else
    {
        mTipBtn.hidden = YES;
        mAddphotoBtn.hidden = mNextBtn.hidden = mClearBtn.hidden = NO;
    }
    
    return retValue;
}

-(UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex
{
    UIImage* image = [mChosenImages objectAtIndex:anIndex];
    return image;
}

- (void)sidebar:(HSImageSidebarView *)sidebar didMoveImageAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex {
	NSLog(@"Image at index %d moved to index %d", oldIndex, newIndex);
	
	UIImage *imageOld = [mChosenImages objectAtIndex:oldIndex];
	UIImage *imageNew = [mChosenImages objectAtIndex:newIndex];
    [mChosenImages replaceObjectAtIndex:oldIndex withObject:imageNew];
    [mChosenImages replaceObjectAtIndex:newIndex withObject:imageOld];
    
    UIScrollView* scrollViewOld = [mScrollViewArrays objectAtIndex:oldIndex];
    UIScrollView* scrollViewNew = [mScrollViewArrays objectAtIndex:newIndex];
    [mScrollViewArrays replaceObjectAtIndex:oldIndex withObject:scrollViewNew];
    [mScrollViewArrays replaceObjectAtIndex:newIndex withObject:scrollViewOld];
}

- (void)sidebar:(HSImageSidebarView *)sidebar didRemoveImageAtIndex:(NSUInteger)anIndex
{
	NSLog(@"Image at index %d removed", anIndex);

//    if (anIndex == sidebar.selectedIndex)
//    {
//        mSelectedImageView.image = nil;
//    }
    
	[mChosenImages removeObjectAtIndex:anIndex];
    [mScrollViewArrays removeObjectAtIndex:anIndex];

    [_sidebar reloadData];
}

- (void)centerScrollViewContents {
    if (mSelectedImageView.frame.size.width < mSelectedImageView.frame.size.height) {
        mSelectedImageView.center = CGPointMake(mContainerView.frame.size.width / 2, mSelectedImageView.center.y);
    }
    else
        mSelectedImageView.center = CGPointMake(mSelectedImageView.center.x, mContainerView.frame.size.height/ 2);
    return;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

-(void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex
{
    if (anIndex == _sidebar.selectedIndex) {
        return;
    }

    if (mEditPhotoScrollView.superview == mContainerView) {
        [mEditPhotoScrollView removeFromSuperview];
    }
    
    mEditPhotoScrollView = [mScrollViewArrays objectAtIndex:anIndex];
    mSelectedImageView = [[mEditPhotoScrollView subviews] firstObject];
    
    [mContainerView insertSubview:mEditPhotoScrollView belowSubview:mTipBtn];
    
    CGFloat origScale = mEditPhotoScrollView.zoomScale;
    mEditPhotoScrollView.zoomScale = 0;
    mEditPhotoScrollView.zoomScale = origScale;

}

#pragma - mark delegate for UIScrollView

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mSelectedImageView;
}

@end
