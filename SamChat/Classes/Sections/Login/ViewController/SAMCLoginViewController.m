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
#import "NIMSDK.h"
#import "NTESLoginManager.h"
#import "SVProgressHUD.h"
#import "NSString+NTES.h"
#import "UIView+Toast.h"
#import "NTESService.h"
#import "SAMCAccountManager.h"

@interface SAMCLoginViewController ()

@property (nonatomic, strong) SAMCTextField *usernameTextField;
@property (nonatomic, strong) SAMCTextField *passwordTextField;
@property (nonatomic, strong) UIButton *signinButton;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) NSLayoutConstraint *bottomSpaceConstraint;

@end

@implementation SAMCLoginViewController

NTES_USE_CLEAR_BAR
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.usernameTextField.rightTextField becomeFirstResponder];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.usernameTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.usernameTextField.leftButton setTitle:@"+1" forState:UIControlStateNormal];
    [self.usernameTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.usernameTextField.rightTextField addTarget:self action:@selector(usernameTextFieldEditingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.usernameTextField.rightTextField.returnKeyType = UIReturnKeyNext;
    self.usernameTextField.rightTextField.placeholder = @"Username or phone no.";
    [self.view addSubview:self.usernameTextField];
    
    self.passwordTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.passwordTextField.leftButton setTitle:@"Pass" forState:UIControlStateNormal];
    [self.passwordTextField.rightTextField addTarget:self action:@selector(signin:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.passwordTextField.rightTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.rightTextField.placeholder = @"Enter your password";
    self.passwordTextField.rightTextField.secureTextEntry = YES;
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_signupButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_signupButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_forgotPasswordButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_forgotPasswordButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.signupButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.forgotPasswordButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_usernameTextField(50)]-10-[_passwordTextField(50)]-10-[_signinButton(50)]-10-[_signupButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField,_passwordTextField,_signinButton,_signupButton)]];
    self.bottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.signupButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:-20.0f];
    [self.view addConstraint:self.bottomSpaceConstraint];
}

#pragma mark 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *view = (UIView *)[touch view];
    if (view == self.view) {
        [self.usernameTextField.rightTextField resignFirstResponder];
        [self.passwordTextField.rightTextField resignFirstResponder];
    }
}

#pragma mark - Action
- (void)usernameTextFieldEditingDidEndOnExit
{
    [self.passwordTextField.rightTextField becomeFirstResponder];
}

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
    extern NSString *SAMCLoginNotification;
    [_usernameTextField.rightTextField resignFirstResponder];
    [_passwordTextField.rightTextField resignFirstResponder];
    
    NSString *countryCode = _usernameTextField.leftButton.titleLabel.text;
    countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *account = [_usernameTextField.rightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = _passwordTextField.rightTextField.text;
    [SVProgressHUD showWithStatus:@"login" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCAccountManager sharedManager] loginWithCountryCode:countryCode account:account password:password completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
            [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SAMCLoginNotification object:nil userInfo:nil];
    }];
}

- (void)signup:(UIButton *)sender
{
    SAMCConfirmPhoneNumViewController *vc = [[SAMCConfirmPhoneNumViewController alloc] init];
    vc.signupOperation = YES;
    vc.countryCode = self.usernameTextField.leftButton.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)forgotPassword:(UIButton *)sender
{
    SAMCConfirmPhoneNumViewController *vc = [[SAMCConfirmPhoneNumViewController alloc] init];
    vc.signupOperation = NO;
    vc.countryCode = self.usernameTextField.leftButton.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.bottomSpaceConstraint setConstant:-keyboardHeight-5];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.bottomSpaceConstraint setConstant:-20];
                         [self.view layoutIfNeeded];
                     }];
}


@end
