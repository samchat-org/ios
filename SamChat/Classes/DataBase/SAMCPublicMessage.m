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
    message.messageType = [dict[SAMC_TYPE] integerValue];
    message.deliveryState = NIMMessageDeliveryStateDeliveried;
    message.isOutgoingMsg = NO;
    message.isRemoteRead = YES;
    message.text = dict[SAMC_CONTENT];
    message.serverId = [dict[SAMC_ADV_ID] integerValue];
    message.timestamp = [dict[SAMC_PUBLISH_TIMESTAMP] integerValue]/1000;
    message.from = [NSString stringWithFormat:@"%@", dict[SAMC_ID]];
    SAMCPublicSession *session = [[SAMCPublicSession alloc] init];
    session.uniqueId = [dict[SAMC_ID] integerValue];
    message.publicSession = session;
    return message;
}

@end
