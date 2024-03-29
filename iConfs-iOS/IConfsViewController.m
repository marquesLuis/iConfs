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
    [self initBDFile:@"notifications_status.db" table:@"notifications_status"];
    [self initBDFile:@"events_status.db" table:@"events_status"];
    [self initBDFile:@"networkings_status.db" table:@"networkings_status"];
    [self initBDFile:@"people_status.db" table:@"PEOPLE_STATUS"];
    [self initBDFile:@"attending_status.db" table:@"ATTENDING_STATUS"];
    [self initBDFile:@"areas_status.db" table:@"AREAS_STATUS"];
    [self initBDFile:@"location_status.db" table:@"LOCATION_STATUS"];
    [self initBDFile:@"notes_status.db" table:@"NOTES_STATUS"];
    
}

-(void) viewWillAppear:(BOOL)animated{
    self.toolbar.hidesBackButton = YES;
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSString *email = @"";
    NSString *password = @"";
    if (self.emailField.text.length || self.passwordField.text.length){
        email = self.emailField.text;
        password = self.passwordField.text;
        
        
        
    }
    
    NSString *key = @"235677A81B29A981E47FB176F6C1F";
    password = [AESCrypt encrypt:password password:key];
    email = [AESCrypt encrypt:email password:key];
    
    NSString * my_self = [self getMySelf];
    if (my_self){
        Update *update = [[Update alloc] initDB];
        if([update updateWithoutMessage])
            if(![my_self isEqualToString:email])
                [self eraseDBS];
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
    NSString *postUrlString = [NSString stringWithFormat:completeLink, @"http://193.136.122.134:3000/"];
   // NSString *postUrlString = [NSString stringWithFormat:completeLink, @"http://0.0.0.0:3000/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: postUrlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    
    @try {
        // Try something
        // Send a synchronous request
        NSURLResponse * response = nil;
        NSData * returnData = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
        NSString *newStr = [[NSString alloc]  initWithBytes:[returnData bytes]
                                                     length:[returnData length] encoding: NSUTF8StringEncoding];
        
        NSError *jsonParsingError = nil;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonParsingError];
        
        NSMutableDictionary * person = [json objectForKey:@"person"];
        NSString * server_id = [person objectForKey:@"server_id"];
        NSString * values = [@"" stringByAppendingFormat:@"'%@', '%@','%@'",server_id, email, password];
        
        NSMutableDictionary * dates = [json objectForKey:@"dates"];
        [self insertTo:@"calendar.db" table:@"CALENDAR" definition:@"FIRST, LAST" values:[@"" stringByAppendingFormat:@"'%@', '%@'", [dates objectForKey:@"begin"], [dates objectForKey:@"end"]]];
        
        NSLog(@"%@", newStr);
        if ([newStr hasPrefix:@"<!DOCTYPE html>"]|| newStr==NULL)
        {
            
            [self alertMessages:@"Error on Login" withMessage:@"Something went wrong on your login :("];
            return NO;
        }
        [self insertTo:@"my_self.db" table:@"MY_SELF" definition:@"SERVER_ID, EMAIL, PASSWORD" values:values];
        [self insertTo:@"asked_contact.db" table:@"ASKED_CONTACT" definition:@"PERSON_ID" values:[NSString stringWithFormat:@"'%@'",server_id]];
        
    }
    @catch (NSException * e) {
        [self alertMessages:@"Failed Connection" withMessage:@"Check your internet connection"];
        return NO;
    }
    return YES;

}

-(void)eraseDBS{
    [self clearDBFile:@"asked_contact.db" table:@"ASKED_CONTACT"];
    [self clearDBFile:@"asked_contact_local.db" table:@"ASKED_CONTACT_LOCAL"];
    [self clearDBFile:@"attending.db" table:@"ATTENDING"];
    [self clearDBFile:@"attending_status.db" table:@"ATTENDING_STATUS"];
    [self clearDBFile:@"contact.db" table:@"CONTACT"];
    [self clearDBFile:@"contact_local.db" table:@"CONTACT_LOCAL"];
    [self clearDBFile:@"deleted_local.db" table:@"DELETED_LOCAL"];
    [self clearDBFile:@"info.db" table:@"INFO"];
    [self clearDBFile:@"my_self.db" table:@"MY_SELF"];
    [self clearDBFile:@"notes.db" table:@"NOTES"];
    [self clearDBFile:@"notes_local.db" table:@"NOTES_LOCAL"];
    [self clearDBFile:@"notes_status.db" table:@"NOTES_STATUS"];
    [self clearDBFile:@"pending_contact.db" table:@"PENDING_CONTACT"];
    [self clearDBFile:@"rejected_contact.db" table:@"REJECTED_CONTACT"];
    [self clearDBFile:@"rejected_contact_local.db" table:@"REJECTED_CONTACT_LOCAL"];
    
    [self initBDFile:@"attending_status.db" table:@"ATTENDING_STATUS"];
    [self initBDFile:@"notes_status.db" table:@"NOTES_STATUS"];
}

