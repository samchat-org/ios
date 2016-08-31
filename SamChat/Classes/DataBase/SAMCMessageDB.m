//
//  SAMCMessageDB.m
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMessageDB.h"
#import "FMDB.h"
#import "NTESFileLocationHelper.h"
#import "NSString+NIM.h"
#import "SAMCRecentSession.h"
#import "GCDMulticastDelegate.h"
#import "SAMCRecentSession.h"
#import "SAMCSession.h"
#import "SAMCMessage.h"
#import "NIMSDK.h"
#import "SAMCMessageDB_2016082201.h"

@interface SAMCMessageDB ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCConversationManagerDelegate> *conversationDelegate;

@end

@implementation SAMCMessageDB

- (instancetype)init
{
    self = [super initWithName:@"samcmessage.db"];
    if (self) {
        [self createMigrationInfo];
    }
    return self;
}

- (void)dealloc
{
}

- (void)addConversationDelegate:(id<SAMCConversationManagerDelegate>)delegate
{
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeConversationDelegate:(id<SAMCConversationManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCConversationManagerDelegate> *)multicastDelegate
{
    if (_conversationDelegate == nil) {
        _conversationDelegate = (GCDMulticastDelegate <SAMCConversationManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _conversationDelegate;
}

#pragma mark - Create DB
- (void)createMigrationInfo
{
    self.migrationManager = [SAMCMigrationManager managerWithDatabaseQueue:self.queue];
    NSArray *migrations = @[[SAMCMessageDB_2016082201 new]];
    [self.migrationManager addMigrations:migrations];
    if (![self.migrationManager hasMigrationsTable]) {
        [self.migrationManager createMigrationsTable:NULL];
    }
}

- (void)insertMessages:(NSArray<SAMCMessage *> *)messages
           sessionMode:(SAMCUserModeType)sessionMode
           unreadCount:(NSInteger)unreadCount
{
    if ([messages count] == 0) {
        return;
    }
    SAMCMessage *lastMessage = [messages lastObject];
    // the messages belongs to the same SAMCSession
    SAMCSession *session = messages.firstObject.session;
    NSString *sessionName = session.tableName;
    NSString *sessionId = session.sessionId;
    NSInteger sessionType = session.sessionType;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSInteger totalUnreadCount = 0;
        NSInteger sessionUnreadCount = unreadCount;
        BOOL isNewSession = false;
        // 1. get pre unread count
        FMResultSet *s = [db executeQuery:@"SELECT unread_count FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(sessionMode), sessionId];
        // 2. update unread count or insert session
        if ([s next]) {
            sessionUnreadCount += [s intForColumn:@"unread_count"];
            [db executeUpdate:@"UPDATE session_table SET unread_count = ?, last_msg_id = ? WHERE session_mode = ? AND session_id = ?",
             @(sessionUnreadCount),lastMessage.messageId,@(sessionMode),sessionId];
        } else {
            isNewSession = true;
            [db executeUpdate:@"INSERT INTO session_table (name, session_id, session_mode, session_type, unread_count, last_msg_id) VALUES (?,?,?,?,?,?)",
             sessionName,sessionId,@(sessionMode),@(sessionType),@(sessionUnreadCount),lastMessage.messageId];
        }
        [s close];
        
        // 3. insert messages
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (serial INTEGER PRIMARY KEY AUTOINCREMENT, msg_id TEXT NOT NULL UNIQUE)",sessionName]];
        [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS '%@_index' ON '%@'(msg_id)",sessionName,sessionName]];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(msg_id) VALUES(?)", sessionName];
        for (SAMCMessage *message in messages) {
            [db executeUpdate:sql, message.messageId];
        }
        // 4. get all current session_mode unreadcount
        s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_table WHERE session_mode = ?",@(sessionMode)];
        if ([s next]) {
            totalUnreadCount = [s intForColumnIndex:0];
        }
        [s close];
        // 5. notify the event
        SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:session
                                                                lastMessage:lastMessage
                                                                unreadCount:sessionUnreadCount];
        if (isNewSession) {
            [_conversationDelegate didAddRecentSession:recentSession totalUnreadCount:totalUnreadCount];
        } else {
            [_conversationDelegate didUpdateRecentSession:recentSession totalUnreadCount:totalUnreadCount];
        }
    }];
}

- (NSArray<SAMCRecentSession *> *)allSessionsOfUserMode:(SAMCUserModeType)userMode
{
    __block NSMutableArray *sessions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM session_table WHERE session_mode = ?", @(userMode)];
        while ([s next]) {
            NSString *sessionId = [s stringForColumn:@"session_id"];
            int sessionType = [s intForColumn:@"session_type"];
            int sessionMode = [s intForColumn:@"session_mode"];
            int unreadCount = [s intForColumn:@"unread_count"];
            NSString *lastMsgId = [s stringForColumn:@"last_msg_id"];
            SAMCSession *session = [SAMCSession session:sessionId
                                                   type:sessionType
                                                   mode:sessionMode];
            SAMCMessage *message = [SAMCMessage message:lastMsgId session:session];
            // get the last message for chat list view display
            [message loadNIMMessage];
            SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:session
                                                                    lastMessage:message
                                                                    unreadCount:unreadCount];
            [sessions addObject:recentSession];
        }
        [s close];
    }];
    return sessions;
}

