//
//  NotificationViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController () {
 
    NSString *dbPathNotification;
    NSMutableArray *arrayOfNotifications;
    
} @end

@implementation NotificationViewController

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
    
    arrayOfNotifications = [[NSMutableArray alloc]init];
    [self displayNotifications];
    [self.NotificationsText setDelegate:self];
    [self.NotificationsText setDataSource:self];
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
        [arrayOfNotifications removeAllObjects];
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM NOTIFICATIONS"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *notificationTitle = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *notificationText = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];

                Notification *notification = [[Notification alloc]init];
    
                [notification setTitle:notificationTitle];
                [notification setNotificationText:notificationText];
                [arrayOfNotifications addObject:notification];
            }
        }
    }
    [self.NotificationsText reloadData];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayOfNotifications count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    Notification *notification = [arrayOfNotifications objectAtIndex:indexPath.row];
    
    
    
    cell.textLabel.text = [self cut: notification.title withRange:30];
    
    //change colors
    cell.textLabel.textColor = [UIColor colorWithRed: 30.0/255.0 green: 144.0/255.0 blue:255.0/255.0 alpha: 1.0];
    
    
    cell.detailTextLabel.text = [self cut:notification.notificationText withRange:60];
    
    //change colors
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
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
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10,0,300,60)] ;
    
    // create image object
    UIImage *myImage = [UIImage imageNamed:@"someimage.png"];;
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.frame = CGRectMake(70,18,200,20);
    headerLabel.text =  @"Some Text";
    headerLabel.textColor = [UIColor redColor];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor darkGrayColor];
    detailLabel.text = @"Some detail text";
    detailLabel.font = [UIFont systemFontOfSize:12];
    detailLabel.frame = CGRectMake(70,33,230,25);
    
    // create the imageView with the image in it
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    imageView.frame = CGRectMake(10,10,50,50);
    
    [customView addSubview:imageView];
    [customView addSubview:headerLabel];
    [customView addSubview:detailLabel];
    
    return customView;
}

*/
@end
