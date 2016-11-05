//
//  SAMCSubmitCellPhoneViewController.m
//  SamChat
//
//  Created by HJ on 11/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSubmitCellPhoneViewController.h"
#import "SAMCMyProfileViewController.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "NSString+SAMCValidation.h"

@interface SAMCSubmitCellPhoneViewController ()

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *cellPhone;

@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *rightNavButton;

@end

@implementation SAMCSubmitCellPhoneViewController

- (instancetype)initWithCountryCode:(NSString *)countryCode
                          cellPhone:(NSString *)cellPhone
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _countryCode = countryCode;
        _cellPhone = cellPhone;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_codeTextField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.navigationItem.title = @"Verification Code";
    [self setupNavItem];
    
    [self.view addSubview:self.codeTextField];
    [self.view addSubview:self.tipLabel];
    NSString *countryCode = @"";;
    if ([self.countryCode length]) {
        countryCode = [NSString stringWithFormat:@"+%@ ", self.countryCode];
    }
    _tipLabel.text = [NSString stringWithFormat:@"Verification code has been sent to your phone:\r\r%@%@",countryCode, self.cellPhone];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_codeTextField]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_codeTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_codeTextField(40)]-10-[_tipLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_codeTextField, _tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_tipLabel]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
}

- (void)setupNavItem
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    _rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightNavButton addTarget:self action:@selector(onTouchSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [_rightNavButton setTitle:@"Submit" forState:UIControlStateNormal];
    [_rightNavButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
    [_rightNavButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateHighlighted];
    [_rightNavButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateDisabled];
    [_rightNavButton sizeToFit];
    UIBarButtonItem *rightNavItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavButton];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightNavItem];
    _rightNavButton.enabled = NO;
}

#pragma mark - Action
- (void)onTouchSubmit:(id)sender
{
    NSString *verifyCode = _codeTextField.text;
    [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCSettingManager sharedManager] editCellPhoneUpdateWithCountryCode:self.countryCode cellPhone:self.cellPhone verifyCode:verifyCode completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        UIViewController *myProfileVC;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[SAMCMyProfileViewController class]]) {
                myProfileVC = vc;
                break;
            }
        }
        if (myProfileVC) {
            [wself.navigationController popToViewController:myProfileVC animated:YES];
        } else {
            DDLogError(@"SAMCMyProfileViewController not found");
            [wself.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

- (void)codeTextFieldEditingChanged:(id)sender
{
    NSString *code = _codeTextField.text;
    _rightNavButton.enabled = [code samc_isValidVerificationCode];
}

#pragma mark - lazy load
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.numberOfLines = 0;
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
        _tipLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f);
    }
    return _tipLabel;
}

- (UITextField *)codeTextField
{
    if (_codeTextField == nil) {
        _codeTextField = [[UITextField alloc] init];
        _codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _codeTextField.backgroundColor = [UIColor whiteColor];
        _codeTextField.borderStyle = UITextBorderStyleNone;
        _codeTextField.font = [UIFont systemFontOfSize:17.0f];
        _codeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _codeTextField.textColor = SAMC_COLOR_INK;
        _codeTextField.placeholder = @"Enter code";
        _codeTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        _codeTextField.leftViewMode = UITextFieldViewModeAlways;
        _codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _codeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_codeTextField addTarget:self action:@selector(codeTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _codeTextField;
}


@end
