//
//  SAMCChatManager.m
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCChatManager.h"
#import "SAMCMessage.h"
#import "SAMCSession.h"
#import "SAMCDataBaseManager.h"

@interface SAMCChatManager ()<NIMChatManagerDelegate>

@end

@implementation SAMCChatManager

+ (instancetype)sharedManager
{
    static SAMCChatManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCChatManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
}

#pragma mark - NIMChatManagerDelegate
- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages
{
    // the messages belongs to the same session
    if (([messages count] == 0) || (messages.firstObject.session.sessionType != NIMSessionTypeP2P)) {
        return;
    }
    
    NSMutableArray<SAMCMessage *> *customMessages = [[NSMutableArray alloc] init];
    NSMutableArray<SAMCMessage *> *spMessages = [[NSMutableArray alloc] init];
    for (NIMMessage *message in messages) {
        id ext = message.remoteExt;
        if ([[ext valueForKey:MESSAGE_EXT_FROM_USER_MODE_KEY] isEqual:MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM]) {
            // from custom user mode, local should display in sp mode
            SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                       type:message.session.sessionType
                                                       mode:SAMCUserModeTypeSP];
            SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
            if (samcmessage) {
                [spMessages addObject:samcmessage];
            }
        } else {
            SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                       type:message.session.sessionType
                                                       mode:SAMCUserModeTypeCustom];
            SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
            if (samcmessage) {
                [customMessages addObject:samcmessage];
            }
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:customMessages sessionMode:SAMCUserModeTypeCustom unread:YES];
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:spMessages sessionMode:SAMCUserModeTypeSP unread:YES];
        //TODO: add SAMCChatManagerDelegate
    });
}

@end
