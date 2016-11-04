//
//  SAMCChangePasswordViewController.m
//  SamChat
//
//  Created by HJ on 11/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCChangePasswordViewController.h"
#import "SAMCPadImageView.h"
#import "SAMCUtils.h"

@interface SAMCChangePasswordViewController ()

@property (nonatomic, strong) UITextField *currentPasswordTextField;
@property (nonatomic, strong) UITextField *changePasswordTextField;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) NSLayoutConstraint *bottomSpaceConstraint;

@end

@implementation SAMCChangePasswordViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.currentPasswordTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Change Password";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self setupNavItem];
    
    [self.view addSubview:self.currentPasswordTextField];
    [self.view addSubview:self.changePasswordTextField];
    [self.view addSubview:self.doneButton];
    _doneButton.enabled = false;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_currentPasswordTextField]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_currentPasswordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_changePasswordTextField]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_changePasswordTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_doneButton]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_doneButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_currentPasswordTextField(40)]-10-[_changePasswordTextField(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_currentPasswordTextField,_changePasswordTextField)]];
    [_doneButton addConstraint:[NSLayoutConstraint constraintWithItem:_doneButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant:40.0f]];
    self.bottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:_doneButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:-20.0f];
    [self.view addConstraint:self.bottomSpaceConstraint];
}

- (void)setupNavItem
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateHighlighted];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,cancelItem];
}

#pragma mark - Action
- (void)onCancel:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onDone:(id)sender
{
}

- (void)textFieldEditingDidEndOnExit:(UITextField *)textField
{
    if ([textField isEqual:_currentPasswordTextField]) {
        [_changePasswordTextField becomeFirstResponder];
    } else {
        [self onDone:nil];
    }
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    _doneButton.enabled = [SAMCUtils isValidPassword:_currentPasswordTextField.text] && [SAMCUtils isValidPassword:_changePasswordTextField.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.bottomSpaceConstraint setConstant:-keyboardHeight-20];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.bottomSpaceConstraint setConstant:-20];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (UITextField *)currentPasswordTextField
{
    if (_currentPasswordTextField == nil) {
        _currentPasswordTextField = [[UITextField alloc] init];
        _currentPasswordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _currentPasswordTextField.secureTextEntry = YES;
        _currentPasswordTextField.backgroundColor = [UIColor whiteColor];
        _currentPasswordTextField.layer.cornerRadius = 6.0f;
        _currentPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Current password"
                                                                                          attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
        _currentPasswordTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]];
        _currentPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
        _currentPasswordTextField.returnKeyType = UIReturnKeyNext;
        [_currentPasswordTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_currentPasswordTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_currentPasswordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _currentPasswordTextField;
}

- (UITextField *)changePasswordTextField
{
    if (_changePasswordTextField == nil) {
        _changePasswordTextField = [[UITextField alloc] init];
        _changePasswordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _changePasswordTextField.secureTextEntry = YES;
        _changePasswordTextField.backgroundColor = [UIColor whiteColor];
        _changePasswordTextField.layer.cornerRadius = 6.0f;
        _changePasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"New password"
                                                                                          attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
        _changePasswordTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_password"]];
        _changePasswordTextField.leftViewMode = UITextFieldViewModeAlways;
        _changePasswordTextField.returnKeyType = UIReturnKeyDone;
        [_changePasswordTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_changePasswordTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_changePasswordTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _changePasswordTextField;
}

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        _doneButton.layer.cornerRadius = 20.0f;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_doneButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_inactive"] forState:UIControlStateDisabled];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

@end
