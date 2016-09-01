//
//  MainTabController.m
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESMainTabController.h"
#import "SAMCAppDelegate.h"
#import "NTESSessionListViewController.h"
#import "NTESContactViewController.h"
#import "NIMSDK.h"
#import "UIImage+NTESColor.h"
#import "NTESCustomNotificationDB.h"
#import "NTESNotificationCenter.h"
#import "NTESNavigationHandler.h"
#import "NTESBundleSetting.h"
#import "SAMCServiceViewController.h"
#import "SAMCChatListViewController.h"
#import "SAMCContactListViewController.h"
#import "SAMCSettingViewController.h"
#import "SAMCConversationManager.h"
#import "SAMCPublicContainerViewController.h"

#define TabbarVC    @"vc"
#define TabbarTitle @"title"
#define TabbarImage @"image"
#define TabbarSelectedImage @"selectedImage"
#define TabbarItemBadgeValue @"badgeValue"
#define TabBarCount 5

typedef NS_ENUM(NSInteger,NTESMainTabType) {
    NTESMainTabTypeService,
    NTESMainTabTypePublic,
    NTESMainTabTypeMessageList,    //聊天
    NTESMainTabTypeContact,
//    NTESMainTabTypeChatroomList,   //聊天室
    NTESMainTabTypeSetting,        //设置
};



@interface NTESMainTabController ()<NIMSystemNotificationManagerDelegate,SAMCConversationManagerDelegate>

//@property (nonatomic,strong) NSArray *navigationHandlers;

@property (nonatomic,assign) NSInteger sessionUnreadCount;

@property (nonatomic,assign) NSInteger systemUnreadCount;

@property (nonatomic,assign) NSInteger customSystemUnreadCount;

@property (nonatomic,copy)  NSDictionary *configs;

@property (nonatomic, assign) SAMCUserModeType currentUserMode;

@end

@implementation NTESMainTabController

+ (instancetype)instance{
    SAMCAppDelegate *delegete = (SAMCAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = delegete.window.rootViewController;
    if ([vc isKindOfClass:[NTESMainTabController class]]) {
        return (NTESMainTabController *)vc;
    }else{
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpSubNav];
    [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    [[SAMCConversationManager sharedManager] addDelegate:self];
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCustomNotifyChanged:)
                                                 name:NTESCustomNotificationCountChanged object:nil];
    
    extern NSString * const SAMCUserModeSwitchNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToUserMode:)
                                                 name:SAMCUserModeSwitchNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpStatusBar];
}

-(void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
}


- (void)dealloc{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    [[SAMCConversationManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)switchToUserMode:(NSNotification *)notification
{
    extern NSString * const SAMCSwitchToUserModeKey;
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    self.sessionUnreadCount = [[SAMCConversationManager sharedManager] allUnreadCountOfUserMode:mode];
    [self refreshSessionBadge];
}

- (NSArray*)tabbars{
    self.sessionUnreadCount = [[SAMCConversationManager sharedManager] allUnreadCountOfUserMode:self.currentUserMode];
    self.systemUnreadCount   = [NIMSDK sharedSDK].systemNotificationManager.allUnreadCount;
    self.customSystemUnreadCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSInteger tabbar = 0; tabbar < TabBarCount; tabbar++) {
        [items addObject:@(tabbar)];
    }
    return items;
}


- (void)setUpSubNav{
//    NSMutableArray *handleArray = [[NSMutableArray alloc] init];
    NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    [self.tabbars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * item =[self vcInfoForTabType:[obj integerValue]];
        NSString *vcName = item[TabbarVC];
        NSString *title  = item[TabbarTitle];
        NSString *imageName = item[TabbarImage];
        NSString *imageSelected = item[TabbarSelectedImage];
        Class clazz = NSClassFromString(vcName);
        UIViewController *vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        vc.hidesBottomBarWhenPushed = NO;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.translucent = NO;
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                       image:[UIImage imageNamed:imageName]
                                               selectedImage:[UIImage imageNamed:imageSelected]];
        nav.tabBarItem.tag = idx;
        NSInteger badge = [item[TabbarItemBadgeValue] integerValue];
        if (badge) {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",badge];
        }
//        NTESNavigationHandler *handler = [[NTESNavigationHandler alloc] initWithNavigationController:nav];
//        nav.delegate = handler;
        
        [vcArray addObject:nav];
//        [handleArray addObject:handler];
    }];
    self.viewControllers = [NSArray arrayWithArray:vcArray];
//    self.navigationHandlers = [NSArray arrayWithArray:handleArray];
}


- (void)setUpStatusBar{
    UIStatusBarStyle style = UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:style
                                                animated:NO];
}


