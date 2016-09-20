//
//  SAMCSession.m
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSession.h"
#import "NSString+NIM.h"

@interface SAMCSession ()

@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, assign) NIMSessionType sessionType;
@property (nonatomic, assign) SAMCUserModeType sessionMode;

@end

@implementation SAMCSession

+ (instancetype)session:(NSString *)sessionId
                   type:(NIMSessionType)sessionType
                   mode:(SAMCUserModeType)sessionMode
{
    SAMCSession *session = [[SAMCSession alloc] init];
    session.sessionId = sessionId;
    session.sessionType = sessionType;
    session.sessionMode = sessionMode;
    return session;
}

- (NIMSession *)nimSession
{
    return [NIMSession session:_sessionId type:_sessionType];
}

- (NSString *)tableName
{
    if (_tableName == nil) {
        _tableName = [NSString stringWithFormat:@"msg_%@_%@_%@",
                      [self.sessionId nim_MD5String],
                      @(self.sessionMode),
                      @(self.sessionType)];
    }
    return _tableName;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    SAMCSession *session = [[SAMCSession allocWithZone:zone] init];
    session.sessionId = [self.sessionId copy];
    session.sessionType = self.sessionType;
    session.sessionMode = self.sessionMode;
    return session;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\nsessionId:%@\nsessionType:%ld\nsessionMode:%ld\n",
            [super description],_sessionId,_sessionType,_sessionMode];
}

@end
