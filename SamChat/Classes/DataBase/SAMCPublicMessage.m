//
//  SAMCPublicMessage.m
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMessage.h"
#import "SAMCPublicSession.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCImageAttachment.h"
#import "SAMCServerAPI.h"

@implementation SAMCPublicMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messageType = NIMMessageTypeText;
        self.deliveryState = NIMMessageDeliveryStateDelivering;
        self.isReceivedMsg = NO;
        self.isOutgoingMsg = YES;
        self.isRemoteRead = YES;
    }
    return self;
}

+ (instancetype)publicMessageFromDict:(NSDictionary *)dict
{
    // ex. {"dest_id":1000027,"id":1000027,"type":0,"content":"1111","adv_id":10000297,"publish_timestamp":1472977564000}
    SAMCPublicMessage *message = [[SAMCPublicMessage alloc] init];
    SAMCAdvertisementType type = [dict[SAMC_TYPE] integerValue];
    message.messageType = [dict[SAMC_TYPE] integerValue];
    if (type == SAMCAdvertisementTypeImage) {
        message.messageType = NIMMessageTypeCustom;
        NIMCustomObject *customObject = [[NIMCustomObject alloc] init];
        SAMCImageAttachment *attachment = [[SAMCImageAttachment alloc] init];
        attachment.url = dict[SAMC_CONTENT];
        attachment.thumbUrl = dict[SAMC_CONTENT_THUMB];
        customObject.attachment = attachment;
        message.messageObject = customObject;
        message.attachmentDownloadState = NIMMessageAttachmentDownloadStateDownloaded;
    } else if(type == SAMCAdvertisementTypeText){
        message.messageType = NIMMessageTypeText;
        message.text = dict[SAMC_CONTENT];
    }
    message.deliveryState = NIMMessageDeliveryStateDeliveried;
    message.isOutgoingMsg = NO;
    message.isRemoteRead = YES;
    message.serverId = [dict[SAMC_ADV_ID] integerValue];
    message.timestamp = [dict[SAMC_PUBLISH_TIMESTAMP] integerValue]/1000;
    message.from = [NSString stringWithFormat:@"%@", dict[SAMC_ID]];
    SAMCPublicSession *session = [[SAMCPublicSession alloc] init];
    session.uniqueId = [dict[SAMC_ID] integerValue];
    message.publicSession = session;
    return message;
}

@end
