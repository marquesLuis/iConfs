//
//  NoteViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 12/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "sqlite3.h"


@interface NoteViewController : UIViewController  <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
- (IBAction)addNote:(UIBarButtonItem *)sender;


@end
