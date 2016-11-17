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
#import "SAMCServerErrorHelper.h"
#import "SAMCPreferenceManager.h"
#import "SAMCDataBaseManager.h"
#import "SAMCAccountManager.h"
#import "GCDMulticastDelegate.h"
#import "SAMCSyncManager.h"

@interface SAMCUserManager ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCUserManagerDelegate> *multicastDelegate;

@end

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
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)addDelegate:(id<SAMCUserManagerDelegate>)delegate
{
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
    [[SAMCDataBaseManager sharedManager].userInfoDB addDelegate:delegate];
}

- (void)removeDelegate:(id<SAMCUserManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
    [[SAMCDataBaseManager sharedManager].userInfoDB removeDelegate:delegate];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCUserManagerDelegate> *)multicastDelegate
{
    if (_multicastDelegate == nil) {
        _multicastDelegate = (GCDMulticastDelegate <SAMCUserManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _multicastDelegate;
}

#pragma mark -
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

- (void)queryAccurateUser:(id)key
                     type:(SAMCQueryAccurateUserType)type
               completion:(void (^)(NSDictionary * __nullable userDict, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryAccurateUser:key type:type];
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
                    // not updateUser here, update according action
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
                    // directly store to db, not trigger onUserInfoChanged:
                    // SAMCDataManager will notfiyUserInfoChanged once a batch
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
                if (isAdd) {
                    [[SAMCDataBaseManager sharedManager].userInfoDB insertToContactList:user type:type];
                } else {
                    [[SAMCDataBaseManager sharedManager].userInfoDB deleteFromContactList:user type:type];
                }
                NSDictionary *stateDate = response[SAMC_STATE_DATE];
                if ([stateDate isKindOfClass:[NSDictionary class]]) {
                    [[SAMCSyncManager sharedManager] updateLocalContactListVersionFrom:stateDate[SAMC_PREVIOUS]
                                                                                    to:stateDate[SAMC_LAST]
                                                                                  type:type];
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

- (void)sendInviteMsg:(NSArray<SAMCPhone *> *)phones
           completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSMutableArray *phonesDictArray = [[NSMutableArray alloc] init];
    for (SAMCPhone *phone in phones) {
        [phonesDictArray addObject:[phone toServerDictionary]];
    }
    NSDictionary *parameters = [SAMCServerAPI sendInviteMsg:phonesDictArray];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_COMMON_SEND_INVITE_MSG parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                completion(nil);
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

#pragma mark -
- (NSArray<NSString *> *)myContactListOfType:(SAMCContactListType)listType
{
    return [[SAMCDataBaseManager sharedManager].userInfoDB myContactListOfType:listType];
}

- (BOOL)isMyProvider:(NSString *)userId
{
    return [[[SAMCDataBaseManager sharedManager].userInfoDB myContactListOfType:SAMCContactListTypeServicer] containsObject:userId];
}

- (BOOL)isMyCustomer:(NSString *)userId
{
    return [[[SAMCDataBaseManager sharedManager].userInfoDB myContactListOfType:SAMCContactListTypeCustomer] containsObject:userId];
}

- (SAMCUser *)userInfo:(NSString *)userId
{
    if ([userId length]) {
        return [[SAMCDataBaseManager sharedManager].userInfoDB userInfo:userId];
    } else {
        return nil;
    }
}

- (void)updateUser:(SAMCUser *)user
{
    if (user) {
        [self.multicastDelegate onUserInfoChanged:[self userInfo:user.userId]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:user];
        });
    }
}

@end
