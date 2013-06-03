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

-(void) update{
    [self handleResponse:[self postRequest:[self buildRequest]]];
}

-(NSMutableDictionary *) postRequest:(NSMutableDictionary *)jsonRequest
{
    NSError *error;
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
    NSMutableArray *messages = [self buildMessages];
    if(messages && [messages count])
        [request setObject: messages forKey:@"messages"];
    NSMutableDictionary *notifications = [self buildNotifications];
    if(notifications && [notifications count])
        [request setObject: notifications forKey:@"notifications"];
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
            sqlite3_finalize(statement);
        }
        sqlite3_close(notificationDB);
    }
    return result;
    
}

-(NSMutableArray *) buildMessages {
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    NSMutableArray *result = [NSMutableArray array];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"messages.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM MESSAGES"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *messageID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                NSString *messageText = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *messageMail = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithCapacity:3];
                [message setObject:messageText forKey:@"content"];
                [message setObject:messageMail forKey:@"email"];
                [message setObject:messageID forKey:@"iOS_Key"];
                NSMutableDictionary *messages = [NSMutableDictionary dictionaryWithCapacity:1];
                [messages setObject:message forKey:@"message"];
                [result addObject:messages];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(notificationDB);
    }
    return result;
    
}

-(NSMutableDictionary *) buildNotifications{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
    
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications_status.db"];
    
   if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
       
       int last_row = 0;
       NSString *querySql = [NSString stringWithFormat:@"SELECT MAX(ID) FROM NOTIFICATIONS_STATUS"];
       const char* query_sql = [querySql UTF8String];
       
       @try{
           
       
       if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *messageID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                last_row = [messageID integerValue];
                break;
            }
            sqlite3_finalize(statement);
        }
       }@catch (NSException *e) {
        
       }
       if(last_row){
           querySql = [NSString stringWithFormat:@"SELECT * FROM NOTIFICATIONS_STATUS WHERE ID = %d",last_row];
           query_sql = [querySql UTF8String];
           
           if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
               while (sqlite3_step(statement)==SQLITE_ROW) {
                   NSString *lastUpdate = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                   NSString *lastID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                   NSString *lastRemovedID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                   [result setObject:lastUpdate forKey:@"last_update"];
                   [result setObject:lastID forKey:@"last_id"];
                   [result setObject:lastRemovedID forKey:@"last_removed_id"];
               }
               sqlite3_finalize(statement);
           }
       }else{
           NSString *lastUpdate = @"2000-01-01 00:00:00.0000 UTC";
           NSString *lastID = @"0";
           [result setObject:lastUpdate forKey:@"last_update"];
           [result setObject:lastID forKey:@"last_id"];
           [result setObject:lastID forKey:@"last_removed_id"];
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
        NSMutableArray *feedbacks_delete = [NSMutableArray arrayWithCapacity:size];
        
        for(NSString *key in feedbacks.allKeys){
            if(![key isEqual:@"size"]){
                NSUInteger feedback = [[feedbacks objectForKey:key] integerValue];
                [feedbacks_delete addObject:[NSNumber numberWithInt:feedback]];
            }
        }
        
        [self deleteFeedback:feedbacks_delete];
    }
    
    NSMutableDictionary *messages = [request objectForKey:@"messages"];
    if(messages){
        NSUInteger size = [[messages objectForKey:@"size"] integerValue];
        NSMutableArray *messages_delete = [NSMutableArray arrayWithCapacity:size];
        
        for(NSString *key in messages.allKeys){
            if(![key isEqual:@"size"]){
                NSUInteger message = [[messages objectForKey:key] integerValue];
                [messages_delete addObject:[NSNumber numberWithInt:message]];
            }
        }
        
        [self deleteMessages:messages_delete];
    }
    
    NSMutableDictionary *notifications = [request objectForKey:@"notifications"];
    if(notifications){
        NSMutableDictionary *news = [notifications objectForKey:@"news"];
        if(news){
            
        }
        NSMutableDictionary *updated = [notifications objectForKey:@"updated"];
        if(updated){
            
        }
        NSMutableDictionary *deleted = [notifications objectForKey:@"deleted"];
        if(deleted){
            
        }
    }
    
    
    
    return nil;
}

-(void) deleteFeedback:(NSMutableArray *)array
{
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

-(void) deleteMessages:(NSMutableArray *)array
{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"messages.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        for(NSNumber *n in array){
            NSString *querySql = [NSString stringWithFormat:@"DELETE FROM MESSAGES WHERE ID = %d", [n integerValue]];
            const char* query_sql = [querySql UTF8String];
            
            if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
                NSLog(@"Message eliminated");
            }
        }
        sqlite3_close(notificationDB);
    }
}


@end
