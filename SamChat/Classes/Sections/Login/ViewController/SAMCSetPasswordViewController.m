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
#import "SAMCUserManager.h"
#import "SAMCPadImageView.h"
#import "SAMCStepperView.h"
#import "SAMCUserAgreementViewController.h"

@interface SAMCSetPasswordViewController ()

@property (nonatomic, strong) SAMCStepperView *stepperView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *usernameCheckLabel;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UILabel *agreeLabel;
@property (nonatomic, strong) UIButton *termsButton;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) NSLayoutConstraint *doneButtonBottomContraint;

@property (nonatomic, assign) BOOL isUsernameExists;

@end

@implementation SAMCSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isUsernameExists = NO;
    if (self.isSignupOperation) {
        self.navigationItem.title = @"Sign Up";
        [self setupSignUpViews];
    } else {
        self.navigationItem.title = @"Reset Password";
        [self setupResetPasswordViews];
    }
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isSignupOperation) {
        [self.usernameTextField becomeFirstResponder];
    } else {
        [self.passwordTextField becomeFirstResponder];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    if (self.isSignupOperation) {
//        [self.usernameTextField becomeFirstResponder];
//    } else {
//        [self.passwordTextField becomeFirstResponder];
//    }
//}

- (void)setupSignUpViews
{
    [self.view addSubview:self.stepperView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.usernameCheckLabel];
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.agreeLabel];
    [self.view addSubview:self.termsButton];
    
    self.tipLabel.text = @"Enter your login details";
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stepperView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [_stepperView addConstraint:[NSLayoutConstraint constraintWithItem:_stepperView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:72.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_usernameCheckLabel]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameCheckLabel)]];
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_termsButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_termsButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepperView(12)]-22-[_tipLabel]-10-[_usernameCheckLabel]-10-[_usernameTextField(40)]-30-[_passwordTextField(40)]-20-[_agreeLabel]-0-[_termsButton(20)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepperView,_tipLabel,_usernameCheckLabel,_usernameTextField,_passwordTextField,_agreeLabel,_termsButton)]];
}

