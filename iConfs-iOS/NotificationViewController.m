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
@synthesize notificationTitle, notificationText, notificationContent, notificationDateContent;

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
    [self.notificationText setEditable:NO];
    self.notificationText.backgroundColor = [UIColor clearColor];
    self.notificationText.text = notificationContent;
    self.notificationDate.text = notificationDateContent;
    [self navigationButtons];
    [self drawLine];
    UIImage    *image = [UIImage imageNamed:@"defaultTableViewBackground.png"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
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

@end
