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

@property (nonatomic, strong) UIImageView *stepImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *usernameCheckLabel;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
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
    self.view.backgroundColor = SAMC_MAIN_BACKGROUNDCOLOR;
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
        [self.usernameTextField becomeFirstResponder];
    } else {
        [self.passwordTextField becomeFirstResponder];
    }
}

- (void)setupSignUpViews
{
    [self.view addSubview:self.stepImageView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.agreeLabel];
    
    self.tipLabel.text = @"Enter your login details";
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.stepImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_usernameTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_passwordTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_agreeLabel]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_agreeLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepImageView]-10-[_tipLabel]-10-[_usernameTextField(35)]-10-[_passwordTextField(35)]-10-[_agreeLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepImageView,_tipLabel,_usernameTextField,_passwordTextField,_agreeLabel)]];
}

- (void)setupResetPasswordViews
{
    [self.view addSubview:self.passwordTextField];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_passwordTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_passwordTextField(35)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
}

- (void)setupDoneButton
{
    _doneButton = [[UIButton alloc] init];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _doneButton.exclusiveTouch = YES;
    _doneButton.backgroundColor = UIColorFromRGB(0xA9E0A7);
    _doneButton.enabled = NO;
    _doneButton.layer.cornerRadius = 17.5f;
    [_doneButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_doneButton addTarget:self action:@selector(touchDoneButton:) forControlEvents:UIControlEventTouchUpInside];
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
                                                             constant:35.0f]];
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
    [self.passwordTextField becomeFirstResponder];
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
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    if ([self isPasswordFormatOK]) {
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
    NSString *password = self.passwordTextField.text;
    if ([self isPasswordFormatOK]) {
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

- (BOOL)isPasswordFormatOK
{
    NSString *password = self.passwordTextField.text;
    return ([password rangeOfString:@" "].location == NSNotFound);
}

- (BOOL)isUsernameValid
{
    if (!self.signupOperation) {
        return YES;
    }
    return YES; // TODO: add username check
}

- (BOOL)isAllInputOK
{
    return ([self isPasswordFormatOK] && [self isUsernameValid]);
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
- (UIImageView *)stepImageView
{
    if (_stepImageView == nil) {
        _stepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_step3"]];
        _stepImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _stepImageView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _tipLabel.textColor = UIColorFromRGB(0x3B4E6E);
    }
    return _tipLabel;
}

- (UILabel *)usernameCheckLabel
{
    if (_usernameCheckLabel == nil) {
        _usernameCheckLabel = [[UILabel alloc] init];
        _usernameCheckLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameCheckLabel.font = [UIFont systemFontOfSize:14.0f];
        _usernameCheckLabel.numberOfLines = 0;
        _usernameCheckLabel.textColor = UIColorFromRGB(0xFF883A);
    }
    return _usernameCheckLabel;
}

- (UITextField *)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameTextField.layer.cornerRadius = 5.0f;
        _usernameTextField.backgroundColor = [UIColor whiteColor];
        _usernameTextField.font = [UIFont systemFontOfSize:15.0f];
        _usernameTextField.placeholder = @"Username";
        _usernameTextField.returnKeyType = UIReturnKeyNext;
        [_usernameTextField addTarget:self action:@selector(usernameTextFieldEditingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_usernameTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_usernameTextField addTarget:self action:@selector(textFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
        
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [leftView setImage:[UIImage imageNamed:@"signup_username"]];
        leftView.contentMode = UIViewContentModeScaleAspectFit;
        _usernameTextField.leftView = leftView;
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.layer.cornerRadius = 5.0f;
        _passwordTextField.backgroundColor = [UIColor whiteColor];
        _passwordTextField.font = [UIFont systemFontOfSize:15.0f];
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.placeholder = @"Password";
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        [_passwordTextField addTarget:self action:@selector(touchDoneButton:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_passwordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_passwordTextField addTarget:self action:@selector(textFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
        
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [leftView setImage:[UIImage imageNamed:@"signup_password"]];
        leftView.contentMode = UIViewContentModeScaleAspectFit;
        _passwordTextField.leftView = leftView;
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _passwordTextField;
}

- (UILabel *)agreeLabel
{
    if (_agreeLabel == nil) {
        _agreeLabel = [[UILabel alloc] init];
        _agreeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _agreeLabel.font = [UIFont systemFontOfSize:12.0f];
        _agreeLabel.numberOfLines = 0;
        _agreeLabel.textAlignment = NSTextAlignmentCenter;
        _agreeLabel.textColor = UIColorFromRGB(0x61829C);
        _agreeLabel.text = @"By clicking Confirm, I accept to the SamChat Terms of Use and User Agreement";
    }
    return _agreeLabel;
}

#pragma mark -
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

- (void)textFieldDidChangedEditing:(UITextField *)textField
{
    if ([self isAllInputOK]) {
        _doneButton.enabled = YES;
        _doneButton.backgroundColor = UIColorFromRGB(0x67D45F);
    } else {
        _doneButton.enabled = NO;
        _doneButton.backgroundColor = UIColorFromRGB(0xA9E0A7);
    }
}

@end
