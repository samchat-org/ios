//
//  SAMCConfirmPhoneNumViewController.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConfirmPhoneNumViewController.h"
#import "SAMCCountryCodeViewController.h"
#import "SAMCTextField.h"
#import "SAMCConfirmPhoneCodeViewController.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCDeviceUtil.h"

@interface SAMCConfirmPhoneNumViewController ()

@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) NSLayoutConstraint *sendButtonBottomContraint;

@property (nonatomic, strong) NSString *phoneNumber;

@end

@implementation SAMCConfirmPhoneNumViewController

- (void)viewDidLoad
{
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
    [self.phoneTextField.rightTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    if (self.isSignupOperation) {
        self.navigationItem.title = @"Sign Up";
    } else {
        self.navigationItem.title = @"Reset Password";
    }
    self.view.backgroundColor = [UIColor whiteColor];

    self.phoneTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.phoneTextField.leftButton setTitle:self.countryCode?:@"+1" forState:UIControlStateNormal];
    self.phoneTextField.rightTextField.placeholder = @"Your phone number";
    self.phoneTextField.rightTextField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:self.phoneTextField];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.backgroundColor = [UIColor grayColor];
    [self.sendButton setTitle:@"Send Confirmation Code" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.sendButton addTarget:self action:@selector(sendConfirmationCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_phoneTextField(50)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_sendButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_sendButton)]];
    [self.sendButton addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:50.0f]];
    self.sendButtonBottomContraint = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:-20.0f];
    [self.view addConstraint:self.sendButtonBottomContraint];
}

#pragma mark - Action
- (void)sendConfirmationCode:(UIButton *)sender
{
    // TODO: add phone no. check
    self.phoneNumber = self.phoneTextField.rightTextField.text;
    NSString *countryCode = self.phoneTextField.leftButton.titleLabel.text;
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    DDLogDebug(@"sendConfirmationCode");
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"正在获取验证码" maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCAccountManager sharedManager] registerCodeRequestWithCountryCode:countryCode
                                                                 cellPhone:self.phoneNumber
                                                                  deviceId:deviceId
                                                                completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey]];
            return;
        }
        SAMCConfirmPhoneCodeViewController *vc = [[SAMCConfirmPhoneCodeViewController alloc] init];
        vc.signupOperation = wself.isSignupOperation;
        vc.countryCode = countryCode;
        vc.phoneNumber = wself.phoneNumber;
        [wself.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.sendButtonBottomContraint setConstant:-keyboardHeight-5];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.sendButtonBottomContraint setConstant:-20];
                         [self.view layoutIfNeeded];
                     }];
}

@end
