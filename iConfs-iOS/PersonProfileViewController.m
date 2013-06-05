//
//  PersonProfileViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 02/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "PersonProfileViewController.h"

@interface PersonProfileViewController () <UITableViewDelegate, UITableViewDataSource>
    @property (nonatomic, strong)  Person * personProfile;
    @property (nonatomic, strong) NSMutableArray * personNetworking;
    @property (nonatomic, retain) UITableView *tableNetworking;

@end

@implementation PersonProfileViewController
@synthesize personID, tableNetworking;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

/*- (void) viewWillAppear:(BOOL) animated {
    
    [super viewWillAppear:animated];
    
    self.navigationBar.topItem.title = 
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [[[[_personProfile.prefix stringByAppendingString:@" " ]stringByAppendingString:_personProfile.firstName]stringByAppendingString:@" "]stringByAppendingString:_personProfile.lastName];;
    
    self.navigationBar.topItem.title = @"Profile";

    
	// Do any additional setup after loading the view.
    _personProfile = [self getPerson:personID];
    NSString * areas = [self getAreas:personID];
    
    
	UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height)];
    
    #warning tamanho justo para a janela
    scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2);
    
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(150, 20, 295, 25)];
    labelName.text = @"Name:";
    labelName.textColor=[UIColor colorWithRed:(0/255.f) green:(191/255.f) blue:(255/255.f) alpha:1.0f];
    [scroll addSubview:labelName];
    
    UITextView *name = [[UITextView alloc] initWithFrame:CGRectMake(150, 45, 200, 25)];
    [name setEditable:NO];
    NSString * n = [[[[_personProfile.prefix stringByAppendingString:@" " ]stringByAppendingString:_personProfile.firstName]stringByAppendingString:@" "]stringByAppendingString:_personProfile.lastName];
    [name setText:n];
    name.scrollEnabled = YES;
    [scroll addSubview:name];
    
    UILabel *labelEmail = [[UILabel alloc] initWithFrame:CGRectMake(15, 120, 295, 25)];
    labelEmail.text = @"Email:";
    labelEmail.textColor=[UIColor colorWithRed:(0/255.f) green:(191/255.f) blue:(255/255.f) alpha:1.0f];
    [scroll addSubview:labelEmail];
    
    UITextView *email = [[UITextView alloc] initWithFrame:CGRectMake(15, 145, 295, 25)];
    [email setEditable:NO];
    [email setText:_personProfile.email];
    email.scrollEnabled = YES;
    [scroll addSubview:email];
    
    UILabel *labelIns = [[UILabel alloc] initWithFrame:CGRectMake(150, 70, 295, 25)];
    labelIns.text = @"Institution:";
    labelIns.textColor=[UIColor colorWithRed:(0/255.f) green:(191/255.f) blue:(255/255.f) alpha:1.0f];
    [scroll addSubview:labelIns];
   
    UITextView *institution = [[UITextView alloc] initWithFrame:CGRectMake(150, 95, 295, 25)];
    [institution setEditable:NO];
    [institution setText:_personProfile.affiliation];
    institution.scrollEnabled = YES;
    [scroll addSubview:institution];

   /* UILabel *interest = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, 295, 25)];
    interest.text = @"Interests:";
    interest.textColor=[UIColor colorWithRed:(0/255.f) green:(191/255.f) blue:(255/255.f) alpha:1.0f];
    [scroll addSubview:interest];
    
    UITextView *interests =  [[UITextView alloc] initWithFrame:CGRectMake(15, 195, 295, 100)];
    [interests setEditable:NO];
    [interests setText:areas];
    interests.scrollEnabled = YES;
    [interests setBackgroundColor:[UIColor colorWithRed:(224/255.f) green:(238/255.f) blue:(238/255.f) alpha:1.0f]];
    [scroll addSubview:interests];
*/
    [self.view addSubview:scroll];
    
    UILabel *personalDescription = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, 295, 25)];
    personalDescription.text = @"Personal description:";
    personalDescription.textColor=[UIColor colorWithRed:(0/255.f) green:(191/255.f) blue:(255/255.f) alpha:1.0f];

    [scroll addSubview:personalDescription];
    
    UITextView *biography =  [[UITextView alloc] initWithFrame:CGRectMake(15, 195, 295, 200)];
    [biography setEditable:NO];
    biography.scrollEnabled = YES;

    [biography setText:_personProfile.biography];
    [biography setBackgroundColor:[UIColor colorWithRed:(224/255.f) green:(238/255.f) blue:(238/255.f) alpha:1.0f]];
    [scroll addSubview:biography];
    
    [self.view addSubview:scroll];
      _personNetworking = [[NSMutableArray alloc] init];
    [self displayNetworking:personID];

    UILabel *networking = [[UILabel alloc] initWithFrame:CGRectMake(15, 395, 295, 25)];
    networking.text = @"Networking:";
    networking.textColor=[UIColor colorWithRed:(0/255.f) green:(191/255.f) blue:(255/255.f) alpha:1.0f];

    [scroll addSubview:networking];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,20,100,70)];
    UIImage * imageFromURL = [UIImage imageWithContentsOfFile:_personProfile.photo];
    
    [imageView setImage:imageFromURL];
    [scroll addSubview:imageView];
        
    self.tableNetworking = [[UITableView alloc] initWithFrame:CGRectMake(15, 420, 295, 150) style:UITableViewStylePlain];
    self.tableNetworking.dataSource = self;
    self.tableNetworking.delegate = self;
    [scroll addSubview:self.tableNetworking ];
   
    scroll.scrollEnabled = YES;
    [self.view addSubview:scroll];
}

