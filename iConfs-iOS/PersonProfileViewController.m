//
//  PersonProfileViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 02/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "PersonProfileViewController.h"

@interface PersonProfileViewController () <UITableViewDelegate, UITableViewDataSource>{
    NSString * pendingID;
    int height;
}
@property (nonatomic, strong)  Person * personProfile;
@property (nonatomic, strong) NSMutableArray * personNetworking;
@property (nonatomic, strong) NSMutableArray * notes;
@property (nonatomic, strong) UIToolbar *t;
@property (nonatomic, strong) NSMutableArray * info;

@end

@implementation PersonProfileViewController
@synthesize personID, tableNetworking, notes, personNetworking, personProfile,  info;

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
    height = 700;

    personProfile = [self getPerson:personID];
    // NSString * areas = [self getAreas:personID];
    personNetworking = [[NSMutableArray alloc] init];
    [self displayNetworking:personID];
    
    //title ; date; authors ; description; notes
    self.tableNetworking = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height- (2*self.navigationController.toolbar.frame.size.height)) style:UITableViewStyleGrouped];
    self.tableNetworking.dataSource = self;
    self.tableNetworking.delegate = self;
    [self.view addSubview:self.tableNetworking];
    
    
    [self.tableNetworking setEditing:YES animated:YES];
    self.tableNetworking.allowsSelectionDuringEditing = YES;
    info = [[NSMutableArray alloc] init];
    [self updateNotes];
    [self personal_info];
    [self createToolbar];
    [self navigationButtons];
}


-(void) personal_info{
    if([self belongsToDB:@"contact.db" withClause:[@"" stringByAppendingFormat:@"SELECT * FROM CONTACT WHERE PERSON_ID = %@", self.personID]]){
        [info removeAllObjects];
        sqlite3_stmt *statement;
        sqlite3 *db;
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [path objectAtIndex:0];
        NSString *dbPathString = [docPath stringByAppendingPathComponent:@"info.db"];
        
        if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
            NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM INFO WHERE PERSON_ID = %@", self.personID];
            const char* query_sql = [querySql UTF8String];
            
            if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    NSString *type = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                    NSString *value = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                    PersonalInfo * infos = [[PersonalInfo alloc]init];
                    [infos setType:type];
                    [infos setValue:value];
                    [info addObject:infos];
                    
                }
                sqlite3_finalize(statement);
            }
        }
        sqlite3_close(db);
    }
}

-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
}
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 || indexPath.section == 2)
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
            sqlite3_finalize(statement);
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
                sqlite3_finalize(statement);
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
            sqlite3_finalize(statement);
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
            sqlite3_finalize(statement);
        }
        sqlite3_close(networkingDB);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([info count]== 0){
        return 2;
    }
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 1)
        return [notes count];
    if(section == 2)
        return [info count];
    return [personNetworking count];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProductCellIdentifier = @"ProductCellIdentifier";
    
    
    UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ProductCellIdentifier];
    
    switch (indexPath.section) {
        case 0:
            [self configureNetworkingCell:cell atIndexPath:indexPath];
            
            break;
        case 1:
            [self configureNoteCell:cell atIndexPath:indexPath];
            break;
        case 2:
            [self configurePersonalInfoCell:cell atIndexPath:indexPath];
        default:
            break;
            
    }
    return cell;
}

- (void)configurePersonalInfoCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PersonalInfo *personal = [info objectAtIndex:indexPath.row];
    
    cell.textLabel.text = personal.type;
    cell.detailTextLabel.text = personal.value;
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
        [self performSegueWithIdentifier:@"segue19" sender:nil];
    }
    // note section
    else if(indexPath.section == 1){
        [self performSegueWithIdentifier:@"segue18" sender: [NSNumber numberWithInteger:indexPath.row]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier] isEqualToString:@"segue19"]){
#warning verificar outras rows...
        NSIndexPath *indexPath = [tableNetworking indexPathForSelectedRow];
        
        NetworkingViewController * network = (NetworkingViewController*)segue.destinationViewController;
        
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
            //NSLog(@"Edit note");
            NoteViewController *note = (NoteViewController*)segue.destinationViewController;
            note.hidePersonButton = YES;
            note.hideSessionButton = NO;
            note.personID = self.personID;
            
            Note *n = [notes objectAtIndex:[sender integerValue]];
            note.noteID = n.noteID;
            note.isLocal = n.isLocal;
            note.content = n.content;
            note.eventID = n.eventID;
            note.date = n.date;
            note.noteID = n.noteID;
        } else {
           /* //NSLog(@"new note...");
            NoteViewController *note = (NoteViewController*)segue.destinationViewController;
            note.hidePersonButton = YES;
            note.hideSessionButton = NO;
            note.personID = self.personID;
            note.noteID = @"0";
            note.date = @"0";*/
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
    /*t = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 464, self.view.frame.size.width, 40)];
     t.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
     [t setItems: [NSArray arrayWithObjects:buttonItems,  nil]];
     [self.view addSubview:t];*/
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.frame = CGRectMake(0, 460, self.view.frame.size.width, 44);
    [self.toolbar setItems:buttonItems];
    self.toolbar.hidden = NO;
    [self.view addSubview:self.toolbar];
}



