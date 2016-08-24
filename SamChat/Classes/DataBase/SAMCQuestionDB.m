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

@implementation SAMCQuestionDB

- (instancetype)init
{
    self = [super initWithName:@"question.db"];
    if (self) {
        [self createMigrationInfo];
    }
    return self;
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
        NSNumber *last_answer_time = @(0);
        [db executeUpdate:@"INSERT OR IGNORE INTO send_question(question_id,question,address,status,datetime,last_answer_time) VALUES(?,?,?,?,?,?)",question_id,question,address,status,datetime,last_answer_time];
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
        [db executeUpdate:@"insert or ignore into received_question(question_id, question, sender_unique_id, status, datetime, address) values (?,?,?,?,?,?)", question_id,question,sender_unique_id,status,datetime,address];
    }];
}

@end
