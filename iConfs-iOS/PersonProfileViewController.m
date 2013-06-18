//
//  PersonProfileViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 02/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "PersonProfileViewController.h"

@interface PersonProfileViewController () <UITableViewDelegate, UITableViewDataSource>
    @property (nonatomic, strong)  Person * personProfile;
    @property (nonatomic, strong) NSMutableArray * personNetworking;
@property (nonatomic, strong) NSMutableArray * notes;

@end

@implementation PersonProfileViewController
@synthesize personID, tableNetworking, notes, personNetworking, personProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Profile";
    self.navigationItem.backBarButtonItem.title = @"Back";
    
    personProfile = [self getPerson:personID];
    NSString * areas = [self getAreas:personID];
    
    
	 //title ; date; authors ; description; notes
    self.tableNetworking = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height- (2*self.navigationController.toolbar.frame.size.height)) style:UITableViewStyleGrouped];
    self.tableNetworking.dataSource = self;
    self.tableNetworking.delegate = self;
    [self.view addSubview:self.tableNetworking];
    
    
    [self.tableNetworking setEditing:YES animated:YES];
    self.tableNetworking.allowsSelectionDuringEditing = YES;
    [self updateNotes];
    [self createToolbar];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}



-(NSMutableArray*)getIdAreasOfPerson:(NSString*)personId{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSMutableArray *areas = [[NSMutableArray alloc]init];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people_area.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE_AREA WHERE PERSON_ID = %@", personId];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *area = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                [areas addObject:area];

            }
        }
        sqlite3_close(db);
    }
    return areas;
}

-(NSString*)getAreas:(NSString*)personId{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"areas.db"];
    NSString * personInterests = @"";
    NSMutableArray *areas = [self getIdAreasOfPerson:personID];
    
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        for (NSString *areaId in areas){
            NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM Area WHERE SERVER_ID = %@", areaId];
            const char* query_sql = [querySql UTF8String];
        
            if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    NSString *area = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                    personInterests = [personInterests stringByAppendingString:area];
                }
            }
        }
        sqlite3_close(db);
    }
    return personInterests;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                
                [person setFirstName:firstName];
                [person setLastName:lastName];
                [person setPrefix:prefix];
                [person setAffiliation:affiliation];
                [person setEmail:emails];
                [person setBiography:biography];
                [person setCalendar_version:calendarVersion];
                [person setDate:date];
                [person setPhoto:photo];
            }
        }
        sqlite3_close(peopleDB);
    }
    return person;
}

-(void)displayNetworking:(NSString*)personId{
    sqlite3_stmt *statement;
    sqlite3 *networkingDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"networkings.db"];
    if (sqlite3_open([dbPathString UTF8String], &networkingDB)==SQLITE_OK) {
        [personNetworking removeAllObjects];
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM NETWORKINGS WHERE PERSON_ID = %@", personId];
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
                [personNetworking addObject:networking];
            }
            sqlite3_close(networkingDB);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 1)
        return [notes count];
    return [personNetworking count];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProductCellIdentifier = @"ProductCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier];
    
    cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ProductCellIdentifier];

    switch (indexPath.section) {
        case 0:
            [self configureNetworkingCell:cell atIndexPath:indexPath];

            break;
        case 1:
            [self configureNoteCell:cell atIndexPath:indexPath];
            break;
        default:
            break;
    
    }
    return cell;
}

- (void)configureNetworkingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Networking *networking = [personNetworking objectAtIndex:indexPath.row];
    
    cell.textLabel.text = networking.title;
    cell.detailTextLabel.text = networking.text;
    
    
}