-(BOOL)belongsToDB:(NSString*)table withClause:(NSString*)clause{
    
    sqlite3_stmt *statement;
    sqlite3 *peopleDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:table];
    BOOL belongsToTable = NO;
    if (sqlite3_open([dbPathString UTF8String], &peopleDB)==SQLITE_OK) {
        
        NSString *querySql = clause;
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(peopleDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                
                if([table isEqualToString:@"pending_contact.db"])
                    pendingID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                belongsToTable = YES;
                break;
            }
            sqlite3_finalize(statement);
            
        }
        sqlite3_close(peopleDB);
    }
    return belongsToTable;
}

-(NSMutableArray *)getNotes:(NSString*)table withClause:(NSString*)clause{
    sqlite3_stmt *statement;
    sqlite3 *peopleDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:table];
    NSMutableArray* allNotes = [[NSMutableArray alloc]init];
    
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
                    [allNotes addObject:note];
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
                    [allNotes addObject:note];
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(peopleDB);
    }
    return allNotes;
}




- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 100)]; // x,y,width,height
    
    if(section == 0){
        // person label name
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(150, 20, 160, 20)];
        labelName.text = @"Name:";
        labelName.layer.cornerRadius = 5.0f;
        labelName.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
        labelName.textColor = [UIColor whiteColor];
        labelName.clipsToBounds = YES;
        [headerView addSubview:labelName];
        
        // person name
        UITextView *name = [[UITextView alloc] initWithFrame:CGRectMake(150, 40, 160, 20)];
        [name setEditable:NO];
        name.layer.cornerRadius = 5.0f;
        name.clipsToBounds = YES;
        NSString * n = [[[[personProfile.prefix stringByAppendingString:@" " ]stringByAppendingString:personProfile.firstName]stringByAppendingString:@" "]stringByAppendingString:personProfile.lastName];
        [name setText:n];
        name.scrollEnabled = YES;
        [headerView addSubview:name];
        
        
        
        
        // if contact show private info
        if([self belongsToDB:@"contact.db" withClause:[@"" stringByAppendingFormat:@"SELECT * FROM CONTACT WHERE PERSON_ID = %@", self.personID]]){
            // do nothing
        }
        // if is pending contact
        else if([self belongsToDB:@"pending_contact.db" withClause:[@"" stringByAppendingFormat:@"SELECT * FROM PENDING_CONTACT WHERE PERSON_ID = %@", self.personID]]) {
            
            UIButton *addContact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            addContact.frame = CGRectMake(150, 120, 75, 30);
            [addContact setTitle: @"Accept" forState:UIControlStateNormal];
            
            [addContact addTarget:self
                           action:@selector(acceptContact:)
                 forControlEvents:UIControlEventTouchDown];
            
            [headerView addSubview:addContact];
            UIButton *rejectContact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            rejectContact.frame = CGRectMake(225, 120, 75, 30);
            [rejectContact setTitle: @"Reject" forState:UIControlStateNormal];
            
            [rejectContact addTarget:self
                              action:@selector(rejectContact:)
                    forControlEvents:UIControlEventTouchDown];
            
            [headerView addSubview:rejectContact];
            
        }
        // if is a rejected or an asked contact
        else if([self belongsToDB:@"asked_contact.db" withClause:[@"" stringByAppendingFormat:@"SELECT * FROM ASKED_CONTACT WHERE PERSON_ID = %@", self.personID]]){
            // do nothing
        }
        // only option add contact
        else {
            UIButton *addContact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            addContact.frame = CGRectMake(150, 120, 150, 30);
            [addContact setTitle: @"Add contact" forState:UIControlStateNormal];
            
            [addContact addTarget:self
                           action:@selector(addContact:)
                 forControlEvents:UIControlEventTouchDown];
            
            [headerView addSubview:addContact];
            
        }
        
        // person label email
        UILabel *labelEmail = [[UILabel alloc] initWithFrame:CGRectMake(15, 160, self.view.frame.size.width-25, 20)];
        labelEmail.text = @"Email:";
        labelEmail.layer.cornerRadius = 5.0f;
        labelEmail.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
        labelEmail.textColor = [UIColor whiteColor];
        labelEmail.clipsToBounds = YES;
        [headerView addSubview:labelEmail];
        //10
        // person email
        UITextView *email = [[UITextView alloc] initWithFrame:CGRectMake(15, 180, self.view.frame.size.width-25, 20)];
        [email setEditable:NO];
        [email setText:personProfile.email];
        email.scrollEnabled = YES;
        email.layer.cornerRadius = 5.0f;
        email.clipsToBounds = YES;
        [headerView addSubview:email];
        
        // person label institution
        UILabel *labelIns = [[UILabel alloc] initWithFrame:CGRectMake(150, 70, 160, 20)];
        labelIns.text = @"Institution:";
        labelIns.layer.cornerRadius = 5.0f;
        labelIns.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
        labelIns.textColor = [UIColor whiteColor];
        labelIns.clipsToBounds = YES;
        [headerView addSubview:labelIns];
        
        // person institution
        UITextView *institution = [[UITextView alloc] initWithFrame:CGRectMake(150, 90, 160, 20)];
        [institution setEditable:NO];
        institution.layer.cornerRadius = 5.0f;
        institution.clipsToBounds = YES;
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
        height = 210;
        if(![personProfile.biography isEqualToString:@""]){
            
            UILabel *personalDescription = [[UILabel alloc] initWithFrame:CGRectMake(15, height, 295, 20)];
            personalDescription.text = @"Personal description:";
            personalDescription.layer.cornerRadius = 5.0f;
            personalDescription.clipsToBounds = YES;
            personalDescription.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
            personalDescription.textColor = [UIColor whiteColor];
            height+=20;
            [headerView addSubview:personalDescription];
            
            UITextView *biography =  [[UITextView alloc] initWithFrame:CGRectMake(15, height, self.view.frame.size.width-25, 200)];
            [biography setEditable:NO];
            biography.scrollEnabled = YES;
            [biography setText:personProfile.biography];
            biography.layer.cornerRadius = 5.0f;
            biography.clipsToBounds = YES;
            
            
            
            [biography setFrame:CGRectMake(15, height, self.view.frame.size.width-25,biography.contentSize.height) ];
            //NSLog(@"biography content : %f", biography.contentSize.height);
            
            if(biography.contentSize.height <= 200){
                CGRect frame = biography.frame;
                frame.size.height = biography.contentSize.height;
                biography.frame = frame;
                height+=biography.contentSize.height + 10;
            } else {
                [biography setFrame:CGRectMake(15, height, self.view.frame.size.width-25,200) ];
                height+=210;
            }
            [headerView addSubview:biography];
            //NSLog(@"biography done : %f", biography.frame.size.height);
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,30,100,90)];
        imageView.contentMode  = UIViewContentModeScaleAspectFit;
        
        UIImage * imageFromURL;
        //NSLog(@"photo:  %@", personProfile.photo);
                //NSLog(@"photo:  %d", personProfile.photo == nil);
        if([personProfile.photo isEqualToString:@""]){
            imageFromURL = [UIImage imageNamed:@"defaultPerson.jpg"];
            //NSLog(@"hey");
        }        else
            imageFromURL = [UIImage imageWithContentsOfFile:personProfile.photo];
        
        
        [imageView setImage:imageFromURL];
        [headerView addSubview:imageView];

        
        if(personNetworking.count != 0){
            UILabel *networking = [[UILabel alloc] initWithFrame:CGRectMake(15, height, 295, 20)];
            networking.text = @"Networking:";
            networking.layer.cornerRadius = 5.0f;
            networking.clipsToBounds = YES;
            networking.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
            networking.textColor = [UIColor whiteColor];
            [headerView addSubview:networking];
            height += 30;

        }        
}
    
    else if(section == 1){
        if(notes.count != 0){
            UILabel *notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 295, 20)];
            notesLabel.text = @"My notes:";
            notesLabel.layer.cornerRadius = 5.0f;
            notesLabel.clipsToBounds = YES;
            notesLabel.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
            notesLabel.textColor = [UIColor whiteColor];
            [headerView addSubview:notesLabel];
        }
    } else if (section == 2){
        
        if(info.count != 0){
            UILabel *personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 295, 25)];
            personalInfoLabel.text = @"Personal information:";
            personalInfoLabel.layer.cornerRadius = 5.0f;
            personalInfoLabel.clipsToBounds = YES;
            personalInfoLabel.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
            personalInfoLabel.textColor = [UIColor whiteColor];
            [headerView addSubview:personalInfoLabel];
        }
    }
    
    return headerView;
}



