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
#import "NSString+NIM.h"

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
    NSArray *increasedFollowList = [self increasedFollowList:users];
    __block BOOL result = YES;
    // TODO: separate transaction?
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSDictionary *user in increasedFollowList) {
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
    // TODO: delegate to ui
    return result;
}

- (NSArray<SAMCPublicSession *> *)myFollowList
{
    __block NSMutableArray *follows = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"follow_list"]) {
            // table not found, may sync not finished
            return;
        }
        FMResultSet *s = [db executeQuery:@"SELECT * FROM session_list"];
        NSMutableDictionary *sessionDict = [[NSMutableDictionary alloc] init];
        while ([s next]) {
            NSInteger uniqueId = [s longForColumn:@"unique_id"];
            NSString *lastMsgId = [s stringForColumn:@"last_msg_id"];
            NSString *lastMsgContent = [s stringForColumn:@"last_msg_content"];
            NSTimeInterval lastMsgTime = [s doubleForColumn:@"last_msg_time"];
            NSInteger unreadCount = [s intForColumn:@"unread_count"];
            NSString *uniqueIdString = @(uniqueId).stringValue;
            SAMCPublicSession *session = [SAMCPublicSession sessionId:uniqueIdString
                                                        lastMessageId:lastMsgId
                                                   lastMessageContent:lastMsgContent
                                                      lastMessageTime:lastMsgTime
                                                          unreadCount:unreadCount];
            [sessionDict setValue:session forKey:uniqueIdString];
        }
        [s close];
        
        s = [db executeQuery:@"SELECT * FROM follow_list"];
        while ([s next]) {
            NSInteger uniqueId = [s longForColumn:@"unique_id"];
            NSString *username = [s stringForColumn:@"username"];
            NSString *avatar = [s stringForColumn:@"avatar"];
            BOOL blockTag = [s boolForColumn:@"block_tag"];
            BOOL favouriteTag = [s boolForColumn:@"favourite_tag"];
            NSString *spServiceCategory = [s stringForColumn:@"sp_service_category"];
            
            NSString *uniqueIdString = @(uniqueId).stringValue;
            SAMCSPBasicInfo *info = [SAMCSPBasicInfo infoOfUser:uniqueIdString
                                                       username:username
                                                         avatar:avatar
                                                       blockTag:blockTag
                                                   favouriteTag:favouriteTag
                                                       category:spServiceCategory];
            SAMCPublicSession *session = [sessionDict valueForKey:uniqueIdString];
            if (session) {
                session.spBasicInfo = info;
            } else {
                session = [SAMCPublicSession session:info
                                       lastMessageId:@""
                                  lastMessageContent:@""
                                     lastMessageTime:0
                                         unreadCount:0];
            }
            [follows addObject:session];
        }
        [s close];
        
    }];
    return follows;
}

- (void)insertToFollowList:(SAMCSPBasicInfo *)userInfo
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSNumber *uniqueId = @([userInfo.userId integerValue]);
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM follow_list WHERE unique_id = ?",uniqueId];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count > 0) {
            return; // already exist
        }
        NSString *username = userInfo.username;
        NSString *avatar = userInfo.avatar;
        NSNumber *blockTag = @(userInfo.blockTag);
        NSNumber *favouriteTag = @(userInfo.favouriteTag);
        NSString *spServiceCategory = userInfo.spServiceCategory;
        [db executeUpdate:@"INSERT INTO follow_list(unique_id,username,avatar,block_tag,favourite_tag,sp_service_category) VALUES (?,?,?,?,?,?)",uniqueId,username,avatar,blockTag,favouriteTag,spServiceCategory];
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
        NSNumber *uniqueId = @([userInfo.userId integerValue]);
        [wself deleteUser:uniqueId inDatabase:db];
        SAMCPublicSession *session = [SAMCPublicSession session:userInfo
                                                  lastMessageId:@""
                                             lastMessageContent:@""
                                                lastMessageTime:0
                                                    unreadCount:0];
        [wself.publicDelegate didRemovePublicSession:session];
        [wself notifyUnreadCountChanged:db];
    }];
}

