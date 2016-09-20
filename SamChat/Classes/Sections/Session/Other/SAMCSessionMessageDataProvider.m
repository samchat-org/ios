//
//  SAMCSessionMessageDataProvider.m
//  SamChat
//
//  Created by HJ on 8/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSessionMessageDataProvider.h"
#import "NIMSession.h"
#import "NIMSDK.h"
#import "SAMCConversationManager.h"

@interface SAMCSessionMessageDataProvider ()

@property (nonatomic, copy) SAMCSession *session;

@end

@implementation SAMCSessionMessageDataProvider

- (instancetype)initWithSession:(SAMCSession *)samcsession;
{
    self = [super init];
    if (self) {
        _session = samcsession;
    }
    return self;
}

- (void)pullDown:(NIMMessage *)firstMessage handler:(NIMKitDataProvideHandler)handler
{
    [[SAMCConversationManager sharedManager] fetchMessagesInSession:_session
                                                            message:firstMessage
                                                              limit:10
                                                             result:^(NSError *error, NSArray *messages) {
         if (handler) {
             handler(nil, messages);
         }
    }];
}


- (BOOL)needTimetag{
    return YES;
}

@end
