//
//  CommunicationViewController.m
//  iConfs-iOS
//
//  Created by Luis Marques on 5/29/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "CommunicationViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "HomeViewController.h"

@interface CommunicationViewController (){
    BOOL isfeedback;
}

@end

@implementation CommunicationViewController 
@synthesize feedback = _feedback;

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
    UIImage    *image = [UIImage imageNamed:@"defaultTableViewBackground.png"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    isfeedback = YES;
    self.emailField.hidden = isfeedback;
    [self changeFeedMsgBox];
    [self treatKeyboard];
    [self navigationButtons];
    
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}


-(void)navigationButtons{
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
}
- (IBAction)goBack:(UIBarButtonItem *)sender {
    [[self navigationController] popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

/*
 * single tap to resign (hide) the keyboard
 */
- (void) treatKeyboard {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapRecognizer];
}

-(void)changeFeedMsgBox{
    //[self.feedback setTextColor:[UIColor lightGrayColor]];
    
    //self.feedback.placeholderText = @"Write here anything you wish to share with the organization. Complaints, suggestions or your best wishes. Be aware this is anonymous so if you wish leave your name.";
    
    //The rounded corner part
    self.feedback.layer.cornerRadius = 10;
    self.feedback.clipsToBounds = YES;
    
    //border
    self.feedback.layer.borderWidth = 2.0f;
    self.feedback.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButton:(id)sender {    
    if([self.feedback.text isEqual: @""]){
        [self alertMessages:@"Text empty." withMessage:@"Please write something."];
        return;
    }
    
    if(isfeedback){
        [self insertOnDB:[NSString stringWithFormat:@"INSERT INTO FEEDBACKS (FEEDBACK) values ('%s')",[self.feedback.text UTF8String]] On:(BOOL)isfeedback WithName:@"feedbacks.db"];

    } else {
        Message *msg = [[Message alloc]init];
        // if emails isn't valid return
        if(![msg verifyEmail:self.emailField.text]){
            [self alertMessages:@"Email incorrect." withMessage:@"Please correct your email."];
            return;
        }
        
        [self insertOnDB:[NSString stringWithFormat:@"INSERT INTO MESSAGES (MESSAGE, EMAIL) values ('%s', '%s')",[self.feedback.text UTF8String], [self.emailField.text UTF8String]] On:(BOOL)isfeedback WithName:@"messages.db"];
    }
    
    //update
    Update *update = [[Update alloc] initDB];
    [update updateWithoutMessage];
    
    //change view
    [[self navigationController] popViewControllerAnimated:YES];
    
    
}

-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) insertOnDB:(NSString*)insert On:(BOOL)feedback WithName:(NSString*)name{
    sqlite3 *db;
    char *error;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:name];
    
    
    if(sqlite3_open([dbPath UTF8String], &db)== SQLITE_OK){
        NSLog(@"%@", insert);
        if (sqlite3_exec(db, [insert UTF8String], NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"Feedback added");
            
            if(feedback){
                Feedback *feed = [[Feedback alloc]init];
                [feed setFeedbackText:self.feedback.text];
            } else {
                Message *msg = [[Message alloc]init];

                [msg setMessageText:self.feedback.text];
                [msg setEmail:self.emailField.text];
            }
            
        }else{
            NSLog(@"Feedback NOT ADDED");
            NSLog(@"%s", error);
        }
        sqlite3_close(db);
    }
}

- (IBAction)clearButton:(UIButton *)sender {
    self.feedback.text = @"";
}



/**
 * Handles a recognized single tap gesture.
 */
- (void) handleTapFrom: (UITapGestureRecognizer *) recognizer {
    // hide the keyboard
    [self.feedback resignFirstResponder];
    [self.emailField resignFirstResponder];
}





- (IBAction)feedbackOrMessageButton:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex == 0)
        isfeedback = YES;
    else
        isfeedback = NO;
    self.emailField.hidden = isfeedback;
}

@end
