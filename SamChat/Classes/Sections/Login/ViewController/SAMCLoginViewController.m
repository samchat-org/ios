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

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) SAMCTextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *signinButton;
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

- (void)setupSubviews
{
    self.view.backgroundColor = UIColorFromRGB(0x174164);
    
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo"]];
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoImageView];
    
    self.usernameTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameTextField.backgroundColor = UIColorFromRGB(0x345470);
    [self.usernameTextField.leftButton setTitle:@"USA" forState:UIControlStateNormal];
    [self.usernameTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.usernameTextField.rightTextField addTarget:self action:@selector(usernameTextFieldEditingDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.usernameTextField.rightTextField.returnKeyType = UIReturnKeyNext;
    self.usernameTextField.rightTextField.placeholder = @"Username or phone no.";
    [self.usernameTextField.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.usernameTextField.rightTextField.textColor = [UIColor whiteColor];
    [self.view addSubview:self.usernameTextField];
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordTextField.backgroundColor = UIColorFromRGB(0x345470);
    [self.passwordTextField addTarget:self action:@selector(signin:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.placeholder = @"Enter your password";
    self.passwordTextField.textColor = [UIColor whiteColor];
    self.passwordTextField.layer.cornerRadius = 5.0f;
    self.passwordTextField.leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    UIButton *showPWDButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [showPWDButton setImage:[UIImage imageNamed:@"login_pwd_eye"] forState:UIControlStateNormal];
    showPWDButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [showPWDButton addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
    self.passwordTextField.rightView = showPWDButton;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.passwordTextField];
    
    self.signinButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.signinButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.signinButton.exclusiveTouch = YES;
    self.signinButton.layer.cornerRadius = 17.5f;
    self.signinButton.backgroundColor = [UIColor grayColor];
    self.signinButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.signinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signinButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.signinButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [self.signinButton addTarget:self action:@selector(signin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signinButton];
    
    self.signupButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.signupButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.signupButton.exclusiveTouch = YES;
    self.signupButton.backgroundColor = [UIColor clearColor];
    self.signupButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.signupButton addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signupButton];
    
    self.forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.forgotPasswordButton.exclusiveTouch = YES;
    self.forgotPasswordButton.backgroundColor = [UIColor clearColor];
    self.forgotPasswordButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.forgotPasswordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.forgotPasswordButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_usernameTextField(35)]-10-[_passwordTextField(35)]-10-[_signinButton(35)]-10-[_signupButton]"
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
    [self.logoImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:0.0f
                                                                    constant:150.0f]];
    [self.logoImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:0.0f
                                                                    constant:150.0f]];
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
                                                                    toItem:self.usernameTextField
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:-100.0f];
    [self.view addConstraint:self.logoBottonSpaceContraint];
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
    // fix cursor location unchanged issue
    NSString *tempString = self.passwordTextField.text;
    self.passwordTextField.text = @"";
    self.passwordTextField.text = tempString;
}

- (void)signin:(UIButton *)sender
{
    extern NSString *SAMCLoginNotification;
    [_usernameTextField.rightTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    NSString *countryCode = _usernameTextField.leftButton.titleLabel.text;
    if ([countryCode isEqualToString:@"USA"]) {
        countryCode = @"";
    } else {
        countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    NSString *account = [_usernameTextField.rightTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = _passwordTextField.text;
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
                         [self.logoBottonSpaceContraint setConstant:-30.0f];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.bottomSpaceConstraint setConstant:-20];
                         [self.logoBottonSpaceContraint setConstant:-100.f];
                         [self.view layoutIfNeeded];
                     }];
}


@end
