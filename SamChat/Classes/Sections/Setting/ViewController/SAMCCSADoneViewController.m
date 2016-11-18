//
//  SAMCCSADoneViewController.m
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSADoneViewController.h"
#import "SAMCGradientButton.h"
#import "SVProgressHUD.h"

@interface SAMCCSADoneViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *welcomeLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) SAMCGradientButton *startButton;

@end

@implementation SAMCCSADoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_INK;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.welcomeLabel];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.startButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_titleLabel]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_titleLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_titleLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_titleLabel)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[_welcomeLabel]-48-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_welcomeLabel)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[_tipLabel]-48-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_welcomeLabel]-20-[_tipLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_welcomeLabel,_tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_startButton]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_startButton)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_startButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [_startButton addConstraint:[NSLayoutConstraint constraintWithItem:_startButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:40.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_startButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:-20.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)touchGetStarted:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:NULL];
//    [SVProgressHUD showWithStatus:@"Switching" maskType:SVProgressHUDMaskTypeBlack];
    extern NSString *SAMCUserModeSwitchNotification;
    [[NSNotificationCenter defaultCenter] postNotificationName:SAMCUserModeSwitchNotification
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - lazy load
- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = @"Service Profile Created";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    }
    return _titleLabel;
}

- (UIImageView *)logoImageView
{
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _logoImageView.image = [UIImage imageNamed:@"img_BKG_signin"];
    }
    return _logoImageView;
}

- (UILabel *)welcomeLabel
{
    if (_welcomeLabel == nil) {
        _welcomeLabel = [[UILabel alloc] init];
        _welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _welcomeLabel.text = @"Welcome to Your Service Profile";
        _welcomeLabel.textColor = [UIColor whiteColor];
        _welcomeLabel.numberOfLines = 0;
        _welcomeLabel.textAlignment = NSTextAlignmentCenter;
        _welcomeLabel.font = [UIFont systemFontOfSize:28.0f];
    }
    return _welcomeLabel;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.text = @"You are now a service provider on Samchat! Start selling your service now!";
        _tipLabel.textColor = UIColorFromRGBA(0xFFFFFF, 0.6);
        _tipLabel.numberOfLines = 0;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

- (SAMCGradientButton *)startButton
{
    if (_startButton == nil) {
        _startButton = [[SAMCGradientButton alloc] init];
        _startButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_startButton setTitle:@"Show Me Around" forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _startButton.gradientLayer.colors = @[(__bridge id)SAMC_COLOR_LIGHTBLUE_GRADIENT_DARK.CGColor,(__bridge id)SAMC_COLOR_LIGHTBLUE_GRADIENT_LIGHT.CGColor];
        _startButton.gradientLayer.cornerRadius = 20.0f;
        _startButton.layer.cornerRadius = 20.0f;
        [_startButton addTarget:self action:@selector(touchGetStarted:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

@end
