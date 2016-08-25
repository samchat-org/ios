//
//  SAMCQuestionManager.m
//  SamChat
//
//  Created by HJ on 8/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQuestionManager.h"
#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCDataBaseManager.h"

@implementation SAMCQuestionManager

+ (instancetype)sharedManager
{
    static SAMCQuestionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCQuestionManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)addDelegate:(id<SAMCQuestionManagerDelegate>)delegate
{
    [[SAMCDataBaseManager sharedManager].questionDB addQuestionDelegate:delegate];
}

- (void)removeDelegate:(id<SAMCQuestionManagerDelegate>)delegate
{
    [[SAMCDataBaseManager sharedManager].questionDB removeQuestionDelegate:delegate];
}

- (NSArray<SAMCQuestionSession *> *)allSendQuestion
{
    return [[SAMCDataBaseManager sharedManager].questionDB allSendQuestion];
}

- (NSArray<SAMCQuestionSession *> *)allReceivedQuestion
{
    return [[SAMCDataBaseManager sharedManager].questionDB allReceivedQuestion];
}

- (void)sendQuestion:(NSString *)question
            location:(NSDictionary *)location
          completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI sendQuestion:question location:location];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_QUESTION_QUESTION parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                NSDictionary *questionInfo = [[NSMutableDictionary alloc] initWithDictionary:parameters[SAMC_BODY]];
                [questionInfo setValue:response[SAMC_QUESTION_ID] forKey:SAMC_QUESTION_ID];
                [questionInfo setValue:response[SAMC_DATETIME] forKey:SAMC_DATETIME];
                [self insertSendQuestion:questionInfo];
                completion(nil);
            }
        } else {
            completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

#pragma mark - QuestionDB
- (void)insertSendQuestion:(NSDictionary *)questionInfo
{
    if ((questionInfo == nil) || (![questionInfo isKindOfClass:[NSDictionary class]])) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].questionDB insertSendQuestion:questionInfo];
    });
}

- (void)insertReceivedQuestion:(NSDictionary *)questionInfo
{
    if ((questionInfo == nil) || (![questionInfo isKindOfClass:[NSDictionary class]])) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].questionDB insertReceivedQuestion:questionInfo];
    });
}

@end
