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
    NSMutableArray<SAMCMessage *> *samcmessages = [[NSMutableArray alloc] init];
    for (NIMMessage *message in messages) {
        BOOL isCustomSession = NO;
        BOOL isSpSession = NO;
        id ext = message.remoteExt;
        if ([[ext valueForKey:MESSAGE_EXT_FROM_USER_MODE_KEY] isEqual:MESSAGE_EXT_FROM_USER_MODE_VALUE_SP]) {
            isSpSession = YES;
        } else {
            isCustomSession = YES;
        }
        SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                   type:message.session.sessionType
                                             customFlag:isCustomSession
                                                 spFlag:isSpSession];
        SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
        if (samcmessage) {
           [samcmessages addObject:samcmessage];
            DDLogDebug(@"Message:\n%@", samcmessage);
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:samcmessages];
        //TODO: add SAMCChatManagerDelegate
    });
}

@end
