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
#import "SAMCQuestionSession.h"
#import "SAMCAccountManager.h"
#import "NTESCustomSysNotificationSender.h"
#import "NSDictionary+NTESJson.h"
#import "SAMCPublicManager.h"
#import "SAMCImageAttachment.h"
#import "SAMCServerAPIMacro.h"

@interface SAMCChatManager ()<NIMChatManagerDelegate,NIMSystemNotificationManagerDelegate>

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
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
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
        NSString *questionIdStr = [ext valueForKey:MESSAGE_EXT_QUESTION_ID_KEY];
        if (questionIdStr) {
            [[SAMCQuestionManager sharedManager] updateReceivedQuestion:[questionIdStr intValue]
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
    NIMMessage *lastMessage = [messages lastObject];
    // receive public message
    if ([lastMessage.from hasPrefix:SAMC_PUBLIC_ACCOUNT_PREFIX]) {
        [self receivedNewPublicMessages:messages];
        return;
    }
    NSMutableArray *normalMessages = [messages mutableCopy];
    
    NSMutableArray<SAMCMessage *> *customMessages = [[NSMutableArray alloc] init];
    NSMutableArray<SAMCMessage *> *spMessages = [[NSMutableArray alloc] init];
    NSInteger customUnread = 0;
    NSInteger spUnread = 0;
    for (NIMMessage *message in messages) {
        id ext = message.remoteExt;
        if ([[ext valueForKey:MESSAGE_EXT_SAVE_FLAG_KEY] isEqual:MESSAGE_EXT_SAVE_FLAG_NO]) {
            [normalMessages removeObject:message];
            DDLogWarn(@"discard message: %@", message);
            continue;
        }
        
        SAMCUserModeType localUserMode = [message localUserMode];
        if (localUserMode == SAMCUserModeTypeSP) {
            // from custom user mode, local should display in sp mode
            SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                       type:message.session.sessionType
                                                       mode:SAMCUserModeTypeSP];
            SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
            if (samcmessage) {
                samcmessage.nimMessage = message;
                // 如果消息扩展中含有adv_id,则是用户询问广告的消息,此时需要先插入广告,再插入这条消息
                NSString *publicMessageIdStr = [ext valueForKey:MESSAGE_EXT_PUBLIC_ID_KEY];
                if (publicMessageIdStr) {
                    SAMCMessage *publicMessage = [self publicMessageOfAdvId:@([publicMessageIdStr integerValue])
                                                                         to:message.from
                                                                       time:message.timestamp*1000];
                    if (publicMessage) {
                        [spMessages addObject:publicMessage];
                        NSInteger index = [normalMessages indexOfObject:message];
                        [normalMessages insertObject:publicMessage.nimMessage atIndex:index];
                    }
                }
                
                [spMessages addObject:samcmessage];
                if (![[ext valueForKey:MESSAGE_EXT_UNREAD_FLAG_KEY] isEqual:MESSAGE_EXT_UNREAD_FLAG_NO]) {
                    spUnread ++;
                }
            }
        } else if (localUserMode == SAMCUserModeTypeCustom) {
            SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                       type:message.session.sessionType
                                                       mode:SAMCUserModeTypeCustom];
            SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
            if (samcmessage) {
                samcmessage.nimMessage = message;
                // 如果消息扩展中含有quest_id,则是商家回答问题的消息,此时需要先插入问题,再插入这条消息
                NSString *questionIdStr = [ext valueForKey:MESSAGE_EXT_QUESTION_ID_KEY];
                if (questionIdStr) {
                    SAMCMessage *questionMessage = [self questionMessageOfQuestionId:@([questionIdStr intValue]) answer:message.from time:message.timestamp*1000];
                    if (questionMessage) {
                        [customMessages addObject:questionMessage];
                        NSInteger index = [normalMessages indexOfObject:message];
                        [normalMessages insertObject:questionMessage.nimMessage atIndex:index];
                    }
                }
                
                [customMessages addObject:samcmessage];
                if (![[ext valueForKey:MESSAGE_EXT_UNREAD_FLAG_KEY] isEqual:MESSAGE_EXT_UNREAD_FLAG_NO]) {
                    customUnread ++;
                }
            }
        } else {
            DDLogWarn(@"receive unknow message: %@", message);
            return;
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:customMessages unreadCount:customUnread];
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:spMessages unreadCount:spUnread];
        [self.multicastDelegate onRecvMessages:normalMessages];
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

