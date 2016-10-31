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
#import "NIMMessage+SAMC.h"

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
    [self.conversationDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeConversationDelegate:(id<SAMCConversationManagerDelegate>)delegate
{
    [self.conversationDelegate removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCConversationManagerDelegate> *)conversationDelegate
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
           unreadCount:(NSInteger)unreadCount
{
    if ([messages count] == 0) {
        return;
    }
    SAMCMessage *lastMessage = [messages lastObject];
    // the messages belongs to the same SAMCSession
    SAMCSession *session = messages.firstObject.session;
    SAMCUserModeType sessionMode = session.sessionMode;
    NSString *sessionName = [session tableName];
    NSString *sessionId = session.sessionId;
    NSInteger sessionType = session.sessionType;
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 1. insert messages
        if (![db tableExists:sessionName]) {
            [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (serial INTEGER PRIMARY KEY AUTOINCREMENT, msg_id TEXT NOT NULL UNIQUE)",sessionName]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS '%@_index' ON '%@'(msg_id)",sessionName,sessionName]];
        }
        
        NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(msg_id) VALUES(?)", sessionName];
        for (SAMCMessage *message in messages) {
            [db executeUpdate:sql, message.messageId];
        }
        
        // 2. get pre unread count
        NSInteger sessionUnreadCount = unreadCount;
        NSString *lastMsgId = lastMessage.messageId;
        NSString *lastMsgContent = lastMessage.nimMessage.messageContent;
        NIMMessageDeliveryState lastMsgState = lastMessage.nimMessage.deliveryState;
        NSTimeInterval lastMsgTime = lastMessage.nimMessage.timestamp;
        FMResultSet *s = [db executeQuery:@"SELECT unread_count FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(sessionMode), sessionId];
        // 3. update unread count&last message info or insert session
        if ([s next]) {
            sessionUnreadCount += [s intForColumn:@"unread_count"];
            [db executeUpdate:@"UPDATE session_table SET unread_count=?, last_msg_id=?, last_msg_state=?, last_msg_content=?, last_msg_time=? WHERE session_mode = ? AND session_id = ?",
             @(sessionUnreadCount),lastMsgId,@(lastMsgState),lastMsgContent,@(lastMsgTime),@(sessionMode),sessionId];
            [wself notifyUpdateSession:sessionId new:NO mode:sessionMode inDatabase:db];
        } else {
            [db executeUpdate:@"INSERT INTO session_table (name, session_id, session_mode, session_type, unread_count, last_msg_id, last_msg_state, last_msg_content, last_msg_time) VALUES (?,?,?,?,?,?,?,?,?)",
             sessionName,sessionId,@(sessionMode),@(sessionType),@(sessionUnreadCount),lastMsgId,@(lastMsgState),lastMsgContent,@(lastMsgTime)];
            [wself notifyUpdateSession:sessionId new:YES mode:sessionMode inDatabase:db];
        }
        [s close];
        
        // 4. notify all current session_mode unreadcount changed
        [wself notifyUnreadCountChangedOfMode:sessionMode inDatabase:db];
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
            int lastMsgState = [s intForColumn:@"last_msg_state"];
            NSString *lastMsgContent = [s stringForColumn:@"last_msg_content"];
            NSTimeInterval lastMsgTime = [s doubleForColumn:@"last_msg_time"];
            SAMCSession *session = [SAMCSession session:sessionId
                                                   type:sessionType
                                                   mode:sessionMode];
            SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:session
                                                                  lastMessageId:lastMsgId
                                                                          state:lastMsgState
                                                                        content:lastMsgContent
                                                                           time:lastMsgTime
                                                                    unreadCount:unreadCount];
            [sessions addObject:recentSession];
        }
        [s close];
    }];
    return sessions;
}

- (NSArray<NIMMessage *> *)messagesInSession:(SAMCSession *)session
                                     message:(NIMMessage *)message
                                       limit:(NSInteger)limit
{
    NSString *tableName = [session tableName];
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
        }
        [s close];
        sortedMessageIds = [[messageIds reverseObjectEnumerator] allObjects];
        messages = [[NIMSDK sharedSDK].conversationManager messagesInSession:[session nimSession] messageIds:sortedMessageIds];
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

