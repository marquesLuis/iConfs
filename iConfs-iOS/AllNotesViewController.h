//
//  AllNotesViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 15/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Note.h"
#import "NoteViewController.h"
@interface AllNotesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *notesTableView;
//@property (strong, nonatomic) IBOutlet UIBarButtonItem *newNote;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addNewNote;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addNote;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@end
