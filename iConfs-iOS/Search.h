//
//  Search.h
//  iConfs-iOS
//
//  Created by Luis Marques on 6/19/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "sqlite3.h"

@interface Search : NSObject

//SESSION, PARTICIPANT, NETWORKING, NOTES

- (NSMutableArray *) getEventsFromRegex:(NSString *) regex;
- (NSMutableArray *) getPeopleFromRegex:(NSString *) regex;
- (NSMutableArray *) getNetworkingFromRegex:(NSString *) regex;
- (NSMutableArray *) getNotesFromRegex:(NSString *) regex;

@end