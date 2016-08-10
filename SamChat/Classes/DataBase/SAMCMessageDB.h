//
//  SAMCMessageDB.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCConversationManagerDelegate.h"
#import "SAMCDBBase.h"

@class SAMCMessage;

@interface SAMCMessageDB : SAMCDBBase

// messages should belong to the same session
- (void)insertMessages:(NSArray<SAMCMessage *> *)messages
           sessionMode:(SAMCUserModeType)sessionMode
                unread:(BOOL)unreadFlag;

- (NSArray<SAMCRecentSession *> *)allSessionsOfUserMode:(SAMCUserModeType)userMode;

- (NSArray<NIMMessage *> *)messagesInSession:(NIMSession *)session
                                    userMode:(SAMCUserModeType)userMode
                                     message:(NIMMessage *)message
                                       limit:(NSInteger)limit;
- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)userMode;
- (void)markAllMessagesReadInSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode;

- (void)deleteMessage:(SAMCMessage *)message;

- (void)deleteRecentSession:(SAMCRecentSession *)recentSession;

- (void)addConversationDelegate:(id<SAMCConversationManagerDelegate>)delegate;
- (void)removeConversationDelegate:(id<SAMCConversationManagerDelegate>)delegate;


@end
