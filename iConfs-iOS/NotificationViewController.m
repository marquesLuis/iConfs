//
//  NotificationViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController () {
    CAShapeLayer *line;
    
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
    [self drawLine];
    UIImage    *image = [UIImage imageNamed:@"defaultTableViewBackground.png"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    
    
     UITextView *description =  [[UITextView alloc] initWithFrame:CGRectMake(15, 60, self.view.frame.size.width-25, 350)];
    [description setText:notificationContent];
    description.layer.cornerRadius = 5.0f;
    description.clipsToBounds = YES;
    [description setEditable:NO];
    description.backgroundColor = [UIColor lightTextColor];

    
    
    [description setFrame:CGRectMake(15, 100, self.view.frame.size.width-25,description.contentSize.height) ];
    NSLog(@"description content : %f", description.contentSize.height);
    
    if(description.contentSize.height <= 350){
        CGRect frame = description.frame;
        frame.size.height = description.contentSize.height;
        description.frame = frame;
    } else {
        [description setFrame:CGRectMake(15, 100, self.view.frame.size.width-25,350) ];
    }
    [self.view addSubview:description];
    NSLog(@"description done : %f", description.frame.size.height);
    
    
    
    
    self.notificationName.layer.cornerRadius = 5.0f;
    self.notificationName.clipsToBounds = YES;
    self.notificationName.backgroundColor = [UIColor colorWithRed:(16/255.f) green:(78/255.f) blue:(139/255.f) alpha:1.0f ];
    self.notificationName.textColor = [UIColor whiteColor];
}


-(void)drawLine{
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0,self.view.frame.size.width, 1)];
    
    //shape layer for the line
    line = [CAShapeLayer layer];
    line.path = [linePath CGPath];
    line.fillColor = [[UIColor blackColor] CGColor];
    line.frame = CGRectMake(0, 88, self.view.frame.size.width,1);
    [self.view.layer addSublayer:line];
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

/*- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willAnimateRotationToInterfaceOrientation");
    NSLog(@"%f", self.view.frame.size.width);
   [UIView animateWithDuration:duration animations:^{
       [line setFrame:CGRectMake(0, 88, 700,1)];
       
    }];
}*/

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect b;
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))b = CGRectMake(0, 0, 480, 320);
    else b = CGRectMake(0, 0, 320, 480);
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    [self.view.layer setBounds:b];
    [CATransaction commit];

    [UIView animateWithDuration:duration animations:^{

    [self.view.layer addSublayer:line];
    }];

}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end
