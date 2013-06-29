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
    BOOL loaded;
}

@end

@implementation ImageViewController

@synthesize imageView, toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        loaded = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locals = [self getLocal];
    picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    picker.autoresizingMask = UIAlertViewStyleDefault;
    //NSLog(@"%f", self.view.frame.size.height);
    picker.frame = CGRectMake(0, 300, self.view.frame.size.width, 162);
    picker.dataSource = self;
	[self.view addSubview:picker];
    self.scrollView.delegate = self;
    UIImage    *image = [UIImage imageNamed:@"defaultTableViewBackground.png"];

    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:image];
    
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
                NSString * localID =  [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                
                Local * local = [[Local alloc]init];
                [local setTitle:title];
                [local setPath:path];
                [local setLocalID:localID];
                [locations addObject:local];
            }
            sqlite3_finalize(statement);
        }
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
    Local * l = [locals objectAtIndex:row];
    pickerView.hidden = NO;
    
    if([self.localID isEqualToString:l.localID] && !loaded){
        loaded = YES;
        NSString * path = l.path;
        UIImage * image = [UIImage imageWithContentsOfFile:path];
        //[self.map setImage:imageFromURL];
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        imageView.contentMode  = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
        [self.scrollView setContentSize:[image size]];
        [self.scrollView setMaximumZoomScale:500.0];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [picker selectRow:row inComponent:component animated:NO];
        return l.title;

    }
    
    else if(row == 0 && !self.localID && !loaded){
        loaded = YES;

        NSString * path = l.path;
        UIImage * image = [UIImage imageWithContentsOfFile:path];

        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        imageView.contentMode  = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
        [self.scrollView setContentSize:imageView.frame.size];
        [self.scrollView setMaximumZoomScale:500.0];
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
        [subview removeFromSuperview];

    }
    [self.scrollView setZoomScale:1];
    [self.scrollView addSubview:imageView];
    [self.scrollView setContentSize:imageView.frame.size];
    [self.scrollView setMaximumZoomScale:500.0];
}



-(UIView*) viewForZoomingInScrollView:(UIScrollView*)scrollView{    
    return imageView;
}

- (void) viewDidAppear:(BOOL)animated {
    [picker reloadAllComponents];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}
@end
