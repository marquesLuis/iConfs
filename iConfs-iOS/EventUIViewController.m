//
//  EventUIViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 06/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "EventUIViewController.h"

@interface EventUIViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray * sections;
    int y;
    UITextView * title;
    UILabel * date;
    UITextView * authors;
    UILabel * author;
    UILabel * description;
    UITextView * descriptionText;
    UILabel * notes;
    NSString * all_authors;

}

@end

@implementation EventUIViewController
@synthesize roomButton;
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
    
    y = 700;
    
    //title ; date; authors ; description; notes
    //self.info = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height- (2*self.navigationController.toolbar.frame.size.height)) style:UITableViewStyleGrouped];
    self.info.dataSource = self;
    self.info.delegate = self;
    [self.view addSubview:self.info];
    self.title = @"Session";
    
    // [self displayAuthors];
    
    [self.info setEditing:YES animated:YES];
    self.info.allowsSelectionDuringEditing = YES;
    [self updateNotes];
    /*   self.sessionTitle.font = [UIFont fontWithName:@"Helvetica" size:14.0];    // For setting font style with size
     labelName.textColor = [UIColor whiteColor];        //For setting text color
     labelName.backgroundColor = [UIColor clearColor];  // For setting background color
     //    labelName.textAlignment = UITextAlignmentCenter;   // For setting the horizontal text alignment
     labelName.numberOfLines = 2;                       // For setting allowed number of lines in a label
     //  labelName.lineBreakMode = UILineBreakModeWordWrap;*/
    
    
    
    
    /**Author
     [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AUTHOR( ID INTEGER PRIMARY KEY AUTOINCREMENT, EVENT_ID INTEGER, NAME TEXT, PERSON_ID INTEGER)" WithName:@"author.db"];
     */
    
    
    //self.event.title = [[[[_personProfile.prefix stringByAppendingString:@" " ]stringByAppendingString:_personProfile.firstName]stringByAppendingString:@" "]stringByAppendingString:_personProfile.lastName];;
    
    
	// Do any additional setup after loading the view.
    /*_personProfile = [self getPerson:personID];
     NSString * areas = [self getAreas:personID];
     
     
     */
    
    [self createToolbar];
    [self navigationButtons];
}


-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
}
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}





-(void)updateNotes{
    NSMutableArray * server = [self getNotes:@"notes.db" withClause:[@"" stringByAppendingFormat: @"SELECT * FROM NOTES WHERE ABOUT_SESSION = %@", self.event.eventID]];
    
    NSMutableArray * local = [self getNotes:@"notes_local.db" withClause:[@"" stringByAppendingFormat: @"SELECT * FROM NOTES_LOCAL WHERE ABOUT_SESSION = %@", self.event.eventID]];
    
    sections = [NSMutableArray arrayWithArray:server];
    [sections addObjectsFromArray: local];
}

- (void)createToolbar {
    self.addNoteButton = [[UIBarButtonItem alloc] initWithTitle:@"Add note" style:UIBarButtonItemStyleBordered target:self action:@selector(addNote:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSArray *buttonItems = [NSArray arrayWithObjects:flexibleSpace, self.addNoteButton, flexibleSpace, nil];
    [self.toolbar setItems:buttonItems];
}


-(NSString*)displayAuthors{
    NSString * text = @"";
    NSMutableArray *allAuthors = [self getAuthors];
    int size = allAuthors.count-1;
    for(int i = 0; i <= size; i++){
        Author * auth = [allAuthors objectAtIndex:i];
        if(!i)
            text = auth.name;
        else
            text = [text stringByAppendingFormat:@"; %@", auth.name];
    }
    
    return text;
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
                NSString *emails = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
                NSString *photo = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                NSString *biography = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)];
                NSString *calendarVersion = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                NSString *dates = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                
                [person setFirstName:firstName];
                [person setLastName:lastName];
                [person setPrefix:prefix];
                [person setAffiliation:affiliation];
                [person setEmail:emails];
                [person setBiography:biography];
                [person setCalendar_version:calendarVersion];
                [person setDate:dates];
                [person setPhoto:photo];
            }
        }
        sqlite3_close(peopleDB);
    }
    return person;
}

