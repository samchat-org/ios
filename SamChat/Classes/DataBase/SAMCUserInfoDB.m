//
//  SAMCUserInfoDB.m
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfoDB.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCUserInfoDB_2016082201.h"

@implementation SAMCUserInfoDB

- (instancetype)init
{
    self = [super initWithName:@"userinfo.db"];
    if (self) {
        [self createMigrationInfo];
    }
    return self;
}

#pragma mark - Create DB
- (void)createMigrationInfo
{
    self.migrationManager = [SAMCMigrationManager managerWithDatabaseQueue:self.queue];
    NSArray *migrations = @[[SAMCUserInfoDB_2016082201 new]];
    [self.migrationManager addMigrations:migrations];
    if (![self.migrationManager hasMigrationsTable]) {
        [self.migrationManager createMigrationsTable:NULL];
    }
}

- (void)updateUser:(NSDictionary *)userInfo
{
    DDLogDebug(@"userInfo: %@", userInfo);
    NSNumber *unique_id = [userInfo valueForKey:SAMC_ID];
    if (unique_id == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM userinfo WHERE unique_id = ?", unique_id];
        
        NSString *username = [userInfo valueForKey:SAMC_USERNAME];
        NSString *countrycode = [NSString stringWithFormat:@"%@",[userInfo valueForKey:SAMC_COUNTRYCODE]]; 
        NSString *cellphone = [userInfo valueForKey:SAMC_CELLPHONE];
        NSString *email = [userInfo valueForKey:SAMC_EMAIL];
        NSString *address = [userInfo valueForKey:SAMC_ADDRESS];
        NSNumber *usertype = [userInfo valueForKey:SAMC_TYPE];
        NSString *avatar = [userInfo valueForKeyPath:SAMC_AVATAR_THUMB];
        NSString *avatar_original = [userInfo valueForKeyPath:SAMC_AVATAR_ORIGIN];
        NSNumber *lastupdate = [userInfo valueForKey:SAMC_LASTUPDATE];
        NSString *sp_company_name = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_COMPANY_NAME];
        NSString *sp_service_category = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_CATEGORY];
        NSString *sp_service_description = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_DESCRIPTION];
        NSString *sp_countrycode = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_COUNTRYCODE];
        NSString *sp_phone = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_PHONE];
        NSString *sp_address = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_ADDRESS];
        
        if ([s next]) {
            username = username ?:[s stringForColumn:@"username"];
            countrycode = countrycode ?:[s stringForColumn:@"countrycode"];
            cellphone = cellphone ?:[s stringForColumn:@"cellphone"];
            email = email ?:[s stringForColumn:@"email"];
            address = address ?:[s stringForColumn:@"address"];
            usertype = usertype ?:@([s intForColumn:@"usertype"]);
            avatar = avatar ?:[s stringForColumn:@"avatar"];
            avatar_original = avatar_original ?:[s stringForColumn:@"avatar_original"];
            lastupdate = lastupdate ?:@([s longForColumn:@"lastupdate"]);
            sp_company_name = sp_company_name ?:[s stringForColumn:@"sp_company_name"];
            sp_service_category = sp_service_category ?:[s stringForColumn:@"sp_service_category"];
            sp_service_description = sp_service_description ?:[s stringForColumn:@"sp_service_description"];
            sp_countrycode = sp_countrycode ?:[s stringForColumn:@"sp_countrycode"];
            sp_phone = sp_phone ?:[s stringForColumn:@"sp_phone"];
            sp_address = sp_address ?:[s stringForColumn:@"sp_address"];
            [db executeUpdate:@"UPDATE userinfo SET username=?, usertype=?, lastupdate=?, avatar=?, avatar_original=?, countrycode=?, \
             cellphone=?, email=?, address=?, sp_company_name=?, sp_service_category=?, sp_service_description=?, \
             sp_countrycode=?, sp_phone=?, sp_address=? WHERE unique_id = ?", username, usertype, lastupdate, avatar, avatar_original,
             countrycode, cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode,
             sp_phone, sp_address, unique_id];
        } else {
            [db executeUpdate:@"INSERT INTO userinfo(unique_id, username, usertype, lastupdate, avatar, avatar_original, countrycode, \
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address) \
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", unique_id, username, usertype, lastupdate, avatar, avatar_original, countrycode,
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address];
        }
        [s close];
    }];

}

- (BOOL)updateFollowList:(NSArray *)users
{
    DDLogDebug(@"updateFollowList: %@", users);
    if (![self resetFollowListTable]) {
        return NO;
    }
    __block BOOL result = YES;
    // TODO: separate transaction?
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSDictionary *user in users) {
            NSNumber *unique_id = user[SAMC_ID];
            NSString *username = user[SAMC_USERNAME];
            NSString *avatar = [user valueForKeyPath:SAMC_AVATAR_THUMB];
            NSNumber *block_tag = user[SAMC_BLOCK_TAG];
            NSNumber *favourite_tag = user[SAMC_FAVOURITE_TAG];
            NSString *sp_service_category = [user valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_CATEGORY];
            result = [db executeUpdate:@"INSERT OR IGNORE INTO follow_list(unique_id,username,avatar,block_tag,favourite_tag,sp_service_category) VALUES (?,?,?,?,?,?)",unique_id,username,avatar,block_tag,favourite_tag,sp_service_category];
            if (result == NO) {
                *rollback = YES;
                break;
            }
        }
    }];
    return result;
}

- (NSArray<SAMCPublicSession *> *)myFollowList
{
    __block NSMutableArray *follows = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM follow_list"];
        while ([s next]) {
            NSInteger unique_id = [s longForColumn:@"unique_id"];
            NSString *username = [s stringForColumn:@"username"];
            NSString *avatar = [s stringForColumn:@"avatar"];
            BOOL block_tag = [s boolForColumn:@"block_tag"];
            BOOL favourite_tag = [s boolForColumn:@"favourite_tag"];
            NSString *sp_service_category = [s stringForColumn:@"sp_service_category"];
            NSString *last_message_content = [s stringForColumn:@"last_message_content"];
            
            SAMCSPBasicInfo *info = [SAMCSPBasicInfo infoOfUser:unique_id
                                                       username:username
                                                         avatar:avatar
                                                       blockTag:block_tag
                                                   favouriteTag:favourite_tag
                                                       category:sp_service_category];
            SAMCPublicSession *session = [SAMCPublicSession session:info lastMessageContent:last_message_content];
            [follows addObject:session];
        }
        [s close];
    }];
    return follows;
}

#pragma mark - Private
- (BOOL)resetFollowListTable
{
    __block BOOL result = YES;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSArray *sqls = @[@"DROP TABLE IF EXISTS follow_list",
                          @"CREATE TABLE IF NOT EXISTS follow_list(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
                          unique_id INTEGER UNIQUE, username TEXT NOT NULL, avatar TEXT, block_tag INTEGER, \
                          favourite_tag INTEGER, sp_service_category TEXT, last_message_content TEXT)"];
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
                result = NO;
            }
        }
    }];
    return result;
}

@end
