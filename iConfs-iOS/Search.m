//
//  Search.m
//  iConfs-iOS
// 
//  Created by Luis Marques on 6/19/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "Search.h"

@implementation Search

- (NSString *) prepareRegex: (NSString *)regex{
    NSString *trimmedString = [regex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@"%"];
    trimmedString = [@"%" stringByAppendingString:[trimmedString stringByAppendingString:@"%" ]];
    return trimmedString;
}

- (NSMutableArray *) getEventsFromRegex:(NSString *) regex{
    regex = [self prepareRegex:regex];
    NSString * whereString = [NSString stringWithFormat:@"TITLE LIKE '%@' OR DESCRIPTION LIKE '%@' OR KIND LIKE '%@'",regex, regex, regex];
    return [self doSearchFromFile:@"events.db" fromTable:@"EVENTS" where:whereString numArgs:11];
}
- (NSMutableArray *) getPeopleFromRegex:(NSString *) regex{
    regex = [self prepareRegex:regex];
    NSString * whereString = [NSString stringWithFormat:@"FIRSTNAME || LASTNAME LIKE '%@' OR AFFILIATION LIKE '%@' OR EMAIL LIKE '%@' OR BIOGRAPHY LIKE '%@'",regex, regex,regex,regex];
    return [self doSearchFromFile:@"people.db" fromTable:@"PEOPLE" where:whereString numArgs:10];
}
- (NSMutableArray *) getNetworkingFromRegex:(NSString *) regex{
    regex = [self prepareRegex:regex];
    NSString * whereString = [NSString stringWithFormat:@"TITLE LIKE '%@' OR NETWORKING LIKE '%@'",regex, regex];
    return [self doSearchFromFile:@"networkings.db" fromTable:@"NETWORKINGS" where:whereString numArgs:6];
}
- (NSMutableArray *) getNotesFromRegex:(NSString *) regex{
    regex = [self prepareRegex:regex];
    NSString * whereString = [NSString stringWithFormat:@"CONTENT LIKE '%@'",regex];
   return [self doSearchFromFile:@"notes.db" fromTable:@"NOTES" where:whereString numArgs:6];
}

- (NSMutableArray *) doSearchFromFile:(NSString *)db_file fromTable:(NSString *)table_name where:(NSString *)where numArgs:(int) numArgs{
    sqlite3_stmt *statement;
    sqlite3 *notificationDB;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *dbPathString = [docPath stringByAppendingPathComponent:db_file];
    
    NSMutableArray * result = [NSMutableArray array];
    
    if (sqlite3_open([dbPathString UTF8String], &notificationDB)==SQLITE_OK) {
        
       @try {
        
           NSString * querySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",table_name, where];
           // NSLog(@"Pesquisa SQL: %@", querySql);
           const char* query_sql = [querySql UTF8String];
        if (sqlite3_prepare(notificationDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    NSMutableArray * search = [NSMutableArray arrayWithCapacity:numArgs];
                    for(int i = 0; i<numArgs; i++){
                        [search addObject:[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, i)]];
                    }
                    [result addObject:search];
                }
                sqlite3_finalize(statement);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"PROBLEMA %@",[exception description] );
        }
        @finally {
            sqlite3_close(notificationDB);
        }
            
        
    }
    return result;

}

@end
