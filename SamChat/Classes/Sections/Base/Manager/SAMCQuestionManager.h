//
//  SAMCQuestionManager.h
//  SamChat
//
//  Created by HJ on 8/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCQuestionManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMCQuestionManager : NSObject

+ (instancetype)sharedManager;
- (void)addDelegate:(id<SAMCQuestionManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCQuestionManagerDelegate>)delegate;

- (void)sendQuestion:(NSString *)question
            location:(NSDictionary *)location
          completion:(void (^)(NSError * __nullable error))completion;

- (void)queryPopularRequest:(NSInteger)count
                 completion:(void (^)(NSArray<NSString *> * _Nullable populars))completion;

- (NSArray<SAMCQuestionSession *> *)allSendQuestion;
- (NSArray<SAMCQuestionSession *> *)allReceivedQuestion;
- (NSArray<NSString *> *)sendQuestionHistory;
- (void)insertReceivedQuestion:(NSDictionary *)questionInfo;
- (void)clearSendQuestionNewResponseCount:(SAMCQuestionSession *)session;

- (void)updateReceivedQuestion:(NSInteger)questionId status:(SAMCReceivedQuestionStatus)status;

- (void)deleteSendQuestion:(SAMCQuestionSession *)session;
- (void)deleteReceivedQuestion:(SAMCQuestionSession *)session;

- (void)removeAnswer:(NSString *)answer fromSendQuestion:(NSNumber *)questionId;

@end

NS_ASSUME_NONNULL_END
