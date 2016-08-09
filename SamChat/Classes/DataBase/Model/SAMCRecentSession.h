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

@interface SAMCRecentSession : NSObject

@property (nullable,nonatomic,readonly,copy) SAMCSession *session;
@property (nullable,nonatomic,strong) SAMCMessage *lastMessage;
@property (nonatomic,readonly,assign) NSInteger unreadCount;

+ (instancetype)recentSession:(SAMCSession *)session
                  lastMessage:(nullable SAMCMessage *)message
                  unreadCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
