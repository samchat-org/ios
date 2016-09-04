//
//  SAMCPublicSession.m
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSession.h"
#import "NSString+NIM.h"

@implementation SAMCPublicSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isOutgoing = false;
    }
    return self;
}

+ (instancetype)session:(SAMCSPBasicInfo *)info
     lastMessageContent:(NSString *)messageContent
{
    SAMCPublicSession *session = [[SAMCPublicSession alloc] init];
    session.spBasicInfo = info;
    session.lastMessageContent = messageContent;
    return session;
}

+ (instancetype)sessionOfMyself
{
    SAMCPublicSession *session = [[SAMCPublicSession alloc] init];
    session.isOutgoing = YES;
    return session;
}

- (NSString *)tableName
{
    if (_tableName == nil) {
        if (_isOutgoing) {
            _tableName = @"publicmsg_mine";
        } else {
        _tableName = [NSString stringWithFormat:@"publicmsg_%@",
                      [[NSString stringWithFormat:@"%ld", self.spBasicInfo.uniqueId] nim_MD5String]];
        }
    }
    return _tableName;
}

@end
