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

-(id) initDB
{
    self = [super init];
    if(self){
        NSString *email = @"";
        NSString *password = @"";
        
        NSString * table_name = @"MY_SELF";
        NSString * db_file = @"my_self.db";
        
        sqlite3_stmt *statement;
        sqlite3 *notificationDB;
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [path objectAtIndex:0];
        NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
        
        if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
            
            int last_row = 0;
            NSString *querySql = [NSString stringWithFormat:@"SELECT MAX(SERVER_ID) FROM %@",table_name];
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
                querySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE SERVER_ID = %d",table_name, last_row];
                query_sql = [querySql UTF8String];
                
                if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
                    while (sqlite3_step(statement)==SQLITE_ROW) {
                        email = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                        password = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                    }
                    sqlite3_finalize(statement);
                }
            }
            sqlite3_close(notificationDB);
        }
        
        NSString *initialArgs = @"registry[email]=";
        NSString *withEmail = [initialArgs stringByAppendingString:email];
        NSString *passStart = [withEmail stringByAppendingString:@"&registry[password]="];
        NSString *completeArgs = [passStart stringByAppendingString:password];
        
        _auth_params = completeArgs;
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
    NSString *postURL = [@"http://0.0.0.0:3000/update/update?" stringByAppendingString:[self auth_params]];
    
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

/*
 -----------------------------------------------------Request Build Zone-----------------------------------------------------
 */

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

