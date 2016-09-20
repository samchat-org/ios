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
#import "NTESCustomAttachmentDecoder.h"
#import "SAMCImageAttachment.h"
#import "NIMMessage+SAMC.h"

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
            [db commit];
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
            NSString *last_message_id = [s stringForColumn:@"last_message_id"];
            NSString *last_message_content = [s stringForColumn:@"last_message_content"];
            NSTimeInterval last_message_time = [s doubleForColumn:@"last_message_time"];
            NSInteger unread_count = [s intForColumn:@"unread_count"];
            
            SAMCSPBasicInfo *info = [SAMCSPBasicInfo infoOfUser:[NSString stringWithFormat:@"%ld",unique_id]
                                                       username:username
                                                         avatar:avatar
                                                       blockTag:block_tag
                                                   favouriteTag:favourite_tag
                                                       category:sp_service_category];
            SAMCPublicSession *session = [SAMCPublicSession session:info
                                                      lastMessageId:last_message_id
                                                 lastMessageContent:last_message_content
                                                    lastMessageTime:last_message_time
                                                        unreadCount:unread_count];
            [follows addObject:session];
        }
        [s close];
    }];
    return follows;
}

- (void)insertToFollowList:(SAMCSPBasicInfo *)userInfo
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSNumber *unique_id = @([userInfo.userId integerValue]);
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM follow_list WHERE unique_id = ?",unique_id];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count > 0) {
            return; // already exist
        }
        NSString *username = userInfo.username;
        NSString *avatar = userInfo.avatar;
        NSNumber *block_tag = @(userInfo.blockTag);
        NSNumber *favourite_tag = @(userInfo.favouriteTag);
        NSString *sp_service_category = userInfo.spServiceCategory;
//        [db executeUpdate:@"INSERT OR IGNORE INTO follow_list(unique_id,username,avatar,block_tag,favourite_tag,sp_service_category) VALUES (?,?,?,?,?,?)",unique_id,username,avatar,block_tag,favourite_tag,sp_service_category];
        [db executeUpdate:@"INSERT INTO follow_list(unique_id,username,avatar,block_tag,favourite_tag,sp_service_category) VALUES (?,?,?,?,?,?)",unique_id,username,avatar,block_tag,favourite_tag,sp_service_category];
        SAMCPublicSession *session = [SAMCPublicSession session:userInfo
                                                  lastMessageId:@""
                                             lastMessageContent:@""
                                                lastMessageTime:0
                                                    unreadCount:0];
        [self.publicDelegate didAddPublicSession:session];
    }];
}

- (void)deleteFromFollowList:(SAMCSPBasicInfo *)userInfo
{
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSNumber *unique_id = @([userInfo.userId integerValue]);
        [db executeUpdate:@"DELETE FROM follow_list WHERE unique_id = ?", unique_id];
        [wself delegateUnreadCountChanged:db];
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
            NSString *msgContent = [s stringForColumn:@"msg_content"];
            if (message.messageType == NIMMessageTypeCustom) {
                NIMCustomObject *customObject = [[NIMCustomObject alloc] init];
                customObject.attachment = [[[NTESCustomAttachmentDecoder alloc] init] decodeAttachment:msgContent];
                message.messageObject = customObject;
            }
            message.isOutgoingMsg = session.isOutgoing;
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
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = message.publicSession.tableName;
        // 1. insert message
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (serial INTEGER PRIMARY KEY AUTOINCREMENT, msg_type INTEGER, msg_from TEXT, msg_id TEXT, server_id INTEGER, msg_text TEXT, msg_content TEXT, msg_status INTEGER, msg_time INTEGER)", tableName]];
        [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS '%@_msgid_index' ON '%@'(msg_id)",tableName,tableName]];
        NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(msg_type, msg_from, msg_id, server_id, msg_text, msg_content, msg_status, msg_time) VALUES(?,?,?,?,?,?,?,?)", tableName];
        NSString *msgContent;
        if (message.messageType == NIMMessageTypeCustom) {
            NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
            msgContent = [customObject.attachment encodeAttachment];
        }
        msgContent = msgContent ?:@"";
        [db executeUpdate:sql, @(message.messageType), message.from, message.messageId ,@(message.serverId), message.text, msgContent, @(message.deliveryState),@(message.timestamp)];
        
        // if it's not received message, need not update session list
        if (message.publicSession.isOutgoing) {
            return;
        }
        NSInteger sessionUnreadCount = 0;
        NSNumber *uniqueId = @([message.from integerValue]);
        // 2. get pre unread count
        FMResultSet *s = [db executeQuery:@"SELECT unread_count FROM follow_list WHERE unique_id = ?", uniqueId];
        if ([s next]) {
            sessionUnreadCount = [s intForColumnIndex:0] + 1;
        } else {
            DDLogDebug(@"insertMessage error");
            return;
        }
        [s close];
        NSString *lastMsgContent = [message messageContent];
        // 3. update unread count & last message info
        [db executeUpdate:@"UPDATE follow_list SET last_message_id=?, last_message_content=?, last_message_time=?, unread_count=? WHERE unique_id=?",message.messageId,lastMsgContent,@(message.timestamp), @(sessionUnreadCount), uniqueId];
        
        [wself delegateUpdatePublicSession:db uniqueId:uniqueId];
        
        // 4. get totalUnreadCount
        [wself delegateUnreadCountChanged:db];
    }];
}

