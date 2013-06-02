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
    [update handleResponse:[update postRequest:[update buildRequest]]];
    
    
    //change view
    UIViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageIConfs"];
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

@end
