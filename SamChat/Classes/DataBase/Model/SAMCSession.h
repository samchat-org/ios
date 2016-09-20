//
//  SAMCSession.h
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCSession : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString *sessionId;
@property (nonatomic, assign, readonly) NIMSessionType sessionType;
@property (nonatomic, assign, readonly) SAMCUserModeType sessionMode;

+ (instancetype)session:(NSString *)sessionId
                   type:(NIMSessionType)sessionType
                   mode:(SAMCUserModeType)sessionMode;

- (NIMSession *)nimSession;
- (NSString *)tableName;

@end
