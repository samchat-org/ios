//
//  SAMCEditCellPhoneViewController.m
//  SamChat
//
//  Created by HJ on 11/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCEditCellPhoneViewController.h"
#import "SAMCCountryCodeViewController.h"
#import "SAMCSubmitCellPhoneViewController.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCTextField.h"
#import "NSString+SAMC.h"

@interface SAMCEditCellPhoneViewController ()

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *cellPhone;

@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) UIButton *rightNavButton;

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation SAMCEditCellPhoneViewController

- (instancetype)initWithCountryCode:(NSString *)countryCode
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _countryCode = countryCode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self setupNavItem];
    [self setupPhoneNoViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_phoneTextField becomeFirstResponder];
}

- (void)setupNavItem
{
    [self.navigationItem setHidesBackButton:YES];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateHighlighted];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,cancelItem];
    
    _rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightNavButton addTarget:self action:@selector(onTouchNext:) forControlEvents:UIControlEventTouchUpInside];
    [_rightNavButton setTitle:@"Next" forState:UIControlStateNormal];
    [_rightNavButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
    [_rightNavButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateHighlighted];
    [_rightNavButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateDisabled];
    [_rightNavButton sizeToFit];
    UIBarButtonItem *rightNavItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavButton];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightNavItem];
    _rightNavButton.enabled = NO;
}

- (void)setupPhoneNoViews
{
    self.navigationItem.title = @"Change Phone";
    [self.view addSubview:self.phoneTextField];
    [self.view addSubview:self.tipLabel];
    _tipLabel.text = @"A confirmation code will be sent to the phone number your entered via SMS";
    if ([_countryCode length]) {
        _countryCode = [NSString stringWithFormat:@"+%@", _countryCode];
    } else {
        _countryCode = @"+1";
    }
    [_phoneTextField.leftButton setTitle:_countryCode forState:UIControlStateNormal];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_phoneTextField]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_phoneTextField(40)]-10-[_tipLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField,_tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_tipLabel]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
}

#pragma mark - Action
- (void)onCancel:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTouchNext:(id)sender
{
    [self sendConfirmationCode];
}

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
    NSString *phone = self.phoneTextField.rightTextField.text;
    _rightNavButton.enabled = [phone samc_isValidCellphone];
}

- (void)sendConfirmationCode
{
    self.cellPhone = self.phoneTextField.rightTextField.text;
    NSString *countryCode = self.phoneTextField.leftButton.titleLabel.text;
    self.countryCode = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCSettingManager sharedManager] editCellPhoneCodeRequestWithCountryCode:self.countryCode cellPhone:self.cellPhone completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        [wself pushToSubmitCellPhoneVC];
    }];
}

- (void)pushToSubmitCellPhoneVC
{
    SAMCSubmitCellPhoneViewController *vc = [[SAMCSubmitCellPhoneViewController alloc] initWithCountryCode:self.countryCode
                                                                                                 cellPhone:self.cellPhone];
    [self.navigationController pushViewController:vc animated:YES];
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

- (SAMCTextField *)phoneTextField
{
    if (_phoneTextField == nil) {
        _phoneTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneTextField.layer.cornerRadius = 0.0f;
        [_phoneTextField.leftButton setTitleColor:SAMC_COLOR_INK forState:UIControlStateNormal];
        [_phoneTextField.leftButton addTarget:self action:@selector(selectCountryCode:) forControlEvents:UIControlEventTouchUpInside];
        [_phoneTextField.rightTextField addTarget:self action:@selector(phoneNumberEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        _phoneTextField.splitLabel.backgroundColor = SAMC_COLOR_LIGHTGREY;
        _phoneTextField.rightTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your phone number" attributes:@{NSForegroundColorAttributeName:SAMC_COLOR_TEXT_HINT_LIGHT,NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
        _phoneTextField.rightTextField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _phoneTextField;
}

@end
