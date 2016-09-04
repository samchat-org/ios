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

- (NSArray<SAMCPublicMessage *> *)messagesInSession:(SAMCPublicSession *)session
                                            message:(SAMCPublicMessage *)message
                                              limit:(NSInteger)limit;

- (void)insertMessage:(SAMCPublicMessage *)message;
- (void)updateMessage:(SAMCPublicMessage *)message
        deliveryState:(NIMMessageDeliveryState)state
             serverId:(NSInteger)serverId
            timestamp:(NSInteger)timestamp;

@end
