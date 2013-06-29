//
//  Update.h
//  iConfs-iOS
//
//  Created by Luis Marques on 5/31/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "sqlite3.h"

@interface Update : NSObject

-(id) initDB;
-(void) update;
-(BOOL) updateWithoutMessage;
-(NSMutableDictionary *) postRequest:(NSMutableDictionary *)request withAlert:(BOOL)alert;
-(NSMutableDictionary *) buildRequest;
-(BOOL) handleResponse:(NSMutableDictionary *)request;

@end
