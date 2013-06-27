//
//  HomeViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize update, logout;

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
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.update = [[Update alloc] initDB];
    
    
    NSLog(@"HomeVC %d", self.interfaceOrientation);
    [self navigationButtons];
}


-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateButton:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: logout, homeButton, nil]; 
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)goToContacts:(UIButton *)sender {
    
    NSLog(@"goToParticipants");
    NSMutableArray * items = [self getAllPersons];
    KNMultiItemSelector * selector;
    
    
    selector = [[KNMultiItemSelector alloc] initWithItems:items
                                             preselectedItems:nil
                                                        title:@"Participants"
                                              placeholderText:@"Search by name"
                                                     delegate:self
                                                         text:nil];
        
    selector.infoType = 3;
    // Again, the two optional settings
    selector.allowSearchControl = YES;
    selector.useTableIndex      = YES;
    selector.useRecentItems     = NO;
    selector.maxNumberOfRecentItems = 0;
    selector.allowModeButtons = NO;
    UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
    uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    uinav.modalPresentationStyle = UIModalPresentationFormSheet;
   [self.navigationController pushViewController:selector animated:YES];
}

- (IBAction)updateButton:(UIButton *)sender {
    [self.update update];
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
                
                
                NSString *name = [[firstName stringByAppendingString:@" "]stringByAppendingString:lastName];
                [items addObject:[[KNSelectorItem alloc] initWithDisplayValue:name selectValue:personID imageUrl:photo]];

            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
    return items;
}



-(int)getInfoIcon:(NSString*)database withTableName:(NSString*)tableName{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:database];
    int last_row = 0;
    if (sqlite3_open([dbPathString UTF8String], &db) == SQLITE_OK) {
        NSString *querySql = [NSString stringWithFormat:@"%@%@", @"SELECT COUNT(*) FROM ", tableName];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *messageID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                last_row = [messageID integerValue];
                
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(db);
       
    }
    NSLog(@"%d",last_row );
    return last_row;
}



-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"segue7" ]) {
        if([self getInfoIcon:@"location.db" withTableName:@"LOCATION"] == 0){
            [self alertMessages:@"There's no maps available" withMessage:@""];
            return NO;
        }
    } else if([identifier isEqualToString:@"segue1" ]){
        if([self getInfoIcon:@"networkings.db" withTableName:@"NETWORKINGS"] == 0){
            [self alertMessages:@"There's no topics available" withMessage:@""];
            return NO;
        }
    }
    
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}



@end