- (void)configureNoteCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Note * note = [notes objectAtIndex:indexPath.row];
    cell.textLabel.text =  note.content;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // networking section
    if(indexPath.section == 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"segue19" sender:nil];
    }
    // note section
    else {
        [self performSegueWithIdentifier:@"segue18" sender: [NSNumber numberWithInteger:indexPath.row]];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier] isEqualToString:@"segue19"]){
    
        NSIndexPath *indexPath = [tableNetworking indexPathForSelectedRow];
        
        NetworkingViewController * network = (NetworkingViewController*)segue.destinationViewController;
        
        network.networkingDescription = [[UITextView alloc] init];
        network.personPhoto = [[UIImageView alloc] init];
        
        Networking *networking = [personNetworking objectAtIndex:indexPath.row];
        network.numNetworking = indexPath.row;
        
        
        network.netTitle = networking.title;
        Person * person = [self getPerson:networking.personID];
        
        network.namePerson = [[[[person.prefix stringByAppendingString:@" "]stringByAppendingString:person.firstName]stringByAppendingString:@" "]stringByAppendingString:person.lastName];
        network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
        network.photoPath = person.photo;
        network.networkingDescriptionContent = networking.text;
        network.personId = networking.personID;
    
    } else {
        
        if([[segue identifier] isEqualToString:@"segue18"]){
            NoteViewController *note = (NoteViewController*)segue.destinationViewController;
            note.hidePersonButton = YES;
            note.hideSessionButton = NO;
            note.personID = self.personID;
            
            Note *n = [notes objectAtIndex:[sender integerValue]];
            note.noteID = n.noteID;
            note.isLocal = n.isLocal;
            note.content = n.content;
        } else {
            NSLog(@"new note...");
            NoteViewController *note = (NoteViewController*)segue.destinationViewController;
            note.hidePersonButton = YES;
            note.hideSessionButton = NO;
            note.personID = self.personID;
        }
    }
}

-(void)updateNotes{
    NSMutableArray * server = [self getNotes:@"notes.db" withClause:[@"" stringByAppendingFormat: @"SELECT * FROM NOTES WHERE ABOUT_PERSON = %@", self.personID]];
    
    NSMutableArray * local = [self getNotes:@"notes_local.db" withClause:[@"" stringByAppendingFormat: @"SELECT * FROM NOTES_LOCAL WHERE ABOUT_PERSON = %@", self.personID]];
    
    notes = [NSMutableArray arrayWithArray:server];
    [notes addObjectsFromArray: local];
}

