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

-(id) initWithParams:(NSString *)params;
-(BOOL) postRequest:(NSMutableDictionary *)request;
-(NSMutableDictionary *) buildRequest;

@end
