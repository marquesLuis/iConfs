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
}

- (void) createOrOpenDB:(const char*)sql_stnt WithName:(NSString*)name {
    sqlite3 *feedback;
    
    NSString *s = @"create";
    s = [s stringByAppendingString:name];
    s = [s stringByAppendingString:@"database"];
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
            
            
            NSString *s = @"table";
            s = [s stringByAppendingString:name];
            s = [s stringByAppendingString:@"created! =)"];
            NSLog(@"%@", s);
            
        }
    }
}

@end
