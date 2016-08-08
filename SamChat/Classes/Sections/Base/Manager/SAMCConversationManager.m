//
//  SAMCConversationManager.m
//  SamChat
//
//  Created by HJ on 8/7/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConversationManager.h"
#import "SAMCDataBaseManager.h"
#import "GCDMulticastDelegate.h"
#import "SAMCMessageDB.h"

@interface SAMCConversationManager ()<NIMConversationManagerDelegate>

@end

@implementation SAMCConversationManager

+ (instancetype)sharedManager
{
    static SAMCConversationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCConversationManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}

- (void)addDelegate:(id<SAMCConversationManagerDelegate>)delegate
{
    [[SAMCDataBaseManager sharedManager].messageDB addConversationDelegate:delegate];
}

- (void)removeDelegate:(id<SAMCConversationManagerDelegate>)delegate
{
    [[SAMCDataBaseManager sharedManager].messageDB removeConversationDelegate:delegate];
}

- (NSArray<SAMCRecentSession *> *)allSessionsOfUserMode:(SAMCUserModeType)userMode
{
    return [[SAMCDataBaseManager sharedManager].messageDB allSessionsOfUserMode:userMode];
}

#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
}

- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
}

- (void)messagesDeletedInSession:(NIMSession *)session
{
}

- (void)allMessagesDeleted
{
}

@end
