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

@property (nonatomic, strong) UIImageView *stepImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) UILabel *detailLabel;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    self.view.backgroundColor = UIColorFromRGB(0xECEDF0);
    
    self.stepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_step1"]];
    self.stepImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.stepImageView];
    
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.tipLabel.textColor = UIColorFromRGB(0x3B4E6E);
    self.tipLabel.text = @"Enter your phone number";
    [self.view addSubview:self.tipLabel];

    self.phoneTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.phoneTextField.leftButton setTitle:self.countryCode?:@"+1" forState:UIControlStateNormal];
    [self.phoneTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.phoneTextField.rightTextField addTarget:self action:@selector(phoneNumberEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    self.phoneTextField.rightTextField.placeholder = @"Your phone number";
    self.phoneTextField.rightTextField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:self.phoneTextField];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.font = [UIFont systemFontOfSize:14.0f];
    self.detailLabel.textColor = [UIColor grayColor];
    self.detailLabel.text = @"A confirmation code will be sent to the phone number your entered via SMS";
    [self.view addSubview:self.detailLabel];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.exclusiveTouch = YES;
    self.sendButton.layer.cornerRadius = 17.5f;
    self.sendButton.backgroundColor = UIColorFromRGB(0xA9E0A7);
    self.sendButton.enabled = NO;
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.sendButton setTitle:SAMC_SEND_CONFIRMATION_CODE forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.sendButton addTarget:self action:@selector(sendConfirmationCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-35-[_detailLabel]-35-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_detailLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepImageView(15)]-20-[_tipLabel(35)]-20-[_phoneTextField(35)]-20-[_detailLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepImageView,_tipLabel,_phoneTextField,_detailLabel)]];
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
                                                                 constant:35.0f]];
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

- (void)phoneNumberEditingChanged:(id)sender
{
    if ([self isValidCellphone:self.phoneTextField.rightTextField.text]) {
        self.sendButton.enabled = YES;
        self.sendButton.backgroundColor = UIColorFromRGB(0x67D45F);
    } else {
        self.sendButton.enabled = NO;
        self.sendButton.backgroundColor = UIColorFromRGB(0xA9E0A7);
    }
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
        
        void (^completionBlock)(NSError *) = ^(NSError * _Nullable error){
            [SVProgressHUD dismiss];
            if (error) {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
                return;
            }
            [wself pushToConfirmPhoneCodeView];
            [sender startWithCountDownSeconds:60 title:@"Next"];
        };
        if (self.isSignupOperation) {
            [[SAMCAccountManager sharedManager] registerCodeRequestWithCountryCode:self.countryCode
                                                                         cellPhone:self.phoneNumber
                                                                        completion:completionBlock];
        } else {
            [[SAMCAccountManager sharedManager] findPWDCodeRequestWithCountryCode:self.countryCode
                                                                        cellPhone:self.phoneNumber
                                                                       completion:completionBlock];
        }
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
