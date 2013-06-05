//
//  NotificationTableViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 31/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
@interface NotificationTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (IBAction)goHome:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableNotification;

@end
