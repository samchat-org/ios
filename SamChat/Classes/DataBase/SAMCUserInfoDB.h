//
//  SAMCUserInfoDB.h
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "SAMCPublicSession.h"

@interface SAMCUserInfoDB : SAMCDBBase

- (void)updateUser:(NSDictionary *)userInfo;

- (BOOL)updateFollowList:(NSArray *)users;

- (NSArray<SAMCPublicSession *> *)myFollowList;

@end
