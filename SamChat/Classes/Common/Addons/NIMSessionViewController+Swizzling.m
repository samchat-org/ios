//
//  NIMSessionViewController+Swizzling.m
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMSessionViewController+Swizzling.h"
#import "SwizzlingDefine.h"
#import "NIMMessage.h"
#import "SAMCPreferenceManager.h"
#import "SAMCDataBaseManager.h"

@implementation NIMSessionViewController (Swizzling)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([NIMSessionViewController class] ,@selector(sendMessage:), @selector(swizzling_sendMessage:));
    });
}

- (void)swizzling_sendMessage:(NIMMessage *)message
{
    id usermodeValue = nil;
    SAMCUserModeType mode = [[[SAMCPreferenceManager sharedManager] currentUserMode] integerValue];
    if (mode == SAMCUserModeTypeSP) {
        usermodeValue = MESSAGE_EXT_FROM_USER_MODE_VALUE_SP;
    } else {
        usermodeValue = MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM;
    }
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:message.remoteExt];
    [ext addEntriesFromDictionary:@{MESSAGE_EXT_FROM_USER_MODE_KEY:usermodeValue}];
    message.remoteExt = ext;
    
    SAMCSession *samcsession = [SAMCSession session:self.session.sessionId
                                               type:self.session.sessionType
                                               mode:mode];
    SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:samcsession];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:@[samcmessage]
                                                          sessionMode:mode
                                                               unread:NO];
//        [[SAMCDataBaseManager sharedManager].messageDB insertMessages:@[samcmessage]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self swizzling_sendMessage:message];
        });
    });
}

@end
