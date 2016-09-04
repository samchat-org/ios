//
//  SAMCPublicMessage.m
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMessage.h"
#import "SAMCPublicSession.h"

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

@end
