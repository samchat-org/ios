//
//  SAMCServiceViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServiceViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "SAMCNewRequestViewController.h"
#import "SAMCCustomRequestListDelegate.h"
#import "SAMCSPRequestListDelegate.h"

@interface SAMCServiceViewController()//<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *requestButton;

@property (nonatomic, strong) NSMutableArray *recentSessions;

@property (nonatomic, strong) SAMCTableViewDelegate *delegator;
@property (nonatomic, copy) NSArray *data;

@end

@implementation SAMCServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)switchToUserMode:(NSNotification *)notification
{
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    NSLog(@"%ld", mode);
    if (mode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)setupCustomModeViews
{
    __weak typeof(self) weakSelf = self;
    self.delegator = [[SAMCCustomRequestListDelegate alloc] initWithTableData:^NSArray *{
        return weakSelf.data;
    }];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.tableView = nil;
    self.navigationItem.title = @"Request Service";
    
    self.requestButton = [[UIButton alloc] init];
    self.requestButton.backgroundColor = [UIColor grayColor];
    [self.requestButton.layer setCornerRadius:6.0f];
    self.requestButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.requestButton setTitle:@"+ Make a new service request" forState:UIControlStateNormal];
    [self.requestButton addTarget:self action:@selector(touchMakeNewRequest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.requestButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor greenColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self.delegator;
    self.tableView.dataSource = self.delegator;
    [self.view addSubview:self.tableView];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_requestButton(44)]-20-[_tableView]|", SAMCTopBarHeight+20]
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_requestButton(44)]-20-[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton, _tableView)]];
}

- (void)setupSPModeViews
{
    __weak typeof(self) weakSelf = self;
    self.delegator = [[SAMCSPRequestListDelegate alloc] initWithTableData:^NSArray *{
        return weakSelf.data;
    }];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.tableView = nil;
    self.requestButton = nil;
    self.navigationItem.title = @"Service Requests";
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor yellowColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self.delegator;
    self.tableView.dataSource = self.delegator;
    [self.view addSubview:self.tableView];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_tableView]|",SAMCTopBarHeight]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

#pragma mark - Action
- (void)touchMakeNewRequest:(id)sender
{
    SAMCNewRequestViewController *vc = [[SAMCNewRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
