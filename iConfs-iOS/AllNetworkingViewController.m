//
//  AllNetworkingViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 05/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "AllNetworkingViewController.h"

@interface AllNetworkingViewController () <UITableViewDelegate, UITableViewDataSource>{
}
@property (nonatomic, strong) NSString *dbPathNetworking;
@property (nonatomic, strong) NSMutableArray *arrayOfNetworking;
@property (nonatomic, strong)NSMutableArray *privateNetworking;
@property (nonatomic, strong) UISegmentedControl * typeNet;

@end

@implementation AllNetworkingViewController
@synthesize tableNetworking;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _arrayOfNetworking = [[NSMutableArray alloc]init];
    _privateNetworking = [[NSMutableArray alloc]init];
   
    NSArray *itemArray = [NSArray arrayWithObjects: @"My interests", @"All", nil];
    _typeNet  = [[UISegmentedControl alloc] initWithItems:itemArray];
    _typeNet.frame = CGRectMake(10, 5, 200, 40);
    _typeNet.segmentedControlStyle = UISegmentedControlStyleBar;
    _typeNet.selectedSegmentIndex = 1;
    [_typeNet addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];


    [self displayNetworking];
    
    self.tableNetworking = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableNetworking.dataSource = self;
    self.tableNetworking.delegate = self;
    [self.view addSubview:self.tableNetworking ];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * tamanho de uma cell
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
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
    if(self.typeNet.selectedSegmentIndex == 0)
        return [_privateNetworking count];
    return [_arrayOfNetworking count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell5";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (cell == nil) {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //}

    Networking *networking;
    
    if(self.typeNet.selectedSegmentIndex == 0)
        networking = [_privateNetworking objectAtIndex:indexPath.row];
    else
        networking= [_arrayOfNetworking objectAtIndex:indexPath.row];
    
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
    NSString * letter = [person.firstName substringToIndex:1];
    personName.text = [[[[[person.prefix stringByAppendingString:@" " ]stringByAppendingString:person.lastName]stringByAppendingString:@", "]stringByAppendingString:letter]stringByAppendingString:@"."];
    
    [cell.contentView addSubview:personName];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    UIImage * imageFromURL = [UIImage imageWithContentsOfFile:person.photo];//@"/Users/martalidon/Pictures/apple.jpg"];//person.photo];
    [imageView setImage:imageFromURL];
    [cell addSubview:imageView];
    // cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self performSegueWithIdentifier:@"segue2" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 100)]; // x,y,width,height
    [headerView addSubview:_typeNet];
    return headerView;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [tableNetworking indexPathForSelectedRow];
    NetworkingViewController * network = (NetworkingViewController*)segue.destinationViewController;
    network.networkingDescription = [[UITextView alloc] init];
    network.personPhoto = [[UIImageView alloc] init];
    
    Networking *networking;
    
    if(self.typeNet.selectedSegmentIndex == 0)
        networking = [_privateNetworking objectAtIndex:indexPath.row];
    else
        networking= [_arrayOfNetworking objectAtIndex:indexPath.row];
    
    network.numNetworking = indexPath.row;
    network.netTitle = networking.title;
    Person * person = [self getPerson:networking.personID];
    NSString * letter = [person.firstName substringToIndex:1];
    network.namePerson = [[[[[person.prefix stringByAppendingString:@" " ]stringByAppendingString:person.lastName]stringByAppendingString:@", "]stringByAppendingString:letter]stringByAppendingString:@"."];
    network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    network.photoPath = person.photo;
    network.networkingDescriptionContent = networking.text;
    network.personId = networking.personID;
}


- (void)valueChanged:(UISegmentedControl *)segment {
    
    //get index position for the selected control
    NSInteger selectedIndex = [segment selectedSegmentIndex];
    
    if(selectedIndex == 0) {
        if([_privateNetworking count]== 0)
            [self displayNetworkingPersonal];
            
    }else if (selectedIndex == 1){
        if([_arrayOfNetworking count]==0)
            [self displayNetworking];
        
    }
    [tableNetworking reloadData];
}


-(void) displayNetworking{

    sqlite3_stmt *statement;
    sqlite3 *networkingDB;
    NSString * selectquery = @"SELECT * FROM NETWORKINGS";
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"networkings.db"];
    if (sqlite3_open([dbPathString UTF8String], &networkingDB)==SQLITE_OK) {
        [_arrayOfNetworking removeAllObjects];
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
                [_arrayOfNetworking addObject:networking];
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
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE WHERE SERVER_ID = %@", personId];
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

/*-(NSMutableArray*)getIdAreasOfPerson:(NSString*)personID{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSMutableArray *areas = [[NSMutableArray alloc]init];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people_area.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE_AREA WHERE PERSON_ID = %@", personID];
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

-(NSString*)getAreas:(NSString*)personID{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"areas.db"];
    NSString * personInterests = @"";
    NSMutableArray *areas = [self getIdAreasOfPerson:personID];
    
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        for (NSString *areaId in areas){
            NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM Area WHERE SERVER_ID = %@", areaId];
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
}*/


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
                     return [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                    
                }
            }
            sqlite3_close(db);
        }
    
    return nil;
}

#pragma mark TKCalendarDayViewDelegate
- (NSMutableArray *) displayNetworkingPersonal{

    sqlite3 *db;
    NSString * personID = [self getPersonID];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathPeople_area = [docPath stringByAppendingPathComponent:@"people_area.db"];
    NSString *dbPathNet_area = [docPath stringByAppendingPathComponent:@"networking_area.db"];
    NSString * dbNetworking = [docPath stringByAppendingPathComponent:@"networkings.db"];
    NSMutableArray* personalNetworking = [[NSMutableArray alloc]init];
    [_privateNetworking removeAllObjects];
    if (sqlite3_open([dbPathPeople_area UTF8String], &db) == SQLITE_OK)
    {
        NSString *strSQLAttach = [NSString stringWithFormat:@"ATTACH DATABASE \'%s\' AS SECOND", [dbPathNet_area UTF8String]];
        
        char *errorMessage;
        
        if (sqlite3_exec(db, [strSQLAttach UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK)
        {
            NSString *strSQLAttach = [NSString stringWithFormat:@"ATTACH DATABASE \'%s\' AS THIRD", [dbNetworking UTF8String] ];
            
            if(sqlite3_exec(db, [strSQLAttach UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK){
                sqlite3_stmt *myStatment;
            
                NSString *strSQL = [@"select * from main.PEOPLE_AREA people_area inner join SECOND.NET_AREA net_area inner join THIRD.NETWORKINGS networkings on people_area.AREA_ID = net_area.AREA_ID AND networkings.SERVER_ID = net_area.NETWORKING_ID AND people_area.PERSON_ID = "stringByAppendingString:personID];
            
                if (sqlite3_prepare_v2(db, [strSQL UTF8String], -1, &myStatment, nil) == SQLITE_OK){
                    while (sqlite3_step(myStatment)==SQLITE_ROW) {
                        NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 7)];
                        NSString *text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 8)];
                        NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 10)];
                        NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 9)];
                        Networking *networking = [[Networking alloc]init];
                        [networking setTitle:title];
                        [networking setText:text];
                        [networking setPersonID:personID];
                        [networking setDate:date];
                        [_privateNetworking addObject:networking];                    
                }
            }
        } else
            NSLog(@"Error while attaching '%s'", sqlite3_errmsg(db));
        }
    }
    return personalNetworking;
}

@end