-(void)addContact:(UIButton *)sender {
    
    [self insertTo:@"asked_contact_local.db" table:@"ASKED_CONTACT_LOCAL" definition: @"PERSON_ID"
            values: [@"" stringByAppendingFormat:@"'%@'", self.personID]];
    [self insertTo:@"asked_contact.db" table:@"ASKED_CONTACT" definition: @"PERSON_ID"
            values: [@"" stringByAppendingFormat:@"'%@'", self.personID]];
    
    Update *update = [[Update alloc] initDB];
    [update updateWithoutMessage];
    
    [self.tableNetworking reloadData];
}

-(void)rejectContact:(UIButton *)sender {
    
    [self removeFrom:@"pending_contact.db" table:@"PENDING_CONTACT" attribute:@"PENDING_SERVER_ID" withID:[pendingID intValue]];
    
    [self insertTo:@"rejected_contact_local.db" table:@"REJECTED_CONTACT_LOCAL" definition: @"PENDING_SERVER_ID, PERSON_ID"
            values: [@"" stringByAppendingFormat:@"'%@' , '%@'", pendingID, self.personID]];
    
    Update *update = [[Update alloc] initDB];
    [update updateWithoutMessage];
    
    [self.tableNetworking reloadData];
}

-(void)acceptContact:(UIButton *)sender {
    
    [self removeFrom:@"pending_contact.db" table:@"PENDING_CONTACT" attribute:@"PENDING_SERVER_ID" withID:[pendingID intValue]];
    [self insertTo:@"contact_local.db" table:@"CONTACT_LOCAL" definition: @"PERSON_ID, PENDING_SERVER_ID, REJECTED_SERVER_ID"
            values: [@"" stringByAppendingFormat:@"'%@', '%@', '0'", self.personID, pendingID]];
    [self insertTo:@"contact.db" table:@"CONTACT" definition: @"PERSON_ID"
            values: [@"" stringByAppendingFormat:@"'%@'", self.personID]];
    
    Update *update = [[Update alloc] initDB];
    [update updateWithoutMessage];
    
    [self.tableNetworking reloadData];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return height;
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0f;
}

