//
//  HomeViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Update.h"
#import "sqlite3.h"
#import "KNMultiItemSelector.h"
#import "NetworkingTableViewController.h"
#import "PersonalProgramTKCalendarDayViewController.h"

@interface HomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *logout;
@property  (strong, nonatomic) Update * update;

- (IBAction)updateButton:(UIButton *)sender;
@end
