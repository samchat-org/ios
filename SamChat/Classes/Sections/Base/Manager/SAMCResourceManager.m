//
//  SAMCResourceManager.m
//  SamChat
//
//  Created by HJ on 9/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCResourceManager.h"
#import <AWSS3/AWSS3.h>
#import "SAMCServerAPIMacro.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"

@implementation SAMCResourceManager

+ (instancetype)sharedManager
{
    static SAMCResourceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCResourceManager alloc] init];
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

- (void)upload:(NSString *)filepath
           key:(NSString *)key
   contentType:(NSString *)contentType
      progress:(void(^)(CGFloat progress))progressBlock
    completion:(void(^)(NSString *urlString, NSError *error))completionBlock
{
    
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(progress.fractionCompleted);
            }
        });
    };
    
    AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                DDLogDebug(@"update image error:%@", error);
                if (completionBlock) {
                    completionBlock(nil, error);
                }
            } else {
                if (completionBlock) {
                    NSString *urlString = [NSString stringWithFormat:@"%@%@",SAMC_AWSS3_URLPREFIX,key];
                    completionBlock(urlString, nil);
                }
            }
        });
    };
    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    NSURL *fileUrl = [NSURL fileURLWithPath:filepath];
    [[transferUtility uploadFile:fileUrl bucket:SAMC_AWSS3_BUCKETNAME key:key contentType:contentType expression:expression completionHander:completionHandler] continueWithBlock:^id (AWSTask * task) {
        if (task.error || task.exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(nil, task.error);
                }
            });
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock) {
                    progressBlock(0.f);
                }
            });
        }
        return nil;
    }];
}

- (void)getPlacesInfo:(NSString *)key
           completion:(void(^)(NSArray<SAMCPlaceInfo *> *places, NSError *error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI getPlacesInfo:key];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_PROFILE_GET_PLACESINFO parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(nil, [SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSArray *placesDictArray = response[SAMC_PLACES_INFO];
                NSMutableArray *places = [[NSMutableArray alloc] init];
                for (NSDictionary *placeDict in placesDictArray) {
                    SAMCPlaceInfo *placeInfo = [SAMCPlaceInfo placeInfoFromDict:placeDict];
                    if (placeInfo) {
                        [places addObject:placeInfo];
                    }
                }
                completion(places, nil);
            }
        } else {
            completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

@end
