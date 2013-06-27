//
//  AllNotesViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 15/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "AllNotesViewController.h"

@interface AllNotesViewController () <UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *notes;
}

@end

@implementation AllNotesViewController
@synthesize notesTableView, addNewNote;
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
    
    self.notesTableView.dataSource = self;
    self.notesTableView.delegate = self;
    [self.notesTableView setEditing:YES animated:YES];
    self.notesTableView.allowsSelectionDuringEditing = YES;
    [self updateNotes];
    [self createToolbar];
    [self navigationButtons];
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

- (IBAction)addNote:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"segue11" sender:sender];

}

-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
    
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    buttonItem.style = UIBarButtonItemStyleBordered;
    
    
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: buttonItem, nil]; //segmentBarItem;
}

- (IBAction)search:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    
    SearchViewController *note =[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [[self navigationController] pushViewController:note animated:YES];
    
}

- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)updateNotes{
    NSMutableArray * server = [self getNotes:@"notes.db" withClause: @"SELECT * FROM NOTES"];
    
    NSMutableArray * local = [self getNotes:@"notes_local.db" withClause:@"SELECT * FROM NOTES_LOCAL"];
    
    notes = [NSMutableArray arrayWithArray:server];
    [notes addObjectsFromArray: local];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        }
        sqlite3_finalize(statement);
        sqlite3_close(peopleDB);
    }
    return allNotes;
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
    return [notes  count];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProductCellIdentifier = @"ProductCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
    Note * note = [notes objectAtIndex:indexPath.row];
    cell.textLabel.text =  note.content;
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}



#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segue16" sender: [NSNumber numberWithInteger:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if([[segue identifier] isEqualToString:@"segue16"]){
        NoteViewController *note = (NoteViewController*)segue.destinationViewController;
        note.hidePersonButton = NO;
        note.hideSessionButton = NO;

        Note *n = [notes objectAtIndex:[sender integerValue]];
        note.noteID = n.noteID;
        note.isLocal = n.isLocal;
        note.content = n.content;
        note.personID = n.personID;
        note.eventID = n.eventID;
        note.noteID = n.noteID;
        note.date = n.date;
    } else if([[segue identifier] isEqualToString:@"segue11"]){
        NoteViewController *note = (NoteViewController*)segue.destinationViewController;
        note.hidePersonButton = NO;
        note.hideSessionButton = NO;
        note.noteID = @"0";
        note.date = @"0";
    }

}


- (void)viewDidAppear:(BOOL)animated{
    [self updateNotes];
    [self.notesTableView reloadData];
}



-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"removing the note...");
    
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
        [self.notesTableView reloadData];
    }
    else {
        [self performSegueWithIdentifier:@"segue16" sender: [NSNumber numberWithInteger:indexPath.row]];
        
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

-(void) insertTo:(NSString *) db_file table: (NSString *) table_name definition: (NSString *) definition values: (NSString *) values{
    sqlite3 *notesLocalDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    if (sqlite3_open([dbPathString UTF8String], &notesLocalDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",[table_name uppercaseString], [definition uppercaseString], values];
        const char* query_sql = [querySql UTF8String];
        if(sqlite3_exec(notesLocalDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ inserted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT inserted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notesLocalDB);
    }
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end
