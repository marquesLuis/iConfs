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
    //NSLog(@"%f",self.navigationBar.frame.size.width );
    //NSLog(@"%f",self.navigationBar.frame.size.height );
    
    _typeNet.frame = CGRectMake(0, 5, self.view.frame.size.width-12, 30);
    _typeNet.segmentedControlStyle = UISegmentedControlStyleBar;
    _typeNet.selectedSegmentIndex = 1;
    [_typeNet addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];
    
    
	_typeNet.segmentedControlStyle = UISegmentedControlStyleBar;
	_typeNet.momentary = NO;
	
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_typeNet];
    buttonItem.style = UIBarButtonItemStyleBordered;
    
    [self.toolbar setItems: [NSArray arrayWithObjects:buttonItem,  nil]];
    
    
    
    [self displayNetworking];
    
    //self.tableNetworking = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height- (2*self.navigationController.toolbar.frame.size.height)) style:UITableViewStyleGrouped];
    //  self.tableNetworking.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height- (2*self.navigationController.toolbar.frame.size.height));
    
    
    self.tableNetworking.dataSource = self;
    self.tableNetworking.delegate = self;
    // [self.view addSubview:self.tableNetworking ];
    
    [self navigationButtons];
}
/*- (void)viewWillAppear:(BOOL)animated
 {
 NSArray * toolbarButtons = self.toolbarItems;
 
 for(UI)
 UISegmentedControl *segmentedControl = (UISegmentedControl *).//navigationItem.rightBarButtonItem.customView;
 
 // Before we show this view make sure the segmentedControl matches the nav bar style
 if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTra//NSLucent ||
 self.navigationController.navigationBar.barStyle == UIBarStyleBlackOpaque)
 segmentedControl.tintColor = [UIColor darkGrayColor];
 else
 segmentedControl.tintColor = [UIColor blueColor];
 }*/

-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
}
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
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
    
    // networking title
    UILabel * netTitle = [[UILabel alloc] initWithFrame:Label1Frame];
    netTitle.text = networking.title;
    netTitle.font = [UIFont systemFontOfSize:16.0];
    netTitle.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:netTitle];
    
    // networking description
    UILabel * netText = [[UILabel alloc] initWithFrame:Label2Frame];
    netText.backgroundColor = [UIColor clearColor];
    netText.text = networking.text;
    netText.font = [UIFont systemFontOfSize:14.0];
    [cell.contentView addSubview:netText];
    
    Person *person = [self getPerson:networking.personID];
    UILabel * personName = [[UILabel alloc] initWithFrame:Label3Frame];
    personName.backgroundColor = [UIColor clearColor];
    
    NSString * letter = [person.firstName substringToIndex:1];
    personName.text = [[[[[person.prefix stringByAppendingString:@" " ]stringByAppendingString:person.lastName]stringByAppendingString:@", "]stringByAppendingString:letter]stringByAppendingString:@"."];
    personName.font = [UIFont systemFontOfSize:12.0];
    
    [cell.contentView addSubview:personName];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    imageView.contentMode  = UIViewContentModeScaleAspectFit;
    
    UIImage * imageFromURL;
    if([person.photo isEqualToString:@""])
        imageFromURL = [UIImage imageNamed:@"defaultPerson.jpg"];
    else
        imageFromURL = [UIImage imageWithContentsOfFile:person.photo];
    
    
    [imageView setImage:imageFromURL];
    
    [cell addSubview:imageView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue2" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier] isEqualToString:@"segue2"]){
        
        NSIndexPath *indexPath = [tableNetworking indexPathForSelectedRow];
        NetworkingViewController * network = (NetworkingViewController*)segue.destinationViewController;
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
}


- (void)valueChanged:(UISegmentedControl *)segment {
    
    //get index position for the selected control
    NSInteger selectedIndex = [segment selectedSegmentIndex];
    if(selectedIndex == 0) {
        //NSLog(@"carreguei em my interests");
        if([_privateNetworking count]== 0){
            //NSLog(@"ainda n tinha carregado aqui");
            [self displayNetworkingPersonal];
            
            if([_privateNetworking count] == 0){
                //NSLog(@"nao ha networking com os meus interesses");
                _typeNet.selectedSegmentIndex = 1;
                
                [self alertMessages:@"There's no personal networking to show" withMessage:@""];
                return;
            }
            
        }
        
    }else if (selectedIndex == 1){
        if([_arrayOfNetworking count]==0)
            [self displayNetworking];
        
    }
    [tableNetworking reloadData];
}

