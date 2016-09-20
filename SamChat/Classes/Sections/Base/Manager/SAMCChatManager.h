//
//  SAMCChatManager.h
//  SamChat
//
//  Created by HJ on 8/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCChatManagerDelegate.h"

@class SAMCMessage;

@interface SAMCChatManager : NSObject

+ (instancetype)sharedManager;

- (void)addDelegate:(id<SAMCChatManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCChatManagerDelegate>)delegate;

@end