-(NSMutableArray *)getAuthors{
    sqlite3_stmt *statement;
    sqlite3 *peopleDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"author.db"];
    NSMutableArray* allAuthors = [[NSMutableArray alloc]init];
    
    if (sqlite3_open([dbPathString UTF8String], &peopleDB)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM AUTHOR WHERE EVENT_ID = %@", self.event.eventID];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(peopleDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                Author *auth = [[Author alloc]init];

                NSString * personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSString * name;
                if([personID isEqualToString:@"0"]){
                    name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                } else {
                    Person * p = [self getPerson:personID];
                    name = [p.lastName stringByAppendingFormat:@", %@", p.firstName ];
                }
                [auth setEventID:self.event.eventID];
                [auth setName:name];
                [auth setPersonID:personID];
                [allAuthors addObject:auth];
            }
            sqlite3_finalize(statement);

        }
        sqlite3_close(peopleDB);
    }
    return allAuthors;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Notes
/*[self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES( SERVER_ID INTEGER PRIMARY KEY, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes.db"];

[self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"notes_status.db"];

[self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_LOCAL( ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID INTEGER, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes_local.db"];

[self createOrOpenDB:"CREATE TABLE IF NOT EXISTS DELETED_LOCAL( ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID INTEGER)" WithName:@"deleted_local.db"];*/


-(NSMutableArray *)getNotes:(NSString*)table withClause:(NSString*)clause{
    sqlite3_stmt *statement;
    sqlite3 *peopleDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:table];
    NSMutableArray* array = [[NSMutableArray alloc]init];
    
    if (sqlite3_open([dbPathString UTF8String], &peopleDB)==SQLITE_OK) {
        
        NSString *querySql = clause;
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(peopleDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {

                Note *note = [[Note alloc]init];

                if([table isEqualToString:@"notes.db"]){
                    NSString *content = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                    NSString *serverID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    NSString *personId = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                    NSString *eventID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                    NSString *lastdate = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];

                    [note setContent:content];
                    [note setIsLocal:NO];
                    [note setNoteID:serverID];
                    [note setPersonID:personId];
                    [note setEventID:eventID];
                    [note setDate:lastdate];
                    [array addObject:note];
                }else {
                    NSString *content = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                    NSString *serverID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    NSString *personId = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                    NSString *eventID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
                    NSString *lastdate = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];

                    [note setContent:content];
                    [note setIsLocal:YES];
                    [note setNoteID:serverID];
                    [note setPersonID:personId];
                    [note setEventID:eventID];
                    [note setDate:lastdate];
                    [array addObject:note];
                }
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(peopleDB);
    }
    return array;
}