#pragma mark - handleMessageWithQuestionId
- (SAMCMessage *)questionMessageOfQuestionId:(NSNumber *)questionId answer:(NSString *)answer time:(NSTimeInterval)time
{
    SAMCMessage *quesitonMessage = nil;
    // 查询是否是一个新的回复，如果是则更新到问题表中，同时需要插入问题到聊天消息中
    NSString *question = [[SAMCDataBaseManager sharedManager].questionDB sendQuestion:questionId insertAnswer:answer time:time];
    if (question) {
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = question;
        message.from = [SAMCAccountManager sharedManager].currentAccount;
        // set unread_flag & save_flag extention
        NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:message.remoteExt];
        // 这个问题消息为了保证插入顺序，在下面直接插入数据库，在onRecvMessages:中丢弃
        [ext addEntriesFromDictionary:@{MESSAGE_EXT_FROM_USER_MODE_KEY:MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM,
                                        MESSAGE_EXT_UNREAD_FLAG_KEY:MESSAGE_EXT_UNREAD_FLAG_NO,
                                        MESSAGE_EXT_SAVE_FLAG_KEY:MESSAGE_EXT_SAVE_FLAG_NO}];
        message.remoteExt = ext;
        NIMSession *session = [NIMSession session:answer type:NIMSessionTypeP2P];
        [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:nil];
        SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                   type:message.session.sessionType
                                                   mode:SAMCUserModeTypeCustom];
        quesitonMessage = [SAMCMessage message:message.messageId session:samcsession];
        quesitonMessage.nimMessage = message;
    }
    return quesitonMessage;
}

#pragma mark - 
- (SAMCMessage *)publicMessageOfAdvId:(NSNumber *)advId to:(NSString *)userId time:(NSTimeInterval)time
{
    SAMCMessage *samcmessage = nil;
    SAMCPublicMessage *publicMessage = [[SAMCDataBaseManager sharedManager].publicDB myPublicMessageOfServerId:advId];
    if (publicMessage) {
        NIMMessage *message = [[NIMMessage alloc] init];
        message.from = [SAMCAccountManager sharedManager].currentAccount;
        if (publicMessage.messageType == NIMMessageTypeCustom) {
            message.messageObject = publicMessage.messageObject;
        } else {
            message.text = publicMessage.text;
        }
        // set unread_flag & save_flag extention
        NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:message.remoteExt];
        // 这个问题消息为了保证插入顺序，在下面直接插入数据库，在onRecvMessages:中丢弃
        [ext addEntriesFromDictionary:@{MESSAGE_EXT_FROM_USER_MODE_KEY:MESSAGE_EXT_FROM_USER_MODE_VALUE_SP,
                                        MESSAGE_EXT_UNREAD_FLAG_KEY:MESSAGE_EXT_UNREAD_FLAG_NO,
                                        MESSAGE_EXT_SAVE_FLAG_KEY:MESSAGE_EXT_SAVE_FLAG_NO}];
        message.remoteExt = ext;
        NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
        [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:nil];
        SAMCSession *samcsession = [SAMCSession session:message.session.sessionId
                                                   type:message.session.sessionType
                                                   mode:SAMCUserModeTypeSP];
        samcmessage = [SAMCMessage message:message.messageId session:samcsession];
        samcmessage.nimMessage = message;
    }
    return samcmessage;
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    NSString *content = notification.content;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict jsonInteger:NTESNotifyID] == NTESCustomRequestPush) {
                NSDictionary *requestDict = [dict jsonDict:NTESCustomContent];
                [[SAMCQuestionManager sharedManager] insertReceivedQuestion:requestDict[SAMC_BODY]];
            }
        }
    }
}

- (void)receivedNewPublicMessages:(NSArray *)publicMessages
{
    for (NIMMessage *message in publicMessages) {
        DDLogDebug(@"receivedNewPublicMessages: %@", message);
        NSString *content = message.text;
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            SAMCPublicMessage *message = [SAMCPublicMessage publicMessageFromDict:dict[SAMC_BODY]];
            if (message.messageType == NIMMessageTypeCustom) {
                NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
                SAMCImageAttachment *attachment = (SAMCImageAttachment *)customObject.attachment;
                [[NIMSDK sharedSDK].resourceManager download:attachment.thumbUrl filepath:attachment.thumbPath progress:nil completion:^(NSError * _Nullable error) {
                    if (error) {
                        DDLogError(@"download thumb image error: %@", error);
                    }
                    [[SAMCPublicManager sharedManager] receivePublicMessage:message];
                }];
            } else {
                [[SAMCPublicManager sharedManager] receivePublicMessage:message];
            }
        }
        [[NIMSDK sharedSDK].conversationManager deleteMessage:message];
    }
}

@end
