//
//  SAMCEditProfileViewController.m
//  SamChat
//
//  Created by HJ on 11/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCEditProfileViewController.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "NSString+SAMC.h"
#import "SAMCTextView.h"

@interface SAMCEditProfileViewController () <UITextViewDelegate>

@property (nonatomic, assign) SAMCEditProfileType profileType;
@property (nonatomic, strong) NSDictionary *profileDict;

@property (nonatomic, strong) UIBarButtonItem *rightNavItem;
@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *normalTextField;
@property (nonatomic, strong) SAMCTextView *descriptionTextView;

@property (nonatomic, weak) id currentEditView;

@end

@implementation SAMCEditProfileViewController

- (instancetype)initWithProfileType:(SAMCEditProfileType)profileType profileDict:(NSDictionary *)profileDict
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _profileType = profileType;
        _profileDict = profileDict;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_currentEditView) {
        [_currentEditView becomeFirstResponder];
    }
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    if (_profileType == SAMCEditProfileTypeEmail) {
        [self setupCommonViews];
        [self setupEmailViews];
    } else if (_profileType == SAMCEditProfileTypeSPCompanyName) {
        [self setupCommonViews];
        [self setupCompanyNameViews];
    } else if (_profileType == SAMCEditProfileTypeSPServiceCategory) {
        [self setupCommonViews];
        [self setupServiceCategoryViews];
    } else if (_profileType == SAMCEditProfileTypeSPPhone) {
        [self setupCommonViews];
        [self setupSPPhoneViews];
    } else if (_profileType == SAMCEditProfileTypeSPEmail) {
        [self setupCommonViews];
        [self setupSPEmailViews];
    } else if (_profileType == SAMCEditProfileTypeSPDescription) {
        [self setupSPDescriptionViews];
    }
}

- (void)setupNavItemOfUserMode:(SAMCUserModeType)userMode
{
    [self.navigationItem setHidesBackButton:YES];
    UIColor *activeColor;
    UIColor *inactiveColor;
    UIColor *pressedColor;
    if (userMode == SAMCUserModeTypeCustom) {
        activeColor = SAMC_COLOR_INGRABLUE;
        inactiveColor = UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f);
        pressedColor = UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f);
    } else {
        activeColor = [UIColor whiteColor];
        inactiveColor = UIColorFromRGBA(0xFFFFFF, 0.5);
        pressedColor = UIColorFromRGBA(0xFFFFFF, 0.5);
    }
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:activeColor forState:UIControlStateNormal];
    [cancelButton setTitleColor:pressedColor forState:UIControlStateHighlighted];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,cancelItem];
    
    UIButton *rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavButton addTarget:self action:@selector(onTouchRightNavButton:) forControlEvents:UIControlEventTouchUpInside];
    [rightNavButton setTitle:@"Save" forState:UIControlStateNormal];
    [rightNavButton setTitleColor:activeColor forState:UIControlStateNormal];
    [rightNavButton setTitleColor:pressedColor forState:UIControlStateHighlighted];
    [rightNavButton setTitleColor:inactiveColor forState:UIControlStateDisabled];
    [rightNavButton sizeToFit];
    
    _rightNavItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    _rightNavItem.enabled = false;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, _rightNavItem];
}

- (void)setupCommonViews
{
    [self.view addSubview:self.normalTextField];
    [self.view addSubview:self.tipLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_normalTextField]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_normalTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_normalTextField(40)]-10-[_tipLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_normalTextField, _tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_tipLabel]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
}

- (void)setupEmailViews
{
    [self setupNavItemOfUserMode:SAMCUserModeTypeCustom];
    self.navigationItem.title = @"Email";
    _action = @selector(updateEmail);
    _tipLabel.text = @"Enter your Email.";
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _normalTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address"
                                                                             attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
    _normalTextField.text = _profileDict[SAMC_EMAIL] ?:@"";
    _currentEditView = _normalTextField;
}

- (void)setupCompanyNameViews
{
    [self setupNavItemOfUserMode:SAMCUserModeTypeSP];
    self.navigationItem.title = @"Company Name";
    _action = @selector(updateSPCompanyName);
    _tipLabel.text = @"Enter your company name.";
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _normalTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Business or service name"
                                                                             attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
    _normalTextField.text = [_profileDict valueForKeyPath:SAMC_SAM_PROS_INFO_COMPANY_NAME] ?:@"";
    _currentEditView = _normalTextField;
}

- (void)setupServiceCategoryViews
{
    [self setupNavItemOfUserMode:SAMCUserModeTypeSP];
    self.navigationItem.title = @"Service Category";
    _action = @selector(updateSPServiceCategory);
    _tipLabel.text = @"Enter your service category.";
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _normalTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Business or service category"
                                                                             attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
    _normalTextField.text = [_profileDict valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_CATEGORY] ?:@"";
    _currentEditView = _normalTextField;
}

