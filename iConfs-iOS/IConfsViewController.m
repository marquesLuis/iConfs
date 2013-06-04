//
//  IConfsViewController.m
//  iConfs-iOS
//
//  Created by Luis Marques on 5/29/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "IConfsViewController.h"
#import "Update.h"

@interface IConfsViewController (){

} @end

@implementation IConfsViewController

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
    [self treatKeyboard];
    [self createDatabases];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Handles a recognized single tap gesture.
 */
- (void) handleTapFrom: (UITapGestureRecognizer *) recognizer {
    // hide the keyboard
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
}

/*
 * single tap to resign (hide) the keyboard
 */
- (void) treatKeyboard {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapRecognizer];
}

- (IBAction)loginButton:(UIButton *)sender {
    //TODO
    NSString *email = @"lfmarques2@gmail.com";
    NSString *password = @"123123123";
    
    if (self.emailField.text.length || self.passwordField.text.length){
        email = self.emailField.text;
        password = self.passwordField.text;
    }
    
    // [self postRquest];
    
    NSError *error;
    //First build up the JSON body for login
    
    NSString *initial = @"%@update/login";
    NSString *initialArgs = @"?registry[email]=";
    NSString *withEmail = [initialArgs stringByAppendingString:email];
    NSString *passStart = [withEmail stringByAppendingString:@"&registry[password]="];
    NSString *completeArgs = [passStart stringByAppendingString:password];
    
    NSString *completeLink = [initial stringByAppendingString:completeArgs];
    
    //I send a POST url request
    NSString *postUrlString = [NSString stringWithFormat:completeLink, @"http://0.0.0.0:3000/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: postUrlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"]; 
  
   /* @try {
        // Try something
    
    // Send a synchronous request
    NSURLResponse * response = nil;
    NSData * returnData = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
    NSString* newStr = [NSString stringWithUTF8String:[returnData bytes]];
    
    NSLog(@"%@", newStr);
    if ([newStr hasPrefix:@"<!DOCTYPE html>"]|| newStr==NULL)
    {
        [self alertMessages:@"Error on Login" withMessage:@"Something went wrong on your login :("];
        return;
    }
    }
    @catch (NSException * e) {
        [self alertMessages:@"Failed Connection" withMessage:@"Check your internet connection"];
        return;
    }*/
    
    Update *update = [[Update alloc] initWithParams:completeArgs];
    [update update];
    
    
    //change view
    HomeViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    second.update = update;
    [self presentViewController:second animated:YES completion:nil];
     
    
}

-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) createDatabases{
    
    // feedback
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS FEEDBACKS( ID INTEGER PRIMARY KEY AUTOINCREMENT, FEEDBACK TEXT)" WithName:@"feedbacks.db"];
    
    //messages
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS MESSAGES( ID INTEGER PRIMARY KEY AUTOINCREMENT, MESSAGE TEXT, EMAIL TEXT)" WithName:@"messages.db"];
    
    //notifications
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTIFICATIONS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, NOTIFICATION TEXT, DATE TEXT, SERVER_ID INTEGER)" WithName:@"notifications.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTIFICATIONS_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"notifications_status.db"];
    
    //areas
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AREAS(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, SERVER_ID INTEGER)" WithName:@"areas.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AREAS_STATUS(ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER)" WithName:@"areas_status.db"];
    
    //people
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE( ID INTEGER PRIMARY KEY AUTOINCREMENT, FIRSTNAME TEXT, LASTNAME TEXT, PREFIX TEXT, AFFILIATION TEXT, EMAIL TEXT, PHOTO TEXT, BIOGRAPHY TEXT, SERVER_ID INTEGER, LAST_DATE TEXT, INFO_LAST_DATE TEXT, HAS_PRIVATE INTEGER)" WithName:@"people.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS MY_SELF( ID INTEGER PRIMARY KEY AUTOINCREMENT, FIRSTNAME TEXT, LASTNAME TEXT, PREFIX TEXT, AFFILIATION TEXT, EMAIL TEXT, PHOTO TEXT, BIOGRAPHY TEXT, SERVER_ID INTEGER, LAST_DATE TEXT, INFO_LAST_DATE TEXT)" WithName:@"my_self.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT)" WithName:@"people_status.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS MY_SELF_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, INFO_LAST_DATE TEXT)" WithName:@"my_self_status.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS INFO( ID INTEGER PRIMARY KEY AUTOINCREMENT, TYPE TEXT, VALUE TEXT, PERSON_ID INTEGER)" WithName:@"info.db"];
    
    //calendar
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS CALENDAR_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, CALENDAR_VERSION INTEGER)" WithName:@"calendar_status.db"];
    
    //networkings
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NETWORKINGS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, NETWORKING TEXT, DATE TEXT, PERSON_ID INTEGER, SERVER_ID INTEGER)" WithName:@"networkings.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NETWORKINGS_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"networkings_status.db"];
    
    //networking key and areas key
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NET_AREA( ID INTEGER PRIMARY KEY AUTOINCREMENT, AREA_ID INTEGER, NETWORKING_ID INTEGER)" WithName:@"networking_area.db"];
    
    //people key and area key
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE_AREA( ID INTEGER PRIMARY KEY AUTOINCREMENT, PERSON_ID INTEGER,  AREA_ID INTEGER)" WithName:@"people_area.db"];
    
    //Notes
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES( ID INTEGER PRIMARY KEY AUTOINCREMENT, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, SERVER_ID INTEGER, DATE TEXT, ABOUT_SESSION INTEGER)" WithName:@"notes.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"notes_status.db"];
    
    //Events
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, SERVER_ID INTEGER, KIND TEXT, BEGIN TEXT, END TEXT, DURATION INTEGER, DATE TEXT, LOCATION_ID INTEGER, SPEAKER_ID INTEGER, KEYNOTE INTEGER,  LOCAL_ID INTEGER)" WithName:@"events.db"];
    
    //Attending
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS ATTENDING( ID INTEGER PRIMARY KEY AUTOINCREMENT, SESSION_ID INTEGER)" WithName:@"attending.db"];
    
    //Author
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AUTHOR( ID INTEGER PRIMARY KEY AUTOINCREMENT, EVENT_ID INTEGER, NAME TEXT, PERSON_ID INTEGER)" WithName:@"author.db"];
    
    //Localization
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS LOCALIZATION( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, IMG TEXT, SERVER_ID INTEGER)" WithName:@"localization.db"];
    
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
            
            if (![name compare:@"notifications_status.db"])
                [self initDB];
            
            NSString *s = @"table ";
            s = [s stringByAppendingString:name];
            s = [s stringByAppendingString:@" created! =)"];
            NSLog(@"%@", s);
        }
    }
}

-(void) initDB{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications_status.db"];
    sqlite3 *db;
    char *error;
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        NSString *inserStmt = [NSString stringWithFormat:@"INSERT INTO NOTIFICATIONS_STATUS(LAST_DATE , LAST_ID , LAST_REMOVED) VALUES ('2000-01-01', '0', '0')"];
        
        const char *insert_stmt = [inserStmt UTF8String];
        
        if (sqlite3_exec(db, insert_stmt, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"Notification_Status added");
        }else{
            NSLog(@"%s", error);
        }
        sqlite3_close(db);
    }
}

@end
