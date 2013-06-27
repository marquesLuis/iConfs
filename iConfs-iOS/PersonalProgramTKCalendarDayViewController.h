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
#import "EventUIViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>

@interface PersonalProgramTKCalendarDayViewController : TKCalendarDayViewController<TKCalendarDayViewDelegate>
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@end
