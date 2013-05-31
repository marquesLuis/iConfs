//
//  IConfsViewController.m
//  iConfs-iOS
//
//  Created by Luis Marques on 5/29/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "IConfsViewController.h"
#import "Update.h"

@interface IConfsViewController (){

} @end

@implementation IConfsViewController

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
    [self treatKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Handles a recognized single tap gesture.
 */
- (void) handleTapFrom: (UITapGestureRecognizer *) recognizer {
    // hide the keyboard
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
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

- (IBAction)loginButton:(UIButton *)sender {
    //TODO
    NSString *email = @"lfmarques2@gmail.com";
    NSString *password = @"123123123";
    
    if (self.emailField.text.length || self.passwordField.text.length){
        email = self.emailField.text;
        password = self.passwordField.text;
    }
    
    // [self postRquest];
    
    NSError *error;
    //First build up the JSON body for login
    
    NSString *initial = @"%@update/login";
    NSString *initialArgs = @"?registry[email]=";
    NSString *withEmail = [initialArgs stringByAppendingString:email];
    NSString *passStart = [withEmail stringByAppendingString:@"&registry[password]="];
    NSString *completeArgs = [passStart stringByAppendingString:password];
    
    NSString *completeLink = [initial stringByAppendingString:completeArgs];
    
    //I send a POST url request
    NSString *postUrlString = [NSString stringWithFormat:completeLink, @"http://0.0.0.0:3000/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: postUrlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"]; 
  
   /* @try {
        // Try something
    
    // Send a synchronous request
    NSURLResponse * response = nil;
    NSData * returnData = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
    NSString* newStr = [NSString stringWithUTF8String:[returnData bytes]];
    
    NSLog(@"%@", newStr);
    if ([newStr hasPrefix:@"<!DOCTYPE html>"]|| newStr==NULL)
    {
        [self alertMessages:@"Error on Login" withMessage:@"Something went wrong on your login :("];
        return;
    }
    }
    @catch (NSException * e) {
        [self alertMessages:@"Failed Connection" withMessage:@"Check your internet connection"];
        return;
    }*/
    
    Update *update = [[Update alloc] initWithParams:completeArgs];
    [update postRequest:[update buildRequest]];
    
    //change view
    UIViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageIConfs"];
    [self presentViewController:second animated:YES completion:nil];
    
}

-(void) alertMessages:(NSString*)initWithTitle withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:initWithTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
