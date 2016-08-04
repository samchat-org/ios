//
//  SAMCMessage.h
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAMCSession;

@interface SAMCMessage : NSObject

@property (nonatomic,copy,readonly) NSString *messageId;
@property (nonatomic,copy,readonly) SAMCSession *session;

+ (instancetype)message:(NSString *)messageId session:(SAMCSession *)session;

@end
