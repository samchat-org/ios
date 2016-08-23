//
//  SAMCAddContactViewController.m
//  SamChat
//
//  Created by HJ on 8/22/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAddContactViewController.h"
#import "SAMCQRCodeScanViewController.h"

@interface SAMCAddContactViewController ()

@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UITableView *contactTableView;

@end

@implementation SAMCAddContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    [self setUpNavItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.currentUserMode == SAMCUserModeTypeSP) {
        self.navigationItem.title = @"Add Customer";
    } else {
        self.navigationItem.title = @"Add Service Provider";
    }
    
    _searchTextField = [[UITextField alloc] init];
    _searchTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _searchTextField.backgroundColor = [UIColor lightGrayColor];
    _searchTextField.layer.cornerRadius = 5.0f;
    _searchTextField.placeholder = @"search by username, phone number";
    [self.view addSubview:_searchTextField];
    
    _contactTableView = [[UITableView alloc] init];
    _contactTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _contactTableView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_contactTableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_searchTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_searchTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contactTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_contactTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_searchTextField(44)]-5-[_contactTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_searchTextField,_contactTableView)]];
}

- (void)setUpNavItem
{
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn addTarget:self action:@selector(onOpera:) forControlEvents:UIControlEventTouchUpInside];
    [scanBtn setImage:[UIImage imageNamed:@"icon_tinfo_normal"] forState:UIControlStateNormal];
    [scanBtn setImage:[UIImage imageNamed:@"icon_tinfo_pressed"] forState:UIControlStateHighlighted];
    [scanBtn sizeToFit];
    UIBarButtonItem *teamItem = [[UIBarButtonItem alloc] initWithCustomView:scanBtn];
    self.navigationItem.rightBarButtonItem = teamItem;
}

#pragma mark - Action
- (void)onOpera:(id)sender
{
    SAMCQRCodeScanViewController *vc = [[SAMCQRCodeScanViewController alloc] init];
    vc.currentUserMode = self.currentUserMode;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
