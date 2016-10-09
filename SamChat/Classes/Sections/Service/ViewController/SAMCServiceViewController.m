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
#import "SAMCQuestionManager.h"

@interface SAMCServiceViewController()<SAMCTableReloadDelegate>//<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *requestButton;

@property (nonatomic, strong) NSMutableArray *recentSessions;

@property (nonatomic, strong) SAMCTableViewDelegate *delegator;
@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) UILabel *firstRequestTipLabel;
@property (nonatomic, strong) UILabel *firstRequestDetailLabel;
@property (nonatomic, strong) UIImageView *backgroundLogoImageView;
@property (nonatomic, strong) UIButton *firstRequestButton;

@end

@implementation SAMCServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_MAIN_BACKGROUNDCOLOR;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)setupCustomModeViews
{
    [self.data removeAllObjects];
    [self.data addObjectsFromArray:[[SAMCQuestionManager sharedManager] allSendQuestion]];
    __weak typeof(self) weakSelf = self;
    self.delegator = [[SAMCCustomRequestListDelegate alloc] initWithTableData:^NSMutableArray *{
        return weakSelf.data;
    } viewController:self];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.tableView = nil;
    self.navigationItem.title = @"Request Service";
    
    [self setupCustomModeEmptyRequestViews];
    [self setupCustomModeNotEmptyRequestViews];
    
//    self.requestButton = [[UIButton alloc] init];
//    self.requestButton.backgroundColor = [UIColor grayColor];
//    [self.requestButton.layer setCornerRadius:6.0f];
//    self.requestButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.requestButton setTitle:@"+ Make a new service request" forState:UIControlStateNormal];
//    [self.requestButton addTarget:self action:@selector(touchMakeNewRequest:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.requestButton];
//    
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
//    self.tableView.backgroundColor = [UIColor greenColor];
//    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.tableView.delegate = self.delegator;
//    self.tableView.dataSource = self.delegator;
//    [self.view addSubview:self.tableView];
//    
//    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
//    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestButton]-20-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(_requestButton)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_requestButton(44)]-20-[_tableView]|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(_requestButton, _tableView)]];
}

- (void)setupCustomModeEmptyRequestViews
{
    [self.view addSubview:self.backgroundLogoImageView];
    [self.view addSubview:self.firstRequestTipLabel];
    [self.view addSubview:self.firstRequestDetailLabel];
    [self.view addSubview:self.firstRequestButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundLogoImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_backgroundLogoImageView(200)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_backgroundLogoImageView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_firstRequestTipLabel]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestTipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_firstRequestDetailLabel]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestDetailLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_firstRequestButton]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_firstRequestTipLabel]-10-[_firstRequestDetailLabel]-10-[_firstRequestButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestTipLabel,_firstRequestDetailLabel,_firstRequestButton)]];
    if ([self.data count]) {
        [self hiddeCustomEmptyRequestView:YES];
    }
}

- (void)setupCustomModeNotEmptyRequestViews
{
    [self.view addSubview:self.requestButton];
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_requestButton(35)]-20-[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton, _tableView)]];
    
    if (![self.data count]) {
        [self hiddeCustomNotEmptyRequestView:YES];
    }
}

- (void)setupSPModeViews
{
    [self.data removeAllObjects];
    [self.data addObjectsFromArray:[[SAMCQuestionManager sharedManager] allReceivedQuestion]];
    __weak typeof(self) weakSelf = self;
    self.delegator = [[SAMCSPRequestListDelegate alloc] initWithTableData:^NSMutableArray *{
        return weakSelf.data;
    } viewController:self];
    
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

- (void)hiddeCustomEmptyRequestView:(BOOL)hidden
{
    self.backgroundLogoImageView.hidden = hidden;
    self.firstRequestTipLabel.hidden = hidden;
    self.firstRequestDetailLabel.hidden = hidden;
    self.firstRequestButton.hidden = hidden;
}

- (void)hiddeCustomNotEmptyRequestView:(BOOL)hidden
{
    self.tableView.hidden = hidden;
    self.requestButton.hidden = hidden;
}

#pragma mark - Action
- (void)touchMakeNewRequest:(id)sender
{
    SAMCNewRequestViewController *vc = [[SAMCNewRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

#pragma mark - SAMCTableReloadDelegate
- (void)sortAndReload
{
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        if ([self.data count]) {
            [self hiddeCustomNotEmptyRequestView:NO];
            [self hiddeCustomEmptyRequestView:YES];
        } else {
            [self hiddeCustomNotEmptyRequestView:YES];
            [self hiddeCustomEmptyRequestView:NO];
        }
    }
    // TODO: add sort
    [self.tableView reloadData];
}

#pragma mark - lazy load
- (UILabel *)firstRequestTipLabel
{
    if (_firstRequestTipLabel == nil) {
        _firstRequestTipLabel = [[UILabel alloc] init];
        _firstRequestTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _firstRequestTipLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _firstRequestTipLabel.text = @"Make your first request";
        _firstRequestTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _firstRequestTipLabel;
}

- (UILabel *)firstRequestDetailLabel
{
    if (_firstRequestDetailLabel == nil) {
        _firstRequestDetailLabel = [[UILabel alloc] init];
        _firstRequestDetailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _firstRequestDetailLabel.font = [UIFont systemFontOfSize:14.0f];
        _firstRequestDetailLabel.text = @"Tell us what professional services do you need or what job do you need done. Get started now!";
        _firstRequestDetailLabel.numberOfLines = 0;
        _firstRequestDetailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _firstRequestDetailLabel;
}

- (UIImageView *)backgroundLogoImageView
{
    if (_backgroundLogoImageView == nil) {
        _backgroundLogoImageView = [[UIImageView alloc] init];
        _backgroundLogoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_backgroundLogoImageView setImage:[UIImage imageNamed:@"service_bg_logo"]];
        _backgroundLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backgroundLogoImageView;
}

- (UIButton *)firstRequestButton
{
    if (_firstRequestButton == nil) {
        _firstRequestButton = [[UIButton alloc] init];
        _firstRequestButton.translatesAutoresizingMaskIntoConstraints = NO;
        _firstRequestButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_firstRequestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_firstRequestButton setTitle:@"Make a New Request" forState:UIControlStateNormal];
        _firstRequestButton.backgroundColor = UIColorFromRGB(0x67D45F);
        _firstRequestButton.layer.cornerRadius = 17.5f;
        [_firstRequestButton addTarget:self action:@selector(touchMakeNewRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstRequestButton;
}

- (UIButton *)requestButton
{
    if (_requestButton == nil) {
        _requestButton = [[UIButton alloc] init];
        _requestButton.translatesAutoresizingMaskIntoConstraints = NO;
        _requestButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_requestButton setTitle:@"New Request" forState:UIControlStateNormal];
        _requestButton.backgroundColor = UIColorFromRGB(0x67D45F);
        _requestButton.layer.cornerRadius = 17.5f;
        [_requestButton addTarget:self action:@selector(touchMakeNewRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _requestButton;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self.delegator;
        _tableView.dataSource = self.delegator;
        
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

@end
