//
//  SAMCCSAStepOneViewController.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepOneViewController.h"
#import "SAMCCSAStepTwoViewController.h"
#import "SAMCTextView.h"
#import "SAMCServerAPIMacro.h"

@interface SAMCCSAStepOneViewController ()

@property (nonatomic, strong) UIImageView *stepImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *companyNameTextField;
@property (nonatomic, strong) UITextField *serviceCategoryTextField;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@property (nonatomic, strong) NSLayoutConstraint *nextButtonBottomContraint;

@end

@implementation SAMCCSAStepOneViewController

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
    [self.companyNameTextField becomeFirstResponder];
}

- (void)setupSubviews
{
    [self.navigationItem setTitle:@"Create Service Profile"];
    self.view.backgroundColor = SAMC_MAIN_BACKGROUNDCOLOR;
    [self setUpNavItem];

    [self.view addSubview:self.stepImageView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.companyNameTextField];
    [self.view addSubview:self.serviceCategoryTextField];
    [self.view addSubview:self.skipButton];
    [self.view addSubview:self.nextButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stepImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_tipLabel]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_companyNameTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_companyNameTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_serviceCategoryTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_serviceCategoryTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepImageView(16)]-10-[_tipLabel]-20-[_companyNameTextField(35)]-5-[_serviceCategoryTextField(35)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepImageView,_tipLabel,_companyNameTextField,_serviceCategoryTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_skipButton]-10-[_nextButton(==_skipButton)]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_skipButton,_nextButton)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_skipButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_nextButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    self.nextButtonBottomContraint = [NSLayoutConstraint constraintWithItem:_nextButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:-20.0f];
    [self.view addConstraint:self.nextButtonBottomContraint];
}

- (void)setUpNavItem{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:SAMC_MAIN_DARKCOLOR forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

- (void)onCancel
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onSkip:(id)sender
{
    [self pushToNextStepVC];
}

- (void)onNext:(id)sender
{
    NSString *companyName = _companyNameTextField.text;
    NSString *serviceCategory = _serviceCategoryTextField.text;
    
    [self.samProsInformation setObject:companyName forKey:SAMC_COMPANY_NAME];
    [self.samProsInformation setObject:serviceCategory forKey:SAMC_SERVICE_CATEGORY];
    [self pushToNextStepVC];
}

- (void)pushToNextStepVC
{
    SAMCCSAStepTwoViewController *vc = [[SAMCCSAStepTwoViewController alloc] initWithInformation:self.samProsInformation];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // fix the issue: text bounces after resigning first responder
    [textField layoutIfNeeded];
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    if ([_companyNameTextField.text length] && [_serviceCategoryTextField.text length]) {
        _nextButton.backgroundColor = UIColorFromRGB(0x2676B6);
        _nextButton.enabled = YES;
    } else {
        _nextButton.backgroundColor = UIColorFromRGB(0x88B1D2);
        _nextButton.enabled = NO;
    }
}

- (void)textFieldEditingDidEndOnExit:(UITextField *)textField
{
    if ([textField isEqual:_companyNameTextField]) {
        [_serviceCategoryTextField becomeFirstResponder];
    } else {
        [self onNext:nil];
    }
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.nextButtonBottomContraint setConstant:-keyboardHeight-5];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.nextButtonBottomContraint setConstant:-20];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - lazy load
- (NSMutableDictionary *)samProsInformation
{
    if (_samProsInformation == nil) {
        _samProsInformation = [[NSMutableDictionary alloc] init];
    }
    return _samProsInformation;
}

- (UIImageView *)stepImageView
{
    if (_stepImageView == nil) {
        _stepImageView = [[UIImageView alloc] init];
        _stepImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _stepImageView.image = [UIImage imageNamed:@"create_servicer_step1"];
    }
    return _stepImageView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.text = @"Basic information about your business or service";
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.textColor = UIColorFromRGB(0x1B3257);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

- (UITextField *)companyNameTextField
{
    if (_companyNameTextField == nil) {
        _companyNameTextField = [[UITextField alloc] init];
        _companyNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _companyNameTextField.backgroundColor = [UIColor whiteColor];
        _companyNameTextField.layer.cornerRadius = 5.0f;
        _companyNameTextField.placeholder = @"Business or service name";
        _companyNameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_create_servicer_name"]];
        _companyNameTextField.leftViewMode = UITextFieldViewModeAlways;
        _companyNameTextField.returnKeyType = UIReturnKeyNext;
        [_companyNameTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_companyNameTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_companyNameTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _companyNameTextField;
}

- (UITextField *)serviceCategoryTextField
{
    if (_serviceCategoryTextField == nil) {
        _serviceCategoryTextField = [[UITextField alloc] init];
        _serviceCategoryTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _serviceCategoryTextField.backgroundColor = [UIColor whiteColor];
        _serviceCategoryTextField.layer.cornerRadius = 5.0f;
        _serviceCategoryTextField.placeholder = @"Business or service category";
        _serviceCategoryTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_create_servicer_category"]];
        _serviceCategoryTextField.leftViewMode = UITextFieldViewModeAlways;
        _serviceCategoryTextField.returnKeyType = UIReturnKeyDone;
        [_serviceCategoryTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_serviceCategoryTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_serviceCategoryTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _serviceCategoryTextField;
}

- (UIButton *)skipButton
{
    if (_skipButton == nil) {
        _skipButton = [[UIButton alloc] init];
        _skipButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        [_skipButton addConstraint:[NSLayoutConstraint constraintWithItem:_skipButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:30.0f]];
        _skipButton.layer.cornerRadius = 15.0f;
        _skipButton.backgroundColor = UIColorFromRGB(0xA2AEBC);
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(onSkip:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (UIButton *)nextButton
{
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] init];
        _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [_nextButton addConstraint:[NSLayoutConstraint constraintWithItem:_nextButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:30.0f]];
        _nextButton.layer.cornerRadius = 15.0f;
        _nextButton.backgroundColor = UIColorFromRGB(0x88B1D2);
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
        _nextButton.enabled = NO;
    }
    return _nextButton;
}

@end
