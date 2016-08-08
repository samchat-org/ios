//
//  SAMCConversationManager.h
//  SamChat
//
//  Created by HJ on 8/7/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCConversationManagerDelegate.h"

// NIMConversationManager
@interface SAMCConversationManager : NSObject

+ (instancetype)sharedManager;

- (void)addDelegate:(id<SAMCConversationManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCConversationManagerDelegate>)delegate;

@end
