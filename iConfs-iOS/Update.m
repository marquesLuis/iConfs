//
//  Update.m
//  iConfs-iOS
//
//  Created by Luis Marques on 5/31/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "Update.h"

@interface Update()
@property (strong, nonatomic) NSString *auth_params;
@end

@implementation Update

-(id) initWithParams:(NSString *)params
{
    self = [super init];
    if(self){
        _auth_params = params;
    }
    return self;
}

-(NSMutableDictionary *) postRequest:(NSMutableDictionary *)request
{
    NSError *error;
    NSMutableDictionary *jsonRequest = [self buildRequest];
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonRequest options:0 error:&error];
    NSString *postURL = [@"http://0.0.0.0:3000/update/update" stringByAppendingString:[self auth_params]];
    
  //  NSLog(postURL);
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: postURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [urlRequest setHTTPBody:data];
    
    @try {
        // Send a synchronous request
        NSURLResponse * response = nil;
        NSData * returnData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                    returningResponse:&response
                                                                error:&error];
        //TODO ERASE THIS
        NSString* newStr = [NSString stringWithUTF8String:[returnData bytes]];
       NSLog(@"%@", newStr);
        
        
        NSError *jsonParsingError = nil;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData
                                                                  options:0 error:&jsonParsingError];
        return json;
    
    }
    @catch (NSException * e) {
        return nil;
    }
    
    return nil;
}

-(NSMutableDictionary *) buildRequest{
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    NSMutableArray *feedbacks = [self buildFeedback];
    if(feedbacks && [feedbacks count])
        [request setObject: feedbacks forKey:@"feedbacks"];
    return request;
}

-(NSMutableArray *) buildFeedback {
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    NSMutableArray *result = [NSMutableArray array];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"feedbacks.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM FEEDBACKS"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *feedbackText = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSMutableDictionary *feedback = [NSMutableDictionary dictionaryWithCapacity:2];
                [feedback setObject:feedbackText forKey:@"content"];
                [feedback setObject:[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] forKey:@"iOS_Key"];
                NSMutableDictionary *feedbacks = [NSMutableDictionary dictionaryWithCapacity:1];
                [feedbacks setObject:feedback forKey:@"feedback"];
                [result addObject:feedbacks];
            }
        }
        sqlite3_close(notificationDB);
    }
    return result;
    
}

-(NSMutableDictionary *) handleResponse:(NSMutableDictionary *)request{
    NSLog(@"Here");
    for(id key in request.allKeys){
        NSLog(key);
    }
    
    NSMutableDictionary *feedbacks = [request objectForKey:@"feedbacks"];
    if(feedbacks){
        NSUInteger size = [[feedbacks objectForKey:@"size"] integerValue];
        NSLog(@"%d", size);
        NSMutableArray *feedbacks_delete = [NSMutableArray arrayWithCapacity:size];
        
        for(NSString *key in feedbacks.allKeys){
            if(![key isEqual:@"size"]){
                NSUInteger feedback = [[feedbacks objectForKey:key] integerValue];
                [feedbacks_delete addObject:[NSNumber numberWithInt:feedback]];
            }
        }
        
        [self deleteFeedback:feedbacks_delete];
    }
    
    return nil;
}

-(void) deleteFeedback:(NSMutableArray *)array
{
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"feedbacks.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        for(NSNumber *n in array){
        NSString *querySql = [NSString stringWithFormat:@"DELETE FROM FEEDBACKS WHERE ID = %d", [n integerValue]];
        const char* query_sql = [querySql UTF8String];
        
            if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
                NSLog(@"Feedback eliminated");
            }
        }
        sqlite3_close(notificationDB);
    }
}


@end
