//
//  SAMCCreateSamChatIDViewController.m
//  SamChat
//
//  Created by HJ on 11/15/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCreateSamChatIDViewController.h"
#import "NSString+SAMCValidation.h"

@interface SAMCCreateSamChatIDViewController ()

@property (nonatomic, strong) UIBarButtonItem *rightNavItem;

@property (nonatomic, strong) UITextField *normalTextField;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation SAMCCreateSamChatIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavItem];
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_normalTextField becomeFirstResponder];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
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
    
    UIButton *rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    [rightNavButton setTitle:@"Save" forState:UIControlStateNormal];
    [rightNavButton setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
    [rightNavButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateHighlighted];
    [rightNavButton setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f) forState:UIControlStateDisabled];
    [rightNavButton sizeToFit];
    
    _rightNavItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    _rightNavItem.enabled = false;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, _rightNavItem];
}

#pragma mark - Action
- (void)onCancel:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSave:(id)sender
{
}

#pragma mark -
- (void)normalTextFieldEditingChanged:(UITextField *)textField
{
    NSString *samchatId = textField.text;
    self.rightNavItem.enabled = [samchatId samc_isValidSamchatId];
}

- (void)normalTextFieldEditingDidEndOnExit:(id)sender
{
    [self onSave:nil];
}

#pragma mark - lazy load
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
        _tipLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f);
        _tipLabel.text = @"SamChat ID is a unique certificate for your account and can only be set once.";
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
        _normalTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SamChat ID"
                                                                                 attributes:@{NSForegroundColorAttributeName: UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f)}];
        [_normalTextField addTarget:self action:@selector(normalTextFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_normalTextField addTarget:self action:@selector(normalTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _normalTextField;
}

@end
