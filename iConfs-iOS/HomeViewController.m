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
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.update = [[Update alloc] initDB];
    
    
    
    
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
#warning passar email da pessoa
   // NetworkingTableViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"NetworkingTableViewController"];
    //second.previous = self;
    //[self presentViewController:second animated:YES completion:nil];
}



-(int)getInfoIcon:(NSString*)database withTableName:(NSString*)tableName{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:database];
    int last_row = 0;
    if (sqlite3_open([dbPathString UTF8String], &db) == SQLITE_OK) {
        NSString *querySql = [NSString stringWithFormat:@"%@%@", @"SELECT COUNT(*) FROM ", tableName];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *messageID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                last_row = [messageID integerValue];
                
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(db);
       
    }
    NSLog(@"%d",last_row );
    return last_row;
}



-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"segue7" ]) {
        if([self getInfoIcon:@"location.db" withTableName:@"LOCATION"] == 0){
            [self alertMessages:@"There's no maps available" withMessage:@""];
            return NO;
        }
    } else if([identifier isEqualToString:@"segue1" ]){
        if([self getInfoIcon:@"networkings.db" withTableName:@"NETWORKINGS"] == 0){
            [self alertMessages:@"There's no topics available" withMessage:@""];
            return NO;
        }
    }
    
    return YES;
}

@end
