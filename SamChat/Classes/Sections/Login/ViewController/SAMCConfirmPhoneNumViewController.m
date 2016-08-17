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
#import "UIButton+SAMC.h"

#define SAMC_SEND_CONFIRMATION_CODE @"Send Confirmation Code"

@interface SAMCConfirmPhoneNumViewController ()

@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) NSLayoutConstraint *sendButtonBottomContraint;

@property (nonatomic, copy) NSString *phoneNumber;

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
    [self.phoneTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
    self.phoneTextField.rightTextField.placeholder = @"Your phone number";
    self.phoneTextField.rightTextField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:self.phoneTextField];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.backgroundColor = [UIColor grayColor];
    [self.sendButton setTitle:SAMC_SEND_CONFIRMATION_CODE forState:UIControlStateNormal];
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
- (void)selectCountryCode:(UIButton *)sender
{
    SAMCCountryCodeViewController *countryCodeController = [[SAMCCountryCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    countryCodeController.selectBlock = ^(NSString *text){
        [weakSelf.phoneTextField.leftButton setTitle:text forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:countryCodeController animated:YES];
}

- (void)sendConfirmationCode:(UIButton *)sender
{
    if ([sender.currentTitle isEqualToString:SAMC_SEND_CONFIRMATION_CODE]) {
        self.phoneNumber = self.phoneTextField.rightTextField.text;
        if (![self isValidCellphone:self.phoneNumber]) {
            [self.view makeToast:@"Invalid Phone Number" duration:2.0f position:CSToastPositionCenter];
            return;
        }
        NSString *countryCode = self.phoneTextField.leftButton.titleLabel.text;
        self.countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        [SVProgressHUD showWithStatus:@"正在获取验证码" maskType:SVProgressHUDMaskTypeBlack];
        __weak typeof(self) wself = self;
        [[SAMCAccountManager sharedManager] registerCodeRequestWithCountryCode:self.countryCode cellPhone:self.phoneNumber completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (error) {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
                return;
            }
            [wself pushToConfirmPhoneCodeView];
            [sender startWithCountDownSeconds:60 title:@"Next"];
        }];
    } else {
        [self pushToConfirmPhoneCodeView];
    }
}

- (void)pushToConfirmPhoneCodeView
{
    SAMCConfirmPhoneCodeViewController *vc = [[SAMCConfirmPhoneCodeViewController alloc] init];
    vc.signupOperation = self.isSignupOperation;
    vc.countryCode = self.countryCode;
    vc.phoneNumber = self.phoneNumber;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)isValidCellphone:(NSString *)cellphone
{
    if ((cellphone.length<5) || (cellphone.length>11)) {
        return false;
    }
    cellphone = [cellphone stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (cellphone.length > 0) {
        return false;
    }
    return true;
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
