//
//  SAMCTabViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTabViewController.h"
#import "UIBarButtonItem+Badge.h"

NSString * const SAMCUserModeSwitchNotification = @"SAMCUserModeSwitchNotification";
NSString * const SAMCSwitchToUserModeKey = @"mode";

@interface SAMCTabViewController ()

@property (nonatomic) SAMCUserModeType userMode;

@end

@implementation SAMCTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *image = [UIImage imageNamed:@"icon_message_normal"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,30,30);
    //button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(touchSwitchUserMode:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    
//    self.navigationItem.leftBarButtonItem.badgeValue = @"1";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToUserMode:)
                                                 name:SAMCUserModeSwitchNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchSwitchUserMode:(id)sender
{
    NSDictionary *userInfo;
    if (self.userMode == SAMCUserModeTypeCustom) {
        userInfo = @{SAMCSwitchToUserModeKey : @(SAMCUserModeTypeSP)};
        self.userMode = SAMCUserModeTypeSP;
    } else {
        userInfo = @{SAMCSwitchToUserModeKey : @(SAMCUserModeTypeCustom)};
        self.userMode = SAMCUserModeTypeCustom;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SAMCUserModeSwitchNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)switchToUserMode:(NSDictionary *)notification
{
}

@end
