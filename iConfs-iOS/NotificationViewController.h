//
//  NotificationViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Notification.h"

@interface NotificationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) IBOutlet UILabel *notificationName;

@property (strong, nonatomic) IBOutlet UILabel *notificationDate;
@property (strong, nonatomic) IBOutlet UITextView *notificationText;

@property int numNotification;

@property (strong, nonatomic) NSString * notificationTitle;
@property (strong, nonatomic) NSString * notificationDateContent;
@property (strong, nonatomic) NSString * notificationContent;

@end