-(NSString*)getMySelf{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"my_self.db"];
    NSString * result = nil;
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM MY_SELF"];
        const char* query_sql = [querySql UTF8String];
        
        if (!result && sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                result = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                break;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
    
    return result;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        Update *update = [[Update alloc] initDB];
        [update updateWithoutMessage];
        HomeViewController * home = (HomeViewController*)segue.destinationViewController;
        home.update = update;
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
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTIFICATIONS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, NOTIFICATION TEXT, DATE TEXT, SERVER_ID INTEGER )" WithName:@"notifications.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTIFICATIONS_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"notifications_status.db"];
    
    //areas
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AREAS(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, SERVER_ID INTEGER)" WithName:@"areas.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AREAS_STATUS(ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"areas_status.db"];
    
    //people
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE( ID INTEGER PRIMARY KEY AUTOINCREMENT, FIRSTNAME TEXT, LASTNAME TEXT, PREFIX TEXT, AFFILIATION TEXT, EMAIL TEXT, PHOTO TEXT, BIOGRAPHY TEXT, SERVER_ID INTEGER, LAST_DATE TEXT)" WithName:@"people.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS MY_SELF( SERVER_ID INTEGER PRIMARY KEY, EMAIL TEXT, PASSWORD TEXT)" WithName:@"my_self.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"people_status.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS INFO( SERVER_ID INTEGER PRIMARY KEY, TYPE TEXT, VALUE TEXT, PERSON_ID INTEGER)" WithName:@"info.db"];
    
    //tabela q contem os ids de todos os contactos q vieram do servidor (server id
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS CONTACT( PERSON_ID INTEGER PRIMARY KEY)" WithName:@"contact.db"];
    
    //tabela q contem os ids dos contactos aceites no ios desde a ultima actualizacao
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS CONTACT_LOCAL(PERSON_ID INTEGER PRIMARY KEY, PENDING_SERVER_ID INTEGER, REJECTED_SERVER_ID INTEGER)" WithName:@"contact_local.db"];
    
    //tabela q contem os ids dos contactos pedidos a outros (servidor)
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS ASKED_CONTACT(PERSON_ID INTEGER PRIMARY KEY)" WithName:@"asked_contact.db"];
    
    //tabela q contem os ids dos contactos pedidos a outros (ios)
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS ASKED_CONTACT_LOCAL(PERSON_ID INTEGER PRIMARY KEY)" WithName:@"asked_contact_local.db"];
    
    //tabela q contem os pedidos pendentes que ainda n foram aceites/rejeitados
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PENDING_CONTACT( PENDING_SERVER_ID INTEGER PRIMARY KEY, PERSON_ID INTEGER)" WithName:@"pending_contact.db"];
    
    //tabela q contem os pedidos rejeitados que ja foram ao servidor
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS REJECTED_CONTACT( REJECTED_SERVER_ID INTEGER PRIMARY KEY, PERSON_ID INTEGER)" WithName:@"rejected_contact.db"];
    
    //tabela q contem os pedidos rejeitados no ios
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS REJECTED_CONTACT_LOCAL( PENDING_SERVER_ID INTEGER PRIMARY KEY, PERSON_ID INTEGER)" WithName:@"rejected_contact_local.db"];
    
    
    //networkings
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NETWORKINGS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, NETWORKING TEXT, DATE TEXT, PERSON_ID INTEGER, SERVER_ID INTEGER)" WithName:@"networkings.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NETWORKINGS_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"networkings_status.db"];
    
    //networking key and areas key
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NET_AREA( ID INTEGER PRIMARY KEY AUTOINCREMENT, AREA_ID INTEGER, NETWORKING_ID INTEGER)" WithName:@"networking_area.db"];
    
    //people key and area key
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE_AREA( ID INTEGER PRIMARY KEY AUTOINCREMENT, PERSON_ID INTEGER,  AREA_ID INTEGER)" WithName:@"people_area.db"];
    
    //Notes
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES( SERVER_ID INTEGER PRIMARY KEY, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"notes_status.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_LOCAL( ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID INTEGER, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes_local.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS DELETED_LOCAL( ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID INTEGER)" WithName:@"deleted_local.db"];
    
    //calendar
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS CALENDAR( ID INTEGER PRIMARY KEY AUTOINCREMENT, FIRST TEXT, LAST TEXT)" WithName:@"calendar.db"];
    
    //Events
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, SERVER_ID INTEGER, KIND TEXT, BEGIN TEXT, END TEXT, DATE TEXT, SPEAKER_ID INTEGER, KEYNOTE INTEGER,  LOCAL_ID INTEGER)" WithName:@"events.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"events_status.db"];
    
    //Attending
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS ATTENDING( ID INTEGER PRIMARY KEY AUTOINCREMENT, SESSION_ID INTEGER, SERVER_ID INTEGER)" WithName:@"attending.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS ATTENDING_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"attending_status.db"];
    
    //Author
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AUTHOR( SERVER_ID INTEGER , EVENT_ID INTEGER, NAME TEXT, PERSON_ID INTEGER, ID INTEGER PRIMARY KEY AUTOINCREMENT)" WithName:@"author.db"];  
    
    //Localization
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS LOCATION( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, IMG TEXT, SERVER_ID INTEGER)" WithName:@"location.db"];
    
    [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS LOCATION_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"location_status.db"];
    
    
    
}

