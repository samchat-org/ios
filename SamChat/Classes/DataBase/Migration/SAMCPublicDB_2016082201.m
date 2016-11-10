//
//  SAMCPublicDB_2016082201.m
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicDB_2016082201.h"

@implementation SAMCPublicDB_2016082201

- (uint64_t)version
{
    return 2016082201;
}

- (BOOL)migrateDatabase:(FMDatabase *)db error:(out NSError *__autoreleasing *)error
{
    DDLogDebug(@"SAMCPublicDB_2016082201");
    NSArray *sqls = @[SAMC_CREATE_FOLLOW_LIST_TABLE_SQL_2016082201,
                      @"CREATE TABLE IF NOT EXISTS session_list(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
                      unique_id INTEGER UNIQUE, last_msg_id TEXT, last_msg_state INTEGER, \
                      last_msg_content TEXT, last_msg_time INTEGER, unread_count INTEGER DEFAULT 0, \
                      tag INTEGER DEFAULT 0)",
                      @"CREATE INDEX IF NOT EXISTS session_id_index ON session_list(unique_id)"];
    for (NSString *sql in sqls) {
        if (![db executeUpdate:sql]) {
            DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
            if (error) {
                *error = [db lastError];
                return NO;
            }
        }
    }
    return YES;
}

@end
