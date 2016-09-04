//
//  SAMCPublicManager.m
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicManager.h"
#import "SAMCServerAPI.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCDataBaseManager.h"
#import "SAMCPreferenceManager.h"
#import "GCDMulticastDelegate.h"

@interface SAMCPublicManager ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCPublicManagerDelegate> *publicDelegate;

@end

@implementation SAMCPublicManager

+ (instancetype)sharedManager
{
    static SAMCPublicManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCPublicManager alloc] init];
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

- (void)addDelegate:(id<SAMCPublicManagerDelegate>)delegate
{
    [self.publicDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
    [[SAMCDataBaseManager sharedManager].publicDB addPublicDelegate:delegate];
}

- (void)removeDelegate:(id<SAMCPublicManagerDelegate>)delegate
{
    [self.publicDelegate removeDelegate:delegate];
    [[SAMCDataBaseManager sharedManager].publicDB removePublicDelegate:delegate];
}

- (void)searchPublicWithKey:(NSString * __nullable)key
                   location:(NSDictionary * __nullable)location
                 completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryPublicWithKey:key location:location];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_OFFICIALACCOUNT_PUBLIC_QUERY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)follow:(BOOL)isFollow
officialAccount:(SAMCSPBasicInfo *)userInfo
    completion:(void (^)(NSError * __nullable error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI follow:isFollow officialAccount:@(userInfo.uniqueId)];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    __weak typeof(self) wself = self;
    [manager POST:SAMC_URL_OFFICIALACCOUNT_FOLLOW parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion([SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                DDLogDebug(@"follow response: %@", response);
                if (isFollow) {
                    [wself insertToFollowList:userInfo];
                } else {
                    [wself deleteFromFollowList:userInfo];
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

- (void)queryFollowListIfNecessary
{
    if ([[SAMCPreferenceManager sharedManager].followListSyncFlag isEqual:@(YES)]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self queryFollowList];
    });
}

- (NSArray<SAMCPublicSession *> *)myFollowList
{
    return [[SAMCDataBaseManager sharedManager].publicDB myFollowList];
}

- (void)insertToFollowList:(SAMCSPBasicInfo *)userInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB insertToFollowList:userInfo];
    });
}

- (void)deleteFromFollowList:(SAMCSPBasicInfo *)userInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB deleteFromFollowList:userInfo];
    });
}

- (void)fetchMessagesInSession:(SAMCPublicSession *)session
                       message:(SAMCPublicMessage * __nullable)message
                         limit:(NSInteger)limit
                        result:(void(^)(NSError *error, NSArray<SAMCPublicMessage *> *messages))handler
{
    // TODO: change to async dispatch ?
    NSArray<SAMCPublicMessage *> *messages = [[SAMCDataBaseManager sharedManager].publicDB messagesInSession:session
                                                                                                     message:message
                                                                                                       limit:limit];
    handler(nil, messages);
}


#pragma mark - Server
- (void)sendPublicMessage:(SAMCPublicMessage *)message error:(NSError * __nullable *)errorOut
{
    // TODO: handle text message now, image later
    [[SAMCDataBaseManager sharedManager].publicDB insertMessage:message];
    [self.publicDelegate willSendMessage:message];
    NSDictionary *parameters = [SAMCServerAPI writeAdvertisementType:message.messageType content:message.text];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_ADVERTISEMENT_ADVERTISEMENT_WRITE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogError(@"sendPublicMessage success: %@", responseObject);
        NSError *sendError = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode == 0) {
                NSInteger serverId = [((NSNumber *)response[SAMC_ADV_ID]) integerValue];
                NSInteger timestamp = [((NSNumber *)response[SAMC_PUBLISH_TIMESTAMP]) integerValue]/1000; // seconds
                message.serverId = serverId;
                message.timestamp = timestamp;
                message.deliveryState = NIMMessageDeliveryStateDeliveried;
            } else {
                message.deliveryState = NIMMessageDeliveryStateFailed;
                sendError = [SAMCServerErrorHelper errorWithCode:errorCode];
            }
        } else {
            message.deliveryState = NIMMessageDeliveryStateFailed;
            sendError = [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError];
        }
        [[SAMCDataBaseManager sharedManager].publicDB updateMessageStateServerIdAndTime:message];
        [self.publicDelegate sendMessage:message didCompleteWithError:sendError];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"sendPublicMessage failed: %@", error);
        message.deliveryState = NIMMessageDeliveryStateFailed;
        NSError *sendError = [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable];
        [[SAMCDataBaseManager sharedManager].publicDB updateMessageStateServerIdAndTime:message];
        [self.publicDelegate sendMessage:message didCompleteWithError:sendError];
    }];
}

#pragma mark - Private
- (void)queryFollowList
{
    NSDictionary *parameters = [SAMCServerAPI queryFollowList];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_OFFICIALACCOUNT_FOLLOW_LIST_QUERY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode == 0) {
                NSArray *users = response[SAMC_USERS];
                if ((users != nil) && ([users isKindOfClass:[NSArray class]])) {
                    BOOL result = [[SAMCDataBaseManager sharedManager].publicDB updateFollowList:users];
                    if (result) {
                        [SAMCPreferenceManager sharedManager].followListSyncFlag = @(YES);
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // TODO: check Reachability and retry
    }];
}

#pragma mark - lazy load
- (GCDMulticastDelegate<SAMCPublicManagerDelegate> *)publicDelegate
{
    if (_publicDelegate == nil) {
        _publicDelegate = (GCDMulticastDelegate <SAMCPublicManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    return _publicDelegate;
}
@end
