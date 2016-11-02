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
- (void)didAddPublicSession:(SAMCPublicSession *)publicSession;
- (void)didUpdatePublicSession:(SAMCPublicSession *)publicSession;
- (void)didRemovePublicSession:(SAMCPublicSession *)publicSession;
- (void)publicUnreadCountDidChanged:(NSInteger)unreadCount userMode:(SAMCUserModeType)mode;

- (void)willSendMessage:(SAMCPublicMessage *)message;

- (void)sendMessage:(SAMCPublicMessage *)message progress:(CGFloat)progress;

- (void)sendMessage:(SAMCPublicMessage *)message didCompleteWithError:(nullable NSError *)error;

- (void)onRecvMessage:(SAMCPublicMessage *)message;

- (void)fetchMessageAttachment:(SAMCPublicMessage *)message progress:(CGFloat)progress;

- (void)fetchMessageAttachment:(SAMCPublicMessage *)message didCompleteWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END