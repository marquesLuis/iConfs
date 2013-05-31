//
//  NotificationTableViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 31/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NotificationTableViewController.h"
#import "NotificationViewController.h"

@interface NotificationTableViewController (){
    
    NSString *dbPathNotification;
    NSMutableArray *arrayOfNotifications;
}

@end

@implementation NotificationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrayOfNotifications = [[NSMutableArray alloc]init];
    [self displayNotifications];
    
    self.title = @"Notifications";
    //[self.NotificationsText setDelegate:self];
    //[self.NotificationsText setDataSource:self];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void) displayNotifications {
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        [arrayOfNotifications removeAllObjects];
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM NOTIFICATIONS"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *notificationTitle = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *notificationText = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *notificationDate = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                
                Notification *notification = [[Notification alloc]init];
                
                [notification setTitle:notificationTitle];
                [notification setText:notificationText];
                [notification setDate:notificationDate];
                [arrayOfNotifications addObject:notification];
            }
            sqlite3_close(notificationDB);
        }
        
    }
    //   [self.NotificationsText reloadData];
    
}

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
    return [arrayOfNotifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Notification *notification = [arrayOfNotifications objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self cut: notification.title withRange:30];
    
    //change colors
    //cell.textLabel.textColor = [UIColor colorWithRed: 30.0/255.0 green: 144.0/255.0 blue:255.0/255.0 alpha: 1.0];
    
    
    cell.detailTextLabel.text = notification.text; //[self cut:notification.text withRange:10000];
    
    //change colors
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    // cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

-(NSString*) cut:(NSString*)text withRange:(int)range{
    // define the range
    NSRange stringRange = {0, MIN([text length], range)};
    
    NSString* rest = @"";
    
    if(MIN([text length], range) == range && range != [text length])
        rest = @"...";
    
    // adjust the range to include dependent chars
    stringRange = [text rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    return [[text substringWithRange:stringRange] stringByAppendingString:rest];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NotificationViewController * notif = [[NotificationViewController alloc] init];
    notif.notificationText = [[UITextView alloc] init];
    notif = [segue destinationViewController];
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];
    
    Notification *notification = [arrayOfNotifications objectAtIndex:path.row];
    notif.numNotification = path.row;
    notif.notificationTitle = notification.title;
    notif.notificationDateContent = notification.date;
    notif.notificationContent = notification.text;
}



@end
