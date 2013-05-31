//
//  CommunicationViewController.h
//  iConfs-iOS
//
//  Created by Luis Marques on 5/29/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Feedback.h"
#import "Message.h"

@interface CommunicationViewController : UIViewController
/*- (IBAction)feedbackOrMessageButton:(UISegmentedControl *)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextView *feedback;
- (IBAction)sendButton:(id)sender;
- (IBAction)clearButton:(UIButton *)sender;
*/
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextView *feedback;
- (IBAction)sendButton:(id)sender;
- (IBAction)clearButton:(UIButton *)sender;
- (IBAction)feedbackOrMessageButton:(UISegmentedControl *)sender;
@end
