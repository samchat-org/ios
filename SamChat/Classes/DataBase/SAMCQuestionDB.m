//
//  SAMCQuestionDB.m
//  SamChat
//
//  Created by HJ on 8/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQuestionDB.h"
#import "SAMCQuestionDB_2016082201.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCUserInfoDB.h"
#import "SAMCDataBaseManager.h"
#import "GCDMulticastDelegate.h"
#import "SAMCQuestionManagerDelegate.h"
#import "SAMCQuestionSession.h"
#import "SAMCUser.h"

@interface SAMCQuestionDB ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCQuestionManagerDelegate> *questionDelegate;

@end

@implementation SAMCQuestionDB

- (instancetype)init
{
    self = [super initWithName:@"question.db"];
    if (self) {
        [self createMigrationInfo];
    }
    return self;
}

- (void)addQuestionDelegate:(id<SAMCQuestionManagerDelegate>)delegate
{
    [self.questionDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeQuestionDelegate:(id<SAMCQuestionManagerDelegate>)delegate
{
    [self.questionDelegate removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCQuestionManagerDelegate> *)questionDelegate
{
    if (_questionDelegate == nil) {
        _questionDelegate = (GCDMulticastDelegate <SAMCQuestionManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _questionDelegate;
}

#pragma mark - Create DB
- (void)createMigrationInfo
{
    self.migrationManager = [SAMCMigrationManager managerWithDatabaseQueue:self.queue];
    NSArray *migrations = @[[SAMCQuestionDB_2016082201 new]];
    [self.migrationManager addMigrations:migrations];
    if (![self.migrationManager hasMigrationsTable]) {
        [self.migrationManager createMigrationsTable:NULL];
    }
}

- (NSArray<SAMCQuestionSession *> *)allSendQuestion
{
    __block NSMutableArray *questions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM send_question"];
        while ([s next]) {
            NSInteger question_id = [s longForColumn:@"question_id"];
            NSString *question = [s stringForColumn:@"question"];
            NSString *address = [s stringForColumn:@"address"];
            NSTimeInterval datetime = [s doubleForColumn:@"datetime"];
            NSTimeInterval lastAnswerTime = [s doubleForColumn:@"last_answer_time"];
            NSInteger responseCount = [s longForColumn:@"new_response_count"];
            NSInteger status = [s longForColumn:@"status"];
            NSString *answersStr = [s stringForColumn:@"answers"];
            SAMCQuestionSession *session = [SAMCQuestionSession sendSession:question_id
                                                                   question:question
                                                                    address:address
                                                                   datetime:datetime
                                                              responseCount:responseCount
                                                               responsetime:lastAnswerTime
                                                                     status:status
                                                                    answers:[self answersFromString:answersStr]];
            [questions addObject:session];
        }
        [s close];
    }];
    return questions;
}

- (NSArray<SAMCQuestionSession *> *)allReceivedQuestion
{
    __block NSMutableArray *questions = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM received_question"];
        while ([s next]) {
            NSInteger question_id = [s longForColumn:@"question_id"];
            NSString *question = [s stringForColumn:@"question"];
            NSInteger sender_unique_id = [s longForColumn:@"sender_unique_id"];
            NSInteger status = [s longForColumn:@"status"];
            NSInteger datetime = [s longForColumn:@"datetime"];
            NSString *address = [s stringForColumn:@"address"];
            NSString *sender_username = [s stringForColumn:@"sender_username"];
            
            SAMCQuestionSession *session = [SAMCQuestionSession receivedSession:question_id
                                                                       question:question
                                                                        address:address
                                                                       datetime:datetime
                                                                       senderId:sender_unique_id
                                                                 senderUsername:sender_username
                                                                         status:status];
            [questions addObject:session];
        }
        [s close];
    }];
    return questions;
}

- (void)insertSendQuestion:(NSDictionary *)questionInfo
{
    DDLogDebug(@"insertSendQuestion: %@", questionInfo);
    NSNumber *question_id = [questionInfo valueForKey:SAMC_QUESTION_ID];
    if (question_id == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *question = questionInfo[SAMC_QUESTION] ?:@"";
        NSString *address = [questionInfo valueForKeyPath:SAMC_LOCATION_ADDRESS];
        NSNumber *status = @(1); // TODO: change later
        NSNumber *datetime = questionInfo[SAMC_DATETIME] ?:@(0);
        NSNumber *last_answer_time = datetime; // init with question time
        NSString *answersStr = @"";
        [db executeUpdate:@"INSERT OR IGNORE INTO send_question(question_id,question,address,status,datetime,last_answer_time,new_response_count,answers) VALUES(?,?,?,?,?,?,?,?)",question_id,question,address,status,datetime,last_answer_time,@(0),answersStr];
        SAMCQuestionSession *session = [SAMCQuestionSession sendSession:[question_id integerValue]
                                                               question:question
                                                                address:address
                                                               datetime:[datetime doubleValue]
                                                          responseCount:0
                                                           responsetime:[last_answer_time doubleValue]
                                                                 status:[status integerValue]
                                                                answers:nil];
        [self.questionDelegate didAddQuestionSession:session];
    }];
}

