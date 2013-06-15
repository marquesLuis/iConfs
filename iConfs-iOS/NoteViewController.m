//
//  AllNotesViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 15/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController () <UITextViewDelegate> {
    BOOL isPlaceholder;
}

@end

@implementation NoteViewController

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
    self.noteTextView.text = @"Write your note here";
    isPlaceholder = YES;
    self.noteTextView.textColor = [UIColor lightGrayColor];
    self.noteTextView.delegate = self;
    
    [self costumizeTextView];
    
    
}


-(void)costumizeTextView{
    [self.noteTextView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.noteTextView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.noteTextView.layer setBorderWidth: 1.0];
    [self.noteTextView.layer setCornerRadius:8.0f];
    [self.noteTextView.layer setMasksToBounds:YES];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"textviewshouldbeginediting");
    self.noteTextView.text = @"";
    isPlaceholder = NO;
    self.noteTextView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    NSLog(@"textviewdidchange");
    if(self.noteTextView.text.length == 0 || isPlaceholder){
        self.noteTextView.textColor = [UIColor lightGrayColor];
        self.noteTextView.text = @"Write your note here";
        isPlaceholder = YES;
        [self.noteTextView resignFirstResponder];
    }
}

/*
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS NOTES_LOCAL( ID INTEGER PRIMARY KEY AUTOINCREMENT, SERVER_ID INTEGER, OWNER_ID INTEGER, CONTENT TEXT, ABOUT_PERSON INTEGER, ABOUT_SESSION INTEGER, LAST_DATE TEXT)" WithName:@"notes_local.db"];
 
 */

- (IBAction)addNote:(UIBarButtonItem *)sender {
    if(self.noteTextView.text.length == 0 || isPlaceholder){
        [self alertMessages:@"Note doesn't saved" withMessage:@"Please write your note"];
        return;
    }
    
    NSLog(@"saving note in notes_local.db...");
    
  //  [self insertTo:@"notes_local.db" table:@"NOTES_LOCAL" definition: @"SERVER_ID, OWNER_ID, CONTENT, ABOUT_PERSON, ABOUT_SESSION,LAST_DATE"
 //svalues:<#(NSString *)#>];
    
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
                
                
                NSString * letter = [firstName substringToIndex:1];
                
                NSString *name = [[[lastName stringByAppendingString:@", "]stringByAppendingString:letter]stringByAppendingString:@"."];
                [items addObject:[[KNSelectorItem alloc] initWithDisplayValue:name selectValue:@"appl" imageUrl:photo]];
                
            }
        }
        sqlite3_close(db);
    }
    return items;
    
}
- (IBAction)addPerson:(UIButton *)sender {
    NSMutableArray * items = [self getAllPersons];
    // [items addObject:[[KNSelectorItem alloc] initWithDisplayValue:@"Apple Seed"]];
    
    // You can even change the title and placeholder text for the selector
    KNMultiItemSelector * selector = [[KNMultiItemSelector alloc] initWithItems:items
                                                               preselectedItems:nil
                                                                          title:@"Select friends"
                                                                placeholderText:@"Search by name"
                                                                       delegate:self];
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

@end
