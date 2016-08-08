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
- (void)didAddRecentSession:(SAMCRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount;

- (void)didUpdateRecentSession:(SAMCRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount;

- (void)didRemoveRecentSession:(SAMCRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount;

- (void)messagesDeletedInSession:(SAMCSession *)session;

- (void)allMessagesDeleted;


@end
