//
//  SAMCCSAStepTwoViewController.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepTwoViewController.h"
#import "SAMCCSAStepThreeViewController.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCPadImageView.h"
#import "UIView+Toast.h"
#import "SAMCStepperView.h"
#import "SAMCSelectLocationViewController.h"

@interface SAMCCSAStepTwoViewController ()

@property (nonatomic, strong) SAMCStepperView *stepperView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *workphoneTextField;
@property (nonatomic, strong) UITextField *serviceEmailTextField;
@property (nonatomic, strong) UITextField *serviceLocationTextField;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) NSLayoutConstraint *nextButtonBottomContraint;

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@property (nonatomic, strong) NSDictionary *location;

@end

@implementation SAMCCSAStepTwoViewController

- (instancetype)initWithInformation:(NSMutableDictionary *)information
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _samProsInformation = information;
    }
    return self;
}

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
    [self.workphoneTextField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    [self.navigationItem setTitle:@"Create Service Profile"];
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self setUpNavItem];
    
    [self.view addSubview:self.stepperView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.workphoneTextField];
    [self.view addSubview:self.serviceEmailTextField];
    [self.view addSubview:self.serviceLocationTextField];
    [self.view addSubview:self.nextButton];
    
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_tipLabel]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_workphoneTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_workphoneTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_serviceEmailTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_serviceEmailTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_serviceLocationTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_serviceLocationTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepperView(12)]-10-[_tipLabel]-20-[_workphoneTextField(35)]-5-[_serviceEmailTextField(35)]-5-[_serviceLocationTextField(35)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepperView,_tipLabel,_workphoneTextField,_serviceEmailTextField,_serviceLocationTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_nextButton]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nextButton)]];
    
        [_nextButton addConstraint:[NSLayoutConstraint constraintWithItem:_nextButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:40.0f]];
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
    NSString *phone= _workphoneTextField.text;
    NSString *email= _serviceEmailTextField.text;
    
    [self.samProsInformation setObject:phone forKey:SAMC_PHONE];
    [self.samProsInformation setObject:email forKey:SAMC_EMAIL];
    if (self.location) {
        [self.samProsInformation setObject:self.location forKey:SAMC_LOCATION];
    }
    DDLogDebug(@"SAMCCSAStepTwoViewController: %@", self.samProsInformation);
    [self pushToNextStepVC];
}

- (void)pushToNextStepVC
{
    SAMCCSAStepThreeViewController *vc = [[SAMCCSAStepThreeViewController alloc] initWithInformation:self.samProsInformation];
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
    if ([_workphoneTextField.text length] && [_serviceEmailTextField.text length] && [_serviceLocationTextField.text length]) {
        _nextButton.enabled = YES;
    } else {
        _nextButton.enabled = NO;
    }
}

- (void)textFieldEditingDidEndOnExit:(UITextField *)textField
{
    if ([textField isEqual:_workphoneTextField]) {
        [_serviceEmailTextField becomeFirstResponder];
    } else if ([textField isEqual:_serviceEmailTextField]) {
        [_serviceLocationTextField becomeFirstResponder];
    } else {
        [self onNext:nil];
    }
}

- (void)locationTextFieldEditingDidBegin:(id)sender
{
    SAMCSelectLocationViewController *vc = [[SAMCSelectLocationViewController alloc] initWithHideCurrentLocation:YES userMode:SAMCUserModeTypeCustom];
    __weak typeof(self) wself = self;
    vc.selectBlock = ^(NSDictionary *location, BOOL isCurrentLocation){
        if (!isCurrentLocation) {
            wself.location = location;
            wself.serviceLocationTextField.text = location[SAMC_ADDRESS];
        }
        [wself textFieldEditingChanged:wself.serviceLocationTextField];
    };
    [self.navigationController pushViewController:vc animated:YES];
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
- (SAMCStepperView *)stepperView
{
    if (_stepperView == nil) {
        _stepperView = [[SAMCStepperView alloc] initWithFrame:CGRectZero step:2 color:SAMC_COLOR_LAKE];
        _stepperView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _stepperView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.text = @"Your business contact details";
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.textColor = UIColorFromRGB(0x1B3257);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

- (UITextField *)workphoneTextField
{
    if (_workphoneTextField == nil) {
        _workphoneTextField = [[UITextField alloc] init];
        _workphoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _workphoneTextField.backgroundColor = [UIColor whiteColor];
        _workphoneTextField.layer.cornerRadius = 5.0f;
        _workphoneTextField.placeholder = @"Service work phone no.";
        _workphoneTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_option_phone"]];
        _workphoneTextField.leftViewMode = UITextFieldViewModeAlways;
        _workphoneTextField.returnKeyType = UIReturnKeyNext;
        [_workphoneTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_workphoneTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_workphoneTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _workphoneTextField;
}

- (UITextField *)serviceEmailTextField
{
    if (_serviceEmailTextField == nil) {
        _serviceEmailTextField = [[UITextField alloc] init];
        _serviceEmailTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _serviceEmailTextField.backgroundColor = [UIColor whiteColor];
        _serviceEmailTextField.layer.cornerRadius = 5.0f;
        _serviceEmailTextField.placeholder = @"Service email";
        _serviceEmailTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_option_email"]];
        _serviceEmailTextField.leftViewMode = UITextFieldViewModeAlways;
        _serviceEmailTextField.returnKeyType = UIReturnKeyNext;
        [_serviceEmailTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_serviceEmailTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_serviceEmailTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _serviceEmailTextField;
}

- (UITextField *)serviceLocationTextField
{
    if (_serviceLocationTextField == nil) {
        _serviceLocationTextField = [[UITextField alloc] init];
        _serviceLocationTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _serviceLocationTextField.backgroundColor = [UIColor whiteColor];
        _serviceLocationTextField.layer.cornerRadius = 5.0f;
        _serviceLocationTextField.placeholder = @"Location";
        _serviceLocationTextField.leftView = [[SAMCPadImageView alloc] initWithImage:[UIImage imageNamed:@"ico_location"]];
        _serviceLocationTextField.leftViewMode = UITextFieldViewModeAlways;
        _serviceLocationTextField.returnKeyType = UIReturnKeyDone;
        [_serviceLocationTextField addTarget:self action:@selector(locationTextFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
//        [_serviceLocationTextField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//        [_serviceLocationTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
//        [_serviceLocationTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _serviceLocationTextField;
}

- (UIButton *)nextButton
{
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] init];
        _nextButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
        _nextButton.layer.cornerRadius = 20.0f;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_active"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_pressed"] forState:UIControlStateHighlighted];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_lake_inactive"] forState:UIControlStateDisabled];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
        _nextButton.enabled = NO;
    }
    return _nextButton;
}

@end
