//
//  SAMCPushManager.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPushManager.h"
#import "SAMCPreferenceManager.h"
#import "NTESLoginManager.h"
#import "SAMCQuestionDB.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCQuestionManager.h"
#import "SAMCAccountManager.h"
#import "SAMCPublicManager.h"
#import "SAMCImageAttachment.h"
#import "SAMCServerAPIMacro.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"

#define SAMCGeTuiAppId        @"e56px9TMay6OJRDrwE21P9"
#define SAMCGeTuiAppKey       @"PUnNqMKGxaAdRoWFDmaTX5"
#define SAMCGeTuiAppSecret    @"ovHqi2uWuw5pvqYJf5QgO6"

@interface SAMCPushManager ()<GeTuiSdkDelegate>

@end

@implementation SAMCPushManager

+ (instancetype)sharedManager
{
    static SAMCPushManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCPushManager alloc] init];
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

- (void)open
{
    [GeTuiSdk startSdkWithAppId:SAMCGeTuiAppId appKey:SAMCGeTuiAppKey appSecret:SAMCGeTuiAppSecret delegate:self];
}

- (void)close
{
    [GeTuiSdk destroy];
}

#pragma mark - GeTuiSdkDelegate
/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    DDLogDebug(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    NSString *bindedAlias = [[SAMCPreferenceManager sharedManager] getuiBindedAlias];
    NSString *getuiAlias = [[[NTESLoginManager sharedManager] currentLoginData] getuiAlias];
    if (![bindedAlias isEqualToString:getuiAlias]) {
        [GeTuiSdk bindAlias:getuiAlias];
        [SAMCPreferenceManager sharedManager].getuiBindedAlias = getuiAlias;
    }
    if (![[[SAMCPreferenceManager sharedManager] sendClientIdFlag] isEqual:@(YES)]) {
        [self sendClientId:clientId];
    }
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    DDLogDebug(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData
                            andTaskId:(NSString *)taskId
                             andMsgId:(NSString *)msgId
                           andOffLine:(BOOL)offLine
                          fromGtAppId:(NSString *)appId {
    
    // [4]: 收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@", taskId, msgId, payloadMsg, offLine ? @"<离线消息>" : @""];
    DDLogDebug(@"\n>>>[GexinSdk ReceivePayload]:\n%@\n\n", msg);
    [self dispatchPushMessage:payloadData];
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    DDLogDebug(@"\n>>>[GexinSdk DidSendMessage]:%@\n\n", msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    DDLogDebug(@"\n>>>[GexinSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    DDLogDebug(@"\n>>>[GexinSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}

- (void)sendClientId:(NSString *)clientId
{
    DDLogDebug(@"sendClientId");
    __weak typeof(self) wself = self;
    [self sendClientId:clientId completion:^(NSError *error) {
        if (error) {
            [wself performSelector:@selector(sendClientId:) withObject:clientId afterDelay:10.0];
        } else {
            [SAMCPreferenceManager sharedManager].sendClientIdFlag = @(YES);
        }
    }];
}

- (void)sendClientId:(NSString *)clientId
          completion:(void(^)(NSError *error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI sendClientId:clientId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_PROFILE_SEND_CLIENTID parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogDebug(@"sendClientId result:%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode =  [((NSNumber *)response[SAMC_RET]) integerValue];
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

#pragma mark - Private
- (void)dispatchPushMessage:(NSData *)payloadData
{
    id payloadInfo = [NSJSONSerialization JSONObjectWithData:payloadData options:0 error:NULL];
    if (![payloadInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSDictionary *payloadDict = payloadInfo;
    
    NSString *destId = [NSString stringWithFormat:@"%@", [payloadDict valueForKeyPath:SAMC_BODY_DEST_ID]];
    if (![[SAMCAccountManager sharedManager].currentAccount isEqualToString:destId]) {
        return;
    }
    
    NSString *category = [NSString stringWithFormat:@"%@", [payloadDict valueForKeyPath:SAMC_HEADER_CATEGORY]];
    if ([category isEqualToString:SAMC_PUSHCATEGORY_NEWQUESTION]) {
        [self receivedNewQuestion:payloadDict];
    } else if([category isEqualToString:SAMC_PUSHCATEGORY_NEWPUBLICMESSAGE]) {
        [self receivedNewPublicMessage:payloadDict];
    }
}

- (void)receivedNewQuestion:(NSDictionary *)payload
{
    [[SAMCQuestionManager sharedManager] insertReceivedQuestion:payload[SAMC_BODY]];
}

- (void)receivedNewPublicMessage:(NSDictionary *)payload
{
    SAMCPublicMessage *message = [SAMCPublicMessage publicMessageFromDict:payload[SAMC_BODY]];
    if (message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
        SAMCImageAttachment *attachment = (SAMCImageAttachment *)customObject.attachment;
        [[NIMSDK sharedSDK].resourceManager download:attachment.thumbUrl filepath:attachment.thumbPath progress:nil completion:^(NSError * _Nullable error) {
            if (error) {
                DDLogError(@"download thumb image error: %@", error);
            }
            [[SAMCPublicManager sharedManager] receivePublicMessage:message];
        }];
    } else {
        [[SAMCPublicManager sharedManager] receivePublicMessage:message];
    }
}

@end
