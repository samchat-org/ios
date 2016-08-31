//
//  SAMCSPProfileViewController.m
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPProfileViewController.h"
#import "SAMCPublicManager.h"
#import "UIView+Toast.h"

@interface SAMCSPProfileViewController ()

@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *chatButton;

@end

@implementation SAMCSPProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.userInfo.username;
    
    _followButton = [[UIButton alloc] init];
    _followButton.translatesAutoresizingMaskIntoConstraints = NO;
    _followButton.backgroundColor = [UIColor lightGrayColor];
    [_followButton setTitle:@"+Follow" forState:UIControlStateNormal];
    [_followButton addTarget:self action:@selector(touchFollow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_followButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_followButton(100)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_followButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[_followButton(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_followButton)]];
}

- (void)touchFollow:(id)sender
{
    self.followButton.enabled = NO;
    __weak typeof(self) wself = self;
    [[SAMCPublicManager sharedManager] follow:YES officialAccount:self.userInfo.spBasicInfo completion:^(NSError * _Nullable error) {
        NSString *toast;
        if (error) {
            wself.followButton.enabled = YES;
            toast =error.userInfo[NSLocalizedDescriptionKey];
        } else {
            toast = @"follow success";
        }
        [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
    }];
}

@end
