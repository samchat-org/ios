//
//  NIMMessageWrapper.m
//  SamChat
//
//  Created by HJ on 8/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMMessageWrapper.h"

@implementation NIMMessageWrapper

@synthesize messageType = _messageType;
@synthesize from = _from;
@synthesize session = _session;
@synthesize messageId = _messageId;
@synthesize text = _text;
@synthesize messageObject = _messageObject;
@synthesize setting = _setting;
@synthesize apnsContent = _apnsContent;
@synthesize apnsPayload = _apnsPayload;
@synthesize remoteExt = _remoteExt;
@synthesize localExt = _localExt;
@synthesize messageExt = _messageExt;
@synthesize timestamp = _timestamp;
@synthesize deliveryState = _deliveryState;
@synthesize attachmentDownloadState = _attachmentDownloadState;
@synthesize isReceivedMsg = _isReceivedMsg;
@synthesize isOutgoingMsg = _isOutgoingMsg;
@synthesize isPlayed = _isPlayed;
@synthesize senderName = _senderName;
@synthesize isRemoteRead = _isRemoteRead;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageType = NIMMessageTypeText;
        _text = @"";
//        _timestamp = [@([[NSDate date] timeIntervalSince1970] * 1000) longValue];
        _timestamp = [[NSDate date] timeIntervalSince1970];
        _messageId = [super messageId];
    }
    return self;
}

#pragma mark - messageType
- (NIMMessageType)messageType
{
    return _messageType;
}

- (void)setMessageType:(NIMMessageType)messageType
{
    _messageType = messageType;
}

#pragma mark - from
- (NSString *)from
{
    return _from;
}

- (void)setFrom:(NSString *)from
{
    _from = from;
}

#pragma mark - session
- (NIMSession *)session
{
    return _session;
}

- (void)setSession:(NIMSession *)session
{
    _session = session;
}

#pragma mark - messageId
- (NSString *)messageId
{
    return _messageId;
}

- (void)setMessageId:(NSString *)messageId
{
    _messageId = messageId;
}

#pragma mark - text
- (NSString *)text
{
    return _text;
}

- (void)setText:(NSString *)text
{
    _text = text;
}

#pragma mark - messageObject
- (id<NIMMessageObject>)messageObject
{
    return _messageObject;
}

- (void)setMessageObject:(id<NIMMessageObject>)messageObject
{
    _messageObject = messageObject;
}

#pragma mark - setting
- (NIMMessageSetting *)setting
{
    return _setting;
}

- (void)setSetting:(NIMMessageSetting *)setting
{
    _setting = setting;
}


#pragma mark - apnsContent
- (NSString *)apnsContent
{
    return _apnsContent;
}

- (void)setApnsContent:(NSString *)apnsContent
{
    _apnsContent = apnsContent;
}

#pragma mark - apnsPayload
- (NSDictionary *)apnsPayload
{
    return _apnsPayload;
}

- (void)setApnsPayload:(NSDictionary *)apnsPayload
{
    _apnsPayload = apnsPayload;
}


#pragma mark - remoteExt
- (NSDictionary *)remoteExt
{
    return _remoteExt;
}

- (void)setRemoteExt:(NSDictionary *)remoteExt
{
    _remoteExt = remoteExt;
}

#pragma mark - localExt
- (NSDictionary *)localExt
{
    return _localExt;
}

- (void)setLocalExt:(NSDictionary *)localExt
{
    _localExt = localExt;
}

#pragma mark - messageExt
- (id)messageExt
{
    return _messageExt;
}

- (void)setMessageExt:(id)messageExt
{
    _messageExt = messageExt;
}

#pragma mark - timestamp
- (NSTimeInterval)timestamp
{
    return _timestamp;
}

- (void)setTimestamp:(NSTimeInterval)timestamp
{
    _timestamp = timestamp;
}

#pragma mark - deliveryState
- (NIMMessageDeliveryState)deliveryState
{
    return _deliveryState;
}

- (void)setDeliveryState:(NIMMessageDeliveryState)deliveryState
{
    _deliveryState = deliveryState;
}

#pragma mark - attachmentDownloadState
- (NIMMessageAttachmentDownloadState)attachmentDownloadState
{
    return _attachmentDownloadState;
}

- (void)setAttachmentDownloadState:(NIMMessageAttachmentDownloadState)attachmentDownloadState
{
    _attachmentDownloadState = attachmentDownloadState;
}

#pragma mark - isReceivedMsg
- (BOOL)isReceivedMsg
{
    return _isReceivedMsg;
}

- (void)setIsReceivedMsg:(BOOL)isReceivedMsg
{
    _isReceivedMsg = isReceivedMsg;
}

#pragma mark - isOutgoingMsg
- (BOOL)isOutgoingMsg
{
    return _isOutgoingMsg;
}

- (void)setIsOutgoingMsg:(BOOL)isOutgoingMsg
{
    _isOutgoingMsg = isOutgoingMsg;
}

#pragma mark - isPlayed
- (BOOL)isPlayed
{
    return _isPlayed;
}

- (void)setIsPlayed:(BOOL)isPlayed
{
    _isPlayed = isPlayed;
}

#pragma mark - isDeleted
- (BOOL)isDeleted
{
    return NO;
}

#pragma mark - isRemoteRead
- (BOOL)isRemoteRead
{
    return _isRemoteRead;
}

- (void)setIsRemoteRead:(BOOL)isRemoteRead
{
    _isRemoteRead = isRemoteRead;
}

#pragma mark - senderName
- (NSString *)senderName
{
    return _senderName;
}

- (void)setSenderName:(NSString *)senderName
{
    _senderName = senderName;
}

- (NSString *)description
{
    NSMutableString *desc = [[NSString stringWithFormat:@"****** NIMMessageWrapper <%@: %p> Info ******\n",[self class],self] mutableCopy];
    [desc appendFormat:@"messageId\t: %@\n", self.messageId];
    [desc appendFormat:@"messageType\t: %ld\n", _messageType];
    [desc appendFormat:@"sessionId\t: %@\n", _session.sessionId];
    [desc appendFormat:@"sessionType\t: %ld\n", _session.sessionType];
    [desc appendFormat:@"time\t: %f\n", _timestamp];
    [desc appendFormat:@"text\t: %@\n", _text];
    [desc appendFormat:@"messageObject\t: %@\n", _messageObject];
    [desc appendFormat:@"deliveryState\t: %ld\n", _deliveryState];
    [desc appendFormat:@"attachmentDownloadState\t: %ld\n", _attachmentDownloadState];
    [desc appendFormat:@"remote read\t: %d\n", _isRemoteRead];
    [desc appendFormat:@"received msg\t: %d\n", _isReceivedMsg];
    [desc appendFormat:@"outgoing msg\t: %d\n", _isOutgoingMsg];
    [desc appendString:@"****** NIMMessageWrapper ******"];
    return desc;
}

@end
