//
//  SAMCQuestionSession.h
//  SamChat
//
//  Created by HJ on 8/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SAMCQuestionSession : NSObject

@property (nonatomic, assign) NSInteger questionId;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSTimeInterval datetime;
@property (nonatomic, assign) NSInteger newResponseCount;
@property (nonatomic, assign) NSTimeInterval lastResponseTime;
@property (nonatomic, assign) SAMCQuestionSessionType type;

@property (nonatomic, strong) NSArray<NSString *> *answers;

@property (nonatomic, assign) NSInteger senderId;
@property (nonatomic, copy) NSString *senderUsername;

+ (instancetype)sendSession:(NSInteger)questionId
                   question:(NSString *)quesion
                    address:(NSString *)address
                   datetime:(NSTimeInterval)datetime
              responseCount:(NSInteger)count
               responsetime:(NSTimeInterval)responsetime
                     status:(NSInteger)status
                    answers:(NSArray<NSString *> *)answers;

+ (instancetype)receivedSession:(NSInteger)quesionId
                       question:(NSString *)question
                        address:(NSString *)address
                       datetime:(NSTimeInterval)datetime
                       senderId:(NSInteger)senderId
                 senderUsername:(NSString *)senderUsername
                         status:(NSInteger)status;

- (NSString *)newResponseDescription;
- (NSString *)responseTimeDescription;
- (NSString *)questionTimeDescription;

@end
