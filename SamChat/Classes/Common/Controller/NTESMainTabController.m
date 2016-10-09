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
#import "NTESBundleSetting.h"
#import "SAMCServiceViewController.h"
#import "SAMCChatListViewController.h"
#import "SAMCContactListViewController.h"
#import "SAMCSettingViewController.h"
#import "SAMCPublicContainerViewController.h"
#import "SAMCUnreadCountManager.h"
#import "SAMCTabViewController.h"

#define TabbarVC    @"vc"
#define TabbarTitle @"title"
#define TabbarImage @"image"
#define TabbarSelectedImage @"selectedImage"
#define TabbarItemBadgeValue @"badgeValue"
#define TabBarCount 5

typedef NS_ENUM(NSInteger,SAMCMainTabType) {
    SAMCMainTabTypeService,
    SAMCMainTabTypePublic,
    SAMCMainTabTypeChat,
    SAMCMainTabTypeContact,
    SAMCMainTabTypeSetting,
};

@interface NTESMainTabController ()<NIMSystemNotificationManagerDelegate,SAMCUnreadCountManagerDelegate,SAMCSwitchUserModeDelegate>

@property (nonatomic, assign) NSInteger systemUnreadCount;

@property (nonatomic, assign) NSInteger customSystemUnreadCount;

@property (nonatomic, copy) NSDictionary *configs;

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
    [[SAMCUnreadCountManager sharedManager] addDelegate:self];
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCustomNotifyChanged:)
                                                 name:NTESCustomNotificationCountChanged object:nil];
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
    [[SAMCUnreadCountManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)tabbars{
    self.systemUnreadCount   = [NIMSDK sharedSDK].systemNotificationManager.allUnreadCount;
    self.customSystemUnreadCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSInteger tabbar = 0; tabbar < TabBarCount; tabbar++) {
        [items addObject:@(tabbar)];
    }
    return items;
}


- (void)setUpSubNav{
    _configs = nil;
    NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    [self.tabbars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * item =[self vcInfoForTabType:[obj integerValue]];
        NSString *vcName = item[TabbarVC];
        NSString *title  = item[TabbarTitle];
        NSString *imageName = item[TabbarImage];
        NSString *imageSelected = item[TabbarSelectedImage];
        Class clazz = NSClassFromString(vcName);
        UIViewController *vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        ((SAMCTabViewController *)vc).delegate = self;
        vc.hidesBottomBarWhenPushed = NO;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.translucent = NO;
        UIImage *normalImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *pressedImage = [[UIImage imageNamed:imageSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                       image:normalImage
                                               selectedImage:pressedImage];
        [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SAMC_MAIN_LIGHTCOLOR} forState:UIControlStateNormal];
        [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SAMC_MAIN_DARKCOLOR} forState:UIControlStateSelected];
        
        nav.tabBarItem.tag = idx;
        NSInteger badge = [item[TabbarItemBadgeValue] integerValue];
        if (badge) {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",badge];
        }
        
        [vcArray addObject:nav];
    }];
    self.viewControllers = [NSArray arrayWithArray:vcArray];
}


- (void)setUpStatusBar{
    UIStatusBarStyle style = UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:style
                                                animated:NO];
}


#pragma mark - SAMCUnreadCountManagerDelegate
- (void)chatUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode == self.currentUserMode) {
        [self refreshSessionBadge:count];
    }
}

- (void)serviceUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode == self.currentUserMode) {
        [self refreshServiceBadge:count];
    }
}

- (void)publicUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode == self.currentUserMode) {
        [self refreshPublicBadge:count];
    }
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

- (void)refreshServiceBadge:(NSInteger)unreadCount
{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypeService];
    nav.tabBarItem.badgeValue = unreadCount ? @(unreadCount).stringValue : nil;
}

- (void)refreshSessionBadge:(NSInteger)unreadCount
{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypeChat];
    nav.tabBarItem.badgeValue = unreadCount ? @(unreadCount).stringValue : nil;
}

- (void)refreshPublicBadge:(NSInteger)unreadCount
{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypePublic];
    nav.tabBarItem.badgeValue = unreadCount ? @(unreadCount).stringValue : nil;
}

- (void)refreshContactBadge{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypeContact];
    NSInteger badge = self.systemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}

- (void)refreshSettingBadge{
    UINavigationController *nav = self.viewControllers[SAMCMainTabTypeSetting];
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
- (NSDictionary *)vcInfoForTabType:(SAMCMainTabType)type{
    if (_configs == nil)
    {
        SAMCUnreadCountManager *unreadCountManager = [SAMCUnreadCountManager sharedManager];
        NSInteger chatUnreadCount = [unreadCountManager chatUnreadCountOfUserMode:self.currentUserMode];
        NSInteger serviceUnreadCount = [unreadCountManager serviceUnreadCountOfUserMode:self.currentUserMode];
        NSInteger publicUnreadCount = [unreadCountManager publicUnreadCountOfUserMode:self.currentUserMode];
        _configs = @{
                     @(SAMCMainTabTypeService) : @{
                             TabbarVC           : @"SAMCServiceViewController",
                             TabbarTitle        : @"Service",
                             TabbarImage        : @"icon_service_normal",
                             TabbarSelectedImage: @"icon_service_pressed",
                             TabbarItemBadgeValue: @(serviceUnreadCount)
                             },
                     @(SAMCMainTabTypePublic) : @{
                             TabbarVC           : @"SAMCPublicContainerViewController",
                             TabbarTitle        : @"Public",
                             TabbarImage        : @"icon_public_normal",
                             TabbarSelectedImage: @"icon_public_pressed",
                             TabbarItemBadgeValue: @(publicUnreadCount)
                             },
                     @(SAMCMainTabTypeChat) : @{
                             TabbarVC           : @"SAMCChatListViewController",
                             TabbarTitle        : @"Chat",
                             TabbarImage        : @"icon_chat_normal",
                             TabbarSelectedImage: @"icon_chat_pressed",
                             TabbarItemBadgeValue: @(chatUnreadCount)
                             },
                     @(SAMCMainTabTypeContact) : @{
                             TabbarVC           : @"SAMCContactListViewController",
                             TabbarTitle        : @"Contact",
                             TabbarImage        : @"icon_contact_normal",
                             TabbarSelectedImage: @"icon_contact_pressed",
                             TabbarItemBadgeValue: @(self.systemUnreadCount)
                             },
                     @(SAMCMainTabTypeSetting) : @{
                             TabbarVC           : @"SAMCSettingViewController",
                             TabbarTitle        : @"Me",
                             TabbarImage        : @"icon_me_normal",
                             TabbarSelectedImage: @"icon_me_pressed",
                             TabbarItemBadgeValue: @(self.customSystemUnreadCount)
                             }
                     };
    }
    return _configs[@(type)];
}

#pragma mark - SAMCSwitchUserModeDelegate
- (void)switchToUserMode:(SAMCUserModeType)userMode completion:(void (^)())completion
{
    [self setUpSubNav];
    if (completion) {
        completion();
    }
}

#pragma mark - Private
- (SAMCUserModeType)currentUserMode
{
    return [[[SAMCPreferenceManager sharedManager] currentUserMode] integerValue];
}

@end
