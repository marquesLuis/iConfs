//
//  AllNotificationViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 05/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "AllNotificationViewController.h"

@interface AllNotificationViewController () <UITableViewDelegate, UITableViewDataSource>

    @property (strong, nonatomic) NSString *dbPathNotification;
    @property (strong, nonatomic)  NSMutableArray *arrayOfNotifications;
   // @property (nonatomic, retain) UITableView *tableNotification;


@end

@implementation AllNotificationViewController
@synthesize tableNotifications;
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
    _arrayOfNotifications = [[NSMutableArray alloc]init];
    [self displayNotifications];
    self.tableNotifications = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) style:UITableViewStyleGrouped];
    self.tableNotifications.dataSource = self;
    self.tableNotifications.delegate = self;
    [self.view addSubview:self.tableNotifications ];
    self.title = @"Notifications";
    [self navigationButtons];
}


-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton animated:YES];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
}
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) displayNotifications {
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        [_arrayOfNotifications removeAllObjects];
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM NOTIFICATIONS"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *notificationTitle = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *notificationText = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *notificationDate = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                
                Notification *notification = [[Notification alloc]init];
                NSLog(@"%@", notificationTitle);
                [notification setTitle:notificationTitle];
                [notification setText:notificationText];
                [notification setDate:notificationDate];
                [_arrayOfNotifications addObject:notification];
            }
            sqlite3_close(notificationDB);
        }
        
    }
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
    return [_arrayOfNotifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //subtitle alloc
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    Notification *notification = [_arrayOfNotifications objectAtIndex:indexPath.row];
    
    cell.textLabel.text = notification.title;
    cell.detailTextLabel.text = notification.text;
    
    //change colors
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue5" sender:nil];
    
    
    
  //  [self presentViewController:notif animated:YES completion:nil];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSIndexPath *indexPath = [tableNotifications indexPathForSelectedRow];
    
    NotificationViewController * notif = (NotificationViewController*)segue.destinationViewController;
    notif.notificationText = [[UITextView alloc] init];
    
    Notification *notification = [_arrayOfNotifications objectAtIndex:indexPath.row];
    notif.numNotification = indexPath.row;
    notif.notificationTitle = notification.title;
    notif.notificationDateContent = notification.date;
    notif.notificationContent = notification.text;
    
}

/*
 * tamanho de uma cell
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

@end
