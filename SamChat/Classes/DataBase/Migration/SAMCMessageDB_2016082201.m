//
//  SAMCMessageDB_2016082201.m
//  SamChat
//
//  Created by HJ on 8/22/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMessageDB_2016082201.h"

@implementation SAMCMessageDB_2016082201

- (uint64_t)version
{
    return 2016082201;
}

- (BOOL)migrateDatabase:(FMDatabase *)db error:(out NSError *__autoreleasing *)error
{
    DDLogDebug(@"SAMCMessageDB_2016082201");
    NSArray *sqls = @[@"CREATE TABLE IF NOT EXISTS session_table(name TEXT NOT NULL UNIQUE, \
                      session_id TEXT NOT NULL, session_mode INTEGER DEFAULT 0, \
                      session_type INTEGER DEFAULT 0, last_msg_id TEXT, last_msg_state INTEGER, \
                      last_msg_content TEXT, last_msg_time INTEGER, unread_count INTEGER DEFAULT 0, \
                      tag INTEGER DEFAULT 0)",
                      @"CREATE INDEX IF NOT EXISTS session_id_index ON session_table(session_id)"];
    for (NSString *sql in sqls) {
        if (![db executeUpdate:sql]) {
            DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    return YES;
}

@end
