//
//  SAMCConversationManager.h
//  SamChat
//
//  Created by HJ on 8/7/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCConversationManagerDelegate.h"
#import "SAMCRecentSession.h"
#import "SAMCSession.h"
#import "SAMCMessage.h"

// NIMConversationManager
@interface SAMCConversationManager : NSObject

+ (instancetype)sharedManager;

// SAMCMessageDB
- (NSArray<SAMCRecentSession *> *)allSessionsOfUserMode:(SAMCUserModeType)userMode;
- (void)addDelegate:(id<SAMCConversationManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCConversationManagerDelegate>)delegate;

- (void)fetchMessagesInSession:(NIMSession *)session
                      userMode:(SAMCUserModeType)userMode
                       message:(NIMMessage *)message
                         limit:(NSInteger)limit
                        result:(void(^)(NSError *error, NSArray *messages))handler;

- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)userMode;
- (void)markAllMessagesReadInSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode;

- (void)deleteMessage:(SAMCMessage *)message;

- (void)deleteRecentSession:(SAMCRecentSession *)recentSession;

@end
