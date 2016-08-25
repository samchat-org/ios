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
- (void)insertReceivedQuestion:(NSDictionary *)questionInfo;


@end
