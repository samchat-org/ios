//
//  SAMCCSADoneViewController.m
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSADoneViewController.h"
#import "SAMCSettingViewController.h"
#import "SVProgressHUD.h"

@interface SAMCCSADoneViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *startButton;

@end

@implementation SAMCCSADoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    [self.navigationItem setTitle:@"Done"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = @"Start selling your service now";
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:28.0f];
    [self.view addSubview:_titleLabel];
    
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _subTitleLabel.text = @"Glad to have you on board, we will try our best to help your business reach out to more customers.";
    _subTitleLabel.numberOfLines = 0;
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    _subTitleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.view addSubview:_subTitleLabel];
    
    _startButton = [[UIButton alloc] init];
    _startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_startButton setTitle:@"Get Started" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_startButton setBackgroundColor:[UIColor grayColor]];
    _startButton.layer.cornerRadius = 5.0f;
    [_startButton addTarget:self action:@selector(touchGetStarted:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_titleLabel]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_titleLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_subTitleLabel]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_subTitleLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[_titleLabel]-20-[_subTitleLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_titleLabel,_subTitleLabel)]];
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
                                                              constant:44.0f]];
    [_startButton addConstraint:[NSLayoutConstraint constraintWithItem:_startButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:200.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_startButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:-20.0f]];
}

- (void)touchGetStarted:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    [SVProgressHUD showWithStatus:@"Switching" maskType:SVProgressHUDMaskTypeBlack];
    extern NSString *SAMCUserModeSwitchNotification;
    [[NSNotificationCenter defaultCenter] postNotificationName:SAMCUserModeSwitchNotification
                                                        object:nil
                                                      userInfo:nil];
}

@end
