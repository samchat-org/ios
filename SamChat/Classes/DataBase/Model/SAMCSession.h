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
@property (nonatomic, assign, readonly, getter=isCustomSession) BOOL customSession;
@property (nonatomic, assign, readonly, getter=isSpSession) BOOL spSession;

+ (instancetype)session:(NSString *)sessionId
                   type:(NIMSessionType)sessionType
             customFlag:(BOOL)customFlag
                 spFlag:(BOOL)spFlag;

@end
