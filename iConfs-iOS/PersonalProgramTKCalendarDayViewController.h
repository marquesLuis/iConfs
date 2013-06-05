//
//  PersonalProgramTKCalendarDayViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 04/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Event.h"
#import "HomeViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>

@interface PersonalProgramTKCalendarDayViewController : TKCalendarDayViewController<TKCalendarDayViewDelegate>
- (IBAction)goHome:(UIBarButtonItem *)sender;

@end
