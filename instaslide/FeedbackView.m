//
//  FeedbackView.m
//  EasyRepost
//
//  Created by Muhammad Khalid on 12/29/15.
//  Copyright © 2015 Saeed. All rights reserved.
//

#import "FeedbackView.h"
#import "iRate.h"

#define URLEMail @"mailto:hi@Tapinja.com?subject=Suggestion for PicFlix"

@implementation FeedbackView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)setViewContents:(CGPoint)center
{
    NSLog(@"%@",NSStringFromCGRect(self.frame));
    //self.rateView.center = center;
    //self.feedbackLabel.frame = CGRectMake(-20, 0, self.frame.size.width, 21);
    //self.feedbackLabel.text= @"bc chal par";
}
- (IBAction)starTapped:(id)sender {
    UIButton * star = (UIButton *)sender;
    
    if (!star.selected) {
        for (int i=1; i<=star.tag; i++) {
            UIButton * button = (UIButton*)[self viewWithTag:i];
            button.selected = YES;
        }
    }
    else
    {
        for (int i=(int)star.tag; i<=5; i++) {
            UIButton * button = (UIButton*)[self viewWithTag:i];
            button.selected = NO;
        }
    }
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)rateButtonPressed:(id)sender {
    
    if(!self.star1.selected) {
        return;
    }
    else if (self.star4.selected || self.star5.selected)
    {
        [[iRate sharedInstance] promptForRating];
        [self removeFromSuperview];
    }
    else{
        
        NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
        [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
        [self removeFromSuperview];
        
    }
}
@end
