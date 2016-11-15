//
//  SAMCAccountManager.m
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAccountManager.h"

#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"
#import "AFNetworking.h"
#import "NIMLoginManagerProtocol.h"
#import "GCDMulticastDelegate.h"
#import "SAMCDeviceUtil.h"
#import "NTESLoginManager.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCDataBaseManager.h"
#import "NTESService.h"
#import "SAMCChatManager.h"
#import "SAMCPublicManager.h"
#import "SAMCUserManager.h"
#import "SAMCUnreadCountManager.h"
#import "SAMCSyncManager.h"
#import "SAMCPreferenceManager.h"

@interface SAMCAccountManager () <NIMLoginManagerDelegate, SAMCUserManagerDelegate>

@property (nonatomic, strong) GCDMulticastDelegate<SAMCLoginManagerDelegate> *multicastDelegate;

@end

@implementation SAMCAccountManager

+ (instancetype)sharedManager
{
    static SAMCAccountManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCAccountManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
}

- (void)registerCodeRequestWithCountryCode:(NSString *)countryCode
                                 cellPhone:(NSString *)cellPhone
                                completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI registerCodeRequestWithCountryCode:countryCode
                                                                       cellPhone:cellPhone];
    [self codeRequest:SAMC_URL_REGISTER_CODE_REQUEST parameters:parameters completion:completion];
}

- (void)findPWDCodeRequestWithCountryCode:(NSString *)countryCode
                                cellPhone:(NSString *)cellPhone
                               completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *paramters = [SAMCServerAPI findPWDCodeRequestWithCountryCode:countryCode cellPhone:cellPhone];
    [self codeRequest:SAMC_URL_USER_FIND_PWD_CODE_REQUEST parameters:paramters completion:completion];
}

- (void)registerCodeVerifyWithCountryCode:(NSString *)countryCode
                                cellPhone:(NSString *)cellPhone
                               verifyCode:(NSString *)verifyCode
                               completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI registerCodeVerifyWithCountryCode:countryCode
                                                                      cellPhone:cellPhone
                                                                     verifyCode:verifyCode];
    [self codeVerify:SAMC_URL_SIGNUP_CODE_VERIFY parameters:parameters completion:completion];
}

- (void)findPWDCodeVerifyWithCountryCode:(NSString *)countryCode
                               cellPhone:(NSString *)cellPhone
                              verifyCode:(NSString *)verifyCode
                              completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI findPWDCodeVerifyWithCountryCode:countryCode
                                                                     cellPhone:cellPhone
                                                                    verifyCode:verifyCode];
    [self codeVerify:SAMC_URL_USER_FIND_PWD_CODE_VERIFY parameters:parameters completion:completion];
}

- (void)registerWithCountryCode:(NSString *)countryCode
                      cellPhone:(NSString *)cellPhone
                     verifyCode:(NSString *)verifyCode
                       username:(NSString *)username
                       password:(NSString *)password
                     completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *paramters = [SAMCServerAPI registerWithCountryCode:countryCode
                                                           cellPhone:cellPhone
                                                          verifyCode:verifyCode
                                                            username:username
                                                            password:password];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_REGISTER parameters:paramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSString *token = response[SAMC_TOKEN];
                NSDictionary *userInfo = response[SAMC_USER];
                SAMCUser *user = [[SAMCUser alloc] init];
                user.userId = [userInfo[SAMC_ID] stringValue];
                SAMCUserInfo *info = [[SAMCUserInfo alloc] init];
                info.countryCode = countryCode;
                info.usertype = @(SAMCUserTypeCustom);
                info.cellPhone = cellPhone;
                info.username = username;
                info.lastupdate = userInfo[SAMC_LASTUPDATE];
                user.userInfo = info;
                [self loginNetEase:user token:token completion:completion];
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)findPWDUpdateWithCountryCode:(NSString *)countryCode
                           cellPhone:(NSString *)cellPhone
                          verifyCode:(NSString *)verifyCode
                            password:(NSString *)password
                          completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *paramters = [SAMCServerAPI findPWDUpdateWithCountryCode:countryCode
                                                                cellPhone:cellPhone
                                                               verifyCode:verifyCode
                                                                 password:password];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_FIND_PWD_UPDATE parameters:paramters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)loginWithCountryCode:(NSString *)countryCode
                     account:(NSString *)account
                    password:(NSString *)password
                  completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    
    DDLogDebug(SAMC_URL_USER_LOGIN);
    NSDictionary *parameters = [SAMCServerAPI loginWithCountryCode:countryCode account:account password:password];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_USER_LOGIN parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSString *token = response[SAMC_TOKEN];
                NSDictionary *userInfo = response[SAMC_USER];
                [SAMCPreferenceManager sharedManager].needQuestionNotify = [userInfo valueForKeyPath:SAMC_MY_SETTINGS_QUESTION_NOTIFY];
                SAMCUser *user = [SAMCUser userFromDict:userInfo];
                [self loginNetEase:user token:token completion:completion];
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)loginNetEase:(SAMCUser *)user
               token:(NSString *)token
          completion:(void (^)(NSError *error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    LoginData *sdkData = [[LoginData alloc] init];
    sdkData.username = user.userInfo.username;
    // netease account is the id of samchat
    sdkData.account = user.userId;
    sdkData.token = token;
    [[[NIMSDK sharedSDK] loginManager] login:sdkData.account token:[sdkData finalToken] completion:^(NSError *error) {
        if (error == nil) {
            [[NTESLoginManager sharedManager] setCurrentLoginData:sdkData];
            [[NTESServiceManager sharedManager] start];
            [[SAMCDataBaseManager sharedManager] open];
            if ([[SAMCDataBaseManager sharedManager] needsMigration]) {
                [[SAMCDataBaseManager sharedManager] doMigration];
            }
            [[SAMCUserManager sharedManager] reset];
            [SAMCChatManager sharedManager];
            [[SAMCUserManager sharedManager] updateUser:user];
            [[SAMCSyncManager sharedManager] start];
            [[SAMCUnreadCountManager sharedManager] start];
            completion(nil);
        }else{
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorNetEaseLoginFailed]);
        }
    }];
}

