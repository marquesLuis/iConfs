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
#import "KNMultiItemSelector.h"



@interface NoteViewController : UIViewController  <UITextViewDelegate, KNMultiItemSelectorDelegate>

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UIButton *aboutPersonButton;

- (IBAction)addNote:(UIBarButtonItem *)sender;

- (IBAction)addPerson:(UIButton *)sender;

@end
