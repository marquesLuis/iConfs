//
//  PersonalProgramTKCalendarDayViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 04/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "PersonalProgramTKCalendarDayViewController.h"

@interface PersonalProgramTKCalendarDayViewController ()<TKCalendarDayViewDelegate> {
    NSString * beginDate;
    NSString * endDate;
    NSMutableArray *events;
    int eventSelected;
}

@end

@implementation PersonalProgramTKCalendarDayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/** 
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self getBeginAndEnd];
    events = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
    dateFormatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date = [dateFormatter1 dateFromString:beginDate];NSLog(@"date : %@", date);
    self.dayView.date = date;
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self navigationButtons];
}


-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
}
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

/*-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    NSLog(@"change position");
    [self.dayView reloadData];
}*/



- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    NSLog(@"deviceOrientationDidChange");
    [self.dayView reloadData];
    
}


/*- (BOOL)supportedInterfaceOrientations:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"interfaces supported");
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait)
    || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    ||(interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}*/


-(void)getBeginAndEnd{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"calendar.db"];
            NSLog(@"2");
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM CALENDAR"];
        const char* query_sql = [querySql UTF8String];
        NSLog(@"3");
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                        NSLog(@"4");
                beginDate = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                endDate = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSLog(@"%@", beginDate);
                
            }
        }
        sqlite3_close(db);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) calendarDayTimelineView:(TKCalendarDayView*)calendarDayTimeline didMoveToDate:(NSDate*)eventDate{
	NSDate * begin = [self convertNSStringTONSDateTOMinute:beginDate];
    NSDate * end = [self convertNSStringTONSDateTOMinute:endDate];
    
    if([eventDate compare:begin] == NSOrderedAscending){
        eventDate = begin;
         self.dayView.date = begin;
    } else if ([eventDate compare: end] == NSOrderedDescending){
        eventDate = end;
         self.dayView.date = end;
    }
}

#pragma mark TKCalendarDayViewDelegate
- (NSArray *) calendarDayTimelineView:(TKCalendarDayView*)calendarDayTimeline eventsForDate:(NSDate *)eventDate{
   // UIInterfaceOrientation orien = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation orien = [UIApplication sharedApplication].statusBarOrientation;

    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    
    if(UIInterfaceOrientationIsPortrait(orien)){
        self.title = @"Personal Program";

        NSString *dbPathAttending = [docPath stringByAppendingPathComponent:@"attending.db"];
        NSString *dbPathEvents = [docPath stringByAppendingPathComponent:@"events.db"];
        [events removeAllObjects];
            
        if (sqlite3_open([dbPathAttending UTF8String], &db) == SQLITE_OK)
        {    

            NSString *strSQLAttach = [NSString stringWithFormat:@"ATTACH DATABASE \'%s\' AS SECOND", [dbPathEvents UTF8String]];

            char *errorMessage;
            
            if (sqlite3_exec(db, [strSQLAttach UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK)
            { sqlite3_stmt *myStatment;
                
                NSString *strSQL = @"select * from main.ATTENDING attending inner join SECOND.EVENTS event on attending.SESSION_ID = event.SERVER_ID";
                
                if (sqlite3_prepare_v2(db, [strSQL UTF8String], -1, &myStatment, nil) == SQLITE_OK){
                    while (sqlite3_step(myStatment)==SQLITE_ROW) {

                        Event * e = [[Event alloc]init];
                        NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 4)];
                        NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 5)];
                        NSString *kind = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 7)];
                        NSString *dateBegin = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 8)];
                        NSString *dateEnd = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 9)];
                        NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 10)];
                        NSString *local = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 13)];
                        NSString * eventID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 1)];
                        e.title = title;
                        e.description = description;
                        e.kind = kind;
                        e.eventID = eventID;
                        e.begin = [date stringByAppendingString:dateBegin];
                        e.date = date;
                        e.end = [date stringByAppendingString:dateEnd];
                        e.localID = local;
                        [events addObject:e];
                    }
                
                } else
                        NSLog(@"Error while attaching '%s'", sqlite3_errmsg(db));
            }
        }
    } else {
        NSString *dbPathEvents = [docPath stringByAppendingPathComponent:@"events.db"];
        [events removeAllObjects];
        self.title = @"Complete Program";
        if (sqlite3_open([dbPathEvents UTF8String], &db)==SQLITE_OK) {
            sqlite3_stmt *myStatment;
            NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM EVENTS"];
            const char* query_sql = [querySql UTF8String];
            
            if (sqlite3_prepare(db, query_sql, -1, &myStatment, NULL)==SQLITE_OK) {
                while (sqlite3_step(myStatment)==SQLITE_ROW) {
                    Event * e = [[Event alloc]init];
                    NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 1)];
                    NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 2)];
                    NSString *kind = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 4)];
                    NSString *dateBegin = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 5)];
                    NSString *dateEnd = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 6)];
                    NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 7)];
                    NSString *local = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 10)];
                    NSString * eventID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 3)];
                    
                    e.title = title;
                    e.description = description;
                    e.kind = kind;
                    e.eventID = eventID;
                    e.begin = [date stringByAppendingString:dateBegin];
                    e.date = date;
                    e.end = [date stringByAppendingString:dateEnd];
                    e.localID = local;
                    [events addObject:e];
                    
                }
            }
            sqlite3_close(db);
        }
 
    }
    NSMutableArray *ret = [NSMutableArray array];
    int i = 0;
	for(Event *ev in events){

		TKCalendarDayEventView *event = [calendarDayTimeline dequeueReusableEventView];
		if(event == nil) event = [TKCalendarDayEventView eventView];
        event.identifier = [NSNumber numberWithInt:i];
        
		event.titleLabel.text = ev.title;
        
		event.locationLabel.text = [self getLocal:ev.localID];
		event.startDate = [self convertNSStringToNSDate:ev.begin];
        
		
		event.endDate = [self convertNSStringToNSDate:ev.end];
        
		[ret addObject:event];
        i++;
       // NSLog(@"%d", i);
		
	}
	return ret;
}


-(NSString *)getLocal:(NSString*)localID{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"location.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM LOCATION WHERE SERVER_ID = %@", localID];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                 return [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                
                
            }
        }
        sqlite3_close(db);
    }
    return nil;
}

-(NSDate*)convertNSStringTONSDateTOMinute:(NSString*)date{
    NSString *beginDateDB = date;
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
    return  [dateFormatter1 dateFromString:beginDateDB];
}

-(NSDate*)convertNSStringToNSDate:(NSString*)date{
    NSString *beginDateDB = date;
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
    return  [dateFormatter1 dateFromString:beginDateDB];
}

- (void) calendarDayTimelineView:(TKCalendarDayView*)calendarDayTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView{
    eventSelected = eventView.identifier.intValue;
    [self performSegueWithIdentifier:@"segue6" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    EventUIViewController *second= (EventUIViewController*)segue.destinationViewController;
    second.event = [events objectAtIndex:eventSelected];
}




@end
