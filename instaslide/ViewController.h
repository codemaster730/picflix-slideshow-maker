//
//  ViewController.h
//  instaslide
//
//  Created by me on 12/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView* mTableView;
}

-(IBAction)onNew:(id)sender;
-(IBAction)onEdit:(id)sender;
@end
