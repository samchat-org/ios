//
//  SAMCQuestionSession.m
//  SamChat
//
//  Created by HJ on 8/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQuestionSession.h"
#import "NIMKitUtil.h"

@implementation SAMCQuestionSession

+ (instancetype)sendSession:(NSInteger)questionId
                   question:(NSString *)quesion
                    address:(NSString *)address
                   datetime:(NSTimeInterval)datetime
              responseCount:(NSInteger)count
               responsetime:(NSTimeInterval)responsetime
                     status:(NSInteger)status
                    answers:(NSArray<NSString *> *)answers
{
    SAMCQuestionSession *session = [[SAMCQuestionSession alloc] init];
    session.type = SAMCQuestionSessionTypeSend;
    session.questionId = questionId;
    session.question = quesion;
    session.address = address;
    session.datetime = datetime;
    session.newResponseCount = count;
    session.lastResponseTime = responsetime;
    session.status = status;
    session.answers = answers;
    return session;
}

+ (instancetype)receivedSession:(NSInteger)quesionId
                       question:(NSString *)question
                        address:(NSString *)address
                       datetime:(NSTimeInterval)datetime
                       senderId:(NSInteger)senderId
                 senderUsername:(NSString *)senderUsername
                         status:(NSInteger)status
{
    SAMCQuestionSession *session = [[SAMCQuestionSession alloc] init];
    session.type = SAMCQuestionSessionTypeReceived;
    session.questionId = quesionId;
    session.question = question;
    session.address = address;
    session.datetime = datetime;
    session.senderId = senderId;
    session.senderUsername = senderUsername;
    session.status = status;
    return session;
}

- (NSString *)newResponseDescription
{
    return [NSString stringWithFormat:@"%ld new responses", self.newResponseCount];
}

- (NSString *)responseTimeDescription
{
    return [NIMKitUtil showTime:self.lastResponseTime/1000 showDetail:NO];
}

- (NSString *)questionTimeDescription
{
    return [NIMKitUtil showTime:self.datetime/1000 showDetail:NO];
}

@end