#pragma mark - SAMCConversationManagerDelegate
- (void)didAddRecentSession:(SAMCRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (![self isCurrentModeSession:recentSession.session]) {
        return;
    }
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didUpdateRecentSession:(SAMCRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (![self isCurrentModeSession:recentSession.session]) {
        return;
    }
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didRemoveRecentSession:(SAMCRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (![self isCurrentModeSession:recentSession.session]) {
        return;
    }
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}

- (void)messagesDeletedInSession:(SAMCSession *)session
{
    if (![self isCurrentModeSession:session]) {
        return;
    }
    self.sessionUnreadCount = [NIMSDK sharedSDK].conversationManager.allUnreadCount;
    [self refreshSessionBadge];
}

- (void)allMessagesDeleted
{
    self.sessionUnreadCount = 0;
    [self refreshSessionBadge];
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
{
    self.systemUnreadCount = unreadCount;
    [self refreshContactBadge];
}

#pragma mark - Notification
- (void)onCustomNotifyChanged:(NSNotification *)notification
{
    NTESCustomNotificationDB *db = [NTESCustomNotificationDB sharedInstance];
    self.customSystemUnreadCount = db.unreadCount;
    [self refreshSettingBadge];
}

- (void)refreshSessionBadge{
    UINavigationController *nav = self.viewControllers[NTESMainTabTypeMessageList];
    nav.tabBarItem.badgeValue = self.sessionUnreadCount ? @(self.sessionUnreadCount).stringValue : nil;
}

- (void)refreshContactBadge{
    UINavigationController *nav = self.viewControllers[NTESMainTabTypeContact];
    NSInteger badge = self.systemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}

- (void)refreshSettingBadge{
    UINavigationController *nav = self.viewControllers[NTESMainTabTypeSetting];
    NSInteger badge = self.customSystemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - NTESNavigationGestureHandlerDataSource
- (UINavigationController *)navigationController
{
    return self.selectedViewController;
}


#pragma mark - Rotate

- (BOOL)shouldAutorotate{
    BOOL enableRotate = [NTESBundleSetting sharedConfig].enableRotate;
    return enableRotate ? [self.selectedViewController shouldAutorotate] : NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    BOOL enableRotate = [NTESBundleSetting sharedConfig].enableRotate;
    return enableRotate ? [self.selectedViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
}


#pragma mark - VC
- (NSDictionary *)vcInfoForTabType:(NTESMainTabType)type{
    
    if (_configs == nil)
    {
        _configs = @{
                     @(NTESMainTabTypeService) : @{
                             TabbarVC           : @"SAMCServiceViewController",
                             TabbarTitle        : @"Service",
                             TabbarImage        : @"icon_message_normal",
                             TabbarSelectedImage: @"icon_message_pressed",
                             TabbarItemBadgeValue: @(self.sessionUnreadCount)
                             },
                     @(NTESMainTabTypePublic) : @{
//                             TabbarVC           : @"SAMCPublicViewController",
                             TabbarVC           : @"SAMCPublicContainerViewController",
                             TabbarTitle        : @"Public",
                             TabbarImage        : @"icon_message_normal",
                             TabbarItemBadgeValue: @(self.sessionUnreadCount)
                             },
                     @(NTESMainTabTypeMessageList) : @{
//                             TabbarVC           : @"NTESSessionListViewController",
                             TabbarVC           : @"SAMCChatListViewController",
                             TabbarTitle        : @"Chat",
                             TabbarImage        : @"icon_message_normal",
                             TabbarSelectedImage: @"icon_message_pressed",
                             TabbarItemBadgeValue: @(self.sessionUnreadCount)
                             },
                     @(NTESMainTabTypeContact) : @{
                             TabbarVC           : @"SAMCContactListViewController",
                             TabbarTitle        : @"Contact",
                             TabbarImage        : @"icon_contact_normal",
                             TabbarSelectedImage: @"icon_contact_pressed",
                             TabbarItemBadgeValue: @(self.systemUnreadCount)
                             },
                     @(NTESMainTabTypeSetting) : @{
                             TabbarVC           : @"SAMCSettingViewController",
                             TabbarTitle        : @"Settings",
                             TabbarImage        : @"icon_setting_normal",
                             TabbarSelectedImage: @"icon_setting_pressed",
                             TabbarItemBadgeValue: @(self.customSystemUnreadCount)
                             }
//                     @(NTESMainTabTypeContact)     : @{
//                             TabbarVC           : @"NTESContactViewController",
//                             TabbarTitle        : @"通讯录",
//                             TabbarImage        : @"icon_contact_normal",
//                             TabbarSelectedImage: @"icon_contact_pressed",
//                             TabbarItemBadgeValue: @(self.systemUnreadCount)
//                             },
//                     @(NTESMainTabTypeSetting)     : @{
//                             TabbarVC           : @"NTESSettingViewController",
//                             TabbarTitle        : @"设置",
//                             TabbarImage        : @"icon_setting_normal",
//                             TabbarSelectedImage: @"icon_setting_pressed",
//                             TabbarItemBadgeValue: @(self.customSystemUnreadCount)
//                             }
                     };
    }
    return _configs[@(type)];
}

#pragma mark - Private
- (SAMCUserModeType)currentUserMode
{
    return [[[SAMCPreferenceManager sharedManager] currentUserMode] integerValue];
}

- (BOOL)isCurrentModeSession:(SAMCSession *)session
{
    return (session.sessionMode == self.currentUserMode);
}



@end
