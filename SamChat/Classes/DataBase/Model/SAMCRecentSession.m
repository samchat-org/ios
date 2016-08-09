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
                  lastMessage:(SAMCMessage *)message
                  unreadCount:(NSInteger)count
{
    SAMCRecentSession *recentSession = [[SAMCRecentSession alloc] init];
    recentSession.session = session;
    recentSession.lastMessage = message;
    recentSession.unreadCount = count;
    return recentSession;
}

@end