- (IBAction)goToRoom:(UIButton *)sender {
    if([self shouldPerformSegueWithIdentifier:@"segue12" sender:sender])
        [self performSegueWithIdentifier:@"segue12" sender:sender];

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
    return [sections  count];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProductCellIdentifier = @"ProductCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
    
   
    Note * note = [sections objectAtIndex:indexPath.row];
    cell.textLabel.text =  note.content;
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSLog(@"header");
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 100)]; // x,y,width,height
    
    
    //title
     title.backgroundColor =[UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [[title layer] setCornerRadius:5]; // radius of rounded corners
    [title setClipsToBounds: YES]; //clip text within the bounds
    [title setEditable:NO];
    title.text = self.event.title;
    title.font = [UIFont boldSystemFontOfSize:20.0f];
    [headerView addSubview:title];
    
    //date
    date.backgroundColor =  [UIColor lightTextColor];
    [[date layer] setCornerRadius:5]; // radius of rounded corners
    [date setClipsToBounds: YES]; //clip text within the bounds

    date.text = [@"Date "  stringByAppendingString: self.event.date];
    [date setFont:[UIFont fontWithName:@"Arial" size:14]];
    [headerView addSubview:date];
    
    //room
    roomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [roomButton setTitle: @"Local" forState:UIControlStateNormal];
    
    [roomButton addTarget:self
                     action:@selector(goToRoom:)
           forControlEvents:UIControlEventTouchDown];
    
    if(![self.event.localID  isEqualToString:@"0"])
        [headerView addSubview:roomButton];
    
    if(![all_authors isEqualToString:@""]){
    
        //authors
        [authors setEditable:NO];
        authors.scrollEnabled = YES;
        authors.layer.cornerRadius = 5.0f;
        authors.clipsToBounds = YES;
        authors.backgroundColor = [UIColor lightTextColor];
        authors.layer.borderColor = [[UIColor colorWithRed:(255/255.f) green:(250/255.f) blue:(240/255) alpha:1.0f ]CGColor];
        [authors setTextAlignment: NSTextAlignmentJustified];
        [authors setText:all_authors];
        [headerView addSubview:authors];
        
        //author label
        author.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
        author.textColor = [UIColor whiteColor];
        author.layer.cornerRadius = 5.0f;
        author.clipsToBounds = YES;
        [author setText: @"Authors:"];
        author.font = [UIFont boldSystemFontOfSize:15.0f];
        [headerView addSubview:author];
    }
    
    if(![self.event.description isEqualToString:@""]){
        
        //description label
        description.textColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];

        description.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
        description.textColor = [UIColor whiteColor];
        description.layer.cornerRadius = 5.0f;
        description.clipsToBounds = YES;
        description.font = [UIFont boldSystemFontOfSize:15.0f];
        [description setText: @"Description"];
        [headerView addSubview:description];
        
        //description
        [descriptionText setEditable:NO];
        descriptionText.scrollEnabled = YES;
        descriptionText.layer.cornerRadius = 5.0f;
        descriptionText.backgroundColor = [UIColor lightTextColor];
        descriptionText.clipsToBounds = YES;
        
        descriptionText.layer.borderColor = [[UIColor colorWithRed:(255/255.f) green:(250/255.f) blue:(240/255) alpha:1.0f ]CGColor];
        [descriptionText setTextAlignment: NSTextAlignmentJustified];
        
        
        
        
        [headerView addSubview:descriptionText];
    }
    y+=25;

    if(sections.count != 0){
        notes.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
        notes.textColor = [UIColor whiteColor];
        notes.layer.cornerRadius = 5.0f;
        notes.clipsToBounds = YES;
        notes.font = [UIFont boldSystemFontOfSize:15.0f];
        [notes setText: @"My notes"];
        [headerView addSubview:notes];

    }
    

    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return y;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60.0f;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segue15" sender: [NSNumber numberWithInteger:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segue12"]){
        ImageViewController *map = (ImageViewController*)segue.destinationViewController;    
        map.localID = self.event.localID;
    } else if([[segue identifier] isEqualToString:@"segue15"]){
        
        NSLog(@"Edit note...");
        NoteViewController *note = (NoteViewController*)segue.destinationViewController;
        note.hidePersonButton = NO;
        note.hideSessionButton = YES;
        note.eventID = self.event.eventID;

        Note *n = [sections objectAtIndex:[sender integerValue]];
        note.noteID = n.noteID;
        note.isLocal = n.isLocal;
        note.content = n.content;
        note.personID = n.personID;
        note.eventID = n.eventID;
        note.date = n.date;
        
        
    } else if([[segue identifier] isEqualToString:@"segue14"]){
        NSLog(@"New note");
        NoteViewController *note = (NoteViewController*)segue.destinationViewController;
        note.hidePersonButton = NO;
        note.hideSessionButton = YES;
        note.eventID = self.event.eventID;
        note.date = @"0";
        note.noteID = @"0";
    }
}

- (IBAction)addNote:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"segue14" sender:sender];
}

