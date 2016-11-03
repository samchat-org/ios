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

- (void)dealloc
{
}

- (void)addDelegate:(id<SAMCUserManagerDelegate>)delegate
{
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<SAMCUserManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
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
                    // TODO: do not use this updateUser, as it will trigger onUserInfoChanged:
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
    __weak typeof(self) wself = self;
    [manager POST:SAMC_URL_CONTACT_CONTACT parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                if (isAdd) {
                    [[SAMCDataBaseManager sharedManager].userInfoDB insertToContactList:user type:type];
                    [wself.multicastDelegate didAddContact:user type:type];
                } else {
                    [[SAMCDataBaseManager sharedManager].userInfoDB deleteFromContactList:user type:type];
                    [wself.multicastDelegate didRemoveContact:user type:type];
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

- (void)updateAvatar:(NSString *)url
          completion:(void (^)(SAMCUser * __nullable user, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI updateAvatar:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    __weak typeof(self) wself = self;
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
//                [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:user];
                [wself updateUser:user];
                completion(user, nil);
            }
        } else {
            completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)updateProfile:(NSDictionary *)profileDict
           completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI updateProfile:profileDict];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    __weak typeof(self) wself = self;
    [manager POST:SAMC_URL_PROFILE_PROFILE_UPDATE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                SAMCUser *user = [[SAMCDataBaseManager sharedManager].userInfoDB userInfo:[SAMCAccountManager sharedManager].currentAccount];
                user.userInfo.lastupdate = [response valueForKeyPath:SAMC_USER_LASTUPDATE];
                user.userInfo.countryCode = profileDict[SAMC_COUNTRYCODE] ?:user.userInfo.countryCode;
                user.userInfo.cellPhone = profileDict[SAMC_CELLPHONE] ?:user.userInfo.cellPhone;
                user.userInfo.email = profileDict[SAMC_EMAIL] ?:user.userInfo.email;
                user.userInfo.address = [profileDict valueForKeyPath:SAMC_LOCATION_ADDRESS] ?:user.userInfo.address;
                if (profileDict[SAMC_SAM_PROS_INFO]) {
                    NSDictionary *prosProfileDict = profileDict[SAMC_SAM_PROS_INFO];
                    user.userInfo.spInfo.companyName = prosProfileDict[SAMC_COMPANY_NAME] ?:user.userInfo.spInfo.companyName;
                    user.userInfo.spInfo.serviceCategory = prosProfileDict[SAMC_SERVICE_CATEGORY] ?:user.userInfo.spInfo.serviceCategory;
                    user.userInfo.spInfo.serviceDescription = prosProfileDict[SAMC_SERVICE_DESCRIPTION] ?:user.userInfo.spInfo.serviceDescription;
                    user.userInfo.spInfo.countryCode = prosProfileDict[SAMC_COUNTRYCODE] ?:user.userInfo.spInfo.countryCode;
                    user.userInfo.spInfo.phone = prosProfileDict[SAMC_PHONE] ?:user.userInfo.spInfo.phone;
                    user.userInfo.spInfo.email = prosProfileDict[SAMC_EMAIL] ?:user.userInfo.spInfo.email;
                    user.userInfo.spInfo.address = [prosProfileDict valueForKeyPath:SAMC_LOCATION_ADDRESS] ? :user.userInfo.spInfo.address;
                }
                [wself updateUser:user];
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

- (void)editCellPhoneCodeRequestWithCountryCode:(NSString *)countryCode
                                      cellPhone:(NSString *)cellPhone
                                     completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI editCellPhoneCodeRequestWithCountryCode:countryCode cellPhone:cellPhone];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_EDITCELLPHONE_CODER_EQUEST parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    return [[SAMCDataBaseManager sharedManager].userInfoDB isUser:userId inMyContactListOfType:SAMCContactListTypeServicer];
}

- (BOOL)isMyCustomer:(NSString *)userId
{
    return [[SAMCDataBaseManager sharedManager].userInfoDB isUser:userId inMyContactListOfType:SAMCContactListTypeCustomer];
}

- (SAMCUser *)userInfo:(NSString *)userId
{
    return [[SAMCDataBaseManager sharedManager].userInfoDB userInfo:userId];
}

- (void)updateUser:(SAMCUser *)user
{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].userInfoDB updateUser:user];
        [wself.multicastDelegate onUserInfoChanged:[wself userInfo:user.userId]];
    });
}

@end
