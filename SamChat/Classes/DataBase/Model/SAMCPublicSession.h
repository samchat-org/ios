//
//  SAMCPublicSession.h
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCSPBasicInfo.h"

@interface SAMCPublicSession : NSObject

@property (nonatomic, strong) SAMCSPBasicInfo *spBasicInfo;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *lastMessageContent;
@property (nonatomic, assign) NSTimeInterval lastMesssageTime;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) BOOL isOutgoing;

@property (nonatomic, copy) NSString *tableName;

+ (instancetype)session:(SAMCSPBasicInfo *)info
     lastMessageContent:(NSString *)messageContent
        lastMessageTime:(NSTimeInterval)lastMessageTime
            unreadCount:(NSInteger)unreadCount;

+ (instancetype)sessionOfMyself;

@end
