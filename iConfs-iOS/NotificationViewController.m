//
//  NotificationViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController () {
    
} @end

@implementation NotificationViewController
@synthesize notificationTitle, notificationContent, notificationDateContent;

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
	// Do any additional setup after loading the view.
    
    self.notificationName.text = notificationTitle;
    self.notificationName.font = [UIFont boldSystemFontOfSize:16.0f];
    self.notificationDate.text = notificationDateContent;
    [self navigationButtons];
    UIImage    *image = [UIImage imageNamed:@"defaultTableViewBackground.png"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    
    
     UITextView *description =  [[UITextView alloc] initWithFrame:CGRectMake(15, 80, self.view.frame.size.width-25, 350)];
    [description setText:notificationContent];
    description.layer.cornerRadius = 5.0f;
    description.clipsToBounds = YES;
    [description setEditable:NO];
    description.backgroundColor = [UIColor lightTextColor];

    self.notificationDate.backgroundColor = [UIColor lightTextColor];;
    self.notificationDate.font = [UIFont boldSystemFontOfSize:14.0f];
    self.notificationDate.layer.cornerRadius = 5.0f;
    self.notificationDate.clipsToBounds = YES;
    
    [description setFrame:CGRectMake(15, 80, self.view.frame.size.width-25,description.contentSize.height) ];
    //NSLog(@"description content : %f", description.contentSize.height);
    
    if(description.contentSize.height <= 350){
        CGRect frame = description.frame;
        frame.size.height = description.contentSize.height;
        description.frame = frame;
    } else {
        [description setFrame:CGRectMake(15, 80, self.view.frame.size.width-25,350) ];
    }
    [self.view addSubview:description];
    //NSLog(@"description done : %f", description.frame.size.height);
    
    self.notificationName.layer.cornerRadius = 5.0f;
    self.notificationName.clipsToBounds = YES;
    self.notificationName.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
    self.notificationName.textColor = [UIColor whiteColor];
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

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end