- (BOOL)isFollowing:(NSString *)userId
{
    if (userId == nil) {
        return NO;
    }
    __block BOOL isFollowing;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSNumber *uniqueId = @([userId integerValue]);
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM follow_list WHERE unique_id = ?",uniqueId];
        [s next];
        isFollowing = ([s intForColumnIndex:0] > 0);
        [s close];
    }];
    return isFollowing;
}

- (NSArray<SAMCPublicMessage *> *)messagesInSession:(SAMCPublicSession *)session
                                            message:(SAMCPublicMessage *)message
                                              limit:(NSInteger)limit
{
    NSString *tableName = [session tableName];
    __block NSMutableArray *messages = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            return;
        }
        messages = [[NSMutableArray alloc] init];
        FMResultSet *s;
        if (message == nil) {
            NSString *sql;
            if (session.isOutgoing) {
                sql = [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY serial DESC LIMIT ?", tableName];
            } else {
                sql = [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY msg_time DESC LIMIT ?", tableName];
            }
            s = [db executeQuery:sql, @(limit)];
        } else {
            NSString *sql;
            if (session.isOutgoing) {
                sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE serial<(SELECT serial FROM '%@' WHERE msg_id = ?) ORDER BY serial DESC LIMIT ?", tableName, tableName];
            } else {
                sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE msg_time<(SELECT msg_time FROM '%@' WHERE msg_id = ?) ORDER BY msg_time DESC LIMIT ?", tableName, tableName];
            }
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

- (SAMCPublicMessage *)myPublicMessageOfServerId:(NSNumber *)serverId
{
    SAMCPublicSession *session = [SAMCPublicSession sessionOfMyself];
    NSString *tableName = [session tableName];
    __block SAMCPublicMessage *message;
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            return;
        }
        FMResultSet *s;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE server_id = ?", tableName];
        s = [db executeQuery:sql, serverId];
        if ([s next]) {
            message = [[SAMCPublicMessage alloc] init];
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
        }
        [s close];
    }];
    return message;
}