- (void)clearSendQuestionNewResponseCount:(SAMCQuestionSession *)session
{
    if (session == nil) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE send_question SET new_response_count=0 WHERE question_id=?", @(session.questionId)];
    }];
    [self.questionDelegate questionUnreadCountDidChanged:[self allUnreadCountOfSendQuestion] userMode:SAMCUserModeTypeCustom];
}

- (void)deleteSendQuestion:(SAMCQuestionSession *)session
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM send_question WHERE question_id = ?", @(session.questionId)];
    }];
    [self.questionDelegate questionUnreadCountDidChanged:[self allUnreadCountOfSendQuestion] userMode:SAMCUserModeTypeCustom];
}

- (void)insertReceivedQuestion:(NSDictionary *)questionInfo
{
    DDLogDebug(@"insertReceivedQuestion: %@", questionInfo);
    NSNumber *question_id = [questionInfo valueForKey:SAMC_QUESTION_ID];
    if (question_id == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:[SAMCUser userFromDict:questionInfo[SAMC_USER]]];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *question = questionInfo[SAMC_QUESTION] ?:@"";
        NSNumber *sender_unique_id = [questionInfo valueForKeyPath:SAMC_USER_ID];
        NSNumber *status = @(SAMCReceivedQuestionStatusNew);
        NSNumber *datetime = questionInfo[SAMC_DATETIME];
        NSString *address = questionInfo[SAMC_ADDRESS]; // TODO: change later
        NSString *sender_username = [questionInfo valueForKeyPath:SAMC_USER_USERNAME];
        [db executeUpdate:@"INSERT OR IGNORE INTO received_question(question_id, question, sender_unique_id, status, datetime, address, sender_username) VALUES (?,?,?,?,?,?,?)", question_id,question,sender_unique_id,status,datetime,address,sender_username];
        SAMCQuestionSession *session = [SAMCQuestionSession receivedSession:[question_id integerValue]
                                                                   question:question
                                                                    address:address
                                                                   datetime:[datetime doubleValue]
                                                                   senderId:[sender_unique_id integerValue]
                                                             senderUsername:sender_username
                                                                     status:[status integerValue]];
        [self.questionDelegate didAddQuestionSession:session];
    }];
    [self.questionDelegate questionUnreadCountDidChanged:[self allUnreadCountOfReceivedQuestion] userMode:SAMCUserModeTypeSP];
}

- (void)updateReceivedQuestion:(NSInteger)questionId status:(SAMCReceivedQuestionStatus)status
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE received_question SET status = ? WHERE question_id = ?", @(status), @(questionId)];
    }];
    [self.questionDelegate questionUnreadCountDidChanged:[self allUnreadCountOfReceivedQuestion] userMode:SAMCUserModeTypeSP];
}

- (void)deleteReceivedQuestion:(SAMCQuestionSession *)session
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM received_question WHERE question_id = ?", @(session.questionId)];
    }];
    [self.questionDelegate questionUnreadCountDidChanged:[self allUnreadCountOfReceivedQuestion] userMode:SAMCUserModeTypeSP];
}

