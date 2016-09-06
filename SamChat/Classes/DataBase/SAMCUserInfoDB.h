//
//  SAMCUserInfoDB.h
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "SAMCPublicSession.h"
#import "SAMCUserInfo.h"

@interface SAMCUserInfoDB : SAMCDBBase

- (void)updateUser:(SAMCUserInfo *)userInfo;

- (BOOL)updateContactList:(NSArray *)users type:(SAMCContactListType)listType;

- (void)insertToContactList:(SAMCUserInfo *)user type:(SAMCContactListType)listType;

- (NSArray *)myContactListOfType:(SAMCContactListType)listType;

@end
