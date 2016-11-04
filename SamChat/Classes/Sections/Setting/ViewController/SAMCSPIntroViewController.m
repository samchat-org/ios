//
//  SAMCSPIntroViewController.m
//  SamChat
//
//  Created by HJ on 11/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPIntroViewController.h"

@interface SAMCSPIntroViewController ()

@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation SAMCSPIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.doneButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_doneButton]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_doneButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_doneButton(40)]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_doneButton)]];
}

- (void)onDone:(id)sender
{
}

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        _doneButton.layer.cornerRadius = 20.0f;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_active"] forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_pressed"] forState:UIControlStateHighlighted];
        [_doneButton setTitle:@"Become a Service Profiver" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}


@end
