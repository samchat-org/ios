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
#import "SAMCStepperView.h"

@interface SAMCConfirmPhoneCodeViewController ()<SAMCPhoneCodeViewDelegate>

@property (nonatomic, strong) SAMCStepperView *stepperView;
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
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    
    [self.view addSubview:self.stepperView];
    
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.textColor = SAMC_COLOR_INK;
    self.tipLabel.text = @"Enter the confirmation code";
    [self.view addSubview:self.tipLabel];
    
    self.phoneCodeView = [[SAMCPhoneCodeView alloc] initWithFrame:CGRectZero];
    self.phoneCodeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneCodeView.delegate = self;
    [self.view addSubview:self.phoneCodeView];
    
    self.splitLabel = [[UILabel alloc] init];
    self.splitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.splitLabel.backgroundColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.1);
    [self.view addSubview:self.splitLabel];
    
    self.phoneLabel = [[UILabel alloc] init];
    self.phoneLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    self.phoneLabel.textColor = SAMC_COLOR_INK;
    self.phoneLabel.textAlignment = NSTextAlignmentCenter;
    self.phoneLabel.text = [NSString stringWithFormat:@"+%@-%@",self.countryCode,self.phoneNumber];
    [self.view addSubview:self.phoneLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.font = [UIFont systemFontOfSize:15.0f];
    self.detailLabel.textColor = SAMC_COLOR_BODY_MID;
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.text = @"A confirmation code has been sent to your phone, enter the code to continue";
    [self.view addSubview:self.detailLabel];
    
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
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_tipLabel]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_phoneCodeView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_splitLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_splitLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_phoneLabel]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[_detailLabel]-48-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_detailLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepperView(12)]-22-[_tipLabel]-25-[_phoneCodeView(50)]-25-[_splitLabel(1)]-30-[_phoneLabel]-15-[_detailLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepperView,_tipLabel,_phoneCodeView,_splitLabel,_phoneLabel,_detailLabel)]];
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

#pragma mark - lazy load
- (SAMCStepperView *)stepperView
{
    if (_stepperView == nil) {
        _stepperView = [[SAMCStepperView alloc] initWithFrame:CGRectZero step:2 color:SAMC_COLOR_GREEN];
        _stepperView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _stepperView;
}

@end
