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
    // | serial | unique_id | username | avatar | block_tag | favourite_tag | sp_service_category
    // | last_message_content | last_message_time | unread_count
    NSArray *sqls = @[SAMC_CREATE_FOLLOW_LIST_TABLE_SQL_2016082201];
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