- (void)setupResetPasswordViews
{
    [self.view addSubview:self.stepperView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.passwordTextField];
    
    self.tipLabel.text = @"Enter your new password";
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stepperView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [_stepperView addConstraint:[NSLayoutConstraint constraintWithItem:_stepperView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:72.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tipLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_passwordTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepperView]-22-[_tipLabel]-30-[_passwordTextField(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepperView,_tipLabel,_passwordTextField)]];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *view = (UIView *)[touch view];
    if (view == self.view) {
        [self.view endEditing:YES];
    }
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

- (void)touchTerms:(id)sender
{
    SAMCUserAgreementViewController *vc = [[SAMCUserAgreementViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)signUp
{
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
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

- (void)checkExistOfUsername:(NSString *)username
{
    __weak typeof(self) wself = self;
    [[SAMCUserManager sharedManager] checkExistOfUser:username completion:^(BOOL isExists, NSError * _Nullable error) {
        DDLogDebug(@"checkExistOfUsername:%@ isExists:%@", username, isExists?@"YES":@"NO");
        if ([wself.usernameTextField.text isEqualToString:username]) {
            wself.isUsernameExists = isExists;
            wself.doneButton.enabled = [self isAllInputOK];
            SAMCPadImageView *rightView = (SAMCPadImageView *)self.usernameTextField.rightView;
            if (error == nil) {
                if (isExists) {
                   [rightView setImage:[UIImage imageNamed:@"ico_warning"]];
                } else {
                   [rightView setImage:[UIImage imageNamed:@"ico_check"]];
                }
            }
        }
    }];
}

- (void)showPassword:(UIButton *)sender
{
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    // fix cursor location unchanged issue
    NSString *tempString = self.passwordTextField.text;
    self.passwordTextField.text = @"";
    self.passwordTextField.text = tempString;
}

- (BOOL)isPasswordFormatOK
{
    NSString *password = self.passwordTextField.text;
    return ([password length] && [password rangeOfString:@" "].location == NSNotFound);
}

- (BOOL)isUsernameValid
{
    if (!self.signupOperation) {
        return YES;
    }
    return ([self.usernameTextField.text length] && (!self.isUsernameExists));
}

- (BOOL)isAllInputOK
{
    BOOL isOk = ([self isPasswordFormatOK] && [self isUsernameValid]);
    if (isOk) {
        self.doneButton.enabled = YES;
        self.doneButton.backgroundColor = SAMC_COLOR_GREEN;
    } else {
        self.doneButton.enabled = NO;
        self.doneButton.backgroundColor = UIColorFromRGBA(SAMC_COLOR_RGB_GREEN, 0.5);
    }
    return isOk;
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
- (SAMCStepperView *)stepperView
{
    if (_stepperView == nil) {
        _stepperView = [[SAMCStepperView alloc] initWithFrame:CGRectZero step:3 color:SAMC_COLOR_GREEN];
        _stepperView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _stepperView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _tipLabel.textColor = SAMC_COLOR_INK;
    }
    return _tipLabel;
}

- (UILabel *)usernameCheckLabel
{
    if (_usernameCheckLabel == nil) {
        _usernameCheckLabel = [[UILabel alloc] init];
        _usernameCheckLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameCheckLabel.font = [UIFont systemFontOfSize:13.0f];
        _usernameCheckLabel.numberOfLines = 0;
        _usernameCheckLabel.textAlignment = NSTextAlignmentCenter;
        _usernameCheckLabel.textColor = SAMC_COLOR_RED;
        _usernameCheckLabel.text = @" ";
    }
    return _usernameCheckLabel;
}

- (UITextField *)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _usernameTextField.layer.cornerRadius = 5.0f;
        _usernameTextField.backgroundColor = [UIColor whiteColor];
        _usernameTextField.font = [UIFont systemFontOfSize:17.0f];
        _usernameTextField.placeholder = @"Username";
        _usernameTextField.returnKeyType = UIReturnKeyNext;
        [_usernameTextField addTarget:self action:@selector(usernameTextFieldEditingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_usernameTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_usernameTextField addTarget:self action:@selector(usernameTextFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
        
        _usernameTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_option_username"]
                                                                     hpadding:15.0f
                                                                     vpadding:15.0f];
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        
        SAMCPadImageView *rightView = [[SAMCPadImageView alloc] initWithImage:nil hpadding:15.0f vpadding:15.0f];
        _usernameTextField.rightView = rightView;
        _usernameTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTextField.layer.cornerRadius = 5.0f;
        _passwordTextField.backgroundColor = [UIColor whiteColor];
        _passwordTextField.font = [UIFont systemFontOfSize:17.0f];
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.placeholder = @"Password";
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        [_passwordTextField addTarget:self action:@selector(touchDoneButton:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_passwordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_passwordTextField addTarget:self action:@selector(passwordTextFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
        
        _passwordTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]
                                                                     hpadding:15.0f
                                                                     vpadding:15.0f];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton *showPWDButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [showPWDButton setImage:[UIImage imageNamed:@"login_pwd_eye"] forState:UIControlStateNormal];
        showPWDButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [showPWDButton addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
        self.passwordTextField.rightView = showPWDButton;
        self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _passwordTextField;
}

- (UILabel *)agreeLabel
{
    if (_agreeLabel == nil) {
        _agreeLabel = [[UILabel alloc] init];
        _agreeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _agreeLabel.font = [UIFont systemFontOfSize:13.0f];
        _agreeLabel.numberOfLines = 0;
        _agreeLabel.textAlignment = NSTextAlignmentCenter;
        _agreeLabel.textColor = SAMC_COLOR_BODY_MID;
        _agreeLabel.text = @"By clicking Confirm, I accept to the SamChat";
    }
    return _agreeLabel;
}

- (UIButton *)termsButton
{
    if (_termsButton == nil) {
        _termsButton = [[UIButton alloc] init];
        _termsButton.translatesAutoresizingMaskIntoConstraints = NO;
        _termsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _termsButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        [_termsButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
        [_termsButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5) forState:UIControlStateHighlighted];
        _termsButton.backgroundColor = [UIColor clearColor];
        [_termsButton setTitle:@"Terms of Use and User Agreement" forState:UIControlStateNormal];
        [_termsButton addTarget:self action:@selector(touchTerms:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _termsButton;
}

- (void)setIsUsernameExists:(BOOL)isUsernameExists
{
    _isUsernameExists = isUsernameExists;
    if (isUsernameExists) {
        self.usernameCheckLabel.text = @"Ooops, username already token. Try a combination of letters and numbers";
        self.usernameTextField.textColor = SAMC_COLOR_RED;
        SAMCPadImageView *leftView = (SAMCPadImageView *)self.usernameTextField.leftView;
        [leftView setImage:[UIImage imageNamed:@"signup_username_wrong"]];
    } else {
        self.usernameCheckLabel.text = @" ";
        self.usernameTextField.textColor = UIColorFromRGB(0x3B4E6E);
        SAMCPadImageView *leftView = (SAMCPadImageView *)self.usernameTextField.leftView;
        [leftView setImage:[UIImage imageNamed:@"ico_option_username"]];
    }
}

#pragma mark -
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

- (void)usernameTextFieldDidChangedEditing:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.isUsernameExists = NO;
    SAMCPadImageView *rightView = (SAMCPadImageView *)self.usernameTextField.rightView;
    [rightView setImage:nil];
    NSString *username = self.usernameTextField.text;
    [self isAllInputOK];
    if ([username length] <= 0) {
        return;
    }
    [self performSelector:@selector(checkExistOfUsername:) withObject:username afterDelay:2];
}

- (void)passwordTextFieldDidChangedEditing:(id)sender
{
    [self isAllInputOK];
}

@end
