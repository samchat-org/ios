//
//  SAMCMessage.m
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMessage.h"
#import "NIMSession.h"
#import "SAMCSession.h"

@interface SAMCMessage ()

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) SAMCSession *session;

@end

@implementation SAMCMessage

+ (instancetype)message:(NSString *)messageId session:(SAMCSession *)session
{
    SAMCMessage *message = [[SAMCMessage alloc] init];
    message.messageId = messageId;
    message.session = session;
    return message;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\nmessageId:%@\nsession:\n%@",[super description],_messageId,_session];
}

- (void)loadNIMMessage
{
    if (_nimMessage == nil) {
        NIMSession *nimSession = [NIMSession session:_session.sessionId type:_session.sessionType];
        NSArray *messages = nil;
        if ((_messageId == nil) || ([_messageId isEqualToString:@""])) {
            messages = [[NIMSDK sharedSDK].conversationManager messagesInSession:nimSession message:nil limit:1];
        } else {
            messages = [[NIMSDK sharedSDK].conversationManager messagesInSession:nimSession messageIds:@[_messageId]];
        }
        _nimMessage = [messages firstObject];
    }
}

@end