- (void)createToolbar {
    self.addNote = [[UIBarButtonItem alloc] initWithTitle:@"Add note" style:UIBarButtonItemStyleBordered target:self action:@selector(addNote:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *buttonItems = [NSArray arrayWithObjects:flexibleSpace, self.addNote, flexibleSpace, nil];
    [self.toolbar setItems:buttonItems];
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
                    [note setContent:content];
                    [note setIsLocal:NO];
                    [note setNoteID:serverID];
                    [array addObject:note];
                }else {
                    NSString *content = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                    NSString *serverID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                    
                    [note setContent:content];
                    [note setIsLocal:YES];
                    [note setNoteID:serverID];
                    [array addObject:note];
                }
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(peopleDB);
    }
    return array;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 100)]; // x,y,width,height
    
   if(section == 0){
        // person label name
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(150, 20, 160, 25)];
        labelName.text = @"Name:";
        labelName.backgroundColor = [UIColor clearColor];
        [headerView addSubview:labelName];
        
        // person name
        UITextView *name = [[UITextView alloc] initWithFrame:CGRectMake(150, 45, 160, 25)];
        [name setEditable:NO];
        NSString * n = [[[[personProfile.prefix stringByAppendingString:@" " ]stringByAppendingString:personProfile.firstName]stringByAppendingString:@" "]stringByAppendingString:personProfile.lastName];
        [name setText:n];
        name.scrollEnabled = YES;
        [headerView addSubview:name];
        
        // person label email
        UILabel *labelEmail = [[UILabel alloc] initWithFrame:CGRectMake(15, 120, 295, 25)];
        labelEmail.text = @"Email:";
        labelEmail.backgroundColor = [UIColor clearColor];
        [headerView addSubview:labelEmail];
        
        // person email
        UITextView *email = [[UITextView alloc] initWithFrame:CGRectMake(15, 145, 295, 25)];
        [email setEditable:NO];
        [email setText:personProfile.email];
        email.scrollEnabled = YES;
        [headerView addSubview:email];
        
        // person label institution
        UILabel *labelIns = [[UILabel alloc] initWithFrame:CGRectMake(150, 70, 160, 25)];
        labelIns.text = @"Institution:";
        labelIns.backgroundColor = [UIColor clearColor];
        [headerView addSubview:labelIns];
        
        // person institution
        UITextView *institution = [[UITextView alloc] initWithFrame:CGRectMake(150, 95, 160, 25)];
        [institution setEditable:NO];
        [institution setText:personProfile.affiliation];
        institution.scrollEnabled = YES;
        [headerView addSubview:institution];
        
        /* UILabel *interest = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, 295, 25)];
         interest.text = @"Interests:";
         interest.textColor=[UIColor colorWithRed:(0/255.f) green:(191/255.f) blue:(255/255.f) alpha:1.0f];
         [scroll addSubview:interest];
         
         UITextView *interests =  [[UITextView alloc] initWithFrame:CGRectMake(15, 195, 295, 100)];
         [interests setEditable:NO];
         [interests setText:areas];
         interests.scrollEnabled = YES;
         [interests setBackgroundColor:[UIColor colorWithRed:(224/255.f) green:(238/255.f) blue:(238/255.f) alpha:1.0f]];
         [scroll addSubview:interests];
         */
        
        UILabel *personalDescription = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, 295, 25)];
        personalDescription.text = @"Personal description:";
        personalDescription.backgroundColor = [UIColor clearColor];
        
        [headerView addSubview:personalDescription];
        
        UITextView *biography =  [[UITextView alloc] initWithFrame:CGRectMake(15, 195, 295, 200)];
        [biography setEditable:NO];
        biography.scrollEnabled = YES;
        
        [biography setText:personProfile.biography];
        [headerView addSubview:biography];
        
        personNetworking = [[NSMutableArray alloc] init];
        [self displayNetworking:personID];
        
        UILabel *networking = [[UILabel alloc] initWithFrame:CGRectMake(15, 395, 295, 25)];
        networking.text = @"Networking:";
        networking.backgroundColor = [UIColor clearColor];        
        [headerView addSubview:networking];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,30,100,90)];
       imageView.contentMode  = UIViewContentModeScaleAspectFit;

       UIImage * imageFromURL;
       NSLog(@"foto da pessoa");
       if([personProfile.photo isEqualToString:@""])
           imageFromURL = [UIImage imageNamed:@"defaultPerson.jpg"];
       else
           imageFromURL = [UIImage imageWithContentsOfFile:personProfile.photo];
       
        
        [imageView setImage:imageFromURL];
        [headerView addSubview:imageView];
    }
    
    else if(section == 1){
        UILabel *notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 295, 25)];
        notesLabel.text = @"My notes:";
        notesLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:notesLabel];
    }

    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return 425.0f;
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0f;
}


#pragma mark - UITableViewDelegate Methods

- (IBAction)addNote:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"segue17" sender:sender];
}

- (void)viewDidAppear:(BOOL)animated{
    [self updateNotes];
    [self.tableNetworking reloadData];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"removing the note...");
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Note * note = [notes objectAtIndex:indexPath.row];
        if(note.isLocal){
            [self removeFrom:@"notes_local.db" table:@"NOTES_LOCAL" attribute:@"ID" withID:[note.noteID intValue]];
        } else {
            [self removeFrom:@"notes.db" table:@"NOTES" attribute:@"SERVER_ID" withID:[note.noteID intValue]];
        }
        [notes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableNetworking reloadData];
    }
    else {
       // [self performSegueWithIdentifier:@"segue15" sender: [NSNumber numberWithInteger:indexPath.row]];
        
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

@end