- (void)insertMessage:(SAMCPublicMessage *)message initDeliveryState:(NIMMessageDeliveryState)deliveryState
{
    if (message == nil) {
        return;
    }
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = message.publicSession.tableName;
        // 1. insert message
        if (![db tableExists:tableName]) {
            [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (serial INTEGER PRIMARY KEY AUTOINCREMENT, msg_type INTEGER, msg_from TEXT, msg_id TEXT, server_id INTEGER, msg_text TEXT, msg_content TEXT, msg_status INTEGER, msg_time INTEGER)", tableName]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS '%@_msgid_index' ON '%@'(msg_id)",tableName,tableName]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS '%@_msgtime_index' ON '%@'(msg_time)",tableName,tableName]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS '%@_serverid_index' ON '%@'(server_id)",tableName,tableName]];
        }
        
        NSString *sql;
        FMResultSet *s;
        if (!message.publicSession.isOutgoing) {
            // for received message, check if is already inserted
            NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE server_id = ?", tableName];
            FMResultSet *s = [db executeQuery:sql, @(message.serverId)];
            [s next];
            int count = [s intForColumnIndex:0];
            [s close];
            if (count > 0) {
                DDLogWarn(@"public message %@ already inserted", message);
                return;
            }
        }
        
        sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(msg_type, msg_from, msg_id, server_id, msg_text, msg_content, msg_status, msg_time) VALUES(?,?,?,?,?,?,?,?)", tableName];
        NSString *msgContent;
        if (message.messageType == NIMMessageTypeCustom) {
            NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
            msgContent = [customObject.attachment encodeAttachment];
        }
        msgContent = msgContent ?:@"";
        [db executeUpdate:sql, @(message.messageType), message.from, message.messageId ,@(message.serverId), message.text, msgContent, @(deliveryState),@(message.timestamp)];
        
        // if it's not received message, need not update session list
        if (message.publicSession.isOutgoing) {
            return;
        }
        NSNumber *uniqueId = @([message.from integerValue]);
        
        // 2. get pre unread count
        NSInteger sessionUnreadCount = 1;
        NSString *lastMsgId = message.messageId;
        NSString *lastMsgContent = message.messageContent;
        NSInteger lastMsgState = deliveryState;
        NSTimeInterval lastMsgTime = message.timestamp;
        s = [db executeQuery:@"SELECT unread_count FROM session_list WHERE unique_id = ?", uniqueId];
        // 3. update unread count&last message info or insert session
        if ([s next]) {
            sessionUnreadCount += [s intForColumn:@"unread_count"];
            [db executeUpdate:@"UPDATE session_list SET unread_count=?, last_msg_id=?, last_msg_state=?, last_msg_content=?, last_msg_time=? WHERE unique_id = ?", @(sessionUnreadCount),lastMsgId,@(lastMsgState),lastMsgContent,@(lastMsgTime),uniqueId];
        } else {
            [db executeUpdate:@"INSERT INTO session_list (unique_id, unread_count, last_msg_id, last_msg_state, last_msg_content, last_msg_time) VALUES (?,?,?,?,?,?)",uniqueId, @(sessionUnreadCount),lastMsgId,@(lastMsgState),lastMsgContent,@(lastMsgTime)];
        }
        [s close];
        
        [wself notifyUpdatePublicSession:db uniqueId:uniqueId];
        
        // 4. get totalUnreadCount
        [wself notifyUnreadCountChanged:db];
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
        FMResultSet *s = [db executeQuery:@"SELECT last_msg_id FROM follow_list WHERE unique_id = ?", uniqueId];
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
            [db executeUpdate:@"UPDATE session_list SET last_msg_id=?, last_msg_content=?, last_msg_time=? WHERE unique_id=?",lastMsgId,lastMsgContent,@(lastMsgTime), uniqueId];
            [wself notifyUpdatePublicSession:db uniqueId:uniqueId];
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
        FMResultSet *s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_list"];
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
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM session_list WHERE unique_id=?", uniqueId];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count == 0) {
            return;
        }
        [db executeUpdate:@"UPDATE session_list SET unread_count=0 WHERE unique_id=?", uniqueId];
        [wself notifyUpdatePublicSession:db uniqueId:uniqueId];
        [wself notifyUnreadCountChanged:db];
    }];
}

- (void)block:(BOOL)blockFlag user:(NSString *)userId
{
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSNumber *uniqueId = @([userId integerValue]);
        [db executeUpdate:@"UPDATE follow_list SET block_tag=? WHERE unique_id=?", @(blockFlag), uniqueId];
        [wself notifyUpdatePublicSession:db uniqueId:uniqueId];
    }];
}