- (void)updateMessage:(SAMCPublicMessage *)message
{
    if (message == nil) {
        return;
    }
    NSNumber *state = @(message.deliveryState);
    NSNumber *serverId = @(message.serverId);
    NSNumber *timestamp = @(message.timestamp);
    NSString *msgContent = @"";
    if (message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
        msgContent = [customObject.attachment encodeAttachment];
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *tableName = message.publicSession.tableName;
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET msg_status = ?, server_id = ?, msg_time = ?, msg_content = ? WHERE msg_id = ?", tableName];
        [db executeUpdate:sql, state, serverId, timestamp, msgContent, message.messageId];
    }];
}

- (void)deleteMessage:(SAMCPublicMessage *)message
{
    if (message == nil) {
        return;
    }
    if (message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
        SAMCImageAttachment *attachment = (SAMCImageAttachment *)customObject.attachment;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error;
        if ([attachment.path length] && [fileMgr fileExistsAtPath:attachment.path]) {
            [fileMgr removeItemAtPath:attachment.path error:&error];
            DDLogDebug(@"path: %@", error);
        }
        if ([attachment.thumbPath length] && [fileMgr fileExistsAtPath:attachment.thumbPath]) {
            [fileMgr removeItemAtPath:attachment.thumbPath error:&error];
            DDLogDebug(@"thumbPath: %@", error);
        }
    }
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = message.publicSession.tableName;
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE msg_id = ?", tableName];
        [db executeUpdate:sql, message.messageId];
        // if delete the last message & not outgoing message, need update session
        if (message.publicSession.isOutgoing) {
            return;
        }
        NSNumber *uniqueId = @([message.from integerValue]);
        FMResultSet *s = [db executeQuery:@"SELECT last_message_id from follow_list where unique_id = ?", uniqueId];
        NSString *lastMsgId = nil;
        if ([s next]) {
            lastMsgId = [s stringForColumnIndex:0];
        }
        [s close];
        if ([message.messageId isEqualToString:lastMsgId]) {
            // get the new last message id
            sql = [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY serial DESC LIMIT 1", tableName];
            s = [db executeQuery:sql];
            NSString *lastMsgContent = @"";
            NSTimeInterval lastMsgTime = 0;
            if ([s next]) {
                SAMCPublicMessage *lastMessage = [[SAMCPublicMessage alloc] init];
                //lastMessage = session;
                lastMessage.messageType = [s intForColumn:@"msg_type"];
                lastMessage.from = [s stringForColumn:@"msg_from"];
                lastMessage.messageId = [s stringForColumn:@"msg_id"];
                lastMessage.serverId = [s intForColumn:@"server_id"];
                lastMessage.text = [s stringForColumn:@"msg_text"];
                lastMessage.deliveryState = [s intForColumn:@"msg_status"];
                lastMessage.timestamp = [s longForColumn:@"msg_time"];
                NSString *msgContent = [s stringForColumn:@"msg_content"];
                if (lastMessage.messageType == NIMMessageTypeCustom) {
                    NIMCustomObject *customObject = [[NIMCustomObject alloc] init];
                    customObject.attachment = [[[NTESCustomAttachmentDecoder alloc] init] decodeAttachment:msgContent];
                    lastMessage.messageObject = customObject;
                }
                //lastMessage = session.isOutgoing;
                lastMsgId = lastMessage.messageId;
                lastMsgContent = [lastMessage messageContent];
                lastMsgTime = lastMessage.timestamp;
            } else {
                lastMsgId = @"";
            }
            [s close];
            // 3. update unread count & last message info
            [db executeUpdate:@"UPDATE follow_list SET last_message_id=?, last_message_content=?, last_message_time=? WHERE unique_id=?",lastMsgId,lastMsgContent,@(lastMsgTime), uniqueId];
            [wself delegateUpdatePublicSession:db uniqueId:uniqueId];
        }
    }];
}

- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)userMode
{
    if (userMode == SAMCUserModeTypeSP) {
        return 0;
    }
    __block NSInteger unreadCount = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT SUM(unread_count) FROM follow_list"];
        if ([s next]) {
            unreadCount = [s intForColumnIndex:0];
        }
        [s close];
    }];
    return unreadCount;
}

- (void)markAllMessagesReadInSession:(SAMCPublicSession *)session
{
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSNumber *uniqueId = @([session.userId integerValue]);
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM follow_list WHERE unique_id=?", uniqueId];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count == 0) {
            return;
        }
        [db executeUpdate:@"UPDATE follow_list SET unread_count=0 WHERE unique_id=?", uniqueId];
        [wself delegateUpdatePublicSession:db uniqueId:uniqueId];
        [wself delegateUnreadCountChanged:db];
    }];
}

#pragma mark -
- (void)delegateUpdatePublicSession:(FMDatabase *)db
                           uniqueId:(NSNumber *)uniqueId
{
    FMResultSet *s = [db executeQuery:@"SELECT * FROM follow_list WHERE unique_id = ?", uniqueId];
    if ([s next]) {
        NSString *username = [s stringForColumn:@"username"];
        NSString *avatar = [s stringForColumn:@"avatar"];
        BOOL block_tag = [s boolForColumn:@"block_tag"];
        BOOL favourite_tag = [s boolForColumn:@"favourite_tag"];
        NSString *sp_service_category = [s stringForColumn:@"sp_service_category"];
        NSString *last_message_id = [s stringForColumn:@"last_message_id"];
        NSString *last_message_content = [s stringForColumn:@"last_message_content"];
        NSTimeInterval last_message_time = [s doubleForColumn:@"last_message_time"];
        NSInteger unread_count = [s intForColumn:@"unread_count"];
        
        SAMCSPBasicInfo *info = [SAMCSPBasicInfo infoOfUser:uniqueId.stringValue
                                                   username:username
                                                     avatar:avatar
                                                   blockTag:block_tag
                                               favouriteTag:favourite_tag
                                                   category:sp_service_category];
        SAMCPublicSession *session = [SAMCPublicSession session:info
                                                  lastMessageId:last_message_id
                                             lastMessageContent:last_message_content
                                                lastMessageTime:last_message_time
                                                    unreadCount:unread_count];
        session.isOutgoing = NO; // only outgoing need update session
        [_publicDelegate didUpdatePublicSession:session];
    };
    [s close];
}

- (void)delegateUnreadCountChanged:(FMDatabase *)db
{
    NSInteger unreadCount = 0;
    FMResultSet *s = [db executeQuery:@"SELECT SUM(unread_count) FROM follow_list"];
    if ([s next]) {
        unreadCount = [s intForColumnIndex:0];
    }
    [s close];
    [_publicDelegate publicUnreadCountDidChanged:unreadCount userMode:SAMCUserModeTypeCustom];
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
