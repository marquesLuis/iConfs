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
//@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
//- (IBAction)goBack:(UIBarButtonItem *)sender;
//@property (strong, nonatomic) UIViewController * previous;
@property (strong, nonatomic) NSString * personID;
@end
