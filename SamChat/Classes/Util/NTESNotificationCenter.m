//
//  NTESNotificationCenter.m
//  NIM
//
//  Created by Xuhui on 15/3/25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESNotificationCenter.h"
#import "NTESVideoChatViewController.h"
#import "NTESAudioChatViewController.h"
#import "NTESMainTabController.h"
#import "NTESSessionViewController.h"
#import "NSDictionary+NTESJson.h"
#import "NTESCustomNotificationDB.h"
#import "NTESCustomNotificationObject.h"
#import "UIView+Toast.h"
#import "NTESWhiteboardViewController.h"
#import "NTESCustomSysNotificationSender.h"
#import "SAMCGlobalMacro.h"
#import <AVFoundation/AVFoundation.h>
#import "NTESLiveViewController.h"

NSString *NTESCustomNotificationCountChanged = @"NTESCustomNotificationCountChanged";

@interface NTESNotificationCenter () <NIMSystemNotificationManagerDelegate,NIMNetCallManagerDelegate,NIMRTSManagerDelegate,NIMChatManagerDelegate>

@property (nonatomic,strong) AVAudioPlayer *player; //播放提示音

@end

@implementation NTESNotificationCenter

+ (instancetype)sharedCenter
{
    static NTESNotificationCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESNotificationCenter alloc] init];
    });
    return instance;
}

- (void)start
{
    DDLogInfo(@"Notification Center Setup");
}

- (instancetype)init {
    self = [super init];
    if(self) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"message" withExtension:@"wav"];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];

        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
        [[NIMSDK sharedSDK].netCallManager addDelegate:self];
        [[NIMSDK sharedSDK].rtsManager addDelegate:self];
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
    }
    return self;
}


- (void)dealloc{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    [[NIMSDK sharedSDK].netCallManager removeDelegate:self];
    [[NIMSDK sharedSDK].rtsManager removeDelegate:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
}

#pragma mark - NIMChatManagerDelegate
- (void)onRecvMessages:(NSArray *)messages
{
    method_execute_frequency(self, @selector(playMessageAudioTip), 0.3);
}

- (void)playMessageAudioTip
{
    UINavigationController *nav = [NTESMainTabController instance].selectedViewController;
    BOOL needPlay = YES;
    for (UIViewController *vc in nav.viewControllers) {
        if ([vc isKindOfClass:[NIMSessionViewController class]] ||  [vc isKindOfClass:[NTESLiveViewController class]])
        {
            needPlay = NO;
            break;
        }
    }
    if (needPlay) {
        [self.player stop];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error:nil];
        [self.player play];
    }
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification{
    
    NSString *content = notification.content;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            if ([dict jsonInteger:NTESNotifyID] == NTESCustom)
            {
                //SDK并不会存储自定义的系统通知，需要上层结合业务逻辑考虑是否做存储。这里给出一个存储的例子。
                NTESCustomNotificationObject *object = [[NTESCustomNotificationObject alloc] initWithNotification:notification];
                //这里只负责存储可离线的自定义通知，推荐上层应用也这么处理，需要持久化的通知都走可离线通知
                if (!notification.sendToOnlineUsersOnly) {
                    [[NTESCustomNotificationDB sharedInstance] saveNotification:object];
                }
                if (notification.setting.shouldBeCounted) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NTESCustomNotificationCountChanged object:nil];
                }
                NSString *content  = [dict jsonString:NTESCustomContent];
                [[NTESMainTabController instance].selectedViewController.view makeToast:content duration:2.0 position:CSToastPositionCenter];
            }
        }
    }
}

#pragma mark - NIMNetCallManagerDelegate
- (void)onReceive:(UInt64)callID from:(NSString *)caller type:(NIMNetCallType)type message:(NSString *)extendMessage{
    
    NTESMainTabController *tabVC = [NTESMainTabController instance];
    [tabVC.view endEditing:YES];
    UINavigationController *nav = tabVC.selectedViewController;

    if ([self shouldResponseBusy]){
        [[NIMSDK sharedSDK].netCallManager control:callID type:NIMNetCallControlTypeBusyLine];
    }
    else {
        UIViewController *vc;
        switch (type) {
            case NIMNetCallTypeVideo:{
                vc = [[NTESVideoChatViewController alloc] initWithCaller:caller callId:callID];
            }
                break;
            case NIMNetCallTypeAudio:{
                vc = [[NTESAudioChatViewController alloc] initWithCaller:caller callId:callID];
            }
                break;
            default:
                break;
        }
        if (!vc) {
            return;
        }
        
        //由于音视频聊天里头有音频和视频聊天界面的切换，直接用present的话页面过渡会不太自然，这里还是用push，然后做出present的效果
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromTop;
        transition.delegate = self;
        [nav.view.layer addAnimation:transition forKey:nil];
        nav.navigationBarHidden = YES;
        [nav pushViewController:vc animated:NO];
    }

}

- (void)onRTSRequest:(NSString *)sessionID
                from:(NSString *)caller
            services:(NSUInteger)types
             message:(NSString *)info
{
    NTESMainTabController *tabVC = [NTESMainTabController instance];
    
    [tabVC.view endEditing:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self shouldResponseBusy]) {
            [[NIMSDK sharedSDK].rtsManager responseRTS:sessionID accept:NO option:nil completion:nil];
        }
        else {
            NTESWhiteboardViewController *vc = [[NTESWhiteboardViewController alloc] initWithSessionID:sessionID
                                                                                                peerID:caller
                                                                                                 types:types
                                                                                                  info:info];
            if (tabVC.presentedViewController) {
                __weak NTESMainTabController *wtabVC = (NTESMainTabController *)tabVC;
                [tabVC.presentedViewController dismissViewControllerAnimated:NO completion:^{
                    [wtabVC presentViewController:vc animated:NO completion:nil];
                }];
            }else{
                [tabVC presentViewController:vc animated:NO completion:nil];
            }
        }
    });
}

- (BOOL)shouldResponseBusy
{
    NTESMainTabController *tabVC = [NTESMainTabController instance];
    UINavigationController *nav = tabVC.selectedViewController;
    return [nav.topViewController isKindOfClass:[NTESNetChatViewController class]] || [tabVC.presentedViewController isKindOfClass:[NTESWhiteboardViewController class]];
}


@end
