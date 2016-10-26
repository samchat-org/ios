//
//  SAMCUserInfoDB_2016082201.m
//  SamChat
//
//  Created by HJ on 8/22/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfoDB_2016082201.h"
#import "SAMCDataBaseMacro.h"

@implementation SAMCUserInfoDB_2016082201

- (uint64_t)version
{
    return 2016082201;
}

- (BOOL)migrateDatabase:(FMDatabase *)db error:(out NSError *__autoreleasing *)error
{
    DDLogDebug(@"SAMCUserInfoDB_2016082201");
    NSArray *sqls = @[@"CREATE TABLE IF NOT EXISTS userinfo(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
                      unique_id INTEGER UNIQUE, username TEXT NOT NULL, usertype INTEGER, lastupdate INTEGER, \
                      avatar TEXT, avatar_original TEXT, countrycode TEXT, cellphone TEXT, \
                      email TEXT, address TEXT, sp_company_name TEXT, sp_service_category TEXT, \
                      sp_service_description TEXT, sp_countrycode TEXT, sp_phone TEXT, sp_address TEXT, sp_email TEXT)",
                      @"CREATE INDEX IF NOT EXISTS unique_id_index ON userinfo(unique_id)",
                      @"CREATE index IF NOT EXISTS username_index ON userinfo(username)",
                      SAMC_CREATE_CONTACT_LIST_CUSTOMER_TABLE_SQL_2016082201,
                      SAMC_CREATE_CONTACT_LIST_SERVICER_TABLE_SQL_2016082201];
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
