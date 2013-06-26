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

@interface HomeViewController : UIViewController

- (IBAction)goToContacts:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logout;

- (IBAction)updateButton:(UIButton *)sender;

@property  (strong, nonatomic) Update * update;
@end
