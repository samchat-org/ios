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
    DDLogDebug(@"questionInfo: %@", questionInfo);
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
        [db executeUpdate:@"Insert or ignore into send_question(question_id,question,address,status,datetime,last_answer_time) values(?,?,?,?,?,?)",question_id,question,address,status,datetime,last_answer_time];
    }];
}

@end
