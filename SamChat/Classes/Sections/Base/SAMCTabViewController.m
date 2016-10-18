//
//  SAMCTabViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTabViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "SVProgressHUD.h"

@interface SAMCTabViewController ()

@end

@implementation SAMCTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSString *icoSwitchName;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        icoSwitchName = @"ico_nav_switch_light";
    } else {
        icoSwitchName = @"ico_nav_switch_dark";
    }
    UIImage *image = [UIImage imageNamed:icoSwitchName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,24,24);
    [button addTarget:self action:@selector(touchSwitchUserMode:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,navLeftButton];
}

- (void)dealloc
{
}

- (void)touchSwitchUserMode:(id)sender
{
    self.navigationItem.leftBarButtonItem.enabled = false;
//    [SVProgressHUD showWithStatus:@"Switching" maskType:SVProgressHUDMaskTypeBlack];
    
    extern NSString *SAMCUserModeSwitchNotification;
    [[NSNotificationCenter defaultCenter] postNotificationName:SAMCUserModeSwitchNotification
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - currentUserMode
- (SAMCUserModeType)currentUserMode
{
    return [[[SAMCPreferenceManager sharedManager] currentUserMode] integerValue];
}

@end
