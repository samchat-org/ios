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

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *companyNameTextField;
@property (nonatomic, strong) UITextField *serviceCategoryTextField;
@property (nonatomic, strong) SAMCTextView *serviceDescTextView;

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@end

@implementation SAMCCSAStepOneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    [self.navigationItem setTitle:@"Create Service Account"];
    [self setUpNavItem];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _usernameTextField = [[UITextField alloc] init];
    _usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _usernameTextField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _usernameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_usernameTextField];
    
    _companyNameTextField = [[UITextField alloc] init];
    _companyNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _companyNameTextField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _companyNameTextField.placeholder = @"Your business name (optional)";
    _companyNameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    _companyNameTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_companyNameTextField];
    
    _serviceCategoryTextField = [[UITextField alloc] init];
    _serviceCategoryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _serviceCategoryTextField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _serviceCategoryTextField.placeholder = @"Service category";
    _serviceCategoryTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    _serviceCategoryTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_serviceCategoryTextField];
    
    _serviceDescTextView = [[SAMCTextView alloc] init];
    _serviceDescTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _serviceDescTextView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _serviceDescTextView.placeholder = @"How do you describe your service?";
    [self.view addSubview:_serviceDescTextView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_usernameTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_companyNameTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_companyNameTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_serviceCategoryTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_serviceCategoryTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_serviceDescTextView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_serviceDescTextView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_usernameTextField(50)]-5-[_companyNameTextField(50)]-5-[_serviceCategoryTextField(50)]-5-[_serviceDescTextView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_usernameTextField,_companyNameTextField,_serviceCategoryTextField,_serviceDescTextView)]];
}

- (void)setUpNavItem{
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextButton sizeToFit];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void)onNext:(id)sender
{
    NSString *companyName = _companyNameTextField.text;
    NSString *serviceCategory = _serviceCategoryTextField.text;
    NSString *serviceDesc = _serviceDescTextView.text;
    
    [self.samProsInformation setObject:companyName forKey:SAMC_COMPANY_NAME];
    [self.samProsInformation setObject:serviceCategory forKey:SAMC_SERVICE_CATEGORY];
    [self.samProsInformation setObject:serviceDesc forKey:SAMC_SERVICE_DESCRIPTION];
    
    SAMCCSAStepTwoViewController *vc = [[SAMCCSAStepTwoViewController alloc] init];
    vc.samProsInformation = self.samProsInformation;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy load
- (NSMutableDictionary *)samProsInformation
{
    if (_samProsInformation == nil) {
        _samProsInformation = [[NSMutableDictionary alloc] init];
    }
    return _samProsInformation;
}

@end
