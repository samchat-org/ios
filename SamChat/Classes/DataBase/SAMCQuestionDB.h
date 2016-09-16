//
//  SAMCQuestionDB.h
//  SamChat
//
//  Created by HJ on 8/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "SAMCQuestionManagerDelegate.h"

@interface SAMCQuestionDB : SAMCDBBase

- (void)addQuestionDelegate:(id<SAMCQuestionManagerDelegate>)delegate;
- (void)removeQuestionDelegate:(id<SAMCQuestionManagerDelegate>)delegate;

- (NSArray<SAMCQuestionSession *> *)allSendQuestion;
- (NSArray<SAMCQuestionSession *> *)allReceivedQuestion;
- (void)insertSendQuestion:(NSDictionary *)questionInfo;
- (void)deleteSendQuestion:(SAMCQuestionSession *)session;
- (void)clearSendQuestionNewResponseCount:(SAMCQuestionSession *)session;

- (void)insertReceivedQuestion:(NSDictionary *)questionInfo;
- (void)updateReceivedQuestion:(NSInteger)questionId status:(SAMCReceivedQuestionStatus)status;
- (void)deleteReceivedQuestion:(SAMCQuestionSession *)session;

- (SAMCQuestionSession *)sendQuestionOfQuestionId:(NSNumber *)questionId;
- (NSString *)sendQuestion:(NSNumber *)questionId inserAnswer:(NSString *)answer time:(NSTimeInterval)time;

@end
