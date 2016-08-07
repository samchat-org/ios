//
//  SAMCMessageDB.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCSession.h"
#import "SAMCMessage.h"
#import "SAMCDBBase.h"

@interface SAMCMessageDB : SAMCDBBase

// messages should belong to the same session
- (void)insertMessages:(NSArray<SAMCMessage *> *)messages
           sessionMode:(SAMCUserModeType)sessionMode
                unread:(BOOL)unreadFlag;

- (NSArray<SAMCSession *> *)allCustomSessions;
- (NSArray<SAMCSession *> *)allSPSessions;

@end