#pragma mark -
- (void)notifyUpdatePublicSession:(FMDatabase *)db
                         uniqueId:(NSNumber *)uniqueId
{
    FMResultSet *s = [db executeQuery:@"SELECT * FROM session_list WHERE unique_id = ?", uniqueId];
    SAMCPublicSession *session = nil;
    if ([s next]) {
        NSInteger uniqueId = [s longForColumn:@"unique_id"];
        NSString *lastMsgId = [s stringForColumn:@"last_msg_id"];
        NSString *lastMsgContent = [s stringForColumn:@"last_msg_content"];
        NSTimeInterval lastMsgTime = [s doubleForColumn:@"last_msg_time"];
        NSInteger unreadCount = [s intForColumn:@"unread_count"];
        NSString *uniqueIdString = @(uniqueId).stringValue;
        session = [SAMCPublicSession sessionId:uniqueIdString
                                 lastMessageId:lastMsgId
                            lastMessageContent:lastMsgContent
                               lastMessageTime:lastMsgTime
                                   unreadCount:unreadCount];
    }
    [s close];
    
    s = [db executeQuery:@"SELECT * FROM follow_list WHERE unique_id = ?", uniqueId];
    if ([s next]) {
        NSString *username = [s stringForColumn:@"username"];
        NSString *avatar = [s stringForColumn:@"avatar"];
        BOOL blockTag = [s boolForColumn:@"block_tag"];
        BOOL favouriteTag = [s boolForColumn:@"favourite_tag"];
        NSString *spServiceCategory = [s stringForColumn:@"sp_service_category"];
        
        SAMCSPBasicInfo *info = [SAMCSPBasicInfo infoOfUser:uniqueId.stringValue
                                                   username:username
                                                     avatar:avatar
                                                   blockTag:blockTag
                                               favouriteTag:favouriteTag
                                                   category:spServiceCategory];
        if (session) {
            session.spBasicInfo = info;
        } else {
        session = [SAMCPublicSession session:info
                               lastMessageId:@""
                          lastMessageContent:@""
                             lastMessageTime:0
                                 unreadCount:0];
        }
        session.isOutgoing = NO; // only outgoing need update session
        [_publicDelegate didUpdatePublicSession:session];
    };
    [s close];
}

- (void)notifyUnreadCountChanged:(FMDatabase *)db
{
    NSInteger unreadCount = 0;
    FMResultSet *s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_list"];
    if ([s next]) {
        unreadCount = [s intForColumnIndex:0];
    }
    [s close];
    [_publicDelegate publicUnreadCountDidChanged:unreadCount userMode:SAMCUserModeTypeCustom];
}

#pragma mark - Private
- (NSArray<NSDictionary *> *)increasedFollowList:(NSArray<NSDictionary *> *)users
{
    __block NSMutableArray *followUserIds = [[NSMutableArray alloc] init];
    for (NSDictionary *user in users) {
        [followUserIds addObject:user[SAMC_ID]];
    }
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *s = [db executeQuery:@"SELECT unique_id FROM follow_list"];
        NSMutableArray *unfollowUserIds = [[NSMutableArray alloc] init];
        while ([s next]) {
            NSNumber *uniqueId = @([s longForColumn:@"unique_id"]);
            if (![followUserIds containsObject:uniqueId]) {
                [unfollowUserIds addObject:uniqueId];
            } else {
                [followUserIds removeObject:uniqueId];
            }
        }
        [s close];
        for (NSNumber *uniqueId in unfollowUserIds) {
            [wself deleteUser:uniqueId inDatabase:db];
        }
    }];
    NSMutableArray *increasedFollows = [[NSMutableArray alloc] init];
    for (NSDictionary *user in users) {
        if ([followUserIds containsObject:user[SAMC_ID]]) {
            [increasedFollows addObject:user];
        }
    }
    return increasedFollows;
}

- (void)deleteUser:(NSNumber *)uniqueId inDatabase:(FMDatabase *)db
{
    [db executeUpdate:@"DELETE FROM follow_list WHERE unique_id = ?", uniqueId];
    [db executeUpdate:@"DELETE FROM session_list WHERE unique_id = ?", uniqueId];
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS publicmsg_%@", [uniqueId.stringValue nim_MD5String]];
    [db executeUpdate:sql];
}

//- (BOOL)resetFollowListTable
//{
//    __block BOOL result = YES;
//    [self.queue inDatabase:^(FMDatabase *db) {
//        NSArray *sqls = @[@"DROP TABLE IF EXISTS follow_list",
//                          SAMC_CREATE_FOLLOW_LIST_TABLE_SQL_2016082201];
//        for (NSString *sql in sqls) {
//            if (![db executeUpdate:sql]) {
//                DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
//                result = NO;
//            }
//        }
//    }];
//    return result;
//}

@end
