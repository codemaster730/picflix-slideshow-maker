//
//  ViewController.m
//  instaslide
//
//  Created by me on 12/11/13.
//  Copyright (c) 2013 Axiom88. All rights reserved.
//

#import "ViewController.h"
#import "HistoryCell.h"
#import "PhotoChooseController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if (buttonIndex == 0)
    {
    }
    else
    {
        if (alertView.tag == 0)
        {
            UITextField* tf = [alertView textFieldAtIndex:0];
            NSString* slideName = tf.text;
            
            PhotoChooseController* photoChooseController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoChooseController"];
            photoChooseController.mSlideName = slideName;
            [self.navigationController pushViewController:photoChooseController animated:YES];
        }
    }
}


#pragma - mark IBActions

-(IBAction)onNew:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Slide Name" message:@"Enter your new slide name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

-(IBAction)onEdit:(id)sender
{
    mTableView.editing = YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    cell.mLabel.text = [NSString stringWithFormat:@"Slide History %d", indexPath.row];
    return cell;
}

@end
