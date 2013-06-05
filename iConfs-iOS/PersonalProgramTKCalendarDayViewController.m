//
//  PersonalProgramTKCalendarDayViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 04/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "PersonalProgramTKCalendarDayViewController.h"

@interface PersonalProgramTKCalendarDayViewController ()<TKCalendarDayViewDelegate> {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Personal Program";
    
    
    
    NSString *dateStr = @"2013-06-03 07:26";
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd hh:mm"];
    dateFormatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date = [dateFormatter1 dateFromString:dateStr];
   // self.dayView.date = date;
}

-(void)initializeEvents{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TKCalendarDayViewDelegate
- (NSArray *) calendarDayTimelineView:(TKCalendarDayView*)calendarDayTimeline eventsForDate:(NSDate *)eventDate{

   /*
     //Events
     [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, SERVER_ID INTEGER, KIND TEXT, BEGIN TEXT, END TEXT, DURATION INTEGER, DATE TEXT, LOCATION_ID INTEGER, SPEAKER_ID INTEGER, KEYNOTE INTEGER,  LOCAL_ID INTEGER)" WithName:@"events.db"];
     
     [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS_STATUS( ID INTEGER PRIMARY KEY AUTOINCREMENT, LAST_DATE TEXT, LAST_ID INTEGER, LAST_REMOVED INTEGER)" WithName:@"events_status.db"];
     
     //Attending
     [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS ATTENDING( ID INTEGER PRIMARY KEY AUTOINCREMENT, SESSION_ID INTEGER)" WithName:@"attending.db"];
     */
    
    sqlite3 *db;
    NSMutableArray *events = [[NSMutableArray alloc]init];

    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathAttending = [docPath stringByAppendingPathComponent:@"attending.db"];
    NSString *dbPathEvents = [docPath stringByAppendingPathComponent:@"events.db"];
    
    if (sqlite3_open([dbPathAttending UTF8String], &db) == SQLITE_OK)
    {
        NSString *strSQLAttach = [NSString stringWithFormat:@"ATTACH DATABASE \'%s\' AS SECOND", [dbPathEvents UTF8String]];

        char *errorMessage;
        
        if (sqlite3_exec(db, [strSQLAttach UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK)
        {
            
            sqlite3_stmt *myStatment;
            
            NSString *strSQL = @"select * from main.ATTENDING attending inner join SECOND.EVENTS event on attending.SESSION_ID = event.SERVER_ID";
            
            if (sqlite3_prepare_v2(db, [strSQL UTF8String], -1, &myStatment, nil) == SQLITE_OK){
                while (sqlite3_step(myStatment)==SQLITE_ROW) {
                    
                    Event * e = [[Event alloc]init];
                    NSString *title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 3)];
                    NSString *description = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 4)];
                    NSString *kind = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 6)];
                    NSString *dateBegin = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 7)];
                    NSString *dateEnd = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 8)];
                    NSString *date = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 10)];
                    NSString *local = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(myStatment, 11)];
                    
                    e.title = title;
                    e.descrption = description;
                    e.kind = kind;
                    e.begin = [date stringByAppendingString:dateBegin];
                    e.end = [date stringByAppendingString:dateEnd];
                    e.localID = local;
                    [events addObject:e];
                    [events addObject:e];
                }
            
            } else
                    NSLog(@"Error while attaching '%s'", sqlite3_errmsg(db));
        }
    }
    
    NSMutableArray *ret = [NSMutableArray array];

	for(Event *ev in events){

		TKCalendarDayEventView *event = [calendarDayTimeline dequeueReusableEventView];
		if(event == nil) event = [TKCalendarDayEventView eventView];
        
        event.identifier = nil;
        
		event.titleLabel.text = ev.title;
        
		event.locationLabel.text = [self getLocal:ev.localID];
		event.startDate = [self convertNSStringToNSDate:ev.begin];
		
		event.endDate = [self convertNSStringToNSDate:ev.end];
        
		[ret addObject:event];
		
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
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM LOCATION WHERE ID = %@", localID];
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

-(NSDate*)convertNSStringToNSDate:(NSString*)date{
    NSString *beginDateDB = date;
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd hh:mm"];
    dateFormatter1.timeZone = [NSTimeZone defaultTimeZone ];
    return  [dateFormatter1 dateFromString:beginDateDB];
}

- (void) calendarDayTimelineView:(TKCalendarDayView*)calendarDayTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView{
    NSLog(@"selected event from program!");
}




- (IBAction)goHome:(UIBarButtonItem *)sender {
    HomeViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self presentViewController:second animated:YES completion:nil];
}
@end