- (void)viewDidAppear:(BOOL)animated{
    [self updateNotes];
    [self.info reloadData];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"removing the note...");
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Note * note = [sections objectAtIndex:indexPath.row];
        if(note.isLocal){
            [self removeFrom:@"notes_local.db" table:@"NOTES_LOCAL" attribute:@"ID" withID:[note.noteID intValue]];
        } else {
            [self insertTo:@"deleted_local.db" table:@"DELETED_LOCAL" definition:@"SERVER_ID" values:note.noteID];
            [self removeFrom:@"notes.db" table:@"NOTES" attribute:@"SERVER_ID" withID:[note.noteID intValue]];
            Update *update = [[Update alloc] initDB];
            [update updateWithoutMessage];
        }
        [sections removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.info reloadData];
    }
    else {
        [self performSegueWithIdentifier:@"segue15" sender: [NSNumber numberWithInteger:indexPath.row]];

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
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ inserted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT inserted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}

-(void) removeFrom: (NSString *) db_file table: (NSString *) table_name attribute: (NSString *) attribute withID: (int) server_id{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d",[table_name uppercaseString],[attribute uppercaseString], server_id];
        const char* query_sql = [querySql UTF8String];
        
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ deleted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT deleted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

-(BOOL)shouldAutorotate{
    
    return YES;
}

-(void) changePosition:(UIInterfaceOrientation)orientation{
    
    y = 80;

    NSLog(@"changePosition");
    if(UIInterfaceOrientationIsLandscape(orientation)){
        
    } else {
        CGRect LabelFrameTitle = CGRectMake(10, 5, self.view.frame.size.width-20, 30);
        CGRect LabelFrameDate = CGRectMake(10, 45, 150, 30);
        CGRect LabelFrameRoom = CGRectMake(200, 45, 80, 30);
        title = [[UITextView alloc]initWithFrame:LabelFrameTitle];
        date = [[UILabel alloc]initWithFrame:LabelFrameDate];
        roomButton.frame = LabelFrameRoom;
        
        all_authors = [self displayAuthors];
        if(![all_authors isEqualToString:@""]){
            CGRect LabelFrameAuthor = CGRectMake(10, 90, self.view.frame.size.width-20, 20);
            CGRect LabelFrameAuthors = CGRectMake(10, 110, self.view.frame.size.width-20, 40);
            y = 160;
            authors = [[UITextView alloc]initWithFrame:LabelFrameAuthors];
            author = [[UILabel alloc] initWithFrame:LabelFrameAuthor];
        }
        
        
        
        
        if(![self.event.description isEqualToString:@""]){
            CGRect LabelFrameDescription = CGRectMake(10, y+5, self.view.frame.size.width-20, 20);
            y+=25;
            CGRect LabelFrameDescriptionTable = CGRectMake(10, y, self.view.frame.size.width-20, 175);
            
            description = [[UILabel alloc] initWithFrame:LabelFrameDescription];
            descriptionText = [[UITextView alloc]initWithFrame:LabelFrameDescriptionTable];
            [descriptionText setText:self.event.description];
            if(descriptionText.contentSize.height <= 175){
                CGRect frame = descriptionText.frame;
                frame.size.height = descriptionText.contentSize.height;
                descriptionText.frame = frame;
                [descriptionText setFrame:CGRectMake(10, y, self.view.frame.size.width-20,descriptionText.contentSize.height) ];
                y+=descriptionText.contentSize.height + 10;
                
            } else
                y+=185;
            
            
        }
        y+=25;

        if(sections.count != 0){
            CGRect LabelFrameNotes = CGRectMake(10, y, self.view.frame.size.width-20, 20);
            notes = [[UILabel alloc] initWithFrame:LabelFrameNotes];
            notes.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
            notes.textColor = [UIColor whiteColor];
            notes.layer.cornerRadius = 5.0f;
            notes.clipsToBounds = YES;
            notes.font = [UIFont boldSystemFontOfSize:15.0f];
            [notes setText: @"My notes"];            
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self changePosition:self.interfaceOrientation];
}

@end
