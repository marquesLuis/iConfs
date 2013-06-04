//
//  NetworkingTableViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 01/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkingViewController.h"
#import "HomeViewController.h"
#import "Person.h"

@interface NetworkingTableViewController : UITableViewController

- (IBAction)goHome:(UIBarButtonItem *)sender;
- (IBAction)changeToAllOrPref:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *prefOrAllButton;
@property (strong, nonatomic) NSString * personID;


@end
