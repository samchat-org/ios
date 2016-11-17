//
//  SAMCAppDelegate.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAppDelegate.h"
#import "NTESLoginViewController.h"
#import "NIMSDK.h"
#import "UIView+Toast.h"
#import "NTESService.h"
#import "NTESNotificationCenter.h"
#import "NTESLogManager.h"
#import "NTESDemoConfig.h"
#import "NTESSessionUtil.h"
#import "NTESMainTabController.h"
#import "NTESCustomAttachmentDecoder.h"
#import "NTESClientUtil.h"
#import "NTESNotificationCenter.h"
#import "NIMKit.h"
#import "SAMCDataManager.h"
#import "NTESSDKConfig.h"
#import "SAMCLoginViewController.h"
#import "SAMCDataBaseManager.h"
#import "SAMCChatManager.h"
#import "SAMCPreferenceManager.h"
#import "SAMCAccountManager.h"
#import <AWSS3/AWSS3.h>
#import "SAMCSyncManager.h"
#import "SAMCUnreadCountManager.h"
#import "SAMCUserManager.h"

NSString *NTESNotificationLogout = @"NTESNotificationLogout";
NSString * const SAMCLoginNotification = @"SAMCLoginNotification";
NSString * const SAMCUserModeSwitchNotification = @"SAMCUserModeSwitchNotification";


@interface SAMCAppDelegate ()<SAMCLoginManagerDelegate>
@property (nonatomic,strong) NTESSDKConfig *config;
@end

@implementation SAMCAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //配置 SDK 配置，需要在 SDK 启动之前进行配置 (如文件存储根目录等)
    //NSString *sdkPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //[[NIMSDKConfig sharedConfig] setupSDKDir:sdkPath];
    _config = [[NTESSDKConfig alloc] init];
    [[NIMSDKConfig sharedConfig] setDelegate:_config];
    
    
    //appkey是应用的标识，不同应用之间的数据（用户、消息、群组等）是完全隔离的。
    //如需打网易云信Demo包，请勿修改appkey，开发自己的应用时，请替换为自己的appkey.
    //并请对应更换Demo代码中的获取好友列表、个人信息等网易云信SDK未提供的接口。
    NSString *appKey = [[NTESDemoConfig sharedConfig] appKey];
    NSString *cerName= [[NTESDemoConfig sharedConfig] cerName];
    
    [[NIMSDK sharedSDK] registerWithAppID:appKey
                                  cerName:cerName];
    
    [NIMCustomObject registerCustomDecoder:[NTESCustomAttachmentDecoder new]];
    
    // setup AWSS3
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSWest2
                                                          identityPoolId:@"us-west-2:2d22de2e-5125-4d48-9dec-28367ebeda89"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    
    [self setupServices];
#if !(TARGET_IPHONE_SIMULATOR)
    [self registerAPNs];
#endif
    
    [self commonInitListenEvents];
    
    [[NIMKit sharedKit] setProvider:[SAMCDataManager sharedManager]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor grayColor];
    [self.window makeKeyAndVisible];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setupUserViewController];
    
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SAMCAccountManager sharedManager] removeDelegate:self];
}


#pragma mark - ApplicationDelegate
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSInteger count = [[SAMCUnreadCountManager sharedManager] allUnreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 云信DeviceToken上传
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
    DDLogInfo(@"didRegisterForRemoteNotificationsWithDeviceToken:  %@", deviceToken);
    
//    // 个推DeviceToken上传
//    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    DDLogInfo(@"\n>>>[DeviceToken Success]:%@\n\n", token);
//    [GeTuiSdk registerDeviceToken:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    DDLogInfo(@"receive remote notification:  %@", userInfo);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DDLogError(@"fail to get apns token :%@",error);
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    /* Store the completion handler.*/
    [AWSS3TransferUtility interceptApplication:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}


#pragma mark - misc
- (void)registerAPNs
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

- (void)setupUserViewController
{
    SAMCLoginData *loginData = [SAMCPreferenceManager sharedManager].loginData;
    if ((loginData != nil) && [loginData.account length] && [loginData.token length])
    {
        [[SAMCAccountManager sharedManager] autoLogin:loginData];
        [self setupMainViewController];
    }
    else
    {
        [self setupLoginViewController];
    }
}

- (void)setupMainViewController
{
    NTESMainTabController * mainTab = [[NTESMainTabController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = mainTab;
}

- (void)commonInitListenEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout:)
                                                 name:NTESNotificationLogout
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(login:)
                                                 name:SAMCLoginNotification
                                               object:nil];
    [[SAMCAccountManager sharedManager] addDelegate:self];
}

- (void)setupLoginViewController
{
    [[SAMCPreferenceManager sharedManager] reset];
    SAMCLoginViewController *vc = [[SAMCLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
}

#pragma mark - 主动登录
- (void)login:(NSNotification *)notification
{
    [self setupMainViewController];
}

#pragma mark - 注销
- (void)logout:(NSNotification *)note
{
    [self doLogout];
}

- (void)doLogout
{
    if (![self.window.rootViewController isKindOfClass:[NTESMainTabController class]]) {
        // already logout, may happen when auto login failed & token error
        return;
    }
    [[SAMCUnreadCountManager sharedManager] close];
    [[SAMCSyncManager sharedManager] close];
    [[NTESServiceManager sharedManager] destory];
    [[SAMCUserManager sharedManager] reset];
    [[SAMCDataBaseManager sharedManager] close];
    [self setupLoginViewController];
}

#pragma SAMCLoginManagerDelegate
-(void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType
{
    NSString *reason = @"你被踢下线";
    switch (code) {
        case NIMKickReasonByClient:
        case NIMKickReasonByClientManually:{
            NSString *clientName = [NTESClientUtil clientName:clientType];
            reason = clientName.length ? [NSString stringWithFormat:@"你的帐号被%@端踢出下线，请注意帐号信息安全",clientName] : @"你的帐号被踢出下线，请注意帐号信息安全";
            break;
        }
        case NIMKickReasonByServer:
            reason = @"你被服务器踢下线";
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下线通知" message:reason delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)onAutoLoginFailed:(NSError *)error
{
    //只有连接发生严重错误才会走这个回调，在这个回调里应该登出，返回界面等待用户手动重新登录。
    DDLogInfo(@"onAutoLoginFailed %zd",error.code);
    NSString *toast = [NSString stringWithFormat:@"登录失败: %zd",error.code];
    [self.window makeToast:toast duration:2.0 position:CSToastPositionCenter];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
}


#pragma mark - logic impl
- (void)setupServices
{
    [[NTESLogManager sharedManager] start];
    [[NTESNotificationCenter sharedCenter] start];
}


@end
