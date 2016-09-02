//
//  NIMMessageWrapper.h
//  SamChat
//
//  Created by HJ on 8/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMMessageWrapper : NIMMessage

@property (nonatomic,assign) NIMMessageType messageType;
@property (nullable,nonatomic,copy) NSString *from;
@property (nullable,nonatomic,copy) NIMSession *session;
@property (nonatomic,copy) NSString *messageId;
@property (nullable,nonatomic,copy) NSString *text;
@property (nullable,nonatomic,strong) id<NIMMessageObject> messageObject;
@property (nullable,nonatomic,strong) NIMMessageSetting *setting;
@property (nullable,nonatomic,copy) NSString *apnsContent;
@property (nullable,nonatomic,copy) NSDictionary *apnsPayload;
@property (nullable,nonatomic,copy) NSDictionary *remoteExt;
@property (nullable,nonatomic,copy) NSDictionary *localExt;
@property (nullable,nonatomic,strong) id messageExt;
@property (nonatomic,assign) NSTimeInterval timestamp;
@property (nonatomic,assign) NIMMessageDeliveryState deliveryState;
@property (nonatomic,assign) NIMMessageAttachmentDownloadState attachmentDownloadState;
@property (nonatomic,assign) BOOL isReceivedMsg;
@property (nonatomic,assign) BOOL isOutgoingMsg;
@property (nullable,nonatomic,copy) NSString *senderName;
@property (nonatomic,assign) BOOL isRemoteRead;

@end

NS_ASSUME_NONNULL_END