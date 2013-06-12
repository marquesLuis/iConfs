//
//  MapViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 09/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray * locals;
    UIPickerView * picker;
}

@end

@implementation MapViewController
@synthesize map;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)zoomIn:(UIPinchGestureRecognizer *)reconizer{
    reconizer.view.transform = CGAffineTransformScale(reconizer.view.transform, reconizer.scale, reconizer.scale);
    reconizer.scale = 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locals = [self getLocal];
    picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    picker.autoresizingMask = UIAlertViewStyleDefault;
    picker.frame = CGRectMake(35, 342, 250, 162);
    picker.dataSource = self;
	[self.view addSubview:picker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)getLocal{
    sqlite3_stmt *statement;
    sqlite3 *db;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"location.db"];
    
    NSMutableArray * locations = [[NSMutableArray alloc]init];
    if (sqlite3_open([dbPathString UTF8String], &db) == SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM LOCATION"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(db, query_sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString * title = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString * path =  [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                
                Local * local = [[Local alloc]init];
                [local setTitle:title];
                [local setPath:path];
                [locations addObject:local];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    return locations;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    if ([locals count] == 0)
        return 1;
    return [locals count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
   
    if([locals count] == 0){
        pickerView.hidden = YES;
        map.hidden = YES;
        [self alertMessages:@"There's no maps available" withMessage:@""];
        return nil;
    }
    
    Local * l = [locals objectAtIndex:row];
    pickerView.hidden = NO;

    if(row == 0){
        NSString * path = l.path;
        UIImage * imageFromURL = [UIImage imageWithContentsOfFile:path];
        [self.map setImage:imageFromURL];
    }

    return l.title;
}

-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Local * l = [locals objectAtIndex:row];
    NSString * path = l.path;
    UIImage * imageFromURL = [UIImage imageWithContentsOfFile:path];
    [self.map setImage:imageFromURL];
}



@end
