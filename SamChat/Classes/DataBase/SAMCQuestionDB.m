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
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeQuestionDelegate:(id<SAMCQuestionManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCQuestionManagerDelegate> *)multicastDelegate
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
            SAMCQuestionSession *session = [SAMCQuestionSession sendSession:question_id
                                                                   question:question
                                                                    address:address
                                                                   datetime:datetime
                                                              responseCount:responseCount
                                                               responsetime:lastAnswerTime
                                                                     status:status];
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
        FMResultSet *s = [db executeQuery:@"select * from received_question"];
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
        NSString *address = @"test"; // TODO: change later
        NSNumber *status = @(1); // TODO: change later
        NSNumber *datetime = questionInfo[SAMC_DATETIME] ?:@(0);
        NSNumber *last_answer_time = datetime; // init with question time
        [db executeUpdate:@"INSERT OR IGNORE INTO send_question(question_id,question,address,status,datetime,last_answer_time,new_response_count) VALUES(?,?,?,?,?,?,?)",question_id,question,address,status,datetime,last_answer_time,@(0)];
        SAMCQuestionSession *session = [SAMCQuestionSession sendSession:[question_id integerValue]
                                                               question:question
                                                                address:address
                                                               datetime:[datetime doubleValue]
                                                          responseCount:0
                                                           responsetime:[last_answer_time doubleValue]
                                                                 status:[status integerValue]];
        [self.questionDelegate didAddQuestionSession:session];
    }];
}

- (void)insertReceivedQuestion:(NSDictionary *)questionInfo
{
    DDLogDebug(@"insertReceivedQuestion: %@", questionInfo);
    NSNumber *question_id = [questionInfo valueForKey:SAMC_QUESTION_ID];
    if (question_id == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:questionInfo[SAMC_USER]];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *question = questionInfo[SAMC_QUESTION] ?:@"";
        NSNumber *sender_unique_id = [questionInfo valueForKeyPath:SAMC_USER_ID];
        NSNumber *status = @(0); // TODO: change later
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
}

@end
