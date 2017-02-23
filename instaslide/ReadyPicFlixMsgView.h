//
//  ReadyInstagramMsgView.h
//  EasyRepost
//
//  Created by Muhammad Khalid on 12/1/15.
//  Copyright © 2015 Saeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareController.h"

@interface ReadyPicFlixMsgView : UIView
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel1;
@property (weak, nonatomic) IBOutlet UILabel *textLabel2;
- (IBAction)okButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (nonatomic,weak) ShareController *parentViewController;
-(void)setDesign;
@end
