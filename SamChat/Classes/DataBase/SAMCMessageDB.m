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

@interface SAMCMessageDB ()


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
                          session_type INTEGER DEFAULT 0, unread_count INTEGER DEFAULT 0, tag INTEGER DEFAULT 0)",
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
    NSInteger unreadCount = 0;
    if (unreadFlag) {
        unreadCount = [messages count];
    }
    // the messages belongs to the same session
    SAMCSession *session = messages.firstObject.session;
    NSString *sessionName = session.tableName;
    NSString *sessionId = session.sessionId;
    NSInteger sessionType = session.sessionType;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *s = [db executeQuery:@"SELECT unread_count FROM session_table WHERE session_mode = ? AND session_id = ?",
                          @(sessionMode), sessionId];
        if ([s next] && (unreadCount != 0)) {
            NSInteger totalUnread = [s intForColumn:@"unread_count"] + unreadCount;
            [db executeUpdate:@"UPDATE session_table SET unread_count = ? WHERE session_mode = ? AND session_id = ?",
             @(totalUnread),@(sessionMode),sessionId];
        } else {
            [db executeUpdate:@"INSERT INTO session_table (name, session_id, session_mode, session_type, unread_count) VALUES (?,?,?,?,?)",
             sessionName,sessionId,@(sessionMode),@(sessionType),@(unreadCount)];
        }
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (msg_id TEXT NOT NULL UNIQUE)",sessionName]];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(msg_id) VALUES(?)", sessionName];
        for (SAMCMessage *message in messages) {
            [db executeUpdate:sql, message.messageId];
        }
    }];
}

- (NSArray<SAMCSession *> *)allCustomSessions
{
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM session_table WHERE session_mode = ?", @(SAMCUserModeTypeCustom)];
        while ([s next]) {
            NSString *sessionId = [s stringForColumn:@"session_id"];
            int sessionType = [s intForColumn:@"session_type"];
            int sessionMode = [s intForColumn:@"session_mode"];
            int unreadCount = [s intForColumn:@"unread_count"];
            SAMCSession *session = [SAMCSession session:sessionId
                                                   type:sessionType
                                                   mode:sessionMode
                                            unreadCount:unreadCount];
            [sessions addObject:session];
        }
    }];
    return sessions;
}

- (NSArray<SAMCSession *> *)allSPSessions
{
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM session_table WHERE session_mode = ?", @(SAMCUserModeTypeSP)];
        while ([s next]) {
            NSString *sessionId = [s stringForColumn:@"session_id"];
            int sessionType = [s intForColumn:@"session_type"];
            int sessionMode = [s intForColumn:@"session_mode"];
            int unreadCount = [s intForColumn:@"unread_count"];
            SAMCSession *session = [SAMCSession session:sessionId
                                                   type:sessionType
                                                   mode:sessionMode
                                            unreadCount:unreadCount];
            [sessions addObject:session];
        }
    }];
    return sessions;
}



@end
