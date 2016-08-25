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

- (NSArray<SAMCQuestionSession *> *)allSendQuestion;
- (NSArray<SAMCQuestionSession *> *)allReceivedQuestion;
- (void)insertReceivedQuestion:(NSDictionary *)questionInfo;

- (void)updateReceivedQuestion:(NSInteger)questionId status:(SAMCReceivedQuestionStatus)status;

@end

NS_ASSUME_NONNULL_END
