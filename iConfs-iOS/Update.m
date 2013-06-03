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
        NSLog(@"String received:");
        NSLog(@"%@", newStr);
        
        
        NSError *jsonParsingError = nil;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonParsingError];
        
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
            NSString *lastUpdate = @"2000-01-01 00:00:01";
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
    NSLog(@"Handling");
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
        NSLog(@"Handling Notifications");
        NSUInteger last_notif_id = [[notifications objectForKey:@"last_id"] integerValue];
        NSString *last_notif_update = [notifications objectForKey:@"last_update"];
        NSUInteger last_notif_removed_id = [[notifications objectForKey:@"last_removed"] integerValue];
        [self updateNotifStatusID:last_notif_id onDate:last_notif_update removed:last_notif_removed_id];
        
        NSMutableDictionary *news = [notifications objectForKey:@"news"];
        if(news){
            for(NSString *key in news.allKeys){
                NSMutableDictionary *notif = [news objectForKey:key];
                [self addNotificationwithID:[[notif objectForKey:@"id"] integerValue] withTitle: [notif objectForKey:@"title"] withContent: [notif objectForKey:@"content"] withDate:[notif objectForKey:@"updated_at"]];
            }
        }
        NSMutableDictionary *updated = [notifications objectForKey:@"updated"];
        if(updated){
            for(NSString *key in updated.allKeys){
                NSMutableDictionary *notif = [updated objectForKey:key];
                [self removeNotificationWithID: [[notif objectForKey:@"id"] integerValue]];
                [self addNotificationwithID:[[notif objectForKey:@"id"] integerValue] withTitle: [notif objectForKey:@"title"] withContent: [notif objectForKey:@"content"] withDate:[notif objectForKey:@"updated_at"]];
            }
        }
        NSMutableDictionary *deleted = [notifications objectForKey:@"deleted"];
        if(deleted){
            NSUInteger size = [[deleted objectForKey:@"size"] integerValue];
            NSMutableArray *notifs_delete = [NSMutableArray arrayWithCapacity:size];
            
            for(NSString *key in deleted.allKeys){
                if(![key isEqual:@"size"]){
                    NSUInteger old_notif = [[deleted objectForKey:key] integerValue];
                    [notifs_delete addObject:[NSNumber numberWithInt:old_notif]];
                }
            }
            
            [self deleteNotifs:notifs_delete];
        }
    }
    
    
    
    return nil;
}


-(void) removeNotificationWithID: (NSUInteger) server_id{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"DELETE FROM NOTIFICATIONS WHERE ID = %d", server_id];
        const char* query_sql = [querySql UTF8String];
        
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"Notification eliminated");
        }
        
        sqlite3_close(notificationDB);
    }
    
}

-(void) addNotificationwithID:(NSUInteger) server_id withTitle: (NSString *) title withContent: (NSString *) content withDate:(NSString *) date{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications.db"];
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"INSERT INTO NOTIFICATIONS(TITLE, NOTIFICATION, DATE, SERVER_ID) VALUES ('%@', '%@', '%@', '%d')",title, content, date, server_id];
        const char* query_sql = [querySql UTF8String];
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"Notification added");
        }else{
            NSLog(@"Notification Status NOT updated");
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}

-(void) updateNotifStatusID:(NSUInteger) last_notif_id onDate:(NSString *) last_notif_update removed:(NSUInteger) last_notif_removed_id{
    [self insertNotifStatusID:last_notif_id onDate:last_notif_update removed:last_notif_removed_id];
}

-(void) insertNotifStatusID:(NSUInteger) last_notif_id onDate:(NSString *) last_notif_update removed:(NSUInteger) last_notif_removed_id{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications_status.db"];
    sqlite3 *db;
    char *error;
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        NSString *inserStmt = [NSString stringWithFormat:@"INSERT INTO NOTIFICATIONS_STATUS(LAST_DATE , LAST_ID , LAST_REMOVED) VALUES ('%@', '%d', '%d')",last_notif_update,last_notif_id,last_notif_removed_id];
        
        const char *insert_stmt = [inserStmt UTF8String];
        
        if (sqlite3_exec(db, insert_stmt, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"Notification_Status added");
        }else{
            NSLog(@"%s", error);
        }
        sqlite3_close(db);
    }
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

-(void) deleteNotifs:(NSMutableArray *)array
{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:@"notifications.db"];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        for(NSNumber *n in array){
            NSString *querySql = [NSString stringWithFormat:@"DELETE FROM NOTIFICATIONS WHERE ID = %d", [n integerValue]];
            const char* query_sql = [querySql UTF8String];
            
            if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
                NSLog(@"Notification eliminated");
            }
        }
        sqlite3_close(notificationDB);
    }
}

@end
