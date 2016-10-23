//
//  SAMCUserManager.m
//  SamChat
//
//  Created by HJ on 9/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserManager.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCPreferenceManager.h"
#import "SAMCDataBaseManager.h"
#import "SAMCAccountManager.h"

@implementation SAMCUserManager

+ (instancetype)sharedManager
{
    static SAMCUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCUserManager alloc] init];
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

- (void)checkExistOfUser:(NSString *)username
              completion:(void (^)(BOOL isExists, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryWithoutToken:username];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_QUERYWITHOUTTOKEN parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(NO, [SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSInteger count = [((NSNumber *)response[SAMC_COUNT]) integerValue];
                completion(count, nil);
            }
        } else {
            completion(NO, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(NO, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)queryFuzzyUserWithKey:(NSString * __nullable)key
                   completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryFuzzyUser:key];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_QUERYFUZZY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)queryAccurateUser:(NSNumber *)uniqueId
               completion:(void (^)(NSDictionary * __nullable userDict, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryAccurateUser:uniqueId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_QUERYACCURATE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(nil, [SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSInteger count = [((NSNumber *)response[SAMC_COUNT]) integerValue];
                if (count <= 0) {
                    completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUserNotExists]);
                } else {
                    completion(response[SAMC_USERS][0], nil);
                }
            }
        } else {
            completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)fetchUserInfos:(NSArray<NSString *> *)userIds
            completion:(void (^)(NSArray<SAMCUser *> * __nullable users, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryUsers:userIds];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_QUERYGROUP parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(nil, [SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSMutableArray *users = [[NSMutableArray alloc] init];
                for (NSDictionary *userDict in response[SAMC_USERS]) {
                    SAMCUser *user = [SAMCUser userFromDict:userDict];
                    [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:user];
                    [users addObject:user];
                }
                completion(users, nil);
            }
        } else {
            completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)addOrRemove:(BOOL)isAdd
            contact:(SAMCUser *)user
               type:(SAMCContactListType)type
         completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI addOrRemove:isAdd contact:user.userId type:type];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_CONTACT_CONTACT parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                completion(nil);
                [[SAMCDataBaseManager sharedManager].userInfoDB insertToContactList:user type:type];
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)updateAvatar:(NSString *)url
          completion:(void (^)(SAMCUser * __nullable userDict, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI updateAvatar:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_PROFILE_AVATAR_UPDATE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(nil, [SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                SAMCUser *user = [[SAMCDataBaseManager sharedManager].userInfoDB userInfo:[SAMCAccountManager sharedManager].currentAccount];
                user.userInfo.avatar = [response valueForKeyPath:SAMC_USER_THUMB];
                user.userInfo.avatarOriginal = url;
                [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:user];
                [SAMCAccountManager sharedManager].currentUser = user;
                completion(user, nil);
            }
        } else {
            completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (NSArray<NSString *> *)myContactListOfType:(SAMCContactListType)listType
{
    return [[SAMCDataBaseManager sharedManager].userInfoDB myContactListOfType:listType];
}

- (SAMCUser *)userInfo:(NSString *)userId
{
    return [[SAMCDataBaseManager sharedManager].userInfoDB userInfo:userId];
}

- (void)updateUser:(SAMCUser *)user
{
    if ([user.userId isEqualToString:[SAMCAccountManager sharedManager].currentUser.userId]) {
        [SAMCAccountManager sharedManager].currentUser = nil;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:user];
    });
}

@end