- (void)logout:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    LoginData *loginData = [[NTESLoginManager sharedManager] currentLoginData];
    NSDictionary *paramers = [SAMCServerAPI logout:loginData.username];
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [SAMCDataPostSerializer serializer];
        
        extern NSString *NTESNotificationLogout;
        [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
        
        [manager POST:SAMC_URL_USER_LOGOUT parameters:paramers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                DDLogDebug(@"Logout: %@", responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DDLogDebug(@"Logout Error: %@", error);
        }];
//        [[NTESLoginManager sharedManager] setCurrentLoginData:nil];
//      [[SAMCUserProfileManager sharedManager] setCurrentLoginData:nil];
        completion(nil);
    }];
}

- (void)autoLogin:(LoginData *)loginData
{
    [[NTESServiceManager sharedManager] start];
    [[SAMCDataBaseManager sharedManager] open];
    if ([[SAMCDataBaseManager sharedManager] needsMigration]) {
        [[SAMCDataBaseManager sharedManager] doMigration];
    }
    [SAMCChatManager sharedManager];
    [[SAMCSyncManager sharedManager] start];
    [[SAMCUnreadCountManager sharedManager] start];
    [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData.account token:[loginData finalToken]];
}

- (void)kickOtherClient:(NIMLoginClient *)client
             completion:(NIMLoginHandler)completion
{
    [[[NIMSDK sharedSDK] loginManager] kickOtherClient:client
                                            completion:completion];
}

- (NSString *)currentAccount
{
    // 自动登录的时候，未登录云信时，就需要检查数据库是否需要升级
    // 未登录云信时不能使用云信sdk的loginManager.currentAccount
    return [[[NTESLoginManager sharedManager] currentLoginData] account];
}

- (SAMCUser *)currentUser
{
    return [[SAMCUserManager sharedManager] userInfo:[self currentAccount]];
}

- (BOOL)isCurrentUserServicer
{
    return [[self currentUser].userInfo.usertype isEqual:@(SAMCuserTypeSamPros)];
}

- (BOOL)isLogined
{
    return [[[NIMSDK sharedSDK] loginManager] isLogined];
}

- (NSArray *)currentLoginClients
{
    return [[[NIMSDK sharedSDK] loginManager] currentLoginClients];
}

- (void)addDelegate:(id<SAMCLoginManagerDelegate>)delegate
{
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<SAMCLoginManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - NIMLoginManagerDelegate
- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType
{
    [self.multicastDelegate onKick:code clientType:clientType];
}

- (void)onLogin:(NIMLoginStep)step
{
    [self.multicastDelegate onLogin:step];
}

- (void)onAutoLoginFailed:(NSError *)error
{
    [self.multicastDelegate onAutoLoginFailed:error];
}

- (void)onMultiLoginClientsChanged
{
    [self.multicastDelegate onMultiLoginClientsChanged];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCLoginManagerDelegate> *)multicastDelegate
{
    if (_multicastDelegate == nil) {
        _multicastDelegate = (GCDMulticastDelegate <SAMCLoginManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _multicastDelegate;
}

#pragma mark - Private
- (void)codeRequest:(NSString *)url
         parameters:(id)parameters
         completion:(void (^)(NSError * __nullable error))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)codeVerify:(NSString *)url
        parameters:(id)parameters
        completion:(void (^)(NSError * __nullable error))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
