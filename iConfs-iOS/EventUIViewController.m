//
//  EventUIViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 06/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "EventUIViewController.h"

@interface EventUIViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray * sections;
}

@property (nonatomic, retain) UITableView *info;

@end

@implementation EventUIViewController
@synthesize roomButton;
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
    //title ; date; authors ; description; notes
    sections = [[NSMutableArray alloc] init];
    self.info = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.info.dataSource = self;
    self.info.delegate = self;
    [self.view addSubview:self.info];
    
    // [self displayAuthors];
    
    
    [sections addObject:@"notes..."];
     [sections addObject:@"notes..."];
     [sections addObject:@"notes..."];
     [sections addObject:@"notes..."];
     [sections addObject:@"notes..."];
     [sections addObject:@"notes..."];
     [sections addObject:@"notes..."];
#warning add notes...
    
    
    
    /*   self.sessionTitle.font = [UIFont fontWithName:@"Helvetica" size:14.0];    // For setting font style with size
     labelName.textColor = [UIColor whiteColor];        //For setting text color
     labelName.backgroundColor = [UIColor clearColor];  // For setting background color
     //    labelName.textAlignment = UITextAlignmentCenter;   // For setting the horizontal text alignment
     labelName.numberOfLines = 2;                       // For setting allowed number of lines in a label
     //  labelName.lineBreakMode = UILineBreakModeWordWrap;*/
    
    
    
    
    /**Author
     [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS AUTHOR( ID INTEGER PRIMARY KEY AUTOINCREMENT, EVENT_ID INTEGER, NAME TEXT, PERSON_ID INTEGER)" WithName:@"author.db"];
     */
    
    
    //self.event.title = [[[[_personProfile.prefix stringByAppendingString:@" " ]stringByAppendingString:_personProfile.firstName]stringByAppendingString:@" "]stringByAppendingString:_personProfile.lastName];;
    
    
	// Do any additional setup after loading the view.
    /*_personProfile = [self getPerson:personID];
     NSString * areas = [self getAreas:personID];
     
     
     */
}


-(NSString*)displayAuthors{
    NSString * text = @"";
    NSMutableArray *authors = [self getAuthors];
    for(Author *author in authors){
        text = [text stringByAppendingString: author.name];
    }
    return text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSMutableArray *)getAuthors{
    sqlite3_stmt *statement;
    sqlite3 *peopleDB;
    Author *author = [[Author alloc]init];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"author.db"];
    NSMutableArray* authors = [[NSMutableArray alloc]init];
    
    if (sqlite3_open([dbPathString UTF8String], &peopleDB)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM AUTHOR WHERE EVENT_ID = %@", self.event.eventID];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(peopleDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSString *personID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                [author setEventID:self.event.eventID];
                [author setName:name];
                [author setPersonID:personID];
                [authors addObject:author];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(peopleDB);
    }
    return authors;
}


- (IBAction)goToRoom:(UIButton *)sender {
    if([self shouldPerformSegueWithIdentifier:@"segue12" sender:sender])
        [self performSegueWithIdentifier:@"segue12" sender:sender];

}
- (IBAction)addNote:(UIButton *)sender {
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
    return [sections  count];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    static NSString *ProductCellIdentifier = @"ProductCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
    
        
    cell.textLabel.text =  [sections objectAtIndex:indexPath.section];
    
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 100)]; // x,y,width,height
    
    CGRect LabelFrameTitle = CGRectMake(10, 10, self.view.frame.size.width, 25);
    CGRect LabelFrameDate = CGRectMake(10, 45, 150, 30);
    CGRect LabelFrameRoom = CGRectMake(200, 45, 80, 30);
    CGRect LabelFrameAuthor = CGRectMake(10, 80, self.view.frame.size.width-150, 30);
    CGRect LabelFrameAuthors = CGRectMake(10, 110, self.view.frame.size.width-20, 40);
    CGRect LabelFrameDescription = CGRectMake(10, 160, 149, 25);
    CGRect LabelFrameDescriptionTable = CGRectMake(10, 185, self.view.frame.size.width-20, 175);
    
    //title
    UILabel * title = [[UILabel alloc] initWithFrame:LabelFrameTitle];
    title.backgroundColor = [UIColor clearColor];
    title.text = self.event.title;
    [title setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:18]];
    [headerView addSubview:title];
    
    //date
    UILabel * date = [[UILabel alloc] initWithFrame:LabelFrameDate];
    date.backgroundColor = [UIColor clearColor];
    date.text = [@"Date "  stringByAppendingString: self.event.date];
    [date setFont:[UIFont fontWithName:@"Arial" size:14]];
    [headerView addSubview:date];
    
    //room
    roomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    roomButton.frame = LabelFrameRoom;
    [roomButton setTitle: @"Local" forState:UIControlStateNormal];
    
    NSLog(@"the room has id: %@", self.event.localID);
    
    [roomButton addTarget:self
                     action:@selector(goToRoom:)
           forControlEvents:UIControlEventTouchDown];
    if(self.event.localID)
        [headerView addSubview:roomButton];
    else
        roomButton.hidden = YES;
    
    //author label
    UILabel * author = [[UILabel alloc] initWithFrame:LabelFrameAuthor];
    author.backgroundColor = [UIColor clearColor];
    [author setText: @"Authors:"];
    [headerView addSubview:author];
    
    //authors
    UITextView * authors = [[UITextView alloc] initWithFrame:LabelFrameAuthors];
    [authors setEditable:NO];
    authors.scrollEnabled = YES;
    authors.layer.cornerRadius = 5.0f;
    authors.clipsToBounds = YES;
    authors.layer.borderColor = [[UIColor colorWithRed:(255/255.f) green:(250/255.f) blue:(240/255) alpha:1.0f ]CGColor];
    [authors setTextAlignment: NSTextAlignmentJustified];
    [authors setText:[self displayAuthors]];
    [headerView addSubview:authors];
    
    //description label
    UILabel * description = [[UILabel alloc] initWithFrame:LabelFrameDescription];
    description.backgroundColor = [UIColor clearColor];
    [description setText: @"Description"];
    [headerView addSubview:description];
    
    //description
    UITextView * descriptionText = [[UITextView alloc] initWithFrame:LabelFrameDescriptionTable];
    [descriptionText setEditable:NO];
    descriptionText.scrollEnabled = YES;
    descriptionText.layer.cornerRadius = 5.0f;
    descriptionText.clipsToBounds = YES;
    descriptionText.layer.borderColor = [[UIColor colorWithRed:(255/255.f) green:(250/255.f) blue:(240/255) alpha:1.0f ]CGColor];
    [descriptionText setTextAlignment: NSTextAlignmentJustified];
   // [descriptionText setBackgroundColor:[UIColor clearColor]];
    [descriptionText setText:self.event.description];
    [headerView addSubview:descriptionText];
    NSLog(@"%f",self.view.frame.size.height);

    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 100)]; // x,y,width,height
    //room
    UIButton * addNote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addNote.frame = CGRectMake(110, 15, 100, 40);
    [addNote setTitle: @"Add note" forState:UIControlStateNormal];
    [addNote addTarget:self
             action:@selector(goToRoom:)
   forControlEvents:UIControlEventTouchDown];
    [headerView addSubview:addNote];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 400.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60.0f;
}

/*-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
 
 return @"Notes";
 
 }*/

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*   [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
     [self presentViewController:network animated:YES completion:nil];*/
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSLog(@"shoulpreformesegue");
    if(self.event.localID)
         return YES;
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ImageViewController *map = (ImageViewController*)segue.destinationViewController;    
    map.localID = self.event.localID;
}




@end
