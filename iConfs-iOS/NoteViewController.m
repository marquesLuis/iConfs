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
    
    UIToolbar *toolbar = [[UIToolbar alloc] init] ;
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:flexButton, doneButton, nil];
        [toolbar setItems:itemsArray];
    
    [self.noteTextView setInputAccessoryView:toolbar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardwillshow");
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y - 10;
    NSLog(@"%f", newTextViewFrame.size.height);
    newTextViewFrame.size.width = self.view.frame.size.width - 10;
    newTextViewFrame.origin.x = 5;
    newTextViewFrame.origin.y = 5;
    self.noteTextView.frame = newTextViewFrame;

}

-(void)resignKeyboard {
    [self.noteTextView resignFirstResponder];
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
    self.noteTextView.text = @"";
    isPlaceholder = NO;
    self.noteTextView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{

    if(self.noteTextView.text.length == 0){
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
