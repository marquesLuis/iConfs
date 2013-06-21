//
//  SearchViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 21/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "SearchViewController.h"

#define PEOPLE 0
#define SESSIONS 1
#define NOTES 2
#define NETWORKING 3

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *persons;
    NSMutableArray *notesServer;
    NSMutableArray *notesLocal;
    NSMutableArray *sessions;
    NSMutableArray *networking;
    
    UISegmentedControl *options;

}

@end

@implementation SearchViewController

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
    
    
    [self treatKeyboard];
    //self.resultsOfSearch = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height- (2*self.navigationController.toolbar.frame.size.height)) style:UITableViewStyleGrouped];
    self.resultsOfSearch.dataSource = self;
    self.resultsOfSearch.delegate = self;
    [self.view addSubview:self.resultsOfSearch];
    self.resultsOfSearch.allowsSelectionDuringEditing = YES;
    
    self.searchBar.keyboardType = UIKeyboardTypeASCIICapable;
    self.searchBar.returnKeyType = UIReturnKeyDone;


}

/**
 * Handles a recognized single tap gesture.
 */
- (void) handleTapFrom: (UITapGestureRecognizer *) recognizer {
    // hide the keyboard
    [self.searchBar resignFirstResponder];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // se nao houver nenhum resultado.
    
    if(options.selectedSegmentIndex == PEOPLE || options.selectedSegmentIndex == SESSIONS || options.selectedSegmentIndex == NOTES || options.selectedSegmentIndex == NETWORKING)
        return 1;
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(options.selectedSegmentIndex == PEOPLE)
        return [persons count];
    
    if(options.selectedSegmentIndex == SESSIONS)
        return [sessions count];
    
    if(options.selectedSegmentIndex == NOTES)
        return [notesServer count] + [notesLocal count];
    
    if(options.selectedSegmentIndex == NETWORKING)
        return [networking count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    
    if(options.selectedSegmentIndex == NETWORKING)
        [self configureNetworkingCell:cell atIndexPath:indexPath];
        
    else if(options.selectedSegmentIndex == NOTES)
        [self configureNotesCell:cell atIndexPath:indexPath];
    
    else if(options.selectedSegmentIndex == PEOPLE)
        [self configurePeopleCell:cell atIndexPath:indexPath];
    
    else if(options.selectedSegmentIndex == SESSIONS)
        [self configureSessionsCell:cell atIndexPath:indexPath];
    
    return cell;
}
-(Person *)getPerson:(NSString*)personId{
    sqlite3_stmt *statement;
    sqlite3 *peopleDB;
    Person *person = [[Person alloc]init];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &peopleDB)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE WHERE SERVER_ID = %@", personId];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(peopleDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *firstName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *lastName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *prefix = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSString *affiliation = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                NSString *email = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
                NSString *photo = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                NSString *biography = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)];
                NSString *calendarVersion = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                
                [person setFirstName:firstName];
                [person setLastName:lastName];
                [person setPrefix:prefix];
                [person setAffiliation:affiliation];
                [person setEmail:email];
                [person setBiography:biography];
                [person setCalendar_version:calendarVersion];
                [person setDate:date];
                [person setPhoto:photo];
            }
            sqlite3_close(peopleDB);
        }
        
    }
    return person;
}

/*
 //Notes
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES( SERVER_ID INTEGER PRIMARY KEY, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes.db"];
 
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"notes_status.db"];
 
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_LOCAL( ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID INTEGER, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes_local.db"];
 
 //Events
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, SERVER_ID INTEGER, KIND TEXT, BEGIN TEXT, END TEXT, DATE TEXT, SPEAKER_ID INTEGER, KEYNOTE INTEGER,  LOCAL_ID INTEGER)" WithName:@"events.db"];
 
 */

- (void)configureSessionsCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [[sessions objectAtIndex:indexPath.row] objectAtIndex:1];
}

- (void)configureNotesCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // 1º local notes
    if(indexPath.row < [notesLocal count])
        cell.textLabel.text = [[notesLocal objectAtIndex:indexPath.row] objectAtIndex:3];
     else 
        cell.textLabel.text = [[notesServer objectAtIndex:indexPath.row] objectAtIndex:2];

    
    

}

/*
 
 //people
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS PEOPLE( ID INTEGER PRIMARY KEY AUTOINCREMENT, FIRSTNAME TEXT, LASTNAME TEXT, PREFIX TEXT, AFFILIATION TEXT, EMAIL TEXT, PHOTO TEXT, BIOGRAPHY TEXT, SERVER_ID INTEGER, LAST_DATE TEXT)" WithName:@"people.db"];
 
 //networkings
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NETWORKINGS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, NETWORKING TEXT, DATE TEXT, PERSON_ID INTEGER, SERVER_ID INTEGER)" WithName:@"networkings.db"];
 */

- (void)configurePeopleCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * person = [persons objectAtIndex:indexPath.row] ;
    
    NSString * firstName = [person objectAtIndex:1];
    NSString * lastName = [person objectAtIndex:2];
    cell.textLabel.text = [[firstName stringByAppendingFormat:@" "] stringByAppendingFormat:@"%@", lastName];
    UIImage * imageFromURL;
    NSString * photo = [person objectAtIndex:6];
    if([photo isEqualToString:@""])
            imageFromURL = [UIImage imageNamed:@"defaultPerson.jpg"];
    else
            imageFromURL = [UIImage imageWithContentsOfFile:photo];
        
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.imageView setImage:imageFromURL];
}

