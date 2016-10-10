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

@synthesize currentUserMode = _currentUserMode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *image = [UIImage imageNamed:@"icon_switch_customer_normal"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,30,30);
    [button addTarget:self action:@selector(touchSwitchUserMode:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
//    self.navigationItem.leftBarButtonItem = navLeftButton;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,navLeftButton];
//    self.navigationItem.leftBarButtonItem.badgeValue = @"1";
}

- (void)dealloc
{
}

- (void)touchSwitchUserMode:(id)sender
{
    self.navigationItem.leftBarButtonItem.enabled = false;
    [SVProgressHUD showWithStatus:@"Switching" maskType:SVProgressHUDMaskTypeBlack];
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        self.currentUserMode = SAMCUserModeTypeSP;
    } else {
        self.currentUserMode = SAMCUserModeTypeCustom;
    }
    __weak typeof(self) wself = self;
    [self.delegate switchToUserMode:self.currentUserMode completion:^{
        wself.navigationItem.leftBarButtonItem.enabled = true;
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - currentUserMode
- (SAMCUserModeType)currentUserMode
{
    return [[[SAMCPreferenceManager sharedManager] currentUserMode] integerValue];
}

- (void)setCurrentUserMode:(SAMCUserModeType)currentUserMode
{
    [[SAMCPreferenceManager sharedManager] setCurrentUserMode:@(currentUserMode)];
}

@end