-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) displayNetworking{
    
    sqlite3_stmt *statement;
    sqlite3 *networkingDB;
    NSString * selectquery = @"SELECT * FROM NETWORKINGS ORDER BY DATE DESC";
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
            sqlite3_finalize(statement);
        }
        sqlite3_close(networkingDB);
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
            sqlite3_finalize(statement);
        }
        sqlite3_close(peopleDB);
        
    }
    return person;
}

-(NSString*)getPersonID{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"my_self.db"];
    NSString * result = nil;
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM MY_SELF"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (!nil &&sqlite3_step(statement)==SQLITE_ROW) {
                result = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                break;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
    
    return result;
}

#pragma mark TKCalendarDayViewDelegate
- (void) displayNetworkingPersonal{
    //NSLog(@"1");
    sqlite3 *db;
    NSString * personID = [self getPersonID];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathPeople_area = [docPath stringByAppendingPathComponent:@"people_area.db"];
    NSString *dbPathNet_area = [docPath stringByAppendingPathComponent:@"networking_area.db"];
    NSString * dbNetworking = [docPath stringByAppendingPathComponent:@"networkings.db"];
    [_privateNetworking removeAllObjects];
    NSMutableArray * networks = [NSMutableArray array];
    //NSLog(@"2");
    if (sqlite3_open([dbPathPeople_area UTF8String], &db) == SQLITE_OK)
    {
        NSString *strSQLAttach = [NSString stringWithFormat:@"ATTACH DATABASE \'%s\' AS SECOND", [dbPathNet_area UTF8String]];
        char *errorMessage;
        //NSLog(@"3");
        if (sqlite3_exec(db, [strSQLAttach UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK)
        {//NSLog(@"4");
            
            sqlite3_stmt *myStatment;
            NSString *strSQL = [@"select * from main.PEOPLE_AREA people_area inner join SECOND.NET_AREA net_area on people_area.AREA_ID = net_area.AREA_ID AND people_area.PERSON_ID = "stringByAppendingString:personID];
            //NSLog(@"Pesquisa SQL: %@", strSQL);
            if (sqlite3_prepare_v2(db, [strSQL UTF8String], -1, &myStatment, nil) == SQLITE_OK){
                //NSLog(@"6");
                while (sqlite3_step(myStatment)==SQLITE_ROW) {
                    [networks addObject:[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 5)]];
                }
                
                
                
                sqlite3_finalize(myStatment);
                
                
            } else
            NSLog(@"Error while attaching '%s'", sqlite3_errmsg(db));
            
            
        }
        sqlite3_close(db);
    }
    
    
    sqlite3 *notificationDB;
    //NSString *dbPathString = [docPath stringByAppendingPathComponent:dbNetworking];
    //NSLog(@"a");
    sqlite3_stmt *myStatment;
    
    if (sqlite3_open([dbNetworking UTF8String], &notificationDB)==SQLITE_OK) {
        //NSLog(@"b");
        @try {
            NSString * where = @"";
            for (int i = 0; i<[networks count]; i++){
                where = [where stringByAppendingFormat:@"'%@'",[networks objectAtIndex:i]];
                if (i!=[networks count]-1)
                    where = [where stringByAppendingString:@","];
                else
                    where = [where stringByAppendingString:@") ORDER BY DATE DESC"];
            }
            NSString * querySql = [NSString stringWithFormat:@"SELECT * FROM NETWORKINGS WHERE SERVER_ID IN (%@", where];
            //NSLog(@"Pesquisa SQL: %@", querySql);
            const char* query_sql = [querySql UTF8String];
            if (sqlite3_prepare(notificationDB, query_sql, -1, &myStatment, NULL)==SQLITE_OK) {
                while (sqlite3_step(myStatment)==SQLITE_ROW) {
                    //NSLog(@"7");
                    NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 1)];
                    NSString *text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 2)];
                    NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 4)];
                    NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 3)];
                    Networking *networking = [[Networking alloc]init];
                    [networking setTitle:title];
                    [networking setText:text];
                    [networking setPersonID:personID];
                    [networking setDate:date];
                    [_privateNetworking addObject:networking];
                }
                sqlite3_finalize(myStatment);
            }
        }
        @catch (NSException *exception) {
            //NSLog(@"PROBLEMA %@",[exception description] );
        }
        @finally {
            sqlite3_close(notificationDB);
        }
        
    } else
        NSLog(@"Error while attaching '%s'", sqlite3_errmsg(notificationDB));
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}
@end
