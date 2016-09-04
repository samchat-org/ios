//
//  SAMCPublicManagerDelegate.h
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCPublicSession.h"
#import "SAMCPublicMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SAMCPublicManagerDelegate <NSObject>

@optional
- (void)didAddPublicSession:(SAMCPublicSession *)publicSession
           totalUnreadCount:(NSInteger)totalUnreadCount;

- (void)willSendMessage:(SAMCPublicMessage *)message;

- (void)sendMessage:(SAMCPublicMessage *)message progress:(CGFloat)progress;

- (void)sendMessage:(SAMCPublicMessage *)message didCompleteWithError:(nullable NSError *)error;

- (void)onRecvMessages:(NSArray<SAMCPublicMessage *> *)messages;

- (void)fetchMessageAttachment:(SAMCPublicMessage *)message progress:(CGFloat)progress;

- (void)fetchMessageAttachment:(SAMCPublicMessage *)message didCompleteWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END