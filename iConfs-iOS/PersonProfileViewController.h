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
#import "Note.h"
#import "NoteViewController.h"

@interface PersonProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString * personID;
@property (strong, nonatomic) IBOutlet UITableView *tableNetworking;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addNote;

@end
