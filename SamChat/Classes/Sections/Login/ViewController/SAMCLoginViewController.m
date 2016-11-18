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
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "SAMCAccountManager.h"
#import "SAMCGradientButton.h"
#import "NSString+SAMC.h"

@interface SAMCLoginViewController ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) SAMCTextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) SAMCGradientButton *signinButton;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) NSLayoutConstraint *bottomSpaceConstraint;
@property (nonatomic, strong) NSLayoutConstraint *logoBottonSpaceContraint;

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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.usernameTextField.rightTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    _gradientLayer = [[CAGradientLayer alloc] init];
    _gradientLayer.startPoint = CGPointMake(1, 1);
    _gradientLayer.endPoint = CGPointMake(1, 0);
    _gradientLayer.colors = @[(__bridge id)SAMC_COLOR_DARKBLUE_GRADIENT_DARK.CGColor,(__bridge id)SAMC_COLOR_DARKBLUE_GRADIENT_LIGHT.CGColor];
    [self.view.layer addSublayer:_gradientLayer];
    
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_BKG_signin"]];
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.logoImageView];
    
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.signinButton];
    [self.view addSubview:self.signupButton];
    [self.view addSubview:self.forgotPasswordButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_usernameTextField]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_passwordTextField]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_signinButton]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_signinButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_signupButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_signupButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_forgotPasswordButton]-32-|"
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_usernameTextField(40)]-20-[_passwordTextField(40)]-20-[_signinButton(40)]-10-[_signupButton(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField,_passwordTextField,_signinButton,_signupButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.logoImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    self.bottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.signupButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:-20.0f];
    [self.view addConstraint:self.bottomSpaceConstraint];
    self.logoBottonSpaceContraint = [NSLayoutConstraint constraintWithItem:self.logoImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:-20.0f];
    [self.view addConstraint:self.logoBottonSpaceContraint];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _gradientLayer.frame = self.view.bounds;
}

#pragma mark 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *view = (UIView *)[touch view];
    if (view == self.view) {
        [self.usernameTextField.rightTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
    }
}

