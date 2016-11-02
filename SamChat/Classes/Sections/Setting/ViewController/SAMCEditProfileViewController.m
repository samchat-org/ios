//
//  SAMCEditProfileViewController.m
//  SamChat
//
//  Created by HJ on 11/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCEditProfileViewController.h"
#import "SAMCUserManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"

@interface SAMCEditProfileViewController ()

@property (nonatomic, assign) SAMCEditProfileType profileType;

@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *emailTextField;

@property (nonatomic, weak) id currentEditView;

@end

@implementation SAMCEditProfileViewController

- (instancetype)initWithProfileType:(SAMCEditProfileType)profileType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _profileType = profileType;
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
    [self setupNavItem];
    if (_profileType == SAMCEditProfileTypePhoneNo) {
        [self setupPhoneNoViews];
    } else if (_profileType == SAMCEditProfileTypeEmail) {
        [self setupEmailViews];
    } else if (_profileType == SAMCEditProfileLocation) {
    }
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
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
    [saveButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateHighlighted];
    [saveButton sizeToFit];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, saveItem];
}

- (void)setupPhoneNoViews
{
}

- (void)setupEmailViews
{
    _action = @selector(updateEmail);
    self.navigationItem.title = @"Change Email";
    [self.view addSubview:self.emailTextField];
    [self.view addSubview:self.tipLabel];
    _tipLabel.text = @"Enter your Email.";
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _currentEditView = _emailTextField;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emailTextField]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_emailTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_emailTextField(44)]-10-[_tipLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_emailTextField, _tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_tipLabel]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
}

#pragma mark - Action
- (void)onCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSave:(id)sender
{
    if (_action) {
        SuppressPerformSelectorLeakWarning([self performSelector:_action]);
    }
}

- (void)updateEmail
{
    DDLogDebug(@"updateEmail");
    NSString *email = self.emailTextField.text;
    NSDictionary *profileDict = @{SAMC_EMAIL:email};
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"updating" maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCUserManager sharedManager] updateProfile:profileDict completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
        } else {
            [wself.navigationController popViewControllerAnimated:YES];
        }
    }];
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

- (UITextField *)emailTextField
{
    if (_emailTextField == nil) {
        _emailTextField = [[UITextField alloc] init];
        _emailTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _emailTextField.backgroundColor = [UIColor whiteColor];
        _emailTextField.borderStyle = UITextBorderStyleNone;
        _emailTextField.font = [UIFont systemFontOfSize:17.0f];
        _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _emailTextField.textColor = SAMC_COLOR_INK;
        _emailTextField.placeholder = @"Email Address";
        _emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        _emailTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _emailTextField;
}

@end