- (NSMutableDictionary *)buildStatus:(NSString *) db_file fromTable: (NSString *) table_name {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
    table_name = [table_name uppercaseString];
    
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        
        int last_row = 0;
        NSString *querySql = [NSString stringWithFormat:@"SELECT MAX(ID) FROM %@",table_name];
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
            querySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ID = %d",table_name, last_row];
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

-(NSMutableDictionary *) buildNotifications{
    return [self buildStatus:@"notifications_status.db" fromTable:@"notifications_status"];
}

-(NSMutableDictionary *) buildEvents{
    return [self buildStatus:@"events_status.db" fromTable:@"events_status"];
}

- (NSMutableDictionary *) buildNetworking{
    return [self buildStatus:@"networkings_status.db" fromTable:@"networkings_status"];
}

- (NSMutableDictionary *) buildPeople{
    return [self buildStatus:@"people_status.db" fromTable:@"PEOPLE_STATUS"];
}

- (NSMutableDictionary *) buildAttending{
    return [self buildStatus:@"attending_status.db" fromTable:@"ATTENDING_STATUS"];
}

- (NSMutableDictionary *) buildAreas{
    return [self buildStatus:@"areas_status.db" fromTable:@"AREAS_STATUS"];
}

- (NSMutableDictionary *) buildLocations{
    return [self buildStatus:@"location_status.db" fromTable:@"LOCATION_STATUS"];
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
    NSMutableDictionary *events = [self buildEvents];
    if (events && [events count])
        [request setObject: events forKey:@"events"];
    NSMutableDictionary *networkings = [self buildNetworking];
    if (networkings && [networkings count])
        [request setObject: networkings forKey:@"networkings"];
    NSMutableDictionary *people = [self buildPeople];
    if (people && [people count])
        [request setObject:people forKey:@"people"];
    NSMutableDictionary *attending = [self buildAttending];
    if (attending && [attending count])
        [request setObject:attending forKey:@"attending"];
    NSMutableDictionary *areas = [self buildAreas];
    if(areas && [areas count])
        [request setObject:areas forKey:@"areas"];
    NSMutableDictionary *locations = [self buildLocations];
    if (locations && [locations count])
        [request setObject:locations forKey:@"locations"];
    return request;
}

/*
 -----------------------------------------------------End Request Build Zone-----------------------------------------------------
 */
/*
 -----------------------------------------------------Handling Zone-----------------------------------------------------
 */

- (void)handleFeedbacks:(NSMutableDictionary *)feedbacks{
    NSLog(@"Handling Feedbacks");
    NSUInteger size = [[feedbacks objectForKey:@"size"] integerValue];
    NSMutableArray *feedbacks_delete = [NSMutableArray arrayWithCapacity:size];
    
    for(NSString *key in feedbacks.allKeys){
        if(![key isEqual:@"size"]){
            NSUInteger feedback = [[feedbacks objectForKey:key] integerValue];
            [feedbacks_delete addObject:[NSNumber numberWithInt:feedback]];
        }
    }
    
    [self deleteAllFrom:@"feedbacks.db" table:@"feedbacks" where:@"ID" equalsIntegerArray:feedbacks_delete];
}

- (void)handleMessages:(NSMutableDictionary *)messages {
    NSLog(@"Handling Messages");
    NSUInteger size = [[messages objectForKey:@"size"] integerValue];
    NSMutableArray *messages_delete = [NSMutableArray arrayWithCapacity:size];
    
    for(NSString *key in messages.allKeys){
        if(![key isEqual:@"size"]){
            NSUInteger message = [[messages objectForKey:key] integerValue];
            [messages_delete addObject:[NSNumber numberWithInt:message]];
        }
    }
    
    [self deleteAllFrom:@"messages.db" table:@"MESSAGES" where:@"ID" equalsIntegerArray:messages_delete];
}

- (void)handleNotifications:(NSMutableDictionary *)notifications {
    NSLog(@"Handling Notifications");
    NSString * notif_db_file = @"notifications.db";
    NSString * notif_table_name = @"notifications";
    
    NSString * notif_status_db_file =@"notifications_status.db";
    NSString * notif_status_table_name = @"notifications_status";
    
    
    [self updateStatus:notifications status_table_name:notif_status_table_name status_db_file:notif_status_db_file];
    
    NSMutableDictionary *news = [notifications objectForKey:@"news"];
    if(news){
        for(NSString *key in news.allKeys){
            NSMutableDictionary *notif = [news objectForKey:key];
            NSString * values = [@"" stringByAppendingFormat: @"'%@', '%@', '%@', '%d'",[notif objectForKey:@"title"],[notif objectForKey:@"content"],[notif objectForKey:@"updated_at"], [[notif objectForKey:@"id"] integerValue]];
            [self insertTo:notif_db_file table:notif_table_name definition:@"TITLE, NOTIFICATION, DATE, SERVER_ID" values:values];
        }
    }
    NSMutableDictionary *updated = [notifications objectForKey:@"updated"];
    if(updated){
        for(NSString *key in updated.allKeys){
            NSMutableDictionary *notif = [updated objectForKey:key];
            NSString * values = [@"" stringByAppendingFormat: @"'%@', '%@', '%@', '%d'",[notif objectForKey:@"title"],[notif objectForKey:@"content"],[notif objectForKey:@"updated_at"], [[notif objectForKey:@"id"] integerValue]];
            [self updateRowFrom:notif_db_file table:notif_table_name whereAttribute:@"SERVER_ID" equalsID:[[notif objectForKey:@"id"] integerValue] definition:@"TITLE, NOTIFICATION, DATE, SERVER_ID" values:values];
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
        
        [self deleteAllFrom:notif_db_file table:notif_table_name where:@"SERVER_ID" equalsIntegerArray:notifs_delete];
    }
}

- (NSString *)readEvent:(NSMutableDictionary *)event {
    NSString * title = [event objectForKey:@"title"];
    NSString * description = [event objectForKey:@"description"];
    int server_id = [[event objectForKey:@"id"]integerValue];
    NSString * kind = [event objectForKey:@"kind"];
    NSString * begin = [event objectForKey:@"begin"];
    NSString * end = [event objectForKey:@"end"];
    NSString * date = [event objectForKey:@"date"];
    NSString * speaker_id_temp = [event objectForKey:@"speaker_id"];
    int speaker_id = 0;
    if(speaker_id_temp)
        speaker_id = [speaker_id_temp integerValue];
    NSString * keynote_temp = [event objectForKey:@"keynote"];
    int keynote = 0;
    if(keynote_temp)
        keynote = 1;
    NSString * local_id_temp = [event objectForKey:@"local_id"];
    int local_id = 0;
    if ([local_id_temp length])
        local_id = [local_id_temp integerValue];
    
    return [@"" stringByAppendingFormat:@"'%@', '%@', '%d','%@','%@','%@','%@','%d','%d','%d'",title, description, server_id, kind, begin, end, date, speaker_id, keynote, local_id];
}

- (NSString *)readAuthor:(NSMutableArray *)author{
    
    NSString * auth_id = [author objectAtIndex:3];
    int auth_id_int = 0;
    if ([auth_id length])
        auth_id_int = [auth_id integerValue];
    
    return [@"" stringByAppendingFormat:@"'%d','%d','%@','%d'", [[author objectAtIndex:0] integerValue], [[author objectAtIndex:1] integerValue], [author objectAtIndex:2],  auth_id_int ];
}

- (void)handleEvents:(NSMutableDictionary *) events{
    NSLog(@"Handling Events");
    NSString * db_file = @"events.db";
    NSString * table_name = @"EVENTS";
    
    NSString * status_db_file =@"events_status.db";
    NSString * status_table_name = @"EVENTS_STATUS";
    
    
    [self updateStatus:events status_table_name:status_table_name status_db_file:status_db_file];
    
    NSString * definition = @"TITLE, DESCRIPTION, SERVER_ID, KIND, BEGIN, END, DATE, SPEAKER_ID, KEYNOTE, LOCAL_ID";
    NSString * auth_defitintion = @"SERVER_ID, EVENT_ID, NAME, PERSON_ID";
    
    NSMutableDictionary *news = [events objectForKey:@"news"];
    if(news){
        for(NSString *key in news.allKeys){
            NSMutableDictionary *event = [news objectForKey:key];
            NSString * values = [self readEvent:event];
            [self insertTo:db_file table:table_name definition:definition values:values];
            NSMutableDictionary * authors = [event objectForKey:@"authors"];
            for(NSString * auth_key in authors.allKeys){
                NSMutableArray * author = [authors objectForKey:auth_key];
                NSString *auth_values_string = [self readAuthor:author];
                [self insertTo:@"author.db" table:@"AUTHOR" definition:auth_defitintion values:auth_values_string];
            }
            
        }
    }
    
    NSMutableDictionary *updated = [events objectForKey:@"updated"];
    if(updated){
        for(NSString *key in updated.allKeys){
            NSMutableDictionary *event = [updated objectForKey:key];
            NSString * values = [self readEvent:event];
            [self updateRowFrom:db_file table:table_name whereAttribute:@"SERVER_ID" equalsID:[[event objectForKey:@"id"] integerValue] definition:definition values:values];
            [self removeFrom:@"author.db" table:@"AUTHOR" attribute:@"EVENT_ID" withID:[[event objectForKey:@"id"] integerValue]];
            NSMutableDictionary * authors = [event objectForKey:@"authors"];
            for(NSString * auth_key in authors.allKeys){
                NSMutableArray * author = [authors objectForKey:auth_key];
                NSString *auth_values = [self readAuthor:author];
                [self insertTo:@"author.db" table:@"AUTHOR" definition:auth_defitintion values:auth_values];
            }
        }
    }
    
    NSMutableDictionary *deleted = [events objectForKey:@"deleted"];
    if(deleted){
        NSUInteger size = [[deleted objectForKey:@"size"] integerValue];
        NSMutableArray *events_delete = [NSMutableArray arrayWithCapacity:size];
        
        for(NSString *key in deleted.allKeys){
            if(![key isEqual:@"size"]){
                NSUInteger old_event = [[deleted objectForKey:key] integerValue];
                [events_delete addObject:[NSNumber numberWithInt:old_event]];
            }
        }
        
        [self deleteAllFrom:db_file table:table_name where:@"SERVER_ID" equalsIntegerArray:events_delete];
    }
}

- (NSString *) readNetworking: (NSMutableDictionary *)network{
    NSString *title = [network objectForKey:@"title"];
    NSString *content = [network objectForKey:@"content"];
    NSString *date = [network objectForKey:@"date"];
    int person_id = [[network objectForKey:@"person_id"] integerValue];
    int server_id = [[network objectForKey:@"server_id"] integerValue];
    return [@"" stringByAppendingFormat:@"'%@', '%@', '%@', '%d', '%d'", title, content, date, person_id, server_id ];
}

- (void)handleNetworkings: (NSMutableDictionary *)networkings{
    NSLog(@"Handling Networkings");
    NSString * db_file = @"networkings.db";
    NSString * table_name = @"NETWORKINGS";
    
    NSString * status_db_file =@"networkings_status.db";
    NSString * status_table_name = @"NETWORKINGS_STATUS";
    
    NSString *net_area_db_file = @"networking_area.db";
    NSString *net_area_table_name = @"NET_AREA";
    
    [self updateStatus:networkings status_table_name:status_table_name status_db_file:status_db_file];
    
    NSString * definition = @"TITLE, NETWORKING, DATE, PERSON_ID, SERVER_ID";
    
    NSMutableDictionary *news = [networkings objectForKey:@"news"];
    if(news){
        for(NSString *key in news.allKeys){
            NSMutableDictionary *network = [news objectForKey:key];
            NSString * values = [self readNetworking:network];
            [self insertTo:db_file table:table_name definition:definition values:values];
            NSMutableArray *areas = [network objectForKey:@"areas"];
            if (areas && [areas count]){
                int server_id = [[network objectForKey:@"server_id"] integerValue];
                NSString * n_values = [@"" stringByAppendingFormat:@"', '%d'",server_id];
                for(NSNumber * n in areas){
                    NSString * the_value = [[@""stringByAppendingFormat:@"'%d", [n integerValue]] stringByAppendingString:n_values];
                    [self insertTo:net_area_db_file table:net_area_table_name definition:@"AREA_ID, NETWORKING_ID" values:the_value];
                }
            }
            
        }
    }
    
    NSMutableDictionary *updated = [networkings objectForKey:@"updated"];
    if(updated){
        for(NSString *key in updated.allKeys){
            NSMutableDictionary *network = [updated objectForKey:key];
            NSString * values = [self readEvent:network];
            [self updateRowFrom:db_file table:table_name whereAttribute:@"SERVER_ID" equalsID:[[network objectForKey:@"server_id"] integerValue] definition:definition values:values];
            NSMutableArray *areas = [network objectForKey:@"areas"];
            if (areas && [areas count]){
                [self removeFrom:net_area_db_file table:net_area_table_name attribute:@"NETWORKING_ID" withID:[[network objectForKey:@"server_id"] integerValue]];
                int server_id = [[network objectForKey:@"server_id"] integerValue];
                NSString * n_values = [@"" stringByAppendingFormat:@"', '%d'",server_id];
                for(NSNumber * n in areas){
                    NSString * the_value = [[@""stringByAppendingFormat:@"'%d", [n integerValue]] stringByAppendingString:n_values];
                    [self insertTo:net_area_db_file table:net_area_table_name definition:@"AREA_ID, NETWORKING_ID" values:the_value];
                }
            }
        }
    }
    
    NSMutableArray *deleted = [networkings objectForKey:@"deleted"];
    if(deleted && [deleted count]){
        for(NSNumber * n in deleted)
            [self removeFrom:net_area_db_file table:net_area_table_name attribute:@"NETWORKING_ID" withID:[n integerValue]];
        [self deleteAllFrom:db_file table:table_name where:@"SERVER_ID" equalsIntegerArray:deleted];
    }
}

- (NSString *) readPerson: (NSMutableDictionary *)person{
    NSString * first = [person objectForKey:@"first"];
    NSString * last = [person objectForKey:@"last"];
    NSString * pre = [person objectForKey:@"pre"];
    NSString * aff = [person objectForKey:@"affiliation"];
    int server_id = [[person objectForKey:@"server_id"] integerValue];
    NSString * email =[person objectForKey:@"email"];
    NSString *tmp = [person objectForKey:@"photo"];
    NSString *photo = @"";
    if (tmp){
        photo = [self downloadFile:tmp personID:server_id];
        NSLog(@"Photo at %@", photo);
    }
    
    NSString * bio = [person objectForKey:@"bio"];
    NSString * date = [person objectForKey:@"last_date"];
    
    return [@"" stringByAppendingFormat:@"'%@','%@','%@','%@','%@','%@','%@','%d','%@'", first, last, pre, aff, email, photo, bio, server_id, date];
}

- (NSString *) readInfo: (NSMutableDictionary *)info{
    int server_id = [[info objectForKey:@"server_id"] integerValue];
    NSString * type = [info objectForKey:@"type"];
    NSString * value = [info objectForKey:@"value"];
    int person_id = [[info objectForKey:@"person_id"] integerValue];
    
    return [@"" stringByAppendingFormat:@"'%d', '%@', '%@', '%d'", server_id, type, value, person_id];
}

- (void) handlePeople:(NSMutableDictionary *)people{
    NSLog(@"Handling People");
    NSString * db_file = @"people.db";
    NSString * table_name = @"PEOPLE";
    
    NSString * status_db_file =@"people_status.db";
    NSString * status_table_name = @"PEOPLE_STATUS";
    
    NSString * info_db_file = @"info.db";
    NSString * info_table_name = @"INFO";
    NSString * info_definition = @"SERVER_ID, TYPE, VALUE, PERSON_ID";
    
    [self updateStatus:people status_table_name:status_table_name status_db_file:status_db_file];
    
    NSString * definition = @"FIRSTNAME, LASTNAME, PREFIX, AFFILIATION, EMAIL, PHOTO, BIOGRAPHY, SERVER_ID, LAST_DATE";
    
    
    NSString * areas_db_file = @"people_area.db";
    NSString * areas_table_file = @"PEOPLE_AREA";
    NSString * areas_definition = @"PERSON_ID, AREA_ID";
    
    NSMutableDictionary *news = [people objectForKey:@"news"];
    if(news){
        for(NSString *key in news.allKeys){
            NSMutableDictionary *event = [news objectForKey:key];
            NSString * values = [self readPerson:event];
            [self insertTo:db_file table:table_name definition:definition values:values];
            NSMutableDictionary * new_infos = [event objectForKey:@"infos"];
            if (new_infos && [new_infos count]){
                for (NSString * info_key in new_infos){
                    NSMutableDictionary * info = [new_infos objectForKey:info_key];
                    NSString * info_values = [self readInfo:info];
                    [self insertTo:info_db_file table:info_table_name definition:info_definition values:info_values];
                }
            }
            NSMutableArray *areas = [event objectForKey:@"areas"];
            if (areas && [areas count]){
                int server_id = [[event objectForKey:@"server_id"] integerValue];
                NSString * person_area_values = [@"" stringByAppendingFormat:@"'%d', '", server_id];
                for(NSNumber * n in areas){
                    [self insertTo:areas_db_file table:areas_table_file definition:areas_definition values:[person_area_values stringByAppendingFormat:@"%d'",[n integerValue]]];
                }
            }
        }
        
    }
    
    NSMutableDictionary *updated = [people objectForKey:@"updated"];
    if(updated){
        for(NSString *key in updated.allKeys){
            NSMutableDictionary *person = [updated objectForKey:key];
            NSString * values = [self readPerson:person];
            [self updateRowFrom:db_file table:table_name whereAttribute:@"SERVER_ID" equalsID:[[person objectForKey:@"id"] integerValue] definition:definition values:values];
            [self removeFrom:info_db_file table:info_table_name attribute:@"PERSON_ID" withID:[[person objectForKey:@"id"] integerValue]];
            NSMutableDictionary * new_infos = [person objectForKey:@"infos"];
            if (new_infos && [new_infos count]){
                for (NSString * info_key in new_infos){
                    NSMutableDictionary * info = [new_infos objectForKey:info_key];
                    NSString * info_values = [self readInfo:info];
                    [self insertTo:info_db_file table:info_table_name definition:info_definition values:info_values];
                }
            }
            int server_id = [[person objectForKey:@"server_id"] integerValue];
            [self removeFrom:areas_db_file table:areas_table_file attribute:@"PERSON_ID" withID:server_id];
            NSMutableArray *areas = [person objectForKey:@"areas"];
            if (areas && [areas count]){
                NSString * person_area_values = [@"" stringByAppendingFormat:@"'%d', '", server_id];
                for(NSNumber * n in areas){
                    [self insertTo:areas_db_file table:areas_table_file definition:areas_definition values:[person_area_values stringByAppendingFormat:@"%d'",[n integerValue]]];
                }
            }
        }
        
    }
}

- (NSString *)readAttending:(NSMutableDictionary *)att{
    int event_id = [[att objectForKey:@"event_id"] integerValue];
    int server_id = [[att objectForKey:@"server_id"] integerValue];
    
    return [@"" stringByAppendingFormat:@"'%d', '%d'", event_id, server_id];
}

- (void) handleAttending:(NSMutableDictionary *)attendings{
    NSLog(@"Handling Attending");
    NSString * db_file = @"attending.db";
    NSString * table_name = @"ATTENDING";
    
    NSString * status_db_file =@"attending_status.db";
    NSString * status_table_name = @"ATTENDING_STATUS";
    
    NSString * definition = @"SESSION_ID, SERVER_ID";
    
    [self updateStatus:attendings status_table_name:status_table_name status_db_file:status_db_file];
    
    NSMutableDictionary *news = [attendings objectForKey:@"news"];
    if(news){
        for(NSString *key in news.allKeys){
            NSMutableDictionary *event = [news objectForKey:key];
            NSString * values = [self readAttending:event];
            [self insertTo:db_file table:table_name definition:definition values:values];
        }
    }
    
    NSMutableArray *deleted = [attendings objectForKey:@"deleted"];
    if(deleted && [deleted count])
        [self deleteAllFrom:db_file table:table_name where:@"SERVER_ID" equalsIntegerArray:deleted];
    
    
    
}

- (NSString *) readAreas:(NSMutableDictionary *)area{
    
    NSString * name = [area objectForKey:@"name"];
    int server_id = [[area objectForKey:@"server_id"] integerValue];
    
    return [@"" stringByAppendingFormat:@"'%@', '%d'", name, server_id];
}

- (void) handleAreas:(NSMutableDictionary *)areas{
    NSLog(@"Handling Areas");
    NSString * db_file = @"areas.db";
    NSString * table_name = @"AREAS";
    
    NSString * status_db_file =@"areas_status.db";
    NSString * status_table_name = @"AREAS_STATUS";
    
    [self updateStatus:areas status_table_name:status_table_name status_db_file:status_db_file];
    
    NSString * definition = @" NAME, SERVER_ID";
    
    NSMutableDictionary *news = [areas objectForKey:@"news"];
    if(news){
        for(NSString *key in news.allKeys){
            NSMutableDictionary *area = [news objectForKey:key];
            NSString * values = [self readAreas:area];
            [self insertTo:db_file table:table_name definition:definition values:values];            
        }
    }
    
    NSMutableDictionary *updated = [areas objectForKey:@"updated"];
    if(updated){
        for(NSString *key in updated.allKeys){
            NSMutableDictionary *area = [updated objectForKey:key];
            NSString * values = [self readAreas:area];
            [self updateRowFrom:db_file table:table_name whereAttribute:@"SERVER_ID" equalsID:[[area objectForKey:@"server_id"] integerValue] definition:definition values:values];
        }
    }
    
    NSMutableArray *deleted = [areas objectForKey:@"deleted"];
    if(deleted && [deleted count]){
        [self deleteAllFrom:db_file table:table_name where:@"SERVER_ID" equalsIntegerArray:deleted];
    }
    
    
}

- (NSMutableDictionary *) handleResponse:(NSMutableDictionary *)request{
    NSLog(@"Handling");
    for(NSString *key in request.allKeys){
        NSLog(@"%@", key);
    }
    
    NSMutableDictionary *feedbacks = [request objectForKey:@"feedbacks"];
    if(feedbacks){
        [self handleFeedbacks: feedbacks];
    }
    
    NSMutableDictionary *messages = [request objectForKey:@"messages"];
    if(messages){
        [self handleMessages:messages];
    }
    
    NSMutableDictionary *notifications = [request objectForKey:@"notifications"];
    if(notifications){
        [self handleNotifications:notifications];
    }
    
    NSMutableDictionary *events = [request objectForKey:@"events"];
    if(events){
        [self handleEvents:events];
    }
    
    NSMutableDictionary *networkings = [request objectForKey:@"networkings"];
    if (networkings){
        [self handleNetworkings:networkings];
    }
    
    NSMutableDictionary *people = [request objectForKey:@"people"];
    if (people){
        [self handlePeople:people];
    }
    
    NSMutableDictionary *attending = [request objectForKey:@"attendings"];
    if (attending){
        [self handleAttending:attending];
    }
    
    NSMutableDictionary *areas = [request objectForKey:@"areas"];
    if (areas){
        [self handleAreas:areas];
    }
    
    return nil;
}

/*
 -----------------------------------------------------End Handling Zone-----------------------------------------------------
 */
/*
 -----------------------------------------------------Images Zone-----------------------------------------------------
 */

- (NSString *) downloadFile:(NSString *)url personID:(int)server_id{
    NSString * pic = [@"person" stringByAppendingFormat:@"_%d",server_id];
    NSRange range = [url rangeOfString:@"." options:NSBackwardsSearch];
    NSString * type = [url substringFromIndex:range.location];
    NSLog(@"%@", type);
    url = [url stringByAppendingFormat:@"&%@",_auth_params];
    //Definitions
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //Get Image From URL
    UIImage * imageFromURL = [self getImageFromURL:url];
    
    //Save Image to Directory
    [self saveImage:imageFromURL withFileName:pic ofType:type inDirectory:documentsDirectoryPath];
    
    return [documentsDirectoryPath stringByAppendingFormat:@"/%@%@", pic,type];
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    NSString *low_extension = [extension lowercaseString];
    if ([low_extension isEqualToString:@".png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([low_extension isEqualToString:@".jpg"] || [low_extension isEqualToString:@".jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

/*
 -----------------------------------------------------End images Zone-----------------------------------------------------
 */


/*
 -----------------------------------------------------DB Zone-----------------------------------------------------
 */

- (void)updateStatus:(NSMutableDictionary *)dict status_table_name:(NSString *)status_table_name status_db_file:(NSString *)status_db_file {
    NSUInteger last_notif_id = [[dict objectForKey:@"last_id"] integerValue];
    NSString *last_notif_update = [dict objectForKey:@"last_update"];
    NSUInteger last_notif_removed_id = [[dict objectForKey:@"last_removed"] integerValue];
    
    [self updateStatus:status_db_file table:status_table_name lastID:last_notif_id onDate:last_notif_update removed:last_notif_removed_id];
}

-(void) updateRowFrom:(NSString *) db_file table: (NSString *) table_name whereAttribute: (NSString *) attribute equalsID:(int) server_id definition: (NSString *) definition values: (NSString *) values{
    [self removeFrom:db_file table:table_name attribute:attribute withID:server_id];
    [self insertTo:db_file table:table_name definition:definition values:values];
}

-(void) removeFrom: (NSString *) db_file table: (NSString *) table_name attribute: (NSString *) attribute withID: (int) server_id{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d",[table_name uppercaseString],[attribute uppercaseString], server_id];
        const char* query_sql = [querySql UTF8String];
        
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ deleted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT deleted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}

-(void) insertTo:(NSString *) db_file table: (NSString *) table_name definition: (NSString *) definition values: (NSString *) values{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",[table_name uppercaseString], [definition uppercaseString], values];
        const char* query_sql = [querySql UTF8String];
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ inserted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT inserted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}

-(void) updateStatus:(NSString *) db_file table: (NSString *) table_name lastID:(NSUInteger) last_notif_id onDate:(NSString *) last_notif_update removed:(NSUInteger) last_notif_removed_id{
    [self clearDBFile:db_file table:table_name];
    [self insertStatus:db_file table:table_name lastID:last_notif_id onDate:last_notif_update removed:last_notif_removed_id];
}

-(void) clearDBFile:(NSString *) db_file table: (NSString *) table_name{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        NSString *querySql = [NSString stringWithFormat:@"DELETE FROM %@",[table_name uppercaseString]];
        const char* query_sql = [querySql UTF8String];
        
        if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
            NSLog(@"%@ deleted", [table_name capitalizedString]);
        }else{
            NSLog(@"%@ NOT deleted", [table_name capitalizedString]);
            NSLog(@"%s", error);
        }
        
        sqlite3_close(notificationDB);
    }
}

-(void) insertStatus:(NSString *) db_file table: (NSString *) table_name lastID: (NSUInteger) last_id onDate:(NSString *) last_update removed:(NSUInteger) last_removed_id{
    NSString * values = [@"" stringByAppendingFormat:@"'%@', '%d', '%d'",last_update,last_id,last_removed_id];
    [self insertTo:db_file table:table_name definition:@"LAST_DATE , LAST_ID , LAST_REMOVED" values:values];
}

-(void) deleteAllFrom:(NSString *) db_file table: (NSString *) table_name where: (NSString *) attribute equalsIntegerArray: (NSMutableArray *) array{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        for(NSNumber *n in array){
            NSString *querySql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d",[table_name uppercaseString], [attribute uppercaseString], [n integerValue]];
            const char* query_sql = [querySql UTF8String];
            
            if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
                NSLog(@"%@ deleted", [table_name capitalizedString]);
            }else{
                NSLog(@"%@ NOT deleted", [table_name capitalizedString]);
                NSLog(@"%s", error);
            }
        }
        sqlite3_close(notificationDB);
    }
}

-(void) deleteAllFrom:(NSString *) db_file table: (NSString *) table_name where: (NSString *) atribute equalsArray: (NSMutableArray *) array{
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        char *error;
        for(NSString *n in array){
            NSString *querySql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %@",[table_name uppercaseString], [atribute uppercaseString], n];
            const char* query_sql = [querySql UTF8String];
            
            if(sqlite3_exec(notificationDB, query_sql, NULL, NULL, &error)==SQLITE_OK){
                NSLog(@"%@ deleted", [table_name capitalizedString]);
            }else{
                NSLog(@"%@ NOT deleted", [table_name capitalizedString]);
                NSLog(@"%s", error);
            }
        }
        sqlite3_close(notificationDB);
    }
}

/*
 -----------------------------------------------------End DB Zone-----------------------------------------------------
 */

@end
