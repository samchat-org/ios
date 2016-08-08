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

@property (nonatomic,copy) NIMSession *session;
@property (nonatomic, assign) SAMCUserModeType userMode;

@end

@implementation SAMCSessionMessageDataProvider

- (instancetype)initWithSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode
{
    self = [super init];
    if (self) {
        _session = session;
        _userMode = userMode;
    }
    return self;
}

- (void)pullDown:(NIMMessage *)firstMessage handler:(NIMKitDataProvideHandler)handler
{
    [[SAMCConversationManager sharedManager] fetchMessagesInSession:_session
                                                           userMode:_userMode
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
