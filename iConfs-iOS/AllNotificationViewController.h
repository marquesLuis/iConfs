//
//  AllNotificationViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 05/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "NotificationViewController.h"
#import "Notification.h"

@interface AllNotificationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableNotifications;

@end


