//
//  HomeController.h
//  instaslide
//
//  Created by axiom88 on 3/4/14.
//  Copyright (c) Created by Black Ace Media Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"

@interface HomeController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, ELCImagePickerControllerDelegate>
{
    IBOutlet UIButton* mRestoreButton;
    
    NSMutableArray *mChosenImages;
}

@property(nonatomic, retain)     UIImagePickerController *mPicker;

-(void)onFailedTransaction;
-(void)onSucceededTransaction;

-(IBAction)onRestore:(id)sender;
@end
