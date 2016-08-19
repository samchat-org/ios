//
//  SAMCCSAStepTwoViewController.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepTwoViewController.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCCSADoneViewController.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"

@interface SAMCCSAStepTwoViewController ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *locationTextField;

@end

@implementation SAMCCSAStepTwoViewController

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
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarView.backgroundColor = [UIColor blueColor]; // TODO: delete it, just for test
    [self.view addSubview:_avatarView];
    
    _phoneTextField = [[UITextField alloc] init];
    _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _phoneTextField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _phoneTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    _phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    _phoneTextField.placeholder = @"your phone";
    [self.view addSubview:_phoneTextField];
    
    _emailTextField = [[UITextField alloc] init];
    _emailTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _emailTextField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    _emailTextField.leftViewMode = UITextFieldViewModeAlways;
    _emailTextField.placeholder = @"your email";
    [self.view addSubview:_emailTextField];
    
    _locationTextField = [[UITextField alloc] init];
    _locationTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _locationTextField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _locationTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    _locationTextField.leftViewMode = UITextFieldViewModeAlways;
    _locationTextField.placeholder = @"company location";
    [self.view addSubview:_locationTextField];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [_avatarView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_avatarView
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0f
                                                             constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_emailTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_emailTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_locationTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_locationTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_avatarView(120)]-20-[_phoneTextField(50)]-5-[_emailTextField(50)]-5-[_locationTextField(50)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_avatarView,_phoneTextField,_emailTextField,_locationTextField)]];
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
    NSString *phone = _phoneTextField.text;
    NSString *email = _emailTextField.text;
    NSDictionary *location = @{SAMC_ADDRESS:_locationTextField.text};
    
    [self.samProsInformation setObject:phone forKey:SAMC_PHONE];
    [self.samProsInformation setObject:email forKey:SAMC_EMAIL];
    [self.samProsInformation setObject:location forKey:SAMC_LOCATION];
    
    [SVProgressHUD showWithStatus:@"Creating" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCSettingManager sharedManager] createSamPros:self.samProsInformation completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        SAMCCSADoneViewController *vc = [[SAMCCSADoneViewController alloc] init];
        [wself.navigationController pushViewController:vc animated:YES];
    }];
    
}



@end