- (void)markAllMessagesReadInSession:(SAMCSession *)session
{
    // just mark the session as read
    [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:[session nimSession]];
    __weak typeof(self) wself = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(session.sessionMode),session.sessionId];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count == 0) {
            return;
        }
        [db executeUpdate:@"UPDATE session_table SET unread_count = 0 WHERE session_mode = ? AND session_id = ?",
         @(session.sessionMode),session.sessionId];
        [wself notifyUpdateSession:session.sessionId new:NO mode:session.sessionMode inDatabase:db];
        [wself notifyUnreadCountChangedOfMode:session.sessionMode inDatabase:db];
    }];
}

- (void)deleteMessage:(SAMCMessage *)message
{
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = [message.session tableName];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE msg_id = ?", tableName];
        [db executeUpdate:sql, message.messageId];
        NSString *sessionId = message.session.sessionId;
        SAMCUserModeType sessionMode = message.session.sessionMode;
        NIMSessionType sessionType = message.session.sessionType;
        [[NIMSDK sharedSDK].conversationManager deleteMessage:message.nimMessage];
        // if delete the last message, need update recent session
        FMResultSet *s = [db executeQuery:@"SELECT last_msg_id FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(sessionMode),sessionId];
        NSString *lastMsgId = nil;
        if ([s next]) {
            lastMsgId = [s stringForColumnIndex:0];
        }
        [s close];
        if ([message.messageId isEqual:lastMsgId]) {
            // get the new last message id
            sql = [NSString stringWithFormat:@"SELECT msg_id FROM '%@' ORDER BY serial DESC LIMIT 1", tableName];
            s = [db executeQuery:sql];
            int lastMsgState = NIMMessageDeliveryStateDeliveried;
            NSString *lastMsgContent = @"";
            NSTimeInterval lastMsgTime = 0;
            lastMsgId = @"";
            if ([s next]) {
                lastMsgId = [s stringForColumnIndex:0];
                NIMSession *nimSession = [NIMSession session:sessionId type:sessionType];
                NIMMessage *nimmessage = [[[NIMSDK sharedSDK].conversationManager messagesInSession:nimSession messageIds:@[lastMsgId]] firstObject];
                lastMsgState = nimmessage.deliveryState;
                lastMsgContent = [nimmessage messageContent];
                lastMsgTime = nimmessage.timestamp;
            }
            [s close];
            // update last message info to session table
            [db executeUpdate:@"UPDATE session_table SET last_msg_id=?,last_msg_state=?,last_msg_content=?,last_msg_time=? WHERE session_mode = ? AND session_id = ?", lastMsgId, @(lastMsgState),lastMsgContent,@(lastMsgTime),@(sessionMode), sessionId];
            [wself notifyUpdateSession:sessionId new:NO mode:sessionMode inDatabase:db];
            [wself notifyUnreadCountChangedOfMode:sessionMode inDatabase:db];
        }
    }];
}

- (void)deleteRecentSession:(SAMCRecentSession *)recentSession
{
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM session_table WHERE session_mode = ? AND session_id = ?",
         @(recentSession.session.sessionMode),recentSession.session.sessionId];
        NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS '%@'",[recentSession.session tableName]];
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
        [wself notifyUnreadCountChangedOfMode:recentSession.session.sessionMode inDatabase:db];
    }];
}

