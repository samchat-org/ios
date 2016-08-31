//
//  SAMCPublicDB.m
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicDB.h"
#import "GCDMulticastDelegate.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCPublicDB_2016082201.h"

@interface SAMCPublicDB ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCPublicManagerDelegate> *publicDelegate;

@end

@implementation SAMCPublicDB

- (instancetype)init
{
    self = [super initWithName:@"public.db"];
    if (self) {
        [self createMigrationInfo];
    }
    return self;
}

- (void)dealloc
{
}

- (void)addPublicDelegate:(id<SAMCPublicManagerDelegate>)delegate
{
    [self.publicDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removePublicDelegate:(id<SAMCPublicManagerDelegate>)delegate
{
    [self.publicDelegate removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCPublicManagerDelegate> *)publicDelegate
{
    if (_publicDelegate == nil) {
        _publicDelegate = (GCDMulticastDelegate <SAMCPublicManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _publicDelegate;
}

#pragma mark - Create DB
- (void)createMigrationInfo
{
    self.migrationManager = [SAMCMigrationManager managerWithDatabaseQueue:self.queue];
    NSArray *migrations = @[[SAMCPublicDB_2016082201 new]];
    [self.migrationManager addMigrations:migrations];
    if (![self.migrationManager hasMigrationsTable]) {
        [self.migrationManager createMigrationsTable:NULL];
    }
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
    if (![self isTableExists:@"follow_list"]) {
        // table not found, may sync not finished
        return follows;
    }
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

- (void)insertToFollowList:(SAMCUserInfo *)userInfo
{
    [self.queue inDatabase:^(FMDatabase *db) {
        //        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM follow_list WHERE unique_id = ?",@(userInfo.uniqueId)];
        //        [s next];
        //        int count = [s intForColumnIndex:0];
        //        [s close];
        //        if (count > 0) {
        //            return; // already exist
        //        }
        NSNumber *unique_id = @(userInfo.uniqueId);
        NSString *username = userInfo.username;
        NSString *avatar = userInfo.avatar;
        NSNumber *block_tag = @(NO);
        NSNumber *favourite_tag = @(NO);
        NSString *sp_service_category = userInfo.spInfo.serviceCategory;
        [db executeUpdate:@"INSERT OR IGNORE INTO follow_list(unique_id,username,avatar,block_tag,favourite_tag,sp_service_category) VALUES (?,?,?,?,?,?)",unique_id,username,avatar,block_tag,favourite_tag,sp_service_category];
    }];
}

#pragma mark - Private
- (BOOL)resetFollowListTable
{
    __block BOOL result = YES;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSArray *sqls = @[@"DROP TABLE IF EXISTS follow_list",
                          SAMC_CREATE_FOLLOW_LIST_TABLE_SQL_2016082201];
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
