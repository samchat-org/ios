//
//  SAMCRecentSession.m
//  SamChat
//
//  Created by HJ on 8/7/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRecentSession.h"

@interface SAMCRecentSession ()

@property (nullable,nonatomic,copy) SAMCSession *session;
@property (nonatomic,assign) NSInteger unreadCount;

@end

// NIMRecentSession
@implementation SAMCRecentSession

+ (instancetype)recentSession:(SAMCSession *)session
                lastMessageId:(NSString *)messageId
                        state:(NIMMessageDeliveryState)messageState
                      content:(NSString *)messageContent
                         time:(NSTimeInterval)messageTime
                  unreadCount:(NSInteger)count
{
    SAMCRecentSession *recentSession = [[SAMCRecentSession alloc] init];
    recentSession.session = session;
    recentSession.lastMessageId = messageId;
    recentSession.lastMessageDeliveryState = messageState;
    recentSession.lastMessageContent = messageContent;
    recentSession.lastMessageTime = messageTime;
    recentSession.unreadCount = count;
    return recentSession;
}

@end
