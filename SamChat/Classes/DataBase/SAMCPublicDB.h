//
//  SAMCPublicDB.h
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "SAMCPublicManagerDelegate.h"
#import "SAMCSPBasicInfo.h"
#import "SAMCPublicMessage.h"

@interface SAMCPublicDB : SAMCDBBase

- (void)addPublicDelegate:(id<SAMCPublicManagerDelegate>)delegate;
- (void)removePublicDelegate:(id<SAMCPublicManagerDelegate>)delegate;

- (BOOL)updateFollowList:(NSArray *)users;

- (NSArray<SAMCPublicSession *> *)myFollowList;

- (void)insertToFollowList:(SAMCSPBasicInfo *)userInfo;
- (void)deleteFromFollowList:(SAMCSPBasicInfo *)userInfo;

- (BOOL)isFollowing:(NSString *)userId;

- (NSString *)localFollowListVersion;
- (void)updateFollowListVersion:(NSString *)version;

- (NSArray<SAMCPublicMessage *> *)messagesInSession:(SAMCPublicSession *)session
                                            message:(SAMCPublicMessage *)message
                                              limit:(NSInteger)limit;
- (SAMCPublicMessage *)myPublicMessageOfServerId:(NSNumber *)serverId;

- (void)insertMessage:(SAMCPublicMessage *)message initDeliveryState:(NIMMessageDeliveryState)deliveryState;
- (void)updateMessage:(SAMCPublicMessage *)message;
- (void)deleteMessage:(SAMCPublicMessage *)message;

- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)userMode;
- (void)markAllMessagesReadInSession:(SAMCPublicSession *)session;

- (void)block:(BOOL)blockFlag user:(NSString *)userId;

@end
