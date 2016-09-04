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

- (void)insertToFollowList:(SAMCSPBasicInfo *)userInfo
{
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM follow_list WHERE unique_id = ?",@(userInfo.uniqueId)];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count > 0) {
            return; // already exist
        }
        NSNumber *unique_id = @(userInfo.uniqueId);
        NSString *username = userInfo.username;
        NSString *avatar = userInfo.avatar;
        NSNumber *block_tag = @(userInfo.blockTag);
        NSNumber *favourite_tag = @(userInfo.favouriteTag);
        NSString *sp_service_category = userInfo.spServiceCategory;
//        [db executeUpdate:@"INSERT OR IGNORE INTO follow_list(unique_id,username,avatar,block_tag,favourite_tag,sp_service_category) VALUES (?,?,?,?,?,?)",unique_id,username,avatar,block_tag,favourite_tag,sp_service_category];
        [db executeUpdate:@"INSERT INTO follow_list(unique_id,username,avatar,block_tag,favourite_tag,sp_service_category) VALUES (?,?,?,?,?,?)",unique_id,username,avatar,block_tag,favourite_tag,sp_service_category];
        SAMCPublicSession *session = [SAMCPublicSession session:userInfo lastMessageContent:@""];
        [self.publicDelegate didAddPublicSession:session totalUnreadCount:0]; // TODO: get total unread count
    }];
}

- (void)deleteFromFollowList:(SAMCSPBasicInfo *)userInfo
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM follow_list WHERE unique_id = ?", @(userInfo.uniqueId)];
        // TODO: update total unread count & delegate session updating
    }];
}

- (NSArray<SAMCPublicMessage *> *)messagesInSession:(SAMCPublicSession *)session
                                            message:(SAMCPublicMessage *)message
                                              limit:(NSInteger)limit
{
    NSString *tableName = [session tableName];
    if (![self isTableExists:tableName]) {
        return nil;
    }
    __block NSMutableArray *messages = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s;
        if (message == nil) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY serial DESC LIMIT ?", tableName];
            s = [db executeQuery:sql, @(limit)];
        } else {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE serial<(SELECT serial FROM '%@' WHERE msg_id = ?) ORDER BY serial DESC LIMIT ?", tableName, tableName];
            s = [db executeQuery:sql,message.messageId,@(limit)];
        }
        while ([s next]) {
            SAMCPublicMessage *message = [[SAMCPublicMessage alloc] init];
            message.publicSession = session;
            message.messageType = [s intForColumn:@"msg_type"];
            message.from = [s stringForColumn:@"msg_from"];
            message.messageId = [s stringForColumn:@"msg_id"];
            message.serverId = [s intForColumn:@"server_id"];
            message.text = [s stringForColumn:@"msg_text"];
            message.deliveryState = [s intForColumn:@"msg_status"];
            message.timestamp = [s longForColumn:@"msg_time"];
            [messages insertObject:message atIndex:0];
        }
        [s close];
    }];
    return messages;
}

- (void)insertMessage:(SAMCPublicMessage *)message
{
    if (message == nil) {
        return;
    }
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // TODO: add unreadCount &tableName to follow_list
        NSString *tableName = message.publicSession.tableName;
        // insert message
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (serial INTEGER PRIMARY KEY AUTOINCREMENT, msg_type INTEGER, msg_from TEXT, msg_id TEXT, server_id INTEGER, msg_text TEXT, msg_content TEXT, msg_status INTEGER, msg_time INTEGER)", tableName]];
        // TODO: need create index ?
        NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(msg_type, msg_from, msg_id, server_id, msg_text, msg_status, msg_time) VALUES(?,?,?,?,?,?,?)", tableName];
        [db executeUpdate:sql, @(message.messageType), message.from, message.messageId ,@(message.serverId), message.text, @(message.deliveryState),@(message.timestamp)];
        
    }];
}

- (void)updateMessageStateServerIdAndTime:(SAMCPublicMessage *)message
{
    if (message == nil) {
        return;
    }
    NSNumber *state = @(message.deliveryState);
    NSNumber *serverId = @(message.serverId);
    NSNumber *timestamp = @(message.timestamp);
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *tableName = message.publicSession.tableName;
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET msg_status = ?, server_id = ?, msg_time = ? WHERE msg_id = ?", tableName];
        [db executeUpdate:sql, state, serverId, timestamp, message.messageId];
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
