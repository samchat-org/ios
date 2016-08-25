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
@property (nonatomic, assign) NSTimeInterval datetime;
@property (nonatomic, assign) NSInteger newResponseCount;
@property (nonatomic, assign) NSTimeInterval lastResponseTime;
@property (nonatomic, assign) SAMCQuestionSessionType type;

+ (instancetype)session:(NSInteger)questionId
               question:(NSString *)quesion
                address:(NSString *)address
               datetime:(NSTimeInterval)datetime
          responseCount:(NSInteger)count
           responsetime:(NSTimeInterval)responsetime
                   type:(SAMCQuestionSessionType)type;

- (NSString *)newResponseDescription;
- (NSString *)timestampDescription;

@end
