//
//  HomeController.m
//  instaslide
//
//  Created by axiom88 on 3/4/14.
//  Copyright (c) Created by Black Ace Media Inc. All rights reserved.
//

#import "HomeController.h"
#import "MKStoreManager.h"
#import "MBProgressHUD.h"
#import "PhotoChooseController.h"
#import <Parse/Parse.h>
#import <RevMobAds/RevMobAds.h>
#import "UAAppReviewManager.h"
#import "iRate.h"

HomeController* gHomeController = nil;

@interface HomeController ()

@end

@implementation HomeController
@synthesize mPicker;

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
    
    PFQuery * query = [PFQuery queryWithClassName:@"Watermarkpopup"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        BOOL popup = NO;
        if (!error) {
            popup = [[object objectForKey:@"show"] boolValue];
            if (popup) {
                BOOL firstRemove = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstRemoveUsed"] boolValue];
                if (!firstRemove ) {
                    [self performSelectorOnMainThread:@selector(showPopupMessage) withObject:nil waitUntilDone:YES];
                }
            }
        }
    }];
    
    gHomeController = self;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FEATURE_AID])
    {
        mRestoreButton.hidden = YES;
    }
    
    mChosenImages = [[NSMutableArray alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
-(void)viewDidAppear:(BOOL)animated
{
    
}
-(void)showPopupMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Leave us a review to remove your next PicFlix Slideshow Watermark for Free!"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    alert.tag=100;
    [alert show];
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 100) {
        if (buttonIndex==0) {
            
        }
        else if (buttonIndex == 1) {
            
            [[iRate sharedInstance] promptForRating];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstRemoveUsed"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"removeWaterMark"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onFailedTransaction
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [[[UIAlertView alloc] initWithTitle:@"Remove Watermark" message:@"Failed to restore, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)onSucceededTransaction
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    mRestoreButton.hidden = YES;
}

-(void)moveToPhotoChooseController
{
    PhotoChooseController* photoChooseController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoChooseController"];
    photoChooseController.mChosenImages = [NSMutableArray arrayWithArray:mChosenImages];
    [self.navigationController pushViewController:photoChooseController animated:YES];
    
    [mChosenImages removeAllObjects];
}

-(IBAction)onStart:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Take a photo?" delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.navigationController.view];
}


-(IBAction)onRestore:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[MKStoreManager sharedManager] restorePurchase];
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
    elcPicker.maximumImagesCount = 50;
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
    
    [mChosenImages addObject:pImage];
    
    [[RevMobAds session] showBanner];
    
    [self moveToPhotoChooseController];
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
	}
    
    [mChosenImages addObjectsFromArray:images];
    
    
    [[RevMobAds session] showBanner];
    
    [self moveToPhotoChooseController];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[RevMobAds session] showBanner];
}

- (IBAction)instagaramButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/likes-tags-instagram-tags/id721697018?mt=8"]];
}
- (IBAction)shoutoutExchangeButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/easyrepost-repost-pictures/id860970702?mt=8"]];
}
- (IBAction)makeMoneyButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://Chamboost.com"]];
}
- (IBAction)createSlideButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/sketch-vid-draw-paint-or-doodle/id791112287?mt=8"]];
}

@end
