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
#import "SAMCSelectLocationViewController.h"

@import CoreLocation;
@interface SAMCCSAStepTwoViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) UIImageView *stepImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *workphoneTextField;
@property (nonatomic, strong) UITextField *serviceEmailTextField;
@property (nonatomic, strong) UITextField *serviceLocationTextField;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) NSLayoutConstraint *nextButtonBottomContraint;

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSMutableDictionary *location;

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
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
            [self.view makeToast:@"请在设置-隐私里允许程序使用地理位置服务"
                        duration:2
                        position:CSToastPositionCenter];
        }else{
            [_locationManager startUpdatingLocation];
        }
    }else{
        [self.view makeToast:@"请打开地理位置服务"
                    duration:2
                    position:CSToastPositionCenter];
    }
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
    
    [self.view addSubview:self.stepImageView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.workphoneTextField];
    [self.view addSubview:self.serviceEmailTextField];
    [self.view addSubview:self.serviceLocationTextField];
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepImageView(16)]-10-[_tipLabel]-20-[_workphoneTextField(35)]-5-[_serviceEmailTextField(35)]-5-[_serviceLocationTextField(35)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepImageView,_tipLabel,_workphoneTextField,_serviceEmailTextField,_serviceLocationTextField)]];
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
    NSString *phone= _workphoneTextField.text;
    NSString *email= _serviceEmailTextField.text;
    
    if ((self.location == nil) && (self.currentLocation)) {
        self.location = [[NSMutableDictionary alloc] init];
        [self.location setObject:@{SAMC_LONGITUDE:@(self.currentLocation.coordinate.longitude),
                                   SAMC_LATITUDE:@(self.currentLocation.coordinate.latitude)} forKey:SAMC_LOCATION_INFO];
    }
    
    [self.samProsInformation setObject:phone forKey:SAMC_PHONE];
    [self.samProsInformation setObject:email forKey:SAMC_EMAIL];
    [self.samProsInformation setObject:self.location forKey:SAMC_LOCATION];
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
        _nextButton.backgroundColor = UIColorFromRGB(0x2676B6);
        _nextButton.enabled = YES;
    } else {
        _nextButton.backgroundColor = UIColorFromRGB(0x88B1D2);
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
    SAMCSelectLocationViewController *vc = [[SAMCSelectLocationViewController alloc] init];
    __weak typeof(self) wself = self;
    vc.selectBlock = ^(NSDictionary *location, BOOL isCurrentLocation){
        if (isCurrentLocation) {
            wself.location = nil;
            wself.serviceLocationTextField.text = @"Current Location";
        } else {
            wself.location = [location mutableCopy];
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    _currentLocation = [locations lastObject];
    DDLogDebug(@"location: %@", _currentLocation);
    [_locationManager stopUpdatingLocation];
}

#pragma mark - lazy load
- (UIImageView *)stepImageView
{
    if (_stepImageView == nil) {
        _stepImageView = [[UIImageView alloc] init];
        _stepImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _stepImageView.image = [UIImage imageNamed:@"create_servicer_step2"];
    }
    return _stepImageView;
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
