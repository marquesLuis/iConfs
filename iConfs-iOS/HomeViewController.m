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
    [self createDatabases];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createDatabases{
    
    // feedback
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS FEEDBACKS( ID INTEGER PRIMARY KEY AUTOINCREMENT, FEEDBACK TEXT)" WithName:@"feedbacks.db"];
    
    //messages
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS MESSAGES( ID INTEGER PRIMARY KEY AUTOINCREMENT, MESSAGE TEXT, EMAIL TEXT)" WithName:@"messages.db"];
    
    //notifications
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTIFICATIONS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, NOTIFICATION TEXT, DATE DATETIME)" WithName:@"notifications.db"];
    
    //areas
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AREA(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT)" WithName:@"areas.db"];
    
    //people
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE( ID INTEGER PRIMARY KEY AUTOINCREMENT, FIRSTNAME TEXT, LASTNAME TEXT, PREFIX TEXT, AFFILIATION TEXT, EMAIL TEXT, PHOTO TEXT, BIOGRAPHY TEXT, CALENDARVERSION INTEGER, DATE DATETIME)" WithName:@"people.db"];
    
    //networkings
#warning people is only an integer, not a firegn key...
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NETWORKINGS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, NETWORKING TEXT, DATE DATETIME, PEOPLE INTEGER)" WithName:@"networkings.db"];
    
    //networking key and areas key
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NET_AREA( ID INTEGER PRIMARY KEY AUTOINCREMENT, AREA INTEGER, NETWORKING INTEGER)" WithName:@"networking_area.db"];
    
    //people key and networking key
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE_NET( ID INTEGER PRIMARY KEY AUTOINCREMENT, PEOPLE INTEGER, NETWORKING INTEGER)" WithName:@"people_networking.db"];
    
    //people key and area key
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE_AREA( ID INTEGER PRIMARY KEY AUTOINCREMENT, PEOPLE INTEGER,  AREA INTEGER)" WithName:@"people_area.db"];
    
    
}

- (void) createOrOpenDB:(const char*)sql_stnt WithName:(NSString*)name {
    sqlite3 *feedback;
    
    NSString *s = @"create ";
    s = [s stringByAppendingString:name];
    s = [s stringByAppendingString:@" database"];
    NSLog(@"%@", s);
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    
    NSString *dbPathFeed = [docPath stringByAppendingPathComponent:name];
    
    char *error; //TODO
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:dbPathFeed]){
        const char *dbPath = [dbPathFeed UTF8String];
        
        //creat db
        if(sqlite3_open(dbPath, &feedback)== SQLITE_OK){
            sqlite3_exec(feedback, sql_stnt, NULL, NULL, &error);
            sqlite3_close(feedback);
            
            
            NSString *s = @"table ";
            s = [s stringByAppendingString:name];
            s = [s stringByAppendingString:@" created! =)"];
            NSLog(@"%@", s);
            
        }
    }
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



@end
