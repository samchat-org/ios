//
//  SAMCPublicManager.h
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCPublicSession.h"
#import "SAMCSPBasicInfo.h"
#import "SAMCPublicManagerDelegate.h"
#import "SAMCPublicMessage.h"

NS_ASSUME_NONNULL_BEGIN
@interface SAMCPublicManager : NSObject

+ (instancetype)sharedManager;

- (void)addDelegate:(id<SAMCPublicManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCPublicManagerDelegate>)delegate;

- (void)searchPublicWithKey:(NSString * __nullable)key
                   location:(NSDictionary * __nullable)location
                 completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion;

- (void)follow:(BOOL)isFollow
officialAccount:(SAMCSPBasicInfo *)userInfo
    completion:(void (^)(NSError * __nullable error))completion;

- (void)queryFollowListIfNecessary;

- (NSArray<SAMCPublicSession *> *)myFollowList;

- (void)fetchMessagesInSession:(SAMCPublicSession *)session
                       message:(SAMCPublicMessage * __nullable)message
                         limit:(NSInteger)limit
                        result:(void(^)(NSError *error, NSArray<SAMCPublicMessage *> *messages))handler;

- (void)receivePublicMessage:(SAMCPublicMessage *)message;

- (void)sendPublicMessage:(SAMCPublicMessage *)message error:(NSError * __nullable *)error;

@end
NS_ASSUME_NONNULL_END