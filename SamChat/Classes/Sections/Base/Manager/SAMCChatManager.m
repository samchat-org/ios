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
#import "GCDMulticastDelegate.h"

@interface SAMCChatManager ()<NIMChatManagerDelegate>

@property (nonatomic, strong) GCDMulticastDelegate<SAMCChatManagerDelegate> *multicastDelegate;

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

- (void)addDelegate:(id<SAMCChatManagerDelegate>)delegate
{
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<SAMCChatManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCChatManagerDelegate> *)multicastDelegate
{
    if (_multicastDelegate == nil) {
        _multicastDelegate = (GCDMulticastDelegate <SAMCChatManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _multicastDelegate;
}

#pragma mark - NIMChatManagerDelegate
- (void)willSendMessage:(NIMMessage *)message
{
    [self.multicastDelegate willSendMessage:message];
}

- (void)sendMessage:(NIMMessage *)message progress:(CGFloat)progress
{
    [self.multicastDelegate sendMessage:message progress:progress];
}

- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(nullable NSError *)error
{
    [self.multicastDelegate sendMessage:message didCompleteWithError:error];
}

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
                samcmessage.nimMessage = message;
                [spMessages addObject:samcmessage];
            }
        } else {
            SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                       type:message.session.sessionType
                                                       mode:SAMCUserModeTypeCustom];
            SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
            if (samcmessage) {
                samcmessage.nimMessage = message;
                [customMessages addObject:samcmessage];
            }
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:customMessages sessionMode:SAMCUserModeTypeCustom unread:YES];
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:spMessages sessionMode:SAMCUserModeTypeSP unread:YES];
        //TODO: add SAMCChatManagerDelegate
        [self.multicastDelegate onRecvMessages:messages];
    });
}

- (void)onRecvMessageReceipt:(NIMMessageReceipt *)receipt
{
    [self.multicastDelegate onRecvMessageReceipt:receipt];
}

- (void)fetchMessageAttachment:(NIMMessage *)message progress:(CGFloat)progress
{
    [self.multicastDelegate fetchMessageAttachment:message progress:progress];
}

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(nullable NSError *)error
{
    [self.multicastDelegate fetchMessageAttachment:message didCompleteWithError:error];
}

@end