- (void)setupSPPhoneViews
{
    [self setupNavItemOfUserMode:SAMCUserModeTypeSP];
    self.navigationItem.title = @"Work Phone";
    _action = @selector(updateSPPhone);
    _tipLabel.text = @"Enter your service work phone no.";
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _normalTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Service work phone no."
                                                                             attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
    _normalTextField.text = [_profileDict valueForKeyPath:SAMC_SAM_PROS_INFO_PHONE] ?:@"";
    _currentEditView = _normalTextField;
}

- (void)setupSPEmailViews
{
    [self setupNavItemOfUserMode:SAMCUserModeTypeSP];
    self.navigationItem.title = @"Service Email";
    _action = @selector(updateSPEmail);
    _tipLabel.text = @"Enter your service email.";
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _normalTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Service email"
                                                                             attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
    _normalTextField.text = [_profileDict valueForKeyPath:SAMC_SAM_PROS_INFO_EMAIL] ?:@"";
    _currentEditView = _normalTextField;
}

- (void)setupSPDescriptionViews
{
    [self setupNavItemOfUserMode:SAMCUserModeTypeSP];
    self.navigationItem.title = @"Service Description";
    _action = @selector(updateSPDescription);
    [self.view addSubview:self.descriptionTextView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_descriptionTextView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_descriptionTextView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_descriptionTextView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_descriptionTextView)]];
    _descriptionTextView.text = [_profileDict valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_DESCRIPTION] ?:@"";
    _currentEditView = _descriptionTextView;
}

#pragma mark - Action
- (void)onCancel:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTouchRightNavButton:(id)sender
{
    if (_action) {
        SuppressPerformSelectorLeakWarning([self performSelector:_action]);
    }
}

- (void)updateEmail
{
    NSString *email = self.normalTextField.text;
    NSDictionary *profileDict = @{SAMC_EMAIL:email};
    [self updateProfile:profileDict];
}

- (void)updateSPCompanyName
{
    NSString *companyName = self.normalTextField.text;
    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_COMPANY_NAME:companyName}};
    [self updateProfile:profileDict];
}

- (void)updateSPServiceCategory
{
    NSString *serviceCategory = self.normalTextField.text;
    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_SERVICE_CATEGORY:serviceCategory}};
    [self updateProfile:profileDict];
}

- (void)updateSPPhone
{
    NSString *spphone = self.normalTextField.text;
    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_PHONE:spphone}};
    [self updateProfile:profileDict];
}

- (void)updateSPEmail
{
    NSString *spemail = self.normalTextField.text;
    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_EMAIL:spemail}};
    [self updateProfile:profileDict];
}

- (void)updateSPDescription
{
    NSString *spdesc = self.descriptionTextView.text;
    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_SERVICE_DESCRIPTION:spdesc}};
    [self updateProfile:profileDict];
}

- (void)updateProfile:(NSDictionary *)profileDict
{
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"updating" maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCSettingManager sharedManager] updateProfile:profileDict completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
        } else {
            [wself onCancel:nil];
        }
    }];
}

- (BOOL)isInputValid:(NSString *)text
{
    BOOL isValid = YES;
    if (_profileType == SAMCEditProfileTypeEmail) {
        isValid = [text samc_isValidEmail];
    } else if (_profileType == SAMCEditProfileTypeSPCompanyName) {
    } else if (_profileType == SAMCEditProfileTypeSPServiceCategory) {
    } else if (_profileType == SAMCEditProfileTypeSPPhone) {
    } else if (_profileType == SAMCEditProfileTypeSPEmail) {
        isValid = [text samc_isValidEmail];
    } else if (_profileType == SAMCEditProfileTypeSPDescription) {
    }
    return isValid;
}

#pragma mark - 
- (void)normalTextFieldEditingChanged:(UITextField *)textField
{
    self.rightNavItem.enabled = [self isInputValid:textField.text];
}

- (void)normalTextFieldEditingDidEndOnExit:(id)sender
{
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.rightNavItem.enabled = [_descriptionTextView.text length];
}

#pragma mark - lazy load
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
        _tipLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f);
    }
    return _tipLabel;
}

- (UITextField *)normalTextField
{
    if (_normalTextField == nil) {
        _normalTextField = [[UITextField alloc] init];
        _normalTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _normalTextField.backgroundColor = [UIColor whiteColor];
        _normalTextField.borderStyle = UITextBorderStyleNone;
        _normalTextField.font = [UIFont systemFontOfSize:17.0f];
        _normalTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _normalTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _normalTextField.textColor = SAMC_COLOR_INK;
        _normalTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        _normalTextField.leftViewMode = UITextFieldViewModeAlways;
        _normalTextField.returnKeyType = UIReturnKeyDone;
        [_normalTextField addTarget:self action:@selector(normalTextFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_normalTextField addTarget:self action:@selector(normalTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _normalTextField;
}

- (SAMCTextView *)descriptionTextView
{
    if (_descriptionTextView == nil) {
        _descriptionTextView = [[SAMCTextView alloc] init];
        _descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _descriptionTextView.placeholder = @"i.e. your specialization, years of experience, how do you work with your client, etc.";
        _descriptionTextView.delegate = self;
    }
    return _descriptionTextView;
}

@end
