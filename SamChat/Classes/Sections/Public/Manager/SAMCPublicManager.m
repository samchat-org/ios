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
#import <AWSS3/AWSS3.h>
#import "SAMCImageUtil.h"
#import "SAMCImageAttachment.h"
#import "SDImageCache.h"

@interface SAMCPublicManager ()

@property (nonatomic, strong) GCDMulticastDelegate<SAMCPublicManagerDelegate> *publicDelegate;

@property (nonatomic, strong) NSMutableArray *sendingMessages;

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
        _sendingMessages = [[NSMutableArray alloc] init];
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
    NSDictionary *parameters = [SAMCServerAPI follow:isFollow officialAccount:userInfo.userId];
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

- (NSArray<SAMCPublicSession *> *)myFollowList
{
    return [[SAMCDataBaseManager sharedManager].publicDB myFollowList];
}

- (BOOL)isFollowing:(NSString *)userId
{
    return [[SAMCDataBaseManager sharedManager].publicDB isFollowing:userId];
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
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<SAMCPublicMessage *> *messages = [[SAMCDataBaseManager sharedManager].publicDB messagesInSession:session
                                                                                                         message:message
                                                                                                           limit:limit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.isOutgoing && [messages count]) {
                // as outgoing message init to failed in db, should check if it's sending after query from db
                // and set the deliveryState to NIMMessageDeliveryStateDelivering if it's sending
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (SAMCPublicMessage *obj in messages) {
                        if ([wself.sendingMessages count] <= 0) {
                            break;
                        }
                        if ([wself.sendingMessages containsObject:obj.messageId]) {
                            obj.deliveryState = NIMMessageDeliveryStateDelivering;
                        }
                    }
                });
            }
            if (handler) {
                handler(nil, messages);
            }
        });
    });
}

- (void)deleteMessage:(SAMCPublicMessage *)message
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB deleteMessage:message];
    });
}

- (void)receivePublicMessage:(SAMCPublicMessage *)message
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB insertMessage:message initDeliveryState:message.deliveryState];
        [self.publicDelegate onRecvMessage:message];
    });
}

- (void)markAllMessagesReadInSession:(SAMCPublicSession *)session
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB markAllMessagesReadInSession:session];
    });
}

#pragma mark - Server
- (void)sendPublicMessage:(SAMCPublicMessage *)message error:(NSError * __nullable *)errorOut
{
    // init delivery state to failed incase app crash mess the state
    [[SAMCDataBaseManager sharedManager].publicDB insertMessage:message initDeliveryState:NIMMessageDeliveryStateFailed];
    [self.sendingMessages addObject:message.messageId];
    if (message.messageType == NIMMessageTypeCustom) {
        [self sendPublicImageMessage:message];
    } else if(message.messageType == NIMMessageTypeText) {
        [self sendPublicTextMessage:message];
    }
}

#pragma mark - Private
- (void)sendPublicTextMessage:(SAMCPublicMessage *)message
{
    [self.publicDelegate willSendMessage:message];
    [self sendPublicMessage:message];
}


- (void)sendPublicImageMessage:(SAMCPublicMessage *)message
{
    NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
    SAMCImageAttachment *attachment = (SAMCImageAttachment *)customObject.attachment;
    [self.publicDelegate willSendMessage:message];
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    __weak typeof(self) wself = self;
    expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            attachment.progress = progress.fractionCompleted/0.9f;
            attachment.progress = progress.fractionCompleted;
            [wself.publicDelegate sendMessage:message progress:attachment.progress];
        });
    };
    
    AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            attachment.progress = 1.0f;
            if (error) {
                message.deliveryState = NIMMessageDeliveryStateFailed;
                [wself.publicDelegate sendMessage:message didCompleteWithError:error];
                [wself.sendingMessages removeObject:message.messageId];
                [[SAMCDataBaseManager sharedManager].publicDB updateMessage:message];
            } else {
                attachment.url = [NSString stringWithFormat:@"%@%@%@",SAMC_AWSS3_URLPREFIX,SAMC_AWSS3_ADV_ORG_PATH,[attachment filename]];
                DDLogDebug(@"url: %@", attachment.url);
                [wself sendPublicMessage:message];
            }
        });
    };

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    NSString *key = [NSString stringWithFormat:@"%@%@", SAMC_AWSS3_ADV_ORG_PATH, [attachment filename]];
    NSURL *fileUrl = [NSURL fileURLWithPath:attachment.path];
    [[transferUtility uploadFile:fileUrl bucket:SAMC_AWSS3_BUCKETNAME key:key contentType:@"image/jpeg" expression:expression completionHander:completionHandler] continueWithBlock:^id (AWSTask * task) {
        if (task.error || task.exception) {
            DDLogDebug(@"Error: %@", task.error);
            DDLogDebug(@"Exception: %@", task.exception);
            dispatch_async(dispatch_get_main_queue(), ^{
                message.deliveryState = NIMMessageDeliveryStateFailed;
                [[SAMCDataBaseManager sharedManager].publicDB updateMessage:message];
                [wself.publicDelegate sendMessage:message didCompleteWithError:task.error];
                [wself.sendingMessages removeObject:message.messageId];
            });
        }
        if (task.result) {
            DDLogDebug(@"Uploading...");
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.publicDelegate sendMessage:message progress:0.f];
            });
        }
        return nil;
    }];
}

- (void)sendPublicMessage:(SAMCPublicMessage *)message
{
    NSDictionary *parameters = nil;
    if (message.messageType == NIMMessageTypeText) {
        parameters = [SAMCServerAPI writeAdvertisementType:SAMCAdvertisementTypeText content:message.text messageId:message.messageId];
    } else if(message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
        SAMCImageAttachment *attachment = (SAMCImageAttachment *)customObject.attachment;
        parameters = [SAMCServerAPI writeAdvertisementType:SAMCAdvertisementTypeImage content:attachment.url messageId:message.messageId];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    __weak typeof(self) wself = self;
    [manager POST:SAMC_URL_ADVERTISEMENT_ADVERTISEMENT_WRITE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogDebug(@"sendPublicMessage success: %@", responseObject);
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
        [[SAMCDataBaseManager sharedManager].publicDB updateMessage:message];
        [wself.publicDelegate sendMessage:message didCompleteWithError:sendError];
        [wself.sendingMessages removeObject:message.messageId];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"sendPublicMessage failed: %@", error);
        message.deliveryState = NIMMessageDeliveryStateFailed;
        NSError *sendError = [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable];
        [[SAMCDataBaseManager sharedManager].publicDB updateMessage:message];
        [wself.publicDelegate sendMessage:message didCompleteWithError:sendError];
        [wself.sendingMessages removeObject:message.messageId];
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
