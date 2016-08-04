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
    [self.queue inDatabase:^(FMDatabase *db) {
//        NSArray *sqls = @[@"create table if not exists sessiontag(id integer primary key autoincrement, \
//                          sessionid text not null, custom integer, sp integer)",
//                          @"create index if not exists customindex on sessiontag(custom)",
//                          @"create index if not exists spindex on sessiontag(sp)"];
        NSArray *sqls = @[@"CREATE TABLE IF NOT EXISTS session_table(name TEXT NOT NULL, \
                          session_id TEXT NOT NULL, session_type INTEGER NOT NULL, \
                          custom_flag INTEGER DEFAULT 0, sp_flag INTEGER DEFAULT 0)",];
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,db.lastError);
            }
        }
    }];
}

- (void)insertMessages:(NSArray<SAMCMessage *> *)messages
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (SAMCMessage *message in messages) {
            NSString *sessionName = [self nameOfSession:message.session];
            FMResultSet *s = [db executeQuery:@"SELECT custom_flag, sp_flag FROM session_table WHERE session_id = ?", message.session.sessionId];
            if ([s next]) {
                int custom_flag = [s intForColumn:@"custom_flag"];
                int sp_flag = [s intForColumn:@"sp_flag"];
                if (message.session.isCustomSession && (custom_flag == 0)) {
                    [db executeUpdate:@"UPDATE session_table SET custom_flag = ? WHERE session_id = ?", @(YES), message.session.sessionId];
                }
                if (message.session.isSpSession && (sp_flag == 0)) {
                    [db executeUpdate:@"UPDATE session_table SET sp_flag = ? WHERE session_id = ?", @(YES), message.session.sessionId];
                }
            } else {
                DDLogDebug(@"insert");
                [db executeUpdate:@"INSERT INTO session_table (name, session_id, session_type, custom_flag, sp_flag) \
                 VALUES (?,?,?,?,?)",
                 sessionName,
                 message.session.sessionId,
                 @(message.session.sessionType),
                 @(message.session.isCustomSession),
                 @(message.session.isSpSession)];
            }
            [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (msg_id TEXT NOT NULL UNIQUE)",sessionName]];
            NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(msg_id) VALUES(?)", sessionName];
            [db executeUpdate:sql, message.messageId];
        }
    }];
}

- (NSArray<SAMCSession *> *)allCustomSessions
{
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM session_table WHERE custom_flag = ?", @(YES)];
        while ([s next]) {
            NSString *sessionId = [s stringForColumn:@"session_id"];
            int sessionType = [s intForColumn:@"session_type"];
            int customFlag = [s intForColumn:@"custom_flag"];
            int spFlag = [s intForColumn:@"sp_flag"];
            SAMCSession *session = [SAMCSession session:sessionId type:sessionType customFlag:customFlag spFlag:spFlag];
            [sessions addObject:session];
        }
    }];
    return sessions;
}

- (NSArray<SAMCSession *> *)allSPSessions
{
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM session_table WHERE sp_flag = ?", @(YES)];
        while ([s next]) {
            NSString *sessionId = [s stringForColumn:@"session_id"];
            int sessionType = [s intForColumn:@"session_type"];
            int customFlag = [s intForColumn:@"custom_flag"];
            int spFlag = [s intForColumn:@"sp_flag"];
            SAMCSession *session = [SAMCSession session:sessionId type:sessionType customFlag:customFlag spFlag:spFlag];
            [sessions addObject:session];
        }
    }];
    return sessions;
}

#pragma mark - private
- (NSString *)nameOfSession:(SAMCSession *)session
{
    return [NSString stringWithFormat:@"msg_%@_%@", [session.sessionId nim_MD5String], @(session.sessionType)];
}


@end
