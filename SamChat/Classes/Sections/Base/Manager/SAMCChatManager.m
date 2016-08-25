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
#import "NIMMessage+SAMC.h"
#import "SAMCQuestionManager.h"

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
    if (error == nil) {
        id ext = message.remoteExt;
        // 如果发送的消息带有questionId，则发送成功的时候更新这个消息的status
        NSNumber *questionId = [ext valueForKey:MESSAGE_EXT_QUESTION_ID_KEY];
        if (questionId) {
            [[SAMCQuestionManager sharedManager] updateReceivedQuestion:[questionId integerValue]
                                                                 status:SAMCReceivedQuestionStatusResponsed];
        }
    }
    [self.multicastDelegate sendMessage:message didCompleteWithError:error];
}

- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages
{
    // the messages belongs to the same session
    if (([messages count] == 0) || (messages.firstObject.session.sessionType != NIMSessionTypeP2P)) {
        [self.multicastDelegate onRecvMessages:messages];
        return;
    }
    
    NSMutableArray<SAMCMessage *> *customMessages = [[NSMutableArray alloc] init];
    NSMutableArray<SAMCMessage *> *customUnreadMessages = [[NSMutableArray alloc] init];
    NSMutableArray<SAMCMessage *> *spMessages = [[NSMutableArray alloc] init];
    NSMutableArray<SAMCMessage *> *spUnreadMessages = [[NSMutableArray alloc] init];
    for (NIMMessage *message in messages) {
        id ext = message.remoteExt;
        SAMCUserModeType localUserMode = [message localUserMode];
        if (localUserMode == SAMCUserModeTypeSP) {
            // from custom user mode, local should display in sp mode
            SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                       type:message.session.sessionType
                                                       mode:SAMCUserModeTypeSP];
            SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
            if (samcmessage) {
                samcmessage.nimMessage = message;
                if ([[ext valueForKey:MESSAGE_EXT_UNREAD_FLAG_KEY] isEqual:MESSAGE_EXT_UNREAD_FLAG_NO]) {
                    [spMessages addObject:samcmessage];
                } else {
                    [spUnreadMessages addObject:samcmessage];
                }
            }
        } else if (localUserMode == SAMCUserModeTypeCustom) {
            SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                       type:message.session.sessionType
                                                       mode:SAMCUserModeTypeCustom];
            SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
            if (samcmessage) {
                samcmessage.nimMessage = message;
                if ([[ext valueForKey:MESSAGE_EXT_UNREAD_FLAG_KEY] isEqual:MESSAGE_EXT_UNREAD_FLAG_NO]) {
                    [customMessages addObject:samcmessage];
                } else {
                    [customUnreadMessages addObject:samcmessage];
                }
            }
        } else {
            DDLogWarn(@"receive unknow message: %@", message);
            return;
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:customMessages sessionMode:SAMCUserModeTypeCustom unread:NO];
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:customUnreadMessages sessionMode:SAMCUserModeTypeCustom unread:YES];
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:spMessages sessionMode:SAMCUserModeTypeSP unread:NO];
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:spUnreadMessages sessionMode:SAMCUserModeTypeSP unread:YES];
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
