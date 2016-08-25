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

+ (instancetype)session:(NSInteger)questionId
               question:(NSString *)quesion
                address:(NSString *)address
               datetime:(NSTimeInterval)datetime
          responseCount:(NSInteger)count
           responsetime:(NSTimeInterval)responsetime
                   type:(SAMCQuestionSessionType)type
{
    SAMCQuestionSession *session = [[SAMCQuestionSession alloc] init];
    session.questionId = questionId;
    session.question = quesion;
    session.address = address;
    session.datetime = datetime;
    session.newResponseCount = count;
    session.lastResponseTime = responsetime;
    session.type = type;
    return session;
}

- (NSString *)newResponseDescription
{
    return [NSString stringWithFormat:@"%ld new responses", self.newResponseCount];
}

- (NSString *)timestampDescription
{
    return [NIMKitUtil showTime:self.lastResponseTime/1000 showDetail:NO];
}

@end