- (void) createOrOpenDB:(const char*)sql_stnt WithName:(NSString*)name {
    sqlite3 *feedback;
    
    NSString *s = @"create ";
    s = [s stringByAppendingString:name];
    s = [s stringByAppendingString:@" database"];
    //NSLog(@"%@", s);
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    
    NSString *dbPathFeed = [docPath stringByAppendingPathComponent:name];
    
    char *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:dbPathFeed]){
        const char *dbPath = [dbPathFeed UTF8String];
        
        //creat db
        if(sqlite3_open(dbPath, &feedback)== SQLITE_OK){
            if(sqlite3_exec(feedback, sql_stnt, NULL, NULL, &error)==SQLITE_OK){
                NSLog(@"table %@ created", name);
            }else{
                NSLog(@"table NOT %@ created", name);
                NSLog(@"%s", error);
            }
            sqlite3_close(feedback);
        }
    }
}

-(void) initBDFile:(NSString *)db_file table:(NSString *) table_file{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    sqlite3 *db;
    char *error;
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        int last_row = 0;
        NSString *querySql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",[table_file uppercaseString]];
        const char* query_sql = [querySql UTF8String];
        
        @try{
            if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    NSString *messageID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    last_row = [messageID integerValue];
                    break;
                }
                sqlite3_finalize(statement);
            }
        }@catch (NSException *e) {
            last_row = 0;
        }
        if (!last_row){
            
            NSString *inserStmt = [NSString stringWithFormat:@"INSERT INTO %@(LAST_DATE , LAST_ID , LAST_REMOVED) VALUES ('2000-01-01', '0', '0')", [table_file uppercaseString]];
            NSLog(@"%@", inserStmt);
            const char *insert_stmt = [inserStmt UTF8String];
            
            if (sqlite3_exec(db, insert_stmt, NULL, NULL, &error)==SQLITE_OK) {
                NSLog(@"%@ added", [table_file capitalizedString]);
            }else{
                NSLog(@"%s", error);
            }
        }
        sqlite3_close(db);
    }
}

-(void) clearDBFile:(NSString *) db_file table: (NSString *) table_name{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"DELETE FROM %@",[table_name uppercaseString]];
        const char* query_sql = [querySql UTF8String];
        NSLog(@"%@", querySql);
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ deleted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT deleted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}

-(void) insertTo:(NSString *) db_file table: (NSString *) table_name definition: (NSString *) definition values: (NSString *) values{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",[table_name uppercaseString], [definition uppercaseString], values];
        const char* query_sql = [querySql UTF8String];
        NSLog(@"%@", querySql);
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ inserted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT inserted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}
@end

@implementation UINavigationController (RotationIn_IOS6)

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject]  preferredInterfaceOrientationForPresentation];
}

@end


