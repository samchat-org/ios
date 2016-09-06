//
//  SAMCContactManager.h
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMCContactManager : NSObject

+ (instancetype)sharedManager;

- (void)queryFuzzyUserWithKey:(NSString * __nullable)key
                   completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion;

- (void)queryAccurateUser:(NSNumber *)uniqueId
               completion:(void (^)(NSDictionary * __nullable userDict, NSError * __nullable error))completion;

- (void)addOrRemove:(BOOL)isAdd
            contact:(SAMCUser *)user
               type:(SAMCContactListType)type
         completion:(void (^)(NSError * __nullable error))completion;

- (void)queryContactListIfNecessary;

- (NSArray *)myContactListOfType:(SAMCContactListType)listType;

@end

NS_ASSUME_NONNULL_END
