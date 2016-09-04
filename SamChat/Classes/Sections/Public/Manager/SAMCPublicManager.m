//
//  SAMCPublicManager.m
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicManager.h"
#import "SAMCServerAPI.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCDataBaseManager.h"
#import "SAMCPreferenceManager.h"

@implementation SAMCPublicManager

+ (instancetype)sharedManager
{
    static SAMCPublicManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCPublicManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc
{
}

- (void)addDelegate:(id<SAMCPublicManagerDelegate>)delegate
{
    [[SAMCDataBaseManager sharedManager].publicDB addPublicDelegate:delegate];
}

- (void)removeDelegate:(id<SAMCPublicManagerDelegate>)delegate
{
    [[SAMCDataBaseManager sharedManager].publicDB removePublicDelegate:delegate];
}

- (void)searchPublicWithKey:(NSString * __nullable)key
                   location:(NSDictionary * __nullable)location
                 completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryPublicWithKey:key location:location];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_OFFICIALACCOUNT_PUBLIC_QUERY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(nil, [SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                completion(response[SAMC_USERS], nil);
            }
        } else {
            completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
    
}

- (void)follow:(BOOL)isFollow
officialAccount:(SAMCSPBasicInfo *)userInfo
    completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI follow:isFollow officialAccount:@(userInfo.uniqueId)];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    __weak typeof(self) wself = self;
    [manager POST:SAMC_URL_OFFICIALACCOUNT_FOLLOW parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                DDLogDebug(@"follow response: %@", response);
                if (isFollow) {
                    [wself insertToFollowList:userInfo];
                } else {
                    [wself deleteFromFollowList:userInfo];
                }
                completion(nil);
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)queryFollowListIfNecessary
{
    if ([[SAMCPreferenceManager sharedManager].followListSyncFlag isEqual:@(YES)]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self queryFollowList];
    });
}

- (NSArray<SAMCPublicSession *> *)myFollowList
{
    return [[SAMCDataBaseManager sharedManager].publicDB myFollowList];
}

- (void)insertToFollowList:(SAMCSPBasicInfo *)userInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB insertToFollowList:userInfo];
    });
}

- (void)deleteFromFollowList:(SAMCSPBasicInfo *)userInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB deleteFromFollowList:userInfo];
    });
}

- (void)fetchMessagesInSession:(SAMCPublicSession *)session
                       message:(SAMCPublicMessage * __nullable)message
                         limit:(NSInteger)limit
                        result:(void(^)(NSError *error, NSArray<SAMCPublicMessage *> *messages))handler
{
    // TODO: change to async dispatch ?
    NSArray<SAMCPublicMessage *> *messages = [[SAMCDataBaseManager sharedManager].publicDB messagesInSession:session
                                                                                                     message:message
                                                                                                       limit:limit];
    handler(nil, messages);
}


#pragma mark - Server
- (void)sendPublicMessage:(SAMCPublicMessage *)message error:(NSError * __nullable *)error
{
    // TODO: handle text message now, image later
    error = nil;
    [[SAMCDataBaseManager sharedManager].publicDB insertMessage:message];
    NSDictionary *parameters = [SAMCServerAPI writeAdvertisementType:message.messageType content:message.text];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_ADVERTISEMENT_ADVERTISEMENT_WRITE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode == 0) {
                NSInteger serverId = [((NSNumber *)response[SAMC_ADV_ID]) integerValue];
                NSInteger timestamp = [((NSNumber *)response[SAMC_PUBLISH_TIMESTAMP]) integerValue]/1000; // seconds
                [[SAMCDataBaseManager sharedManager].publicDB updateMessage:message
                                                              deliveryState:NIMMessageDeliveryStateDeliveried
                                                                   serverId:serverId
                                                                  timestamp:timestamp];
            } else {
                [[SAMCDataBaseManager sharedManager].publicDB updateMessage:message
                                                              deliveryState:NIMMessageDeliveryStateFailed
                                                                   serverId:message.serverId
                                                                  timestamp:message.timestamp];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"sendPublicMessage failed: %@", error);
        [[SAMCDataBaseManager sharedManager].publicDB updateMessage:message
                                                      deliveryState:NIMMessageDeliveryStateFailed
                                                           serverId:message.serverId
                                                          timestamp:message.timestamp];
    }];
}

#pragma mark - Private
- (void)queryFollowList
{
    NSDictionary *parameters = [SAMCServerAPI queryFollowList];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_OFFICIALACCOUNT_FOLLOW_LIST_QUERY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode == 0) {
                NSArray *users = response[SAMC_USERS];
                if ((users != nil) && ([users isKindOfClass:[NSArray class]])) {
                    BOOL result = [[SAMCDataBaseManager sharedManager].publicDB updateFollowList:users];
                    if (result) {
                        [SAMCPreferenceManager sharedManager].followListSyncFlag = @(YES);
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // TODO: check Reachability and retry
    }];
}

@end
