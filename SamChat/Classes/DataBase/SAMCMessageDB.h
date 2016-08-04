//
//  SAMCMessageDB.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCDBBase.h"

@class SAMCMessage;

@interface SAMCMessageDB : SAMCDBBase

- (void)insertMessages:(NSArray<SAMCMessage *> *)messages;

@end
