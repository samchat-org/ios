//
//  SAMCSetPasswordViewController.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSetPasswordViewController.h"
#import "SAMCTextField.h"
#import "SAMCAccountManager.h"
#import "SAMCDeviceUtil.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCPreferenceManager.h"
#import "SAMCLoginViewController.h"

@interface SAMCSetPasswordViewController ()

@property (nonatomic, strong) SAMCTextField *usernameTextField;
@property (nonatomic, strong) SAMCTextField *passwordTextField;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UILabel *agreeLabel;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) NSLayoutConstraint *doneButtonBottomContraint;

@end

@implementation SAMCSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isSignupOperation) {
        self.navigationItem.title = @"Sign Up";
        [self setupSignUpViews];
    } else {
        self.navigationItem.title = @"Reset Password";
        [self setupResetPasswordViews];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupDoneButton];
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
    if (self.isSignupOperation) {
        [self.usernameTextField.rightTextField becomeFirstResponder];
    } else {
        [self.passwordTextField.rightTextField becomeFirstResponder];
    }
}

- (void)setupSignUpViews
{
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.agreeButton];
    [self.view addSubview:self.agreeLabel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_usernameTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_passwordTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_agreeButton(20)]-10-[_agreeLabel]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_agreeButton,_agreeLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_usernameTextField(50)]-20-[_passwordTextField(50)]-20-[_agreeButton(20)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField,_passwordTextField,_agreeButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_agreeButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_agreeLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (void)setupResetPasswordViews
{
    [self.view addSubview:self.passwordTextField];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_passwordTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_passwordTextField(50)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
}

- (void)setupDoneButton
{
    _doneButton = [[UIButton alloc] init];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _doneButton.backgroundColor = [UIColor grayColor];
    _doneButton.layer.cornerRadius = 5.0f;
    [_doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_doneButton addTarget:self action:@selector(touchDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    if (self.isSignupOperation) {
        _doneButton.enabled = false;
    }
    [self.view addSubview:_doneButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_doneButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_doneButton)]];
    [_doneButton addConstraint:[NSLayoutConstraint constraintWithItem:_doneButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                             constant:50.0f]];
    self.doneButtonBottomContraint = [NSLayoutConstraint constraintWithItem:_doneButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:-20.0f];
    [self.view addConstraint:self.doneButtonBottomContraint];
}

#pragma mark - Action
- (void)usernameTextFieldEditingDidEndOnExit
{
    [self.passwordTextField.rightTextField becomeFirstResponder];
}

- (void)touchAgreeButton:(UIButton *)sender
{
    _agreeButton.selected = !_agreeButton.selected;
    self.doneButton.enabled = _agreeButton.selected;
}

- (void)touchDoneButton:(UIButton *)sender
{
    if (self.isSignupOperation) {
        [self signUp];
    } else {
        [self resetPassword];
    }
}

- (void)signUp
{
    NSString *username = self.usernameTextField.rightTextField.text;
    NSString *password = self.passwordTextField.rightTextField.text;
    if ([self isPasswordFormatOK:password]) {
        [self.view makeToast:@"password format wrong" duration:2.0f position:CSToastPositionCenter];
        return;
    }
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"signing up" maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCAccountManager sharedManager] registerWithCountryCode:self.countryCode cellPhone:self.phoneNumber verifyCode:self.verifyCode username:username password:password completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            if (error.code == SAMCServerErrorNetEaseLoginFailed) {
                [wself setupLoginViewControllerWithToast:@"register success, login now"];
            } else {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            }
            return;
        }
        extern NSString *SAMCLoginNotification;
        [[NSNotificationCenter defaultCenter] postNotificationName:SAMCLoginNotification object:nil userInfo:nil];
    }];
}

- (void)resetPassword
{
    NSString *password = self.passwordTextField.rightTextField.text;
    if ([self isPasswordFormatOK:password]) {
        [self.view makeToast:@"password format wrong" duration:2.0f position:CSToastPositionCenter];
        return;
    }
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"resetting password" maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCAccountManager sharedManager] findPWDUpdateWithCountryCode:self.countryCode cellPhone:self.phoneNumber verifyCode:self.verifyCode password:password completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        [wself setupLoginViewControllerWithToast:@"reset password success, login now"];
    }];
}

- (void)setupLoginViewControllerWithToast:(NSString *)toast
{
    [SAMCPreferenceManager sharedManager].currentUserMode = SAMCUserModeTypeCustom;
    SAMCLoginViewController *vc = [[SAMCLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = nav;
    [window makeToast:toast duration:2.0 position:CSToastPositionCenter];
}

- (BOOL)isPasswordFormatOK:(NSString *)password
{
    return ([password rangeOfString:@" "].location != NSNotFound);
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.doneButtonBottomContraint setConstant:-keyboardHeight-5];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.doneButtonBottomContraint setConstant:-20];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (SAMCTextField *)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[SAMCTextField alloc] init];
        _usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameTextField.rightTextField.placeholder = @"Enter a username";
        _usernameTextField.rightTextField.returnKeyType = UIReturnKeyNext;
        [_usernameTextField.rightTextField addTarget:self action:@selector(usernameTextFieldEditingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    return _usernameTextField;
}

- (SAMCTextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[SAMCTextField alloc] init];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.rightTextField.secureTextEntry = YES;
        _passwordTextField.rightTextField.placeholder = @"Enter your password";
        _passwordTextField.rightTextField.returnKeyType = UIReturnKeyDone;
        [_passwordTextField.rightTextField addTarget:self action:@selector(touchDoneButton:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    return _passwordTextField;
}

- (UIButton *)agreeButton
{
    if (_agreeButton == nil) {
        _agreeButton = [[UIButton alloc] init];
        _agreeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_agreeButton addTarget:self action:@selector(touchAgreeButton:) forControlEvents:UIControlEventTouchUpInside];
        [_agreeButton setBackgroundImage:[UIImage imageNamed:@"icon_checkbox_background"] forState:UIControlStateNormal];
        [_agreeButton setBackgroundImage:[UIImage imageNamed:@"icon_checkbox_selected"] forState:UIControlStateSelected];
    }
    return _agreeButton;
}

- (UILabel *)agreeLabel
{
    if (_agreeLabel == nil) {
        _agreeLabel = [[UILabel alloc] init];
        _agreeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _agreeLabel.textColor = [UIColor grayColor];
        [_agreeLabel setText:@"I agree with SamChat User Agreement"];
    }
    return _agreeLabel;
}


@end
