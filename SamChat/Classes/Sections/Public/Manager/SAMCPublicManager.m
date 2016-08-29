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

- (void)searchPublicWithKey:(NSString *)key
                   location:(NSDictionary *)location
                 completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion
{
}

- (void)follow:(BOOL)isFollow
officialAccount:(NSNumber *)uniqueId
    completion:(void (^)(NSError * __nullable error))completion
{
    
    NSAssert(completion != nil, @"completion block should not be nil");
    DDLogDebug(SAMC_URL_USER_LOGIN);
    NSDictionary *parameters = [SAMCServerAPI follow:isFollow officialAccount:uniqueId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_OFFICIALACCOUNT_FOLLOW parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                DDLogDebug(@"follow response: %@", response);
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)queryFollowList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *parameters = [SAMCServerAPI queryFollowList];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [SAMCDataPostSerializer serializer];
        DDLogDebug(SAMC_URL_OFFICIALACCOUNT_FOLLOW_LIST_QUERY);
        [manager POST:SAMC_URL_OFFICIALACCOUNT_FOLLOW_LIST_QUERY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *response = responseObject;
                NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
                if (errorCode == 0) {
                    DDLogDebug(@"response:%@",response);
                    NSArray *users = response[SAMC_USERS];
                    if ((users != nil) && ([users isKindOfClass:[NSArray class]])) {
                        [[SAMCDataBaseManager sharedManager].userInfoDB updateFollowList:users];
                    }
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        }];
    });
}

@end
