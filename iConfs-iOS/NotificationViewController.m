//
//  NotificationViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController () {
    
    
} @end

@implementation NotificationViewController
@synthesize notificationTitle, notificationText, notificationContent, notificationDateContent;

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
	// Do any additional setup after loading the view.
    
    self.title = notificationTitle;
    [self.notificationText setEditable:NO];
    self.notificationText.text = notificationContent;
    self.notificationDate.text = notificationDateContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
 
 // create the parent view that will hold header Label
 UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10,0,300,60)] ;
 
 // create image object
 UIImage *myImage = [UIImage imageNamed:@"someimage.png"];;
 
 // create the label objects
 UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
 headerLabel.backgroundColor = [UIColor clearColor];
 headerLabel.font = [UIFont boldSystemFontOfSize:18];
 headerLabel.frame = CGRectMake(70,18,200,20);
 headerLabel.text =  @"Some Text";
 headerLabel.textColor = [UIColor redColor];
 
 UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
 detailLabel.backgroundColor = [UIColor clearColor];
 detailLabel.textColor = [UIColor darkGrayColor];
 detailLabel.text = @"Some detail text";
 detailLabel.font = [UIFont systemFontOfSize:12];
 detailLabel.frame = CGRectMake(70,33,230,25);
 
 // create the imageView with the image in it
 UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
 imageView.frame = CGRectMake(10,10,50,50);
 
 [customView addSubview:imageView];
 [customView addSubview:headerLabel];
 [customView addSubview:detailLabel];
 
 return customView;
 }
 
 */
@end
