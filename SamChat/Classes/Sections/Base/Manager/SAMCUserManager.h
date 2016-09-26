//
//  SAMCUserManager.h
//  SamChat
//
//  Created by HJ on 9/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMCUserManager : NSObject

+ (instancetype)sharedManager;

- (void)queryFuzzyUserWithKey:(NSString * __nullable)key
                   completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion;

- (void)queryAccurateUser:(NSNumber *)uniqueId
               completion:(void (^)(NSDictionary * __nullable userDict, NSError * __nullable error))completion;

- (void)fetchUserInfos:(NSArray<NSString *> *)userIds
            completion:(void (^)(NSArray<SAMCUser *> * __nullable users, NSError * __nullable error))completion;

- (void)addOrRemove:(BOOL)isAdd
            contact:(SAMCUser *)user
               type:(SAMCContactListType)type
         completion:(void (^)(NSError * __nullable error))completion;

- (void)updateAvatar:(NSString *)url
          completion:(void (^)(SAMCUser * __nullable user, NSError * __nullable error))completion;

- (NSArray<NSString *> *)myContactListOfType:(SAMCContactListType)listType;

- (SAMCUser *)userInfo:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
