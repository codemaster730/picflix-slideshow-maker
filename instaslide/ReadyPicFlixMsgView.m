//
//  ReadyInstagramMsgView.m
//  EasyRepost
//
//  Created by Muhammad Khalid on 12/1/15.
//  Copyright © 2015 Saeed. All rights reserved.
//

#import "ReadyPicFlixMsgView.h"

@implementation ReadyPicFlixMsgView

-(void)setDesign
{
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    self.popupView.layer.cornerRadius=8;
    self.textView.layer.borderColor =[[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1] CGColor];
    self.textView.layer.cornerRadius=8;
    self.textView.layer.borderWidth=1;
    self.textView.textColor =[UIColor lightGrayColor];
    [self.textView setFont:[UIFont systemFontOfSize:11]];
    self.textLabel1.text = [NSString stringWithFormat:@"Select the video from\nyour camera roll inside Instagram"];
    self.textLabel2.text = [NSString stringWithFormat:@"The Caption has been copied.\nPlease paste into Instagram\nCaption to help you\n get more Likes."];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)okButtonPressed:(id)sender {
    [self.parentViewController sharePostOnInstagram];
    [self removeFromSuperview];
}
@end
