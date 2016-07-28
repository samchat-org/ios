//
//  SAMCLoginViewController.m
//  SamChat
//
//  Created by HJ on 7/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCLoginViewController.h"
#import "SAMCCountryCodeViewController.h"
#import "SAMCTextField.h"
#import "SAMCConfirmPhoneNumViewController.h"
#import "SAMCNewRequestViewController.h"

@interface SAMCLoginViewController ()

@property (nonatomic, strong) SAMCTextField *usernameTextField;
@property (nonatomic, strong) SAMCTextField *passwordTextField;
@property (nonatomic, strong) UIButton *signinButton;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;

@end

@implementation SAMCLoginViewController

NTES_USE_CLEAR_BAR
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.usernameTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.usernameTextField.leftButton setTitle:@"+1" forState:UIControlStateNormal];
    [self.usernameTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
    self.usernameTextField.rightTextField.placeholder = @"Username or phone no.";
    [self.view addSubview:self.usernameTextField];
    
    self.passwordTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.passwordTextField.leftButton setTitle:@"Pass" forState:UIControlStateNormal];
    self.passwordTextField.rightTextField.placeholder = @"Enter your password";
    [self.view addSubview:self.passwordTextField];
    
    self.signinButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.signinButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.signinButton.layer.cornerRadius = 5.0f;
    self.signinButton.backgroundColor = [UIColor grayColor];
    [self.signinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signinButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.signinButton setTitle:@"SIGN IN" forState:UIControlStateNormal];
    [self.signinButton addTarget:self action:@selector(signin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signinButton];
    
    self.signupButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.signupButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.signupButton.backgroundColor = [UIColor clearColor];
    [self.signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.signupButton addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signupButton];
    
    self.forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.forgotPasswordButton.backgroundColor = [UIColor clearColor];
    self.forgotPasswordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.forgotPasswordButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.forgotPasswordButton addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forgotPasswordButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_usernameTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_passwordTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_signinButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_signinButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_signupButton][_forgotPasswordButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_signupButton,_forgotPasswordButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.signupButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.forgotPasswordButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_usernameTextField(50)]-10-[_passwordTextField(50)]-10-[_signinButton(50)]-10-[_signupButton]-100-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField,_passwordTextField,_signinButton,_signupButton)]];
}

#pragma mark - Action
- (void)selectCountryCode:(UIButton *)sender
{
    SAMCCountryCodeViewController *countryCodeController = [[SAMCCountryCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    countryCodeController.selectBlock = ^(NSString *text){
        [weakSelf.usernameTextField.leftButton setTitle:text forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:countryCodeController animated:YES];
}

- (void)signin:(UIButton *)sender
{
}

- (void)signup:(UIButton *)sender
{
    SAMCConfirmPhoneNumViewController *vc = [[SAMCConfirmPhoneNumViewController alloc] init];
    vc.navTitle = @"Sign Up";
    vc.countryCode = self.usernameTextField.leftButton.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)forgotPassword:(UIButton *)sender
{
    SAMCNewRequestViewController *vc = [[SAMCNewRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
