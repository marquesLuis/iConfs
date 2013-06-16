//
//  AllNotesViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 15/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController () <UITextViewDelegate, KNMultiItemSelectorDelegate> {
    BOOL isPlaceholder;
    BOOL isAboutPerson;
    
}
@property (nonatomic, strong)  KNSelectorItem * personChosen;
@property (nonatomic, strong)  KNSelectorItem * sessionChosen;
//@property (nonatomic, strong) NSString * content;
@end

@implementation NoteViewController
@synthesize noteTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
if (self) {
    // Custom initialization

}
return self;
}



- (void)didReceiveMemoryWarning
{
[super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}


- (void)viewDidLoad{
    [super viewDidLoad];
    isAboutPerson = false;
    [self.aboutPersonButton setTitle:@"About person" forState:UIControlStateNormal];
    noteTextView.text = @"Write your note here";
    isPlaceholder = YES;
    noteTextView.textColor = [UIColor lightGrayColor];
    noteTextView.delegate = self;
    
    [self costumizeTextView];
}


-(void)costumizeTextView{
    [noteTextView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [noteTextView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [noteTextView.layer setBorderWidth: 1.0];
    [noteTextView.layer setCornerRadius:8.0f];
    [noteTextView.layer setMasksToBounds:YES];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    
    if(isPlaceholder)
        noteTextView.text = @"";
    isPlaceholder = NO;
    noteTextView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
   

    if(noteTextView.text.length == 0 || isPlaceholder){
        noteTextView.textColor = [UIColor lightGrayColor];
        noteTextView.text = @"Write your note here";
        isPlaceholder = YES;
        [noteTextView resignFirstResponder];
    }
    
}

/*
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_LOCAL( ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID INTEGER, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes_local.db"];
 
 */

- (IBAction)addNote:(UIBarButtonItem *)sender {
    if(noteTextView.text.length == 0 || isPlaceholder){
        [self alertMessages:@"Note doesn't saved" withMessage:@"Please write your note"];
        return;
    }
    
    NSLog(@"saving note in notes_local.db...");
    NSString *values = [@"" stringByAppendingFormat:@" '0' , '%@'  ,  '%@' , ", [self getPersonID], noteTextView.text];

    if(_personChosen)
        values = [values stringByAppendingFormat:@" '%@',  ", _personChosen.selectValue];
    else
        values = [values stringByAppendingFormat:@" '0', "];
    
    if(_sessionChosen)
        values = [values stringByAppendingFormat:@" '%@', '0'", _sessionChosen.selectValue];
    else
        values = [values stringByAppendingFormat:@" '0' , '0' "];
    
    
    [self insertTo:@"notes_local.db" table:@"NOTES_LOCAL" definition: @"SERVER_ID, OWNER_ID, CONTENT, ABOUT_PERSON, ABOUT_SESSION,LAST_DATE"
 values:values];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

-(NSString*)getPersonID{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"my_self.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM MY_SELF"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                return [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                
            }
        }
        sqlite3_close(db);
    }
    
    return nil;
}

-(NSMutableArray*)getAllPersons{
    NSMutableArray * items = [NSMutableArray array];
    
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                
                NSString *firstName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *lastName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *photo = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                
                NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                
                NSString * letter = [firstName substringToIndex:1];
                
                NSString *name = [[[lastName stringByAppendingString:@", "]stringByAppendingString:letter]stringByAppendingString:@"."];
                [items addObject:[[KNSelectorItem alloc] initWithDisplayValue:name selectValue:personID imageUrl:photo]];
                
            }
        }
        sqlite3_close(db);
    }
    return items;
}

-(NSMutableArray*)getAllSessions{
    NSMutableArray * items = [NSMutableArray array];
    
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathEvents = [docPath stringByAppendingPathComponent:@"events.db"];
    
    if (sqlite3_open([dbPathEvents UTF8String], &db)==SQLITE_OK) {
        sqlite3_stmt *myStatment;
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM EVENTS"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &myStatment, NULL)==SQLITE_OK) {
            while (sqlite3_step(myStatment)==SQLITE_ROW) {
                NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 1)];
                NSString * eventID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 3)];
                
                [items addObject:[[KNSelectorItem alloc] initWithDisplayValue:title selectValue:eventID imageUrl:nil]];

                
            }
        }
        sqlite3_close(db);
    }
    return items;
}


