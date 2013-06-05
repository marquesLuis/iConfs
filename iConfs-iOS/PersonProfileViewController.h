//
//  PersonProfileViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 02/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "sqlite3.h"
#import "Networking.h"
#import "NetworkingViewController.h"

@interface PersonProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString * personID;
@property (strong, nonatomic) IBOutlet UITableView *tableNetworking;

- (IBAction)goBack:(UIBarButtonItem *)sender;

@end