- (SAMCQuestionSession *)sendQuestionOfQuestionId:(NSNumber *)questionId
{
    if (questionId == nil) {
        return nil;
    }
    __block SAMCQuestionSession *session = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM send_question where question_id = ?",questionId];
        if ([s next]) {
            NSString *question = [s stringForColumn:@"question"];
            NSString *address = [s stringForColumn:@"address"];
            NSTimeInterval datetime = [s doubleForColumn:@"datetime"];
            NSTimeInterval lastAnswerTime = [s doubleForColumn:@"last_answer_time"];
            NSInteger responseCount = [s longForColumn:@"new_response_count"];
            NSInteger status = [s longForColumn:@"status"];
            NSString *answersStr = [s stringForColumn:@"answers"];
            session = [SAMCQuestionSession sendSession:[questionId integerValue]
                                              question:question
                                               address:address
                                              datetime:datetime
                                         responseCount:responseCount
                                          responsetime:lastAnswerTime
                                                status:status
                                               answers:[self answersFromString:answersStr]];
        }
        [s close];
    }];
    return session;
}

- (NSString *)sendQuestion:(NSNumber *)questionId insertAnswer:(NSString *)answer time:(NSTimeInterval)time;
{
    if (questionId == nil) {
        return nil;
    }
    __block NSString *question = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *answersStr = nil;
        FMResultSet *s = [db executeQuery:@"SELECT * FROM send_question WHERE question_id = ?",questionId];
        if ([s next]) {
            question = [s stringForColumn:@"question"];
            answersStr = [s stringForColumn:@"answers"];
            NSArray *answers = [self answersFromString:answersStr];
            for (NSString *answerIdStr in answers) {
                if ([answerIdStr isEqualToString:answer]) {
                    // already find, no need to insert
                    question = nil;
                    break;
                }
            }
        }
        if (question) {
            NSString *address = [s stringForColumn:@"address"];
            NSTimeInterval datetime = [s doubleForColumn:@"datetime"];
            NSTimeInterval lastAnswerTime = time;
            NSInteger responseCount = [s longForColumn:@"new_response_count"] + 1;
            NSInteger status = [s longForColumn:@"status"];
            if ((answersStr == nil) || [answersStr isEqualToString:@""]) {
                answersStr = answer;
            } else {
                answersStr = [NSString stringWithFormat:@"%@,%@",answersStr,answer];
            }
            [db executeUpdate:@"UPDATE send_question SET answers=?, last_answer_time=?, new_response_count=? WHERE question_id=?",answersStr,@(lastAnswerTime), @(responseCount), questionId];
            SAMCQuestionSession *session = [SAMCQuestionSession sendSession:[questionId integerValue]
                                              question:question
                                               address:address
                                              datetime:datetime
                                         responseCount:responseCount
                                          responsetime:lastAnswerTime
                                                status:status
                                               answers:[self answersFromString:answersStr]];
            [self.questionDelegate didUpdateQuestionSession:session];
        }
        [s close];
    }];
    [self.questionDelegate questionUnreadCountDidChanged:[self allUnreadCountOfSendQuestion] userMode:SAMCUserModeTypeCustom];
    return question;
}



- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        return [self allUnreadCountOfSendQuestion];
    } else {
        return [self allUnreadCountOfReceivedQuestion];
    }
}

#pragma mark - Private
- (NSArray<NSString *> *)answersFromString:(NSString *)answersStr
{
    if ((answersStr == nil) || [answersStr isEqualToString:@""]) {
        return nil;
    }
    return [answersStr componentsSeparatedByString:@","];
}

- (NSInteger)allUnreadCountOfReceivedQuestion
{
    __block NSInteger unreadCount = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT COUNT(serial) FROM received_question WHERE status=?",@(SAMCReceivedQuestionStatusNew)];
        if ([s next]) {
            unreadCount = [s intForColumnIndex:0];
        }
        [s close];
    }];
    return unreadCount;
}

- (NSInteger)allUnreadCountOfSendQuestion
{
    // do not remind the unread count of sendquestion, directlry remind at chat tab
    return 0;
//    __block NSInteger unreadCount = 0;
//    [self.queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *s = [db executeQuery:@"SELECT SUM(new_response_count) FROM send_question"];
//        if ([s next]) {
//            unreadCount = [s intForColumnIndex:0];
//        }
//        [s close];
//    }];
//    return unreadCount;
}

@end