- (IBAction)addPerson:(UIButton *)sender {
    NSMutableArray * items = [self getAllPersons];
    isAboutPerson = YES;
    KNMultiItemSelector * selector;

    if(_personChosen){
        NSMutableArray * prec = [NSMutableArray array];
        [prec addObject:[[KNSelectorItem alloc] initWithDisplayValue:_personChosen.displayValue selectValue:_personChosen.selectValue imageUrl:_personChosen.imageUrl]];
        
        selector = [[KNMultiItemSelector alloc] initWithItems:items
                                             preselectedItems:prec
                                                        title:@"Select a Person"
                                              placeholderText:@"Search by name"
                                                     delegate:self
                                                         text:noteTextView.text];
    }
    
    // You can even change the title and placeholder text for the selector
    else {
        selector = [[KNMultiItemSelector alloc] initWithItems:items
                                                               preselectedItems:nil
                                                                          title:@"Select a Person"
                                                                placeholderText:@"Search by name"
                                                     delegate:self
                                                         text:noteTextView.text];

    }
    // Again, the two optional settings
    selector.allowSearchControl = YES;
    selector.useTableIndex      = YES;
    selector.useRecentItems     = YES;
    selector.maxNumberOfRecentItems = 4;
    selector.allowModeButtons = NO;
    UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
    uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    uinav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:uinav animated:YES completion:nil];
}

- (IBAction)addSession:(UIButton *)sender {
    NSMutableArray * items = [self getAllSessions];
    
    KNMultiItemSelector * selector;
    if(_sessionChosen){
        NSMutableArray * prec = [NSMutableArray array];
        [prec addObject:[[KNSelectorItem alloc] initWithDisplayValue:_sessionChosen.displayValue selectValue:_sessionChosen.selectValue imageUrl:nil]];
        
        selector = [[KNMultiItemSelector alloc] initWithItems:items
                                             preselectedItems:prec
                                                        title:@"Select a Session"
                                              placeholderText:@"Search by name"
                                                     delegate:self
                                                         text:noteTextView.text];

    }
    
    // You can even change the title and placeholder text for the selector
    else {
        selector = [[KNMultiItemSelector alloc] initWithItems:items
                                             preselectedItems:nil
                                                        title:@"Select a Session"
                                              placeholderText:@"Search by name"
                                                     delegate:self
                                                         text:noteTextView.text];

    }
    // Again, the two optional settings
    selector.allowSearchControl = YES;
    selector.useTableIndex      = YES;
    selector.useRecentItems     = YES;
    selector.maxNumberOfRecentItems = 4;
    selector.allowModeButtons = NO;
    UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
    uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    uinav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:uinav animated:YES completion:nil];
 
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


-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Handle delegate callback

-(void)selectorDidCancelSelection:(NSString*)text{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(isAboutPerson){
        if(_personChosen){
            [self.aboutPersonButton setTitle:_personChosen.displayValue forState:UIControlStateNormal];
        } else {
            [self.aboutPersonButton setTitle:@"About Person" forState:UIControlStateNormal];
        }
        isAboutPerson = NO;
    } else {
        if(_sessionChosen){
            [self.aboutSessionButton setTitle:_sessionChosen.displayValue forState:UIControlStateNormal];
        } else {
            [self.aboutSessionButton setTitle:@"About Session" forState:UIControlStateNormal];
        }
    }
    noteTextView.text = text;
}

-(void)selector:(KNMultiItemSelector *)selector didFinishSelectionWithItems:(NSArray*)selectedItems withText:(NSString *)text{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(isAboutPerson){
        for (KNSelectorItem * o in selectedItems)
            _personChosen = o;
        
        if([selectedItems count] != 0)
            [self.aboutPersonButton setTitle:_personChosen.displayValue forState:UIControlStateNormal];
        else {
            [self.aboutPersonButton setTitle:@"About Person" forState:UIControlStateNormal];
            _personChosen = nil;
        }
        isAboutPerson = NO;
    } else {
        for (KNSelectorItem * o in selectedItems)
            _sessionChosen = o;
        
        if([selectedItems count] != 0)
            [self.aboutSessionButton setTitle:_sessionChosen.displayValue forState:UIControlStateNormal];
        else {
            [self.aboutSessionButton setTitle:@"About Session" forState:UIControlStateNormal];
            _sessionChosen = nil;
        }
    }
    [noteTextView setText: text];
}

-(void)selector:(KNMultiItemSelector *)selector didSelectItem:(KNSelectorItem*)selectedItem{}
-(void)selectorDidFinishSelectionWithItems:(NSArray *)selectedItems {}

@end
