//
//  SAMCChatManagerDelegate.h
//  SamChat
//
//  Created by HJ on 8/5/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMMessage;

NS_ASSUME_NONNULL_BEGIN

// wrap NIMChatManagerDelegate
@protocol SAMCChatManagerDelegate <NSObject>

@optional
- (void)willSendMessage:(NIMMessage *)message;

- (void)sendMessage:(NIMMessage *)message progress:(CGFloat)progress;

- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(nullable NSError *)error;

- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages;

- (void)onRecvMessageReceipt:(NIMMessageReceipt *)receipt;

- (void)fetchMessageAttachment:(NIMMessage *)message progress:(CGFloat)progress;

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
