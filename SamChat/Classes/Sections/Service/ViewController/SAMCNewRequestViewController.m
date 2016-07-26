//
//  SAMCNewRequestViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCNewRequestViewController.h"

@interface SAMCNewRequestViewController ()

@property (nonatomic, strong) UILabel *requestLabel;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UITextField *requestTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UITableView *popularTabeView;

@end

@implementation SAMCNewRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"New Request";
    
    self.requestLabel = [[UILabel alloc] init];
    self.requestLabel.text = @"Your Request";
    self.requestLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.requestLabel];
    
    self.sendButton = [[UIButton alloc] init];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor greenColor];
    self.sendButton.layer.cornerRadius = 6.0f;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sendButton];
    
    self.requestTextField = [[UITextField alloc] init];
    self.requestTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.requestTextField.backgroundColor = [UIColor lightGrayColor];
    self.requestTextField.placeholder = @"What do you need help with today?";
//    self.requestTextField.layer.cornerRadius = 6.0f;
    self.requestTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.requestTextField];
    
    self.locationTextField = [[UITextField alloc] init];
    self.locationTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.locationTextField.backgroundColor = [UIColor lightGrayColor];
    self.locationTextField.placeholder = @"Current location";
//    self.locationTextField.layer.cornerRadius = 6.0f;
    self.locationTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.locationTextField];
    
    self.popularTabeView = [[UITableView alloc] init];
    self.popularTabeView.backgroundColor = [UIColor yellowColor];
    self.popularTabeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.popularTabeView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestLabel][_sendButton(120)]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestLabel,_sendButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.requestLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_locationTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_locationTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_popularTabeView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_popularTabeView)]];
    NSString *visualFomat = [NSString stringWithFormat:@"V:|-%f-[_requestLabel(40)]-10-[_requestTextField(50)]-10-[_locationTextField(50)]-20-[_popularTabeView]|", SAMCTopBarHeight+10];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFomat
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestLabel,_requestTextField,_locationTextField,_popularTabeView)]];
}

@end
