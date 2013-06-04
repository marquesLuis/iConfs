//
//  ProgramViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 04/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "ProgramViewController.h"
#import "EventViewController.h"

@interface ProgramViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray * events;
}
@property (nonatomic, retain) UITableView *tableNetworking;
@end

@implementation ProgramViewController

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
    
    #warning title
    //self.title
    self.tableNetworking = [[UITableView alloc] initWithFrame:CGRectMake(15, 545, 295, 150) style:UITableViewStylePlain];
    self.tableNetworking.dataSource = self;
    self.tableNetworking.delegate = self;
    [self.view addSubview:self.tableNetworking];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"w"
                                ascending:YES
                                comparator:^(id obj1, id obj2) {
                                    NSInteger len1 = [obj1 length];
                                    NSInteger len2 = [obj2 length];
                                    if (len1 < len2) return NSOrderedAscending;
                                    if (len1 > len2) return NSOrderedDescending;
                                    return NSOrderedSame;
                                }];
    NSArray * sortEvents = [NSMutableArray arrayWithObject: sorter];
    [events sortUsingDescriptors:sortEvents];
}


-(NSString*)getUserID{
    sqlite3_stmt *statement;
    sqlite3 *mySelfDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"my_self.db"];
    NSString *userID = nil;
    
    if (sqlite3_open([dbPathString UTF8String], &mySelfDB)==SQLITE_OK) {
        NSString *querySql = [NSString stringWithFormat:@"SELECT SERVER_ID FROM MY_SELF"];
        const char* query_sql = [querySql UTF8String];
        if (sqlite3_prepare(mySelfDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                userID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
            }
            sqlite3_close(mySelfDB);
        }
    }
    return userID;
}



/*-(void)displayEvents{
    NSString *userID = [self getUserID];
    
    sqlite3_stmt *statement;
    sqlite3 *networkingDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"events.db"];
    
    
    if (sqlite3_open([dbPathString UTF8String], &networkingDB)==SQLITE_OK) {
        [events removeAllObjects];
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM EVENTS WHERE PEOPLE = %@", personId];
        const char* query_sql = [querySql UTF8String];
        if (sqlite3_prepare(networkingDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                Networking *networking = [[Networking alloc]init];
                [networking setTitle:title];
                [networking setText:text];
                [networking setPersonID:personId];
                [networking setDate:date];
                [_personNetworking addObject:networking];
            }
            sqlite3_close(networkingDB);
        }
    }
}*/

/**
 //Events
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, SERVER_ID INTEGER, KIND TEXT, BEGIN TEXT, END TEXT, DURATION INTEGER, DATE TEXT, LOCATION_ID INTEGER, SPEAKER_ID INTEGER, KEYNOTE INTEGER,  LOCAL_ID INTEGER)" WithName:@"events.db"];
 
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS MY_SELF( ID INTEGER PRIMARY KEY AUTOINCREMENT, FIRSTNAME TEXT, LASTNAME TEXT, PREFIX TEXT, AFFILIATION TEXT, EMAIL TEXT, PHOTO TEXT, BIOGRAPHY TEXT, SERVER_ID INTEGER, LAST_DATE TEXT, INFO_LAST_DATE TEXT)" WithName:@"my_self.db"];
 
 //Attending
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS ATTENDING( ID INTEGER PRIMARY KEY AUTOINCREMENT, SESSION_ID INTEGER)" WithName:@"attending.db"];
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [events count];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProductCellIdentifier = @"ProductCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   /* Networking *networking = [_personNetworking objectAtIndex:indexPath.row];
    
    CGRect Label1Frame = CGRectMake(10, 10, 290, 25);
    CGRect Label2Frame = CGRectMake(10, 30, 290, 25);
    
    UILabel * netTitle = [[UILabel alloc] initWithFrame:Label1Frame];
    netTitle.text = networking.title;
    [cell.contentView addSubview:netTitle];
    
    UILabel * netText = [[UILabel alloc] initWithFrame:Label2Frame];
    netText.text = networking.text;
    [cell.contentView addSubview:netText];
    
    */
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*[tableView deselectRowAtIndexPath:indexPath animated:YES];
    EventViewController.h * network = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    network.networkingDescription = [[UITextView alloc] init];
    network.personPhoto = [[UIImageView alloc] init];
    
    Networking *networking = [_personNetworking objectAtIndex:indexPath.row];
    network.numNetworking = indexPath.row;
    
    
    network.netTitle = networking.title;
    Person * person = [self getPerson:networking.personID];
    
    network.namePerson = [[[[person.prefix stringByAppendingString:@" " ]stringByAppendingString:person.firstName]stringByAppendingString:@" "]stringByAppendingString:person.lastName];
    network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    network.photoPath = person.photo;
    network.networkingDescriptionContent = networking.text;
    network.personId = networking.personID;
    //network.previous = self;
    
    //change view
    [self presentViewController:network animated:YES completion:nil];*/
}

/*
 * tamanho de uma cell
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}


@end
