//
//  SearchViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 21/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Search.h"
#import "Person.h"
#import "NetworkingViewController.h"
#import "PersonProfileViewController.h"
#import "EventUIViewController.h"
#import "NoteViewController.h"

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITextField *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *resultsOfSearch;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)doSearch:(UIButton *)sender;

@end
