//
//  AllNetworkingViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 05/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "Networking.h"
#import "sqlite3.h"
#import "NetworkingViewController.h"

@interface AllNetworkingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableNetworking;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;


@end
