//
//  SAMCSession.m
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSession.h"

@interface SAMCSession ()

@property (nonatomic,copy) NSString *sessionId;
@property (nonatomic,assign) NIMSessionType sessionType;
@property (nonatomic, assign, getter=isCustomSession) BOOL customSession;
@property (nonatomic, assign, getter=isSpSession) BOOL spSession;

@end

@implementation SAMCSession

+ (instancetype)session:(NSString *)sessionId
                   type:(NIMSessionType)sessionType
             customFlag:(BOOL)customFlag
                 spFlag:(BOOL)spFlag
{
    SAMCSession *session = [[SAMCSession alloc] init];
    session.sessionId = sessionId;
    session.sessionType = sessionType;
    session.customSession = customFlag;
    session.spSession = spFlag;
    return session;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    SAMCSession *session = [[SAMCSession allocWithZone:zone] init];
    session.sessionId = [self.sessionId copy];
    session.sessionType = self.sessionType;
    session.customSession = self.isCustomSession;
    session.spSession = self.isSpSession;
    return session;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\nsessionId:%@\nsessionType:%ld\nisCustomSession:%d\nisSpSession:%d\n",
            [super description],_sessionId,_sessionType,_customSession,_spSession];
}

@end
