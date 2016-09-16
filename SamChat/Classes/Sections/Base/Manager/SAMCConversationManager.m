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

- (void)fetchMessagesInSession:(NIMSession *)session
                      userMode:(SAMCUserModeType)userMode
                       message:(NIMMessage *)message
                         limit:(NSInteger)limit
                        result:(void(^)(NSError *error, NSArray *messages))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<NIMMessage *> *messages = [[SAMCDataBaseManager sharedManager].messageDB messagesInSession:session
                                                                                                  userMode:userMode
                                                                                                   message:message
                                                                                                     limit:limit];
        if (handler) {
            handler(nil, messages);
        }
    });
}

- (void)markAllMessagesReadInSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB markAllMessagesReadInSession:(NIMSession *)session
                                                                           userMode:(SAMCUserModeType)userMode];
    });
}

- (void)deleteMessage:(SAMCMessage *)message
{
    if (message.session.sessionType == NIMSessionTypeP2P) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SAMCDataBaseManager sharedManager].messageDB deleteMessage:message];
        });
    } else {
        [[NIMSDK sharedSDK].conversationManager deleteMessage:message.nimMessage];
    }
}

- (void)deleteRecentSession:(SAMCRecentSession *)recentSession
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB deleteRecentSession:recentSession];
    });
}

- (NSArray<SAMCRecentSession *> *)answerSessionsOfAnswers:(NSArray *)answers
{
    return [[SAMCDataBaseManager sharedManager].messageDB answerSessionsOfAnswers:answers];
}

#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (recentSession.session.sessionType != NIMSessionTypeTeam) {
        return;
    }
    [self updateTeamNIMRecentSession:recentSession];
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (recentSession.session.sessionType != NIMSessionTypeTeam) {
        return;
    }
    [self updateTeamNIMRecentSession:recentSession];
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

#pragma mark - Private
- (void)updateTeamNIMRecentSession:(NIMRecentSession *)recentSession
{
    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recentSession.session.sessionId];
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    SAMCUserModeType mode = SAMCUserModeTypeCustom;
    if ([team.owner isEqualToString:currentAccount]) {
        mode = SAMCUserModeTypeSP;
    }
    [[SAMCDataBaseManager sharedManager].messageDB updateTeamNIMRecentSession:recentSession mode:mode];
}

@end
