//
//  HistoryCell.m
//  instaslide
//
//  Created by me on 12/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import "HistoryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation HistoryCell
@synthesize mDotView, mLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)awakeFromNib
{
    mDotView.layer.cornerRadius = 6;
}

@end
