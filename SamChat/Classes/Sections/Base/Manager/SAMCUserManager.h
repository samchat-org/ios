//
//  SAMCUserManager.h
//  SamChat
//
//  Created by HJ on 9/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCUserManagerDelegate.h"
#import "SAMCServerAPI.h"
#import "SAMCUser.h"
#import "SAMCPhone.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMCUserManager : NSObject

+ (instancetype)sharedManager;

- (void)addDelegate:(id<SAMCUserManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCUserManagerDelegate>)delegate;

- (void)checkExistOfUser:(NSString *)username
              completion:(void (^)(BOOL isExists, NSError * __nullable error))completion;

- (void)queryFuzzyUserWithKey:(NSString * __nullable)key
                   completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion;

- (void)queryAccurateUser:(id)key
                     type:(SAMCQueryAccurateUserType)type
               completion:(void (^)(NSDictionary * __nullable userDict, NSError * __nullable error))completion;

- (void)fetchUserInfos:(NSArray<NSString *> *)userIds
            completion:(void (^)(NSArray<SAMCUser *> * __nullable users, NSError * __nullable error))completion;

- (void)addOrRemove:(BOOL)isAdd
            contact:(SAMCUser *)user
               type:(SAMCContactListType)type
         completion:(void (^)(NSError * __nullable error))completion;

- (void)sendInviteMsg:(NSArray<SAMCPhone *> *)phones
           completion:(void (^)(NSError * __nullable error))completion;

- (NSArray<NSString *> *)myContactListOfType:(SAMCContactListType)listType;
- (BOOL)isMyProvider:(NSString *)userId;
- (BOOL)isMyCustomer:(NSString *)userId;

- (SAMCUser *)userInfo:(NSString *)userId;

- (void)updateUser:(SAMCUser *)user;

@end

NS_ASSUME_NONNULL_END
