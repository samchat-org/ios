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
#import "NTESLoginManager.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCAccountManager.h"

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
                [[SAMCAccountManager sharedManager] updateUser:user];
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