- (void)configureNetworkingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray * network = [networking objectAtIndex:indexPath.row];
    
    CGRect Label1Frame = CGRectMake(10, 10, 175, 25);
    CGRect Label2Frame = CGRectMake(10, 30, 175, 25);
    CGRect Label3Frame = CGRectMake(10, 50, 175, 25);
    
    // networking title
    UILabel * netTitle = [[UILabel alloc] initWithFrame:Label1Frame];
    netTitle.text = [network objectAtIndex:1];
    netTitle.font = [UIFont systemFontOfSize:16.0];
    netTitle.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:netTitle];
    
    // networking description
    UILabel * netText = [[UILabel alloc] initWithFrame:Label2Frame];
    netText.backgroundColor = [UIColor clearColor];
    netText.text = [network objectAtIndex:2];
    netText.font = [UIFont systemFontOfSize:14.0];
    [cell.contentView addSubview:netText];
    
    Person *person = [self getPerson:[network objectAtIndex:4]];
    UILabel * personName = [[UILabel alloc] initWithFrame:Label3Frame];
    personName.backgroundColor = [UIColor clearColor];
    
    NSString * letter = [person.firstName substringToIndex:1];
    personName.text = [[[[[person.prefix stringByAppendingString:@" " ]stringByAppendingString:person.lastName]stringByAppendingString:@", "]stringByAppendingString:letter]stringByAppendingString:@"."];
    personName.font = [UIFont systemFontOfSize:12.0];
    
    [cell.contentView addSubview:personName];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    imageView.contentMode  = UIViewContentModeScaleAspectFit;
    
    UIImage * imageFromURL;
    if([person.photo isEqualToString:@""])
        imageFromURL = [UIImage imageNamed:@"defaultPerson.jpg"];
    else
        imageFromURL = [UIImage imageWithContentsOfFile:person.photo];
    
    
    [imageView setImage:imageFromURL];
    
    [cell addSubview:imageView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue5" sender:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)doSearch:(UIButton *)sender {
    
    Search *s = [[Search alloc]init];
    NSLog(@"search is : %@", self.searchBar.text);
    persons = [s getPeopleFromRegex:self.searchBar.text];
    sessions = [s getEventsFromRegex:self.searchBar.text];
    notesServer = [s getNotesServerFromRegex:self.searchBar.text];
    notesLocal = [s getNotesLocalFromRegex:self.searchBar.text];
    networking = [s getNetworkingFromRegex:self.searchBar.text];
    
    [self updateToolbar];
    
    if([self.searchBar.text length] == 0 || ([persons count] == 0 && [sessions count ] == 0 && [notesLocal count]== 0 && [notesServer count] == 0 && [networking count] == 0)){
        [self alertMessages:@"No results found." withMessage:@""];
        [self.resultsOfSearch reloadData];
        return;
    }
    
    
    if([persons count])
        options.selectedSegmentIndex = PEOPLE;
    
    else if([sessions count ])
        options.selectedSegmentIndex = SESSIONS;
        
    else if([notesServer count] || [notesLocal count])
        options.selectedSegmentIndex = NOTES;
            
    else if([networking count])
        options.selectedSegmentIndex = NETWORKING;
    
    [self.resultsOfSearch reloadData];

    
}

- (void)valueChanged:(UISegmentedControl *)segment {
    
    //get index position for the selected control
    NSInteger selectedIndex = [segment selectedSegmentIndex];
    if(selectedIndex == PEOPLE) {
        if([persons count])
            options.selectedSegmentIndex = PEOPLE;
    }else if (selectedIndex == SESSIONS){
        if([sessions count])
            options.selectedSegmentIndex = SESSIONS;
    } else if(selectedIndex == NOTES){
        if([notesServer count] || [notesLocal count])
            options.selectedSegmentIndex = NOTES;
    } else if(selectedIndex == NETWORKING){
        if([networking count])
            options.selectedSegmentIndex = NETWORKING;
    }
        
    [self.resultsOfSearch reloadData];
}

-(void) updateToolbar{
    NSArray *itemArray = [NSArray arrayWithObjects: [@"" stringByAppendingFormat: @"People (%d)",  persons.count], [@"" stringByAppendingFormat: @"Sessions (%d)", sessions.count ], [@"" stringByAppendingFormat:@"Notes (%d)", notesServer.count  + notesLocal.count], [@"" stringByAppendingFormat:@"Network (%d)", networking.count], nil];
    options  = [[UISegmentedControl alloc] initWithItems:itemArray];
    options.frame = CGRectMake(0, 5, self.view.frame.size.width-12, 30);
    options.segmentedControlStyle = UISegmentedControlStyleBar;
    [options addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];
    options.segmentedControlStyle = UISegmentedControlStyleBar;
	options.momentary = NO;
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:options];
    buttonItem.style = UIBarButtonItemStyleBordered;
    
    [self.toolbar setItems: [NSArray arrayWithObjects:buttonItem,  nil]];
}

-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
