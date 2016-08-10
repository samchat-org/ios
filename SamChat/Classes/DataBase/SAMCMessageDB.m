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

@interface SAMCMessageDB ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCConversationManagerDelegate> *conversationDelegate;

@end

@implementation SAMCMessageDB

- (instancetype)init
{
    self = [super initWithName:@"samcmessage.db"];
    if (self) {
        [self createDataBaseIfNeccessary];
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
- (void)createDataBaseIfNeccessary
{
    // | name | session_id | session_mode | session_type | unread_count | tag |
    [self.queue inDatabase:^(FMDatabase *db) {
//        NSArray *sqls = @[@"create table if not exists sessiontag(id integer primary key autoincrement, \
//                          sessionid text not null, custom integer, sp integer)",
//                          @"create index if not exists customindex on sessiontag(custom)",
//                          @"create index if not exists spindex on sessiontag(sp)"];
        NSArray *sqls = @[@"CREATE TABLE IF NOT EXISTS session_table(name TEXT NOT NULL UNIQUE, \
                          session_id TEXT NOT NULL, session_mode INTEGER DEFAULT 0, \
                          session_type INTEGER DEFAULT 0, last_msg_id text, unread_count INTEGER DEFAULT 0, tag INTEGER DEFAULT 0)",
                          @"CREATE INDEX IF NOT EXISTS session_id_index ON session_table(session_id)"];
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,db.lastError);
            }
        }
    }];
}

- (void)insertMessages:(NSArray<SAMCMessage *> *)messages
           sessionMode:(SAMCUserModeType)sessionMode
                unread:(BOOL)unreadFlag
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
        NSInteger unreadCount = 0;
        if (unreadFlag) {
            unreadCount = [messages count];
        }
        BOOL isNewSession = false;
        // 1. get pre unread count
        FMResultSet *s = [db executeQuery:@"SELECT unread_count FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(sessionMode), sessionId];
        // 2. update unread count or insert session
        if ([s next]) {
            unreadCount = [s intForColumn:@"unread_count"] + unreadCount;
            [db executeUpdate:@"UPDATE session_table SET unread_count = ?, last_msg_id = ? WHERE session_mode = ? AND session_id = ?",
             @(unreadCount),lastMessage.messageId,@(sessionMode),sessionId];
        } else {
            isNewSession = true;
            [db executeUpdate:@"INSERT INTO session_table (name, session_id, session_mode, session_type, unread_count, last_msg_id) VALUES (?,?,?,?,?,?)",
             sessionName,sessionId,@(sessionMode),@(sessionType),@(unreadCount),lastMessage.messageId];
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
                                                                unreadCount:unreadCount];
        if (isNewSession) {
            [_conversationDelegate didAddRecentSession:recentSession totalUnreadCount:totalUnreadCount];
        } else {
            [_conversationDelegate didUpdateRecentSession:recentSession totalUnreadCount:totalUnreadCount];
        }
    }];
}

- (NSArray<SAMCRecentSession *> *)allSessionsOfUserMode:(SAMCUserModeType)userMode
{
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
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
    __block NSArray *messages = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = nil;
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
        messages = [[NIMSDK sharedSDK].conversationManager messagesInSession:session messageIds:messageIds];
    }];
    return messages;
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
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE session_table SET unread_count = 0 WHERE session_mode = ? AND session_id = ?",
         @(userMode),session.sessionId];
        SAMCSession *samcsession = [SAMCSession session:session.sessionId type:session.sessionType mode:userMode];
        
        SAMCRecentSession *recentSession = [SAMCRecentSession recentSession:samcsession
                                                                lastMessage:nil
                                                                unreadCount:0];
        NSInteger unreadCount = 0;
        FMResultSet *s = [db executeQuery:@"SELECT SUM(unread_count) FROM session_table WHERE session_mode = ?",@(userMode)];
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
        [db executeUpdate:@"delete from session_table where session_mode = ? and session_id = ?",
         @(recentSession.session.sessionMode),recentSession.session.sessionId];
        NSString *sql = [NSString stringWithFormat:@"drop table %@",recentSession.session.tableName];
        [db executeUpdate:sql];
        FMResultSet *s = [db executeQuery:@"select count(*) from session_table where session_id = ?",
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

@end
