//
//  SAMCPublicDB.h
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "SAMCPublicManagerDelegate.h"
#import "SAMCSPBasicInfo.h"

@interface SAMCPublicDB : SAMCDBBase

- (void)addPublicDelegate:(id<SAMCPublicManagerDelegate>)delegate;
- (void)removePublicDelegate:(id<SAMCPublicManagerDelegate>)delegate;

- (BOOL)updateFollowList:(NSArray *)users;

- (NSArray<SAMCPublicSession *> *)myFollowList;

- (void)insertToFollowList:(SAMCSPBasicInfo *)userInfo;
- (void)deleteFromFollowList:(SAMCSPBasicInfo *)userInfo;

@end