-(NSMutableArray*)getIdAreasOfPerson:(NSString*)personId{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSMutableArray *areas = [[NSMutableArray alloc]init];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"people_area.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PEOPLE_AREA WHERE PERSON_ID = %@", personId];
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

-(NSString*)getAreas:(NSString*)personId{
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                NSString *emails = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
                NSString *photo = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                NSString *biography = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)];
                NSString *calendarVersion = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 8)];
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 9)];
                
                [person setFirstName:firstName];
                [person setLastName:lastName];
                [person setPrefix:prefix];
                [person setAffiliation:affiliation];
                [person setEmail:emails];
                [person setBiography:biography];
                [person setCalendar_version:calendarVersion];
                [person setDate:date];
                [person setPhoto:photo];
            }
        }
        sqlite3_close(peopleDB);
    }
    return person;
}

-(void)displayNetworking:(NSString*)personId{
    sqlite3_stmt *statement;
    sqlite3 *networkingDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"networkings.db"];
    if (sqlite3_open([dbPathString UTF8String], &networkingDB)==SQLITE_OK) {
        [_personNetworking removeAllObjects];
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM NETWORKINGS WHERE PERSON_ID = %@", personId];
        const char* query_sql = [querySql UTF8String];
        if (sqlite3_prepare(networkingDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *text = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                Networking *networking = [[Networking alloc]init];
                [networking setTitle:title];
                [networking setText:text];
                [networking setPersonID:personId];
                [networking setDate:date];
                [_personNetworking addObject:networking];
            }
            sqlite3_close(networkingDB);
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
    return [_personNetworking count];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProductCellIdentifier = @"ProductCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Networking *networking = [_personNetworking objectAtIndex:indexPath.row];
    
    CGRect Label1Frame = CGRectMake(10, 10, 290, 25);
    CGRect Label2Frame = CGRectMake(10, 30, 290, 25);
    
    UILabel * netTitle = [[UILabel alloc] initWithFrame:Label1Frame];
    netTitle.text = networking.title;
    [cell.contentView addSubview:netTitle];
    
    UILabel * netText = [[UILabel alloc] initWithFrame:Label2Frame];
    netText.text = networking.text;
    [cell.contentView addSubview:netText];
    
    
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NetworkingViewController * network = [self.storyboard instantiateViewControllerWithIdentifier:@"NetworkingViewController"];
    network.networkingDescription = [[UITextView alloc] init];
    network.personPhoto = [[UIImageView alloc] init];
    
    Networking *networking = [_personNetworking objectAtIndex:indexPath.row];
    network.numNetworking = indexPath.row;
    
    
    network.netTitle = networking.title;
    Person * person = [self getPerson:networking.personID];
    
    network.namePerson = [[[[person.prefix stringByAppendingString:@" "]stringByAppendingString:person.firstName]stringByAppendingString:@" "]stringByAppendingString:person.lastName];
    network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    network.photoPath = person.photo;
    network.networkingDescriptionContent = networking.text;
    network.personId = networking.personID;
    [self presentViewController:network animated:YES completion:nil];
}

/**-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
 
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

 **/

/*-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    NetworkingViewController * network = [[NetworkingViewController alloc] init];
    network.networkingDescription = [[UITextView alloc] init];
    network.personPhoto = [[UIImageView alloc] init];
    NSIndexPath * indexPath = [tableNetworking indexPathForSelectedRow];
    Networking *networking = [_personNetworking objectAtIndex:indexPath.row];
    network.numNetworking = indexPath.row;
    
    
    network.netTitle = networking.title;
    Person * person = [self getPerson:networking.personID];
    
    network.namePerson = [[[[person.prefix stringByAppendingString:@" "]stringByAppendingString:person.firstName]stringByAppendingString:@" "]stringByAppendingString:person.lastName];
    network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    network.photoPath = person.photo;
    network.networkingDescriptionContent = networking.text;
    network.personId = networking.personID;
    //network.previous = self;
    
    //change view
     network = [segue destinationViewController];
    
   // [self presentViewController:network animated:YES completion:nil];
}

*/
 
 


/*
 * tamanho de uma cell
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}


- (IBAction)goBack:(UIBarButtonItem *)sender {
    NetworkingViewController * network = [self.storyboard instantiateViewControllerWithIdentifier:@"NetworkingViewController"];
    network.networkingDescription = [[UITextView alloc] init];
    network.personPhoto = [[UIImageView alloc] init];
    NSIndexPath * indexPath = [tableNetworking indexPathForSelectedRow];
    Networking *networking = [_personNetworking objectAtIndex:indexPath.row];
    network.numNetworking = indexPath.row;
    
    
    network.netTitle = networking.title;
    Person * person = [self getPerson:networking.personID];
    
    NSString * letter = [person.firstName substringToIndex:1];
    network.namePerson = [[[[[person.prefix stringByAppendingString:@" " ]stringByAppendingString:person.lastName]stringByAppendingString:@", "]stringByAppendingString:letter]stringByAppendingString:@"."];
    network.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    network.photoPath = person.photo;
    network.networkingDescriptionContent = networking.text;
    network.personId = networking.personID;
    
    [self presentViewController:network animated:YES completion:nil];
}
@end
