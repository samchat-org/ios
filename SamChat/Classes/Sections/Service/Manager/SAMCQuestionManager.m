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

- (NSArray<NSString *> *)sendQuestionHistory
{
    return [[SAMCDataBaseManager sharedManager].questionDB sendQuestionHistory];
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

- (void)queryPopularRequest:(NSInteger)count
                 completion:(void (^)(NSArray<NSString *> * _Nullable populars))completion;
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryPopularRequest:count];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_QUESTION_QUERYPOPULARREQUEST parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(nil);
            } else {
                DDLogDebug(@"%@", response[SAMC_POPULAR_REQUEST]);
                NSMutableArray *popularsArray = [[NSMutableArray alloc] init];
                for (NSDictionary *questionDict in response[SAMC_POPULAR_REQUEST]) {
                    NSString *question = questionDict[SAMC_CONTENT];
                    if (question) {
                        [popularsArray addObject:question];
                    }
                }
                completion(popularsArray);
            }
        } else {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil);
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

- (void)clearSendQuestionNewResponseCount:(SAMCQuestionSession *)session
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].questionDB clearSendQuestionNewResponseCount:session];
    });
}

- (void)deleteSendQuestion:(SAMCQuestionSession *)session
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].questionDB deleteSendQuestion:session];
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

- (void)updateReceivedQuestion:(NSInteger)questionId status:(SAMCReceivedQuestionStatus)status
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].questionDB updateReceivedQuestion:questionId status:status];
    });
}

- (void)deleteReceivedQuestion:(SAMCQuestionSession *)session
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].questionDB deleteReceivedQuestion:session];
    });
}

@end
