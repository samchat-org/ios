//
//  SAMCQuestionDB_2016082201.m
//  SamChat
//
//  Created by HJ on 8/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQuestionDB_2016082201.h"

@implementation SAMCQuestionDB_2016082201

- (uint64_t)version
{
    return 2016082201;
}

- (BOOL)migrateDatabase:(FMDatabase *)db error:(out NSError *__autoreleasing *)error
{
    DDLogDebug(@"SAMCQuestionDB_2016082201");
    // | id(primary) | question_id | question | address | status | datetime | last_answer_time
    NSArray *sqls = @[@"CREATE TABLE IF NOT EXISTS send_question(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
                      question_id INTEGER UNIQUE, question TEXT NOT NULL, address text, status INTEGER, \
                      datetime INTEGER, last_answer_time INTEGER)"];
    for (NSString *sql in sqls) {
        if (![db executeUpdate:sql]) {
            DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
            if (error) {
                *error = [db lastError];
                return NO;
            }
        }
    }
    return YES;
}

@end