- (NSArray<NIMMessage *> *)messagesInSession:(NIMSession *)session
                                    userMode:(SAMCUserModeType)userMode
                                     message:(NIMMessage *)message
                                       limit:(NSInteger)limit
{
    NSString *tableName = [SAMCSession session:session.sessionId type:session.sessionType mode:userMode].tableName;
    if (![self isTableExists:tableName]) {
        // table not found, first time enter the session, e.g. enter a new session from contact list
        return nil;
    }
    __block NSArray *messages = nil;
    __block NSArray *sortedMessageIds = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s;
        if (message == nil) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY serial DESC LIMIT ?", tableName];
            s = [db executeQuery:sql, @(limit)];
        } else {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE serial<(SELECT serial FROM '%@' WHERE msg_id = ?) ORDER BY serial DESC LIMIT ?", tableName, tableName];
            s = [db executeQuery:sql,message.messageId, @(limit)];
        }
        NSMutableArray *messageIds = [[NSMutableArray alloc] init];
        while ([s next]) {
            NSString *messageId = [s stringForColumn:@"msg_id"];
            [messageIds addObject:messageId];
            sortedMessageIds = [[messageIds reverseObjectEnumerator] allObjects];
        }
        [s close];
        messages = [[NIMSDK sharedSDK].conversationManager messagesInSession:session messageIds:sortedMessageIds];
    }];
    return [self sortMessages:messages messageIds:sortedMessageIds];
}

- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)userMode
{
    __block NSInteger unreadCount = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_table WHERE session_mode = ?",@(userMode)];
        if ([s next]) {
            unreadCount = [s intForColumnIndex:0];
        }
        [s close];
    }];
    return unreadCount;
}

- (void)markAllMessagesReadInSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode
{
    // just mark the session as read
    [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:session];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(userMode),session.sessionId];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count == 0) {
            return;
        }
        [db executeUpdate:@"UPDATE session_table SET unread_count = 0 WHERE session_mode = ? AND session_id = ?",
         @(userMode),session.sessionId];
        SAMCSession *samcsession = [SAMCSession session:session.sessionId type:session.sessionType mode:userMode];
        
        SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:samcsession
                                                                lastMessage:nil
                                                                unreadCount:0];
        NSInteger unreadCount = 0;
        s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_table WHERE session_mode = ?",@(userMode)];
        if ([s next]) {
            unreadCount = [s intForColumnIndex:0];
        }
        [s close];
        [_conversationDelegate didUpdateRecentSession:recentSession totalUnreadCount:unreadCount];
    }];
}

- (void)deleteMessage:(SAMCMessage *)message
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = message.session.tableName;
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE msg_id = ?", tableName];
        [db executeUpdate:sql, message.messageId];
        [[NIMSDK sharedSDK].conversationManager deleteMessage:message.nimMessage];
        // if delete the last message, need update recent session
        FMResultSet *s = [db executeQuery:@"SELECT last_msg_id FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(message.session.sessionMode),message.session.sessionId];
        NSString *lastMsgId = nil;
        if ([s next]) {
            lastMsgId = [s stringForColumnIndex:0];
        }
        [s close];
        if ([message.messageId isEqual:lastMsgId]) {
            // get the new last message id
            sql = [NSString stringWithFormat:@"SELECT msg_id FROM '%@' ORDER BY serial DESC LIMIT 1", tableName];
            s = [db executeQuery:sql];
            if ([s next]) {
                lastMsgId = [s stringForColumnIndex:0];
            } else {
                lastMsgId = @"";
            }
            [s close];
            // update last message id to session table
            [db executeUpdate:@"UPDATE session_table SET last_msg_id = ? WHERE session_mode = ? AND session_id = ?",
             lastMsgId, @(message.session.sessionMode), message.session.sessionId];
            SAMCSession *session = [message.session copy];
            SAMCMessage *lastMessage = [SAMCMessage message:lastMsgId session:session];
            [lastMessage loadNIMMessage];
            NSInteger totalUnreadCount = 0;
            // get total unread count
            s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_table WHERE session_mode = ?",@(message.session.sessionMode)];
            if ([s next]) {
                totalUnreadCount = [s intForColumnIndex:0];
            }
            [s close];
            SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:session
                                                                    lastMessage:lastMessage
                                                                    unreadCount:0];
            [_conversationDelegate didUpdateRecentSession:recentSession totalUnreadCount:totalUnreadCount];
        }
    }];
}

