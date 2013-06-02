//
//  NetworkingTableViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 01/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NetworkingTableViewController.h"


@interface NetworkingTableViewController (){
    NSString *dbPathNetworking;
    NSMutableArray *arrayOfNetworking;
}

@end

@implementation NetworkingTableViewController

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
   
    [self insertPerson];
    
    arrayOfNetworking = [[NSMutableArray alloc]init];
    [self displayNetworking];
    
    self.title = @"Networking";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) displayNetworking{
    sqlite3_stmt *statement;
    sqlite3 *networkingDB;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"networkings.db"];
     NSLog(@"net");
    if (sqlite3_open([dbPathString UTF8String], &networkingDB)==SQLITE_OK) {
        [arrayOfNetworking removeAllObjects];
         NSLog(@"ok");
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM NETWORKINGS"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(networkingDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSLog(@"add net");
                 Networking *networking = [[Networking alloc]init];
                
                [networking setTitle:title];
                [networking setText:text];
                [networking setPersonID:personID];
                [networking setDate:date];
                [arrayOfNetworking addObject:networking];
            }
            sqlite3_close(networkingDB);
        }
    }
}

-(Person *)getPerson:(NSString*)personId{
    sqlite3_stmt *statement;
    sqlite3 *peopleDB;
    Person *person = [[Person alloc]init];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &peopleDB)==SQLITE_OK) {
        [arrayOfNetworking removeAllObjects];
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE WHERE ID = %@", personId];
        NSLog(@"person clause id: ");
        //NSLog(querySql);
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(peopleDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *firstName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *lastName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *prefix = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSString *affiliation = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                NSString *email = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];

#warning BLOB é mau... 
                NSString *photo = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];

                NSString *biography = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)];
                NSString *calendarVersion = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                
                [person setFirstName:firstName];
                [person setLastName:lastName];
                [person setPrefix:prefix];
                [person setAffiliation:affiliation];
                [person setEmail:email];
                [person setBiography:biography];
                [person setCalendar_version:calendarVersion];
                [person setDate:date];
                [person setPhoto:photo];//[self getImageFromURL:photo]];
                [arrayOfNetworking addObject:person];
            }
            sqlite3_close(peopleDB);
          
        }
        
    }
    return person;
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
    return [arrayOfNetworking count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"view");
    NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Networking *networking = [arrayOfNetworking objectAtIndex:indexPath.row];
    int n = [arrayOfNetworking count];
    NSLog(@"'%d'", n);
    
    if(networking)
        NSLog(@"not nil");
    else
        NSLog(@"nil");
    
    //cell.textLabel.text = networking.title;
    
    
    //change colors
    //cell.textLabel.textColor = [UIColor colorWithRed: 30.0/255.0 green: 144.0/255.0 blue:255.0/255.0 alpha: 1.0];
    
    CGRect Label1Frame = CGRectMake(10, 10, 290, 25);
    CGRect Label2Frame = CGRectMake(10, 30, 290, 25);
    CGRect Label3Frame = CGRectMake(10, 50, 290, 25);

    UILabel * netTitle = [[UILabel alloc] initWithFrame:Label1Frame];
    netTitle.text = networking.title;
    [cell.contentView addSubview:netTitle];
    
    UILabel * netText = [[UILabel alloc] initWithFrame:Label2Frame];
    netText.text = networking.text;
    [cell.contentView addSubview:netText];
    
    
    //change colors
   // cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    Person *person = [self getPerson:networking.personID];
    UILabel * personName = [[UILabel alloc] initWithFrame:Label3Frame];
    personName.text = person.firstName;
    [cell.contentView addSubview:personName];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    UIImage * imageFromURL = [UIImage imageWithContentsOfFile:person.photo];//@"/Users/martalidon/Pictures/apple.jpg"];//person.photo];

    if(imageFromURL)
        NSLog(@"not nil");
    else
        NSLog(@"nil");
    
    [imageView setImage:imageFromURL];
    [cell addSubview:imageView];
    // cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
      //  ALog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

-(void) insertPerson{
    NSLog(@"insert person");
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people.db"];
    sqlite3 *db;
    char *error;
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
         NSLog(@"insert person DB -> OK");
        NSString *inserStmt = [NSString stringWithFormat:@"INSERT INTO PEOPLE(FIRSTNAME, LASTNAME, PREFIX, AFFILIATION,  EMAIL, PHOTO, BIOGRAPHY, CALENDARVERSION, DATE) VALUES ('Marta', 'Lidon', 'Dr.', 'FCT', 'marta.lidon@gmail.com', '/Users/martalidon/Pictures/apple.jpg', 'ME', '1', '1900-01-01 00:00:00')"];
        
        //NSLog(inserStmt);
        
        //Definitions
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSLog(documentsDirectoryPath);
        //Get Image From URL
        UIImage * imageFromURL = [UIImage imageWithContentsOfFile:@"/Users/martalidon/Pictures/apple.jpg"];
     //   NSLog(imageFromURL);
        
        //Save Image to Directory
        [self saveImage:imageFromURL withFileName:@"apple" ofType:@"jpg" inDirectory:documentsDirectoryPath];
        
        const char *insert_stmt = [inserStmt UTF8String];
        
        if (sqlite3_exec(db, insert_stmt, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"Person added");
        }
        sqlite3_close(db);
    }
    
    //--------------------------photo----------------------
    
    //Definitions
   // NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //Get Image From URL
    //UIImage * imageFromURL = [UIImage imageNamed:@"/Users/martalidon/Pictures/apple.jpg"];//[self getImageFromURL:@"http://www.yourdomain.com/yourImage.png"];
    
    //Save Image to Directory
    //[self saveImage:imageFromURL withFileName:@"apple" ofType:@"jpg" inDirectory:documentsDirectoryPath];
    
    //Load Image From Directory
    //UIImage * imageFromWeb = [self loadImage:@"apple" ofType:@"jpg" inDirectory:documentsDirectoryPath];
    
    //--------------------------photo----------------------
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NotificationViewController * notif = [[NotificationViewController alloc] init];
    notif.notificationText = [[UITextView alloc] init];
    notif = [segue destinationViewController];
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];
    
    Notification *notification = [arrayOfNotifications objectAtIndex:path.row];
    notif.numNotification = path.row;
    notif.notificationTitle = notification.title;
    notif.notificationDateContent = notification.date;
    notif.notificationContent = notification.text;
}*/


/*
 *
 */

/* 
 * tamanho de uma cell
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // The first cell
            return 80.0;
        } else if (indexPath.row == 1) {
                return 44.0;
        }
    }
    
    // Default
    return 50.0;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"prepareForSegue2");
    NetworkingViewController * network = [[NetworkingViewController alloc] init];
    network.networkingDescription = [[UITextView alloc] init];
    network.personPhoto = [[UIImageView alloc] init];
    network = [segue destinationViewController];
    NSLog(@"11111");
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];
    NSLog(@"11111");

    Networking *networking = [arrayOfNetworking objectAtIndex:path.row];
    NSLog(@"'%d'", [arrayOfNetworking count]);

    network.numNetworking = path.row;
    NSLog(networking.title);

    network.networkingTitle.text = networking.title;
    NSLog(@"11111");
    Person * person = [self getPerson:networking.personID];
    
    #warning all name....
    network.personName.text = person.firstName;
    NSLog(@"11111");
    network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    network.photoPath = person.photo;
    network.networkingDescriptionContent = networking.text;
    NSLog(@"11111");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue2" sender:nil];
}

@end
