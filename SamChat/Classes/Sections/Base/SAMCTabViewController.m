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
    
    UIImage *image = [UIImage imageNamed:@"icon_message_normal"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,30,30);
    //button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(touchSwitchUserMode:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    
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
