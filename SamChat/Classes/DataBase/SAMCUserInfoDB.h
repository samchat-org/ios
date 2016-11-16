//
//  SAMCUserInfoDB.h
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "SAMCPublicSession.h"
#import "SAMCUserManagerDelegate.h"
#import "SAMCUser.h"

@interface SAMCUserInfoDB : SAMCDBBase

- (void)addDelegate:(id<SAMCUserManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCUserManagerDelegate>)delegate;

- (SAMCUser *)userInfo:(NSString *)userId;

- (void)updateUser:(SAMCUser *)user;

- (BOOL)updateContactList:(NSArray *)users type:(SAMCContactListType)listType;

- (void)insertToContactList:(SAMCUser *)user type:(SAMCContactListType)listType;

- (void)deleteFromContactList:(SAMCUser *)user type:(SAMCContactListType)listType;

- (NSArray<NSString *> *)myContactListOfType:(SAMCContactListType)listType;

- (NSString *)localContactListVersionOfType:(SAMCContactListType)listType;

- (void)updateLocalContactListVersion:(NSString *)version type:(SAMCContactListType)listType;

@end
