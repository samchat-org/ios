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


@interface SAMCAccountManager () <NIMLoginManagerDelegate>

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
    NSString *urlStr = [SAMCServerAPI urlRegisterCodeRequestWithCountryCode:countryCode
                                                                  cellPhone:cellPhone];
    DDLogDebug(@"%@",urlStr);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)registerCodeVerifyWithCountryCode:(NSString *)countryCode
                                cellPhone:(NSString *)cellPhone
                               verifyCode:(NSString *)verifyCode
                               completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSString *urlStr = [SAMCServerAPI urlRegisterCodeVerifyWithCountryCode:countryCode
                                                                 cellPhone:cellPhone
                                                                verifyCode:verifyCode];
    DDLogDebug(@"%@",urlStr);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)registerWithCountryCode:(NSString *)countryCode
                      cellPhone:(NSString *)cellPhone
                     verifyCode:(NSString *)verifyCode
                       username:(NSString *)username
                       password:(NSString *)password
                     completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSString *urlStr = [SAMCServerAPI registerWithCountryCode:countryCode
                                                    cellPhone:cellPhone
                                                   verifyCode:verifyCode
                                                     username:username
                                                     password:password];
    DDLogDebug(@"%@",urlStr);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    NSString *urlStr = [SAMCServerAPI loginWithCountryCode:countryCode
                                                   account:account
                                                  password:password];
    DDLogDebug(@"%@",urlStr);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSString *token = response[SAMC_TOKEN];
                NSDictionary *userInfo = response[SAMC_USER];
                NSString *username = userInfo[SAMC_USERNAME];
                NSString *userId = [NSString stringWithFormat:@"%@",userInfo[SAMC_ID]];
                [self loginNetEaseUsername:username userId:userId token:token completion:completion];
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

//- (void)login:(NSString *)account
//     password:(NSString *)password
//   completion:(void (^)(NSError *error))completion
//{
//    NSAssert(completion != nil, @"completion block should not be nil");
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[SAMCSkyWorldAPI urlLoginWithUsername:account passWord:@"pass00002"] // TODO: change to password
//      parameters:nil progress:^(NSProgress *downloadProgress) {
//      } success:^(NSURLSessionDataTask *task, id responseObject) {
//          if([responseObject isKindOfClass:[NSDictionary class]]){
//              NSDictionary *response = responseObject;
//              NSInteger errorCode = [(NSNumber *)response[SKYWORLD_RET] integerValue];
//              if(errorCode){
//                  completion([SAMCSkyWorldErrorHelper errorWithCode:errorCode]);
//              }else{
//                  DDLogDebug(@"login: %@", response);
//                  [self loginNetEase:account
//                               token:password // TODO:change to token
//                          completion:completion];
//#warning 11111111111111111111111111111
//                  //SCUserProfileManager *userProfileManager = [SCUserProfileManager sharedInstance];
//                  //[userProfileManager saveCurrentLoginUserInformationWithSkyWorldResponse:response
//                  //   andOtherInfo:@{SKYWORLD_PWD:password}];
//                  //[SAMCAccountManager loginEaseMobWithUsername:username password:password completion:completion];
//              }
//          }else{
//              completion([SAMCSkyWorldErrorHelper errorWithCode:SCSkyWorldErrorUnknowError]);
//          }
//      } failure:^(NSURLSessionDataTask *task, NSError *error) {
//          completion([SAMCSkyWorldErrorHelper errorWithCode:SCSkyWorldErrorServerNotReachable]);
//      }];
//}
//
//- (void)autoLogin:(NSString *)account
//            token:(NSString *)token
//{
//    //TODO: add skyworld autologin
//    [[[NIMSDK sharedSDK] loginManager] autoLogin:account
//                                           token:token];
//}
//
//- (void)logout:(void (^)(NSError *error))completion
//{
//    NSAssert(completion != nil, @"completion block should not be nil");
//    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
//        extern NSString *NTESNotificationLogout;
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        [manager GET:[SAMCSkyWorldAPI urlLogout]
//          parameters:nil progress:^(NSProgress *downloadProgress){
//          } success:^(NSURLSessionDataTask *task, id responseObject){
//              if([responseObject isKindOfClass:[NSDictionary class]]) {
//                  DDLogDebug(@"%@", responseObject);
//              }
//          } failure:^(NSURLSessionDataTask *task, NSError *error){
//              DDLogDebug(@"Logout Error: %@", error);
//          }];
//        [[SAMCUserProfileManager sharedManager] setCurrentLoginData:nil];
//        completion(nil);
//    }];
//}


- (void)kickOtherClient:(NIMLoginClient *)client
             completion:(NIMLoginHandler)completion
{
    [[[NIMSDK sharedSDK] loginManager] kickOtherClient:client
                                            completion:completion];
}

- (NSString *)currentAccount
{
    return [[[NIMSDK sharedSDK] loginManager] currentAccount];
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

#pragma mark - private
// netease account is the id of samchat
- (void)loginNetEaseUsername:(NSString *)username
                      userId:(NSString *)userId
                       token:(NSString *)token
                  completion:(void (^)(NSError *error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    LoginData *sdkData = [[LoginData alloc] init];
    sdkData.username = username;
    sdkData.account = userId;
    sdkData.token = token;
    [[[NIMSDK sharedSDK] loginManager] login:sdkData.account token:[sdkData nimToken] completion:^(NSError *error) {
       if (error == nil) {
//        [[SAMCUserProfileManager sharedManager] setCurrentLoginData:sdkData];
           [[NTESLoginManager sharedManager] setCurrentLoginData:sdkData];
           completion(nil);
       }else{
           completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
       }
   }];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCLoginManagerDelegate> *)multicastDelegate
{
    if (_multicastDelegate == nil) {
        _multicastDelegate = (GCDMulticastDelegate <SAMCLoginManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _multicastDelegate;
}

@end
