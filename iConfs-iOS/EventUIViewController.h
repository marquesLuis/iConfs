//
//  EventUIViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 06/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Author.h"
#import "sqlite3.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageViewController.h"

@interface EventUIViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) Event * event;
- (IBAction)addNote:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *roomButton;

@end
