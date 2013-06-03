//
//  HomeViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize update;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.update = update;
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*- (void) SaveImagesToSql: (NSData*) imgData :( NSString*) mainUrl {
    NSLog( @"\n*****Save image to SQLite*****\n" );
    
    const char* sqliteQuery = "INSERT INTO PEOPLE (FIRSTNAME, LASTNAME, PREFIX, AFFILIATION,  EMAIL, PHOTO, BIOGRAPHY, CALENDARVERSION, DATE) VALUES ('Marta', 'Lidon', 'Dr.', 'FCT', 'marta.lidon@gmail.com', )";
    sqlite3_stmt* statement;
    sqlite3 *db = NULL;
    if( sqlite3_prepare_v2(db, sqliteQuery, -1, &statement, NULL) == SQLITE_OK ) {
        sqlite3_bind_text(statement, 1, [mainUrl UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_blob(statement, 2, [imgData bytes], [imgData length], SQLITE_TRANSIENT);
        sqlite3_step(statement);
    }
    else NSLog( @"SaveBody: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(db) );
    
    // Finalize and close database.
    sqlite3_finalize(statement);
}*/



- (IBAction)updateButton:(UIBarButtonItem *)sender {
    [self.update update];
}

- (IBAction)networkingButton:(UIButton *)sender {
   // NetworkingTableViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"NetworkingTableViewController"];
    //second.previous = self;
    //[self presentViewController:second animated:YES completion:nil];
}


@end
