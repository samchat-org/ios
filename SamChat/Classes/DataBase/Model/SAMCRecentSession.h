//
//  SAMCRecentSession.h
//  SamChat
//
//  Created by HJ on 8/7/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SAMCSession;
@class SAMCMessage;

// | name | session_id | session_mode | session_type | unread_count | last_msg_id | last_msg_state | last_msg_content | last_msg_time | tag |
@interface SAMCRecentSession : NSObject

@property (nullable,nonatomic,readonly,copy) SAMCSession *session;
@property (nonatomic,readonly,assign) NSInteger unreadCount;

@property (nonatomic, copy) NSString *lastMessageId;
@property (nonatomic, assign) NIMMessageDeliveryState lastMessageDeliveryState;
@property (nonatomic, copy) NSString *lastMessageContent;
@property (nonatomic, assign) NSTimeInterval lastMessageTime;

+ (instancetype)recentSession:(SAMCSession *)session
                lastMessageId:(NSString *)messageId
                        state:(NIMMessageDeliveryState)messageState
                      content:(NSString *)messageContent
                         time:(NSTimeInterval)messageTime
                  unreadCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