- (void)updateTeamNIMRecentSession:(NIMRecentSession *)recentSession mode:(SAMCUserModeType)sessionMode
{
    __weak typeof(self) wself = self;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NIMMessage *lastMessage = recentSession.lastMessage;
        NSString *lastMsgId = lastMessage ? lastMessage.messageId : @"";
        NIMMessageDeliveryState lastMsgState = lastMessage ? lastMessage.deliveryState : NIMMessageDeliveryStateDeliveried;
        NSString *lastMsgContent = lastMessage ? [lastMessage messageContent] : @"";
        NSTimeInterval lastMsgTime = lastMessage ? lastMessage.timestamp : 0;
        SAMCSession *samcsession = [SAMCSession session:recentSession.session.sessionId type:recentSession.session.sessionType mode:sessionMode];
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(sessionMode),recentSession.session.sessionId];
        [s next];
        int count = [s intForColumnIndex:0];
        [s close];
        if (count == 0) { // new session
            [db executeUpdate:@"INSERT INTO session_table (name, session_id, session_mode, session_type, unread_count, last_msg_id, last_msg_state, last_msg_content, last_msg_time) VALUES (?,?,?,?,?,?,?,?,?)",
             samcsession.tableName,recentSession.session.sessionId,@(sessionMode),@(samcsession.sessionType),@(recentSession.unreadCount),lastMsgId, @(lastMsgState), lastMsgContent, @(lastMsgTime)];
            [wself notifyUpdateSession:recentSession.session.sessionId new:YES mode:sessionMode inDatabase:db];
        } else {
            [db executeUpdate:@"UPDATE session_table SET unread_count=?,last_msg_id=?,last_msg_state=?,last_msg_content=?,last_msg_time=? WHERE session_mode = ? AND session_id = ?",
             @(recentSession.unreadCount),lastMsgId,@(lastMsgState),lastMsgContent,@(lastMsgTime),@(sessionMode),recentSession.session.sessionId];
            [wself notifyUpdateSession:recentSession.session.sessionId new:NO mode:sessionMode inDatabase:db];
        }
        [wself notifyUnreadCountChangedOfMode:sessionMode inDatabase:db];
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
                int lastMsgState = [s intForColumn:@"last_msg_state"];
                NSString *lastMsgContent = [s stringForColumn:@"last_msg_content"];
                NSTimeInterval lastMsgTime = [s doubleForColumn:@"last_msg_time"];
                SAMCSession *session = [SAMCSession session:sessionId
                                                       type:sessionType
                                                       mode:sessionMode];
                SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:session
                                                                      lastMessageId:lastMsgId
                                                                              state:lastMsgState
                                                                            content:lastMsgContent
                                                                               time:lastMsgTime
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

- (void)notifyUpdateSession:(NSString *)sessionId new:(BOOL)isNewSession mode:(SAMCUserModeType)mode inDatabase:(FMDatabase *)db
{
    FMResultSet *s = [db executeQuery:@"SELECT * FROM session_table WHERE session_mode=? AND session_id=?", @(mode), sessionId];
    if ([s next]) {
        int sessionType = [s intForColumn:@"session_type"];
        int sessionMode = [s intForColumn:@"session_mode"];
        int unreadCount = [s intForColumn:@"unread_count"];
        NSString *lastMsgId = [s stringForColumn:@"last_msg_id"];
        int lastMsgState = [s intForColumn:@"last_msg_state"];
        NSString *lastMsgContent = [s stringForColumn:@"last_msg_content"];
        NSTimeInterval lastMsgTime = [s doubleForColumn:@"last_msg_time"];
        SAMCSession *session = [SAMCSession session:sessionId
                                               type:sessionType
                                               mode:sessionMode];
        SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:session
                                                              lastMessageId:lastMsgId
                                                                      state:lastMsgState
                                                                    content:lastMsgContent
                                                                       time:lastMsgTime
                                                                unreadCount:unreadCount];
        if (isNewSession) {
            [_conversationDelegate didAddRecentSession:recentSession];
        } else {
            [_conversationDelegate didUpdateRecentSession:recentSession];
        }
    }
    [s close];
}

- (void)notifyUnreadCountChangedOfMode:(SAMCUserModeType)mode inDatabase:(FMDatabase *)db
{
    NSInteger unreadCount = 0;
    FMResultSet *s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_table WHERE session_mode = ?",@(mode)];
    if ([s next]) {
        unreadCount = [s intForColumnIndex:0];
    }
    [s close];
    [_conversationDelegate totalUnreadCountDidChanged:unreadCount userMode:mode];
}

@end
