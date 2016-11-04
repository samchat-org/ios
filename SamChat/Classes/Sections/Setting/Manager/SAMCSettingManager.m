//
//  SAMCSettingManager.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingManager.h"
#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCAccountManager.h"
#import "SAMCUserManager.h"
#import "SAMCDataBaseManager.h"
#import "SAMCUserManager.h"

@implementation SAMCSettingManager

+ (instancetype)sharedManager
{
    static SAMCSettingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCSettingManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)createSamPros:(NSDictionary *)info
           completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI createSamPros:info];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_CREATE_SAM_PROS parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                DDLogDebug(@"createSamPros response:%@", response);
                NSDictionary *userInfo = response[SAMC_USER];
                SAMCUser *user = [SAMCUser userFromDict:userInfo];
                [[SAMCUserManager sharedManager] updateUser:user];
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
                [[SAMCUserManager sharedManager] updateUser:user];
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
                [[SAMCUserManager sharedManager] updateUser:user];
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
    [manager POST:SAMC_URL_PROFILE_EDITCELLPHONE_CODER_EQUEST parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)editCellPhoneUpdateWithCountryCode:(NSString *)countryCode
                                 cellPhone:(NSString *)cellPhone
                                verifyCode:(NSString *)verifyCode
                                completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI editCellPhoneUpdateWithCountryCode:countryCode cellPhone:cellPhone verifyCode:verifyCode];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_PROFILE_EDITCELLPHONE_UPDATE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                SAMCUser *user = [[SAMCDataBaseManager sharedManager].userInfoDB userInfo:[SAMCAccountManager sharedManager].currentAccount];
                user.userInfo.countryCode = countryCode;
                user.userInfo.cellPhone = cellPhone;
                user.userInfo.lastupdate = [response valueForKeyPath:SAMC_USER_LASTUPDATE];
                [[SAMCUserManager sharedManager] updateUser:user];
                completion(nil);
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)updatePWDFrom:(NSString *)currentPWD
                   to:(NSString *)changePWD
           completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI updatePWDFrom:currentPWD to:changePWD];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_PWD_UPDATE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

@end
