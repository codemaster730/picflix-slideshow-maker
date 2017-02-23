//
//  FeedbackView.h
//  EasyRepost
//
//  Created by Muhammad Khalid on 12/29/15.
//  Copyright © 2015 Saeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackView : UIView

@property (weak, nonatomic) IBOutlet UIView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UIButton *star1;
@property (weak, nonatomic) IBOutlet UIButton *star2;
@property (weak, nonatomic) IBOutlet UIButton *star3;
@property (weak, nonatomic) IBOutlet UIButton *star4;
@property (weak, nonatomic) IBOutlet UIButton *star5;

-(void)setViewContents:(CGPoint)center;
- (IBAction)starTapped:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)rateButtonPressed:(id)sender;
@end
