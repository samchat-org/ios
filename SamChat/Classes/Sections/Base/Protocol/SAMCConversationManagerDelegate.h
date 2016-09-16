//
//  SAMCConversationManagerDelegate.h
//  SamChat
//
//  Created by HJ on 8/7/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAMCSession;
@class SAMCRecentSession;

// replace NIMConversationManagerDelegate
@protocol SAMCConversationManagerDelegate <NSObject>

@optional
- (void)didAddRecentSession:(SAMCRecentSession *)recentSession;

- (void)didUpdateRecentSession:(SAMCRecentSession *)recentSession;

- (void)didRemoveRecentSession:(SAMCRecentSession *)recentSession;

- (void)messagesDeletedInSession:(SAMCSession *)session;

- (void)allMessagesDeleted;

- (void)totalUnreadCountDidChanged:(NSInteger)totalUnreadCount userMode:(SAMCUserModeType)mode;

@end
