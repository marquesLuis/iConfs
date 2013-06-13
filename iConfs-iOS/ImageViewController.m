//
//  ImageViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 13/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate>{
    NSMutableArray * locals;
    UIPickerView * picker;
}

@end

@implementation ImageViewController

@synthesize imageView;



//
//  MapViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 09/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//



- (void)viewDidLoad
{
    [super viewDidLoad];
    locals = [self getLocal];
    picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    picker.autoresizingMask = UIAlertViewStyleDefault;
    picker.frame = CGRectMake(0, 342, self.view.frame.size.width, 162);
    picker.dataSource = self;
	[self.view addSubview:picker];
    self.scrollView.delegate = self;
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
    
    /*if([locals count] == 0){
     pickerView.hidden = YES;
     map.hidden = YES;
     [self alertMessages:@"There's no maps available" withMessage:@""];
     //[[self navigationController] popViewControllerAnimated:YES];
     return nil;
     }*/
    
    Local * l = [locals objectAtIndex:row];
    pickerView.hidden = NO;
    
    if(row == 0){
        
        
        NSString * path = l.path;
        UIImage * image = [UIImage imageWithContentsOfFile:path];
        //[self.map setImage:imageFromURL];
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        imageView.contentMode  = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
        [self.scrollView setContentSize:[image size]];
        [self.scrollView setMaximumZoomScale:5.0];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
    }
    
    return l.title;
}



- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Local * l = [locals objectAtIndex:row];
    NSString * path = l.path;
    
    UIImage * image = [UIImage imageWithContentsOfFile:path];
    imageView = [[UIImageView alloc] initWithImage:image ];
    imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    imageView.contentMode  = UIViewContentModeScaleAspectFit;
    for (UIView *subview in self.scrollView.subviews) {
        NSLog(@"remove view");
        [subview removeFromSuperview];
    }
    [self.scrollView addSubview:imageView];
    [self.scrollView setContentSize:[image size]];
    [self.scrollView setMaximumZoomScale:5.0];
}


-(UIView*) viewForZoomingInScrollView:(UIScrollView*)scrollView{
    NSLog(@"zoom");
    return imageView;
}


@end