- (void)deleteRecentSession:(SAMCRecentSession *)recentSession
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM SESSION_TABLE WHERE session_mode = ? AND session_id = ?",
         @(recentSession.session.sessionMode),recentSession.session.sessionId];
        NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS '%@'",recentSession.session.tableName];
        [db executeUpdate:sql];
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM session_table WHERE session_id = ?",
                          recentSession.session.sessionId];
        if ([s next]) {
            int count = [s intForColumnIndex:0];
            // the sesssion on both user mode has been deleted, then delete it
            if (count == 0) {
                NIMSession *nimsession = [NIMSession session:recentSession.session.sessionId type:recentSession.session.sessionType];
                [[NIMSDK sharedSDK].conversationManager deleteAllmessagesInSession:nimsession removeRecentSession:YES];
                [[NIMSDK sharedSDK].conversationManager deleteRemoteSessions:@[nimsession] completion:nil];
            }
        }
        [s close];
    }];
}

- (void)updateTeamNIMRecentSession:(NIMRecentSession *)recentSession mode:(SAMCUserModeType)sessionMode
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        SAMCSession *samcsession = [SAMCSession session:recentSession.session.sessionId type:recentSession.session.sessionType mode:sessionMode];
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(sessionMode),recentSession.session.sessionId];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        BOOL isNewSession = false;
        if (count == 0) { // new
            isNewSession = true;
            [db executeUpdate:@"INSERT INTO session_table (name, session_id, session_mode, session_type, unread_count, last_msg_id) VALUES (?,?,?,?,?,?)",
             samcsession.tableName,recentSession.session.sessionId,@(sessionMode),@(samcsession.sessionType),@(recentSession.unreadCount),@""];
        } else {
            [db executeUpdate:@"UPDATE session_table SET unread_count = ? WHERE session_mode = ? AND session_id = ?",
             @(recentSession.unreadCount),@(sessionMode),recentSession.session.sessionId];
        }
        SAMCMessage *message = [SAMCMessage message:recentSession.lastMessage.messageId session:samcsession];
        message.nimMessage = recentSession.lastMessage;
        SAMCRecentSession *samcRecentSession = [SAMCRecentSession recentSession:samcsession
                                                                    lastMessage:message
                                                                    unreadCount:recentSession.unreadCount];
        NSInteger totalUnreadCount = 0;
        // get total unread count
        s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_table WHERE session_mode = ?",@(sessionMode)];
        if ([s next]) {
            totalUnreadCount = [s intForColumnIndex:0];
        }
        [s close];
        if (isNewSession) {
            [_conversationDelegate didAddRecentSession:samcRecentSession totalUnreadCount:totalUnreadCount];
        } else {
            [_conversationDelegate didUpdateRecentSession:samcRecentSession totalUnreadCount:totalUnreadCount];
        }
    }];
}

- (NSArray<SAMCRecentSession *> *)answerSessionsOfAnswers:(NSArray *)answers
{
    __block NSMutableArray *sessions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        for (NSString *answerId in answers) {
            FMResultSet *s = [db executeQuery:@"SELECT * FROM session_table WHERE session_mode = ? AND session_id = ?",@(SAMCUserModeTypeCustom),answerId];
            if ([s next]) {
                NSString *sessionId = answerId;
                int sessionMode = SAMCUserModeTypeCustom;
                int sessionType = [s intForColumn:@"session_type"];
                int unreadCount = [s intForColumn:@"unread_count"];
                NSString *lastMsgId = [s stringForColumn:@"last_msg_id"];
                SAMCSession *session = [SAMCSession session:sessionId
                                                       type:sessionType
                                                       mode:sessionMode];
                SAMCMessage *message = [SAMCMessage message:lastMsgId session:session];
                // get the last message for chat list view display
                [message loadNIMMessage];
                SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:session
                                                                        lastMessage:message
                                                                        unreadCount:unreadCount];
                [sessions addObject:recentSession];
            }
            [s close];
        }
    }];
    return sessions;
}

#pragma mark - Private
- (NSArray<NIMMessage *> *)sortMessages:(NSArray<NIMMessage *> *)messages messageIds:(NSArray *)messageIds
{
    if ((messages == nil) || ([messages count] <= 0)) {
        return nil;
    }
    NSMutableArray *sortedMessages = [[NSMutableArray alloc] init];
    for (NSString *messageId in messageIds) {
        for (NIMMessage *message in messages) {
            if ([message.messageId isEqualToString:messageId]) {
                [sortedMessages addObject:message];
                break;
            }
        }
    }
    return sortedMessages;
}

@end
