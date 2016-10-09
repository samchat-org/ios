//
//  SAMCConfirmPhoneCodeViewController.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConfirmPhoneCodeViewController.h"
#import "SAMCTextField.h"
#import "SAMCPhoneCodeView.h"
#import "SAMCSetPasswordViewController.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"

@interface SAMCConfirmPhoneCodeViewController ()<SAMCPhoneCodeViewDelegate>

@property (nonatomic, strong) UIImageView *stepImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCPhoneCodeView *phoneCodeView;
@property (nonatomic, strong) UILabel *splitLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation SAMCConfirmPhoneCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.phoneCodeView becomeFirstResponder];
}

- (void)setupSubviews
{
    if (self.isSignupOperation) {
        self.navigationItem.title = @"Sign Up";
    } else {
        self.navigationItem.title = @"Reset Password";
    }
    self.view.backgroundColor = SAMC_MAIN_BACKGROUNDCOLOR;
    
    self.stepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_step2"]];
    self.stepImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.stepImageView];
    
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.tipLabel.textColor = UIColorFromRGB(0x3B4E6E);
    self.tipLabel.text = @"Enter the confirmation code";
    [self.view addSubview:self.tipLabel];
    
    self.phoneCodeView = [[SAMCPhoneCodeView alloc] initWithFrame:CGRectZero];
    self.phoneCodeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneCodeView.delegate = self;
    [self.view addSubview:self.phoneCodeView];
    
    self.splitLabel = [[UILabel alloc] init];
    self.splitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.splitLabel.backgroundColor = UIColorFromRGB(0xE8EAED);
    [self.view addSubview:self.splitLabel];
    
    self.phoneLabel = [[UILabel alloc] init];
    self.phoneLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.phoneLabel.textColor = [UIColor grayColor];
    self.phoneLabel.textAlignment = NSTextAlignmentCenter;
    self.phoneLabel.text = [NSString stringWithFormat:@"+%@-%@",self.countryCode,self.phoneNumber];
    [self.view addSubview:self.phoneLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.font = [UIFont systemFontOfSize:14.0f];
    self.detailLabel.textColor = [UIColor grayColor];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.text = @"A confirmation code has been sent to your phone, enter the code to continue";
    [self.view addSubview:self.detailLabel];
    
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
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneCodeView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneCodeView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_splitLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_splitLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_phoneLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-35-[_detailLabel]-35-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_detailLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepImageView(15)]-10-[_tipLabel(35)]-10-[_phoneCodeView]-10-[_splitLabel(2)]-10-[_phoneLabel(35)]-10-[_detailLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepImageView,_tipLabel,_phoneCodeView,_splitLabel,_phoneLabel,_detailLabel)]];
}

#pragma mark - SAMCPhoneCodeViewDelegate
- (void)phonecodeCompleteInput:(SAMCPhoneCodeView *)view
{
    DDLogDebug(@"phone code:%@", view.phoneCode);
    NSString *verifyCode = view.phoneCode;
    [SVProgressHUD showWithStatus:@"Verifing" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    void (^completionBlock)(NSError *) = ^(NSError * _Nullable error){
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        SAMCSetPasswordViewController *vc = [[SAMCSetPasswordViewController alloc] init];
        vc.signupOperation = wself.isSignupOperation;
        vc.countryCode = self.countryCode;
        vc.phoneNumber = self.phoneNumber;
        vc.verifyCode = verifyCode;
        [self.navigationController pushViewController:vc animated:YES];
    };
    if (self.isSignupOperation) {
        [[SAMCAccountManager sharedManager] registerCodeVerifyWithCountryCode:self.countryCode
                                                                    cellPhone:self.phoneNumber
                                                                   verifyCode:verifyCode
                                                                   completion:completionBlock];
    } else {
        [[SAMCAccountManager sharedManager] findPWDCodeVerifyWithCountryCode:self.countryCode
                                                                   cellPhone:self.phoneNumber
                                                                  verifyCode:verifyCode
                                                                  completion:completionBlock];
    }
}

@end
