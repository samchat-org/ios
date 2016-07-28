//
//  SAMCConfirmPhoneCodeViewController.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCConfirmPhoneCodeViewController.h"
#import "SAMCTextField.h"
#import "SAMCPhoneCodeView.h"

@interface SAMCConfirmPhoneCodeViewController ()<SAMCPhoneCodeViewDelegate>

@property (nonatomic, strong) SAMCTextField *phoneTextField;
@property (nonatomic, strong) SAMCPhoneCodeView *phoneCodeView;

@end

@implementation SAMCConfirmPhoneCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.navigationItem.title = self.navTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.phoneTextField = [[SAMCTextField alloc] initWithFrame:CGRectZero];
    self.phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneTextField.userInteractionEnabled = false;
    [self.phoneTextField.leftButton setTitle:self.countryCode forState:UIControlStateNormal];
    [self.phoneTextField.leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.phoneTextField.rightTextField.text = self.phoneNumber;
    self.phoneTextField.rightTextField.textColor = [UIColor grayColor];
    [self.view addSubview:self.phoneTextField];
    
    self.phoneCodeView = [[SAMCPhoneCodeView alloc] initWithFrame:CGRectZero];
    self.phoneCodeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneCodeView.delegate = self;
    [self.view addSubview:self.phoneCodeView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneCodeView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneCodeView)]];
//    NSString *visualFormat = [NSString stringWithFormat:@"V:|-20-[_phoneTextField(50)]-20-[_phoneCodeView(%f)]",]
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_phoneTextField(50)]-20-[_phoneCodeView]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_phoneTextField,_phoneCodeView)]];
}

#pragma mark - SAMCPhoneCodeViewDelegate
- (void)phonecodeCompleteInput:(SAMCPhoneCodeView *)view
{
    DDLogDebug(@"phone code:%@", view.phoneCode);
}

@end
