//
//  Event.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 04/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 //Events
 [self createOrOpenDB:"CREATE TABLE IF NOT EXISTS EVENTS( ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, SERVER_ID INTEGER, KIND TEXT, BEGIN TEXT, END TEXT, DURATION INTEGER, DATE TEXT, LOCATION_ID INTEGER, SPEAKER_ID INTEGER, KEYNOTE INTEGER,  LOCAL_ID INTEGER)" WithName:@"events.db"];
 
 */

@interface Event : NSObject
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * description;
@property (strong, nonatomic) NSString * kind;
@property (strong, nonatomic) NSString * begin;
@property (strong, nonatomic) NSString * end;
@property (strong, nonatomic) NSString * date;
@property (strong, nonatomic) NSString * location;
@property (strong, nonatomic) NSString * keynote;
@property (strong, nonatomic) NSString * speakerID;
@property (strong, nonatomic) NSString * localID;
@property (strong, nonatomic) NSString * eventID;
@end
