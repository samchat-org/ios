//
//  SAMCSession.h
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

// | name | session_id | session_mode | session_type | unread_count | tag |
@interface SAMCSession : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString *tableName;
@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, assign, readonly) NIMSessionType sessionType;
@property (nonatomic, assign, readonly) SAMCUserModeType sessionMode;

+ (instancetype)session:(NSString *)sessionId
                   type:(NIMSessionType)sessionType
                   mode:(SAMCUserModeType)sessionMode;

@end
