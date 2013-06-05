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
    BOOL isAll;
}
@end

@implementation NetworkingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        /*NSArray *itemArray = [NSArray arrayWithObjects: @"My interests", @"All", nil];
        UISegmentedControl *optionAllOrPref = [[UISegmentedControl alloc] initWithItems:itemArray];
        optionAllOrPref.frame = CGRectMake(0, self.view.frame.size.height-52, self.view.frame.size.width, 48);
        
        optionAllOrPref.segmentedControlStyle = UISegmentedControlStylePlain;
        optionAllOrPref.selectedSegmentIndex = 1;
        self.tableView.tableHeaderView = optionAllOrPref;*/
        //[self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //self.tableView.tableHeaderView = self.prefOrAllButton;
        isAll = YES;

           }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    //[self insertPerson];
    
    arrayOfNetworking = [[NSMutableArray alloc]init];
    [self displayNetworking:@"SELECT * FROM NETWORKINGS"];
    
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


-(void) displayNetworking:(NSString*)selectquery{
    sqlite3_stmt *statement;
    sqlite3 *networkingDB;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"networkings.db"];
    if (sqlite3_open([dbPathString UTF8String], &networkingDB)==SQLITE_OK) {
        [arrayOfNetworking removeAllObjects];
        const char* query_sql = [selectquery UTF8String];
        
        if (sqlite3_prepare(networkingDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
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
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE WHERE ID = %@", personId];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(peopleDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *firstName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *lastName = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *prefix = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSString *affiliation = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                NSString *email = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
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
                [person setPhoto:photo];
            }
            sqlite3_close(peopleDB);
        }
        
    }
    return person;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //[[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor whiteColor]];
    /*NSArray *itemArray = [NSArray arrayWithObjects: @"My interests", @"All", nil];
    UISegmentedControl *optionAllOrPref = [[UISegmentedControl alloc] initWithItems:itemArray];
    optionAllOrPref.frame = CGRectMake(0, self.view.frame.size.height-52, self.view.frame.size.width, 48);
    
    optionAllOrPref.segmentedControlStyle = UISegmentedControlStylePlain;
    optionAllOrPref.selectedSegmentIndex = 1;*/
    self.tableView.tableHeaderView = self.prefOrAllButton;
//self.prefOrAllButton.frame = CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50);

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
    NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Networking *networking = [arrayOfNetworking objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = networking.title;
    
    
    //change colors
    //cell.textLabel.textColor = [UIColor colorWithRed: 30.0/255.0 green: 144.0/255.0 blue:255.0/255.0 alpha: 1.0];
    
    CGRect Label1Frame = CGRectMake(10, 10, 175, 25);
    CGRect Label2Frame = CGRectMake(10, 30, 175, 25);
    CGRect Label3Frame = CGRectMake(10, 50, 175, 25);

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
        //error
    }
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

/*-(void) insertPerson{
    NSLog(@"insert person");
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people.db"];
    sqlite3 *db;
    char *error;
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
         NSLog(@"insert person DB -> OK");
        NSString *inserStmt = [NSString stringWithFormat:@"INSERT INTO PEOPLE(FIRSTNAME, LASTNAME, PREFIX, AFFILIATION,  EMAIL, PHOTO, BIOGRAPHY, CALENDARVERSION, DATE) VALUES ('Ana', 'Gonçalves', 'Dr.', 'FCT', 'anaflores@gmail.com', '/Users/martalidon/Pictures/apple.jpg', 'Herodotus, a 5th century B.C. Greek historian is considered within the Western tradition to be the father of history, and, along with his contemporary Thucydides, helped form the foundations for the modern study of human history. Their work continues to be read today and the divide between the culture-focused Herodotus and the military-focused Thucydides remains a point of contention or approach in modern historical writing. In the Eastern tradition, a state chronicle the Spring and Autumn Annals was known to be compiled from as early as 722 BCE although only 2nd century BCE texts survived.Ancient influences have helped spawn variant interpretations of the nature of history which have evolved over the centuries and continue to change today. The modern study of history is wide-ranging, and includes the study of specific regions and the study of certain topical or thematical elements of historical investigation. Often history is taught as part of primary and secondary education, and the academic study of history is a major discipline in University studies.', '1', '1900-01-01 00:00:00')"];
        
        //NSLog(inserStmt);
        
        //Definitions
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        //Get Image From URL
        UIImage * imageFromURL = [UIImage imageWithContentsOfFile:@"/Users/martalidon/Pictures/apple.jpg"];
     
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
}*/

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

/* 
 * tamanho de uma cell
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{    
    
    NetworkingViewController * network = [[NetworkingViewController alloc] init];
    network.networkingDescription = [[UITextView alloc] init];
    network.personPhoto = [[UIImageView alloc] init];
    network = [segue destinationViewController];
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];

    Networking *networking = [arrayOfNetworking objectAtIndex:path.row];

    network.numNetworking = path.row;
    network.netTitle = networking.title;
    Person * person = [self getPerson:networking.personID];
    
    network.namePerson = [[[[person.prefix stringByAppendingString:@" " ]stringByAppendingString:person.firstName]stringByAppendingString:@" "]stringByAppendingString:person.lastName];
    network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    network.photoPath = person.photo;
    network.networkingDescriptionContent = networking.text;
    network.personId = networking.personID;
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue2" sender:nil];
}*/

- (IBAction)goHome:(UIBarButtonItem *)sender {
    HomeViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self presentViewController:second animated:YES completion:nil];
}

- (IBAction)changeToAllOrPref:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex == 0)
        isAll = NO;
    else
        isAll = YES;
   // [self displayNetworking:@"SELECT * FROM NETWORKINGS WHERE "];
    
}

-(NSMutableArray*)getIdAreasOfPerson{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSMutableArray *areas = [[NSMutableArray alloc]init];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people_area.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE_AREA WHERE ID = %@", self.personID];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *area = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                [areas addObject:area];
                
            }
        }
        sqlite3_close(db);
    }
    return areas;
}

-(NSString*)getAreas{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"areas.db"];
    NSString * personInterests = @"";
    NSMutableArray *areas = [self getIdAreasOfPerson];
    
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        for (NSString *areaId in areas){
            NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM Area WHERE ID = %@", areaId];
            const char* query_sql = [querySql UTF8String];
            
            if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    NSString *area = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                    personInterests = [personInterests stringByAppendingString:area];
                }
            }
        }
        sqlite3_close(db);
    }
    return personInterests;
}

@end