#pragma mark - Action
- (void)textFieldEditingChanged:(UITextField *)textField
{
    NSString *username = self.usernameTextField.rightTextField.text;
    NSString *password = self.passwordTextField.text;
    if ([username samc_isValidUsername] && [password samc_isValidPassword]) {
        self.signinButton.enabled = YES;
        self.signinButton.gradientLayer.colors = @[(__bridge id)SAMC_COLOR_GRASSFIELD_GRADIENT_DARK.CGColor,
                                                   (__bridge id)SAMC_COLOR_GRASSFIELD_GRADIENT_LIGHT.CGColor];
    } else {
        self.signinButton.enabled = NO;
        self.signinButton.gradientLayer.colors = nil;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

- (void)usernameTextFieldEditingDidEndOnExit
{
    [self.passwordTextField becomeFirstResponder];
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

- (void)showPassword:(UIButton *)sender
{
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    UIButton *showPWDButton = (UIButton *)self.passwordTextField.rightView;
    NSString *showImageName = self.passwordTextField.secureTextEntry ? @"ico_showpw_dark_dim" : @"ico_showpw_dark_full";
    [showPWDButton setImage:[UIImage imageNamed:showImageName] forState:UIControlStateNormal];
    // fix cursor location unchanged issue
    NSString *tempString = self.passwordTextField.text;
    self.passwordTextField.text = @"";
    self.passwordTextField.text = tempString;
}

- (void)signin:(UIButton *)sender
{
    if (self.signinButton.enabled == NO) {
        return;
    }
    [SVProgressHUD showWithStatus:@"login" maskType:SVProgressHUDMaskTypeBlack];
    extern NSString *SAMCLoginNotification;
    [_usernameTextField.rightTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    NSString *countryCode = _usernameTextField.leftButton.titleLabel.text;
    if ([countryCode isEqualToString:@"USA"]) {
        countryCode = @"1";
    } else {
        countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    NSString *account = [_usernameTextField.rightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    NSString *countryCode = self.usernameTextField.leftButton.titleLabel.text;
    if ([countryCode hasPrefix:@"+"]) {
        vc.countryCode = self.usernameTextField.leftButton.titleLabel.text;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)forgotPassword:(UIButton *)sender
{
    SAMCConfirmPhoneNumViewController *vc = [[SAMCConfirmPhoneNumViewController alloc] init];
    vc.signupOperation = NO;
    NSString *countryCode = self.usernameTextField.leftButton.titleLabel.text;
    if ([countryCode hasPrefix:@"+"]) {
        vc.countryCode = self.usernameTextField.leftButton.titleLabel.text;
    }
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
                         CGFloat h = 220+keyboardHeight - self.view.frame.size.height/2;
                         h = MAX(h, 150);
                         [self.logoBottonSpaceContraint setConstant:-h];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.bottomSpaceConstraint setConstant:-20];
                         [self.logoBottonSpaceContraint setConstant:-20.f];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (SAMCTextField *)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
        _usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameTextField.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.2);
        [_usernameTextField.leftButton setTitle:@"USA" forState:UIControlStateNormal];
        [_usernameTextField.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_usernameTextField.leftButton setTitleColor:SAMC_COLOR_TEXT_HINT_DARK forState:UIControlStateHighlighted];
        [_usernameTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
        _usernameTextField.rightTextField.returnKeyType = UIReturnKeyNext;
        _usernameTextField.rightTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username or moible no." attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_TEXT_HINT_DARK, NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        _usernameTextField.rightTextField.textColor = [UIColor whiteColor];
        [_usernameTextField.rightTextField addTarget:self action:@selector(usernameTextFieldEditingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_usernameTextField.rightTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_usernameTextField.rightTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.2);
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_TEXT_HINT_DARK, NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        _passwordTextField.textColor = [UIColor whiteColor];
        _passwordTextField.layer.cornerRadius = 6.0f;
        _passwordTextField.leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        UIButton *showPWDButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [showPWDButton setImage:[UIImage imageNamed:@"ico_showpw_dark_dim"] forState:UIControlStateNormal];
        showPWDButton.imageView.contentMode = UIViewContentModeCenter;
        [showPWDButton addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
        _passwordTextField.rightView = showPWDButton;
        _passwordTextField.rightViewMode = UITextFieldViewModeAlways;
        [_passwordTextField addTarget:self action:@selector(signin:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_passwordTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_passwordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _passwordTextField;
}

- (SAMCGradientButton *)signinButton
{
    if (_signinButton == nil) {
        _signinButton = [[SAMCGradientButton alloc] initWithFrame:CGRectZero];
        _signinButton.translatesAutoresizingMaskIntoConstraints = NO;
        _signinButton.exclusiveTouch = YES;
        _signinButton.layer.cornerRadius = 20.0f;
        _signinButton.layer.masksToBounds = YES;
        _signinButton.backgroundColor = SAMC_COLOR_GREY;
        _signinButton.gradientLayer.cornerRadius = 20.0f;
        _signinButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_signinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signinButton setTitleColor:SAMC_COLOR_TEXT_HINT_DARK forState:UIControlStateHighlighted];
        [_signinButton setTitle:@"Sign In" forState:UIControlStateNormal];
        [_signinButton addTarget:self action:@selector(signin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signinButton;
}

- (UIButton *)signupButton
{
    if (_signupButton == nil) {
        _signupButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _signupButton.translatesAutoresizingMaskIntoConstraints = NO;
        _signupButton.exclusiveTouch = YES;
        _signupButton.backgroundColor = [UIColor clearColor];
        _signupButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [_signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [_signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signupButton setTitleColor:SAMC_COLOR_TEXT_HINT_DARK forState:UIControlStateHighlighted];
        [_signupButton addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signupButton;
}

- (UIButton *)forgotPasswordButton
{
    if (_forgotPasswordButton == nil) {
        _forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = NO;
        _forgotPasswordButton.exclusiveTouch = YES;
        _forgotPasswordButton.backgroundColor = [UIColor clearColor];
        _forgotPasswordButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _forgotPasswordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_forgotPasswordButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
        [_forgotPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_forgotPasswordButton setTitleColor:SAMC_COLOR_TEXT_HINT_DARK forState:UIControlStateHighlighted];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgotPasswordButton;
}


@end