-(void) insertTo:(NSString *) db_file table: (NSString *) table_name definition: (NSString *) definition values: (NSString *) values{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",[table_name uppercaseString], [definition uppercaseString], values];
        NSLog(@"%@",querySql);
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




#pragma mark - UITableViewDelegate Methods

- (IBAction)addNote:(UIBarButtonItem *)sender {
    
    //NSLog(@"new note...");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    
    NoteViewController *note =[storyboard instantiateViewControllerWithIdentifier:@"NoteViewController"];
    note.hidePersonButton = YES;
    note.hideSessionButton = NO;
    note.personID = self.personID;
    note.date = @"0";
    note.noteID = @"0";
    [[self navigationController] pushViewController:note animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [self updateNotes];
    [self.tableNetworking reloadData];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"removing the note...");
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Note * note = [notes objectAtIndex:indexPath.row];
        if(note.isLocal){
            [self removeFrom:@"notes_local.db" table:@"NOTES_LOCAL" attribute:@"ID" withID:[note.noteID intValue]];
        } else {
            [self insertTo:@"deleted_local.db" table:@"DELETED_LOCAL" definition:@"SERVER_ID" values:note.noteID];
            [self removeFrom:@"notes.db" table:@"NOTES" attribute:@"SERVER_ID" withID:[note.noteID intValue]];
            Update *update = [[Update alloc] initDB];
            [update updateWithoutMessage];
        }
        [notes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableNetworking reloadData];
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
            //NSLog(@"%@ deleted", [table_name capitalizedString]);
        }else{
            //NSLog(@"%@ NOT deleted", [table_name capitalizedString]);
            //NSLog(@"%s", error);
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
