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
#import "Note.h"
#import "Event.h"


//, KNMultiItemSelectorDelegate
@interface NoteViewController : UIViewController  <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UIButton *aboutPersonButton;
@property (strong, nonatomic) IBOutlet UIButton *aboutSessionButton;
@property BOOL hidePersonButton;
@property BOOL hideSessionButton;
@property (strong, nonatomic) NSString * eventID;
@property (strong, nonatomic) NSString * personID;
@property (strong, nonatomic) NSString * content;
@property (strong, nonatomic) NSString * noteID;

@property BOOL isLocal;


- (IBAction)addNote:(UIBarButtonItem *)sender;
- (IBAction)addPerson:(UIButton *)sender;
- (IBAction)addSession:(UIButton *)sender;

@end
