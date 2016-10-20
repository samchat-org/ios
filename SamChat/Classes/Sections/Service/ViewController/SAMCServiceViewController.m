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
#import "SAMCServiceProfileViewController.h"
#import "SAMCAddContactViewController.h"

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

@property (nonatomic, strong) UILabel *noRequestTipLabel;
@property (nonatomic, strong) UILabel *noRequestDetailLabel;
@property (nonatomic, strong) UIButton *updateSPProfileButton;
@property (nonatomic, strong) UIButton *sendPublicUpdateButton;
@property (nonatomic, strong) UIButton *addCustomerButton;

@end

@implementation SAMCServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
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
        [self hideCustomEmptyRequestView:YES];
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
        [self hideCustomNotEmptyRequestView:YES];
    }
}

- (void)setupSPModeEmptyRequestViews
{
    [self.view addSubview:self.noRequestTipLabel];
    [self.view addSubview:self.noRequestDetailLabel];
    [self.view addSubview:self.updateSPProfileButton];
    [self.view addSubview:self.sendPublicUpdateButton];
    [self.view addSubview:self.addCustomerButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_noRequestTipLabel]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_noRequestTipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[_noRequestDetailLabel]-48-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_noRequestDetailLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-65-[_updateSPProfileButton]-65-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_updateSPProfileButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-65-[_sendPublicUpdateButton]-65-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_sendPublicUpdateButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-65-[_addCustomerButton]-65-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_addCustomerButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_noRequestTipLabel]-12-[_noRequestDetailLabel]-20-[_updateSPProfileButton(40)]-10-[_sendPublicUpdateButton(40)]-10-[_addCustomerButton(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_noRequestTipLabel,_noRequestDetailLabel,_updateSPProfileButton,_sendPublicUpdateButton,_addCustomerButton)]];
    if ([self.data count]) {
        [self hideSPEmptyRequestView:YES];
    }
}

- (void)setupSPModeNotEmptyRequestViews
{
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_tableView]|",SAMCTopBarHeight]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    if (![self.data count]) {
        [self hideSPNotEmptyRequestView:YES];
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

    [self setupSPModeNotEmptyRequestViews];
    [self setupSPModeEmptyRequestViews];
}

- (void)hideCustomEmptyRequestView:(BOOL)hidden
{
    self.backgroundLogoImageView.hidden = hidden;
    self.firstRequestTipLabel.hidden = hidden;
    self.firstRequestDetailLabel.hidden = hidden;
    self.firstRequestButton.hidden = hidden;
}

- (void)hideCustomNotEmptyRequestView:(BOOL)hidden
{
    self.tableView.hidden = hidden;
    self.requestButton.hidden = hidden;
}

- (void)hideSPEmptyRequestView:(BOOL)hidden
{
    self.noRequestTipLabel.hidden = hidden;
    self.noRequestDetailLabel.hidden = hidden;
    self.updateSPProfileButton.hidden = hidden;
    self.sendPublicUpdateButton.hidden = hidden;
    self.addCustomerButton.hidden = hidden;
}

- (void)hideSPNotEmptyRequestView:(BOOL)hidden
{
    self.tableView.hidden = hidden;
}

#pragma mark - Action
- (void)touchMakeNewRequest:(id)sender
{
    SAMCNewRequestViewController *vc = [[SAMCNewRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchUpdateServiceProfile:(id)sender
{
    SAMCServiceProfileViewController *vc = [[SAMCServiceProfileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchSendPublicUpdate:(id)sender
{
    self.tabBarController.selectedIndex = 1;
}

- (void)touchAddCustomer:(id)sender
{
    SAMCAddContactViewController *vc = [[SAMCAddContactViewController alloc] init];
    vc.currentUserMode = SAMCUserModeTypeSP;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SAMCTableReloadDelegate
- (void)sortAndReload
{
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        if ([self.data count]) {
            [self hideCustomNotEmptyRequestView:NO];
            [self hideCustomEmptyRequestView:YES];
        } else {
            [self hideCustomNotEmptyRequestView:YES];
            [self hideCustomEmptyRequestView:NO];
        }
    } else {
        if ([self.data count]) {
            [self hideSPNotEmptyRequestView:NO];
            [self hideSPEmptyRequestView:YES];
        } else {
            [self hideSPNotEmptyRequestView:YES];
            [self hideSPEmptyRequestView:NO];
        }
    }
    // TODO: add sort
    [self.tableView reloadData];
}

#pragma mark - lazy load
- (NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

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
        
//        [_tableView setSeparatorInset:UIEdgeInsetsZero];
//        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//            [_tableView setLayoutMargins:UIEdgeInsetsZero];
//        }
    }
    return _tableView;
}

- (UILabel *)noRequestTipLabel
{
    if (_noRequestTipLabel == nil) {
        _noRequestTipLabel = [[UILabel alloc] init];
        _noRequestTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noRequestTipLabel.font = [UIFont systemFontOfSize:19.0f];
        _noRequestTipLabel.textColor = SAMC_COLOR_INK;
        _noRequestTipLabel.text = @"No request yet, take a break!";
        _noRequestTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noRequestTipLabel;
}

- (UILabel *)noRequestDetailLabel
{
    if (_noRequestDetailLabel == nil) {
        _noRequestDetailLabel = [[UILabel alloc] init];
        _noRequestDetailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noRequestDetailLabel.font = [UIFont systemFontOfSize:15.0f];
        _noRequestDetailLabel.numberOfLines = 0;
        _noRequestDetailLabel.textColor = SAMC_COLOR_BODY_MID;
        _noRequestDetailLabel.text = @"Meanwhile, tell us more about your service and professional experience to increase your chance of getting a match.";
        _noRequestDetailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noRequestDetailLabel;
}

- (UIButton *)updateSPProfileButton
{
    if (_updateSPProfileButton == nil) {
        _updateSPProfileButton = [[UIButton alloc] init];
        _updateSPProfileButton.translatesAutoresizingMaskIntoConstraints = NO;
        _updateSPProfileButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_updateSPProfileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _updateSPProfileButton.backgroundColor = SAMC_COLOR_LAKE;
        _updateSPProfileButton.layer.cornerRadius = 20.0f;
        [_updateSPProfileButton setTitle:@"Update Service Profile" forState:UIControlStateNormal];
        [_updateSPProfileButton addTarget:self action:@selector(touchUpdateServiceProfile:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateSPProfileButton;
}

- (UIButton *)sendPublicUpdateButton
{
    if (_sendPublicUpdateButton == nil) {
        _sendPublicUpdateButton = [[UIButton alloc] init];
        _sendPublicUpdateButton.translatesAutoresizingMaskIntoConstraints = NO;
        _sendPublicUpdateButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_sendPublicUpdateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendPublicUpdateButton.backgroundColor = SAMC_COLOR_GREY;
        _sendPublicUpdateButton.layer.cornerRadius = 20.0f;
        [_sendPublicUpdateButton setTitle:@"Send Public Update" forState:UIControlStateNormal];
        [_sendPublicUpdateButton addTarget:self action:@selector(touchSendPublicUpdate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendPublicUpdateButton;
}

- (UIButton *)addCustomerButton
{
    if (_addCustomerButton == nil) {
        _addCustomerButton = [[UIButton alloc] init];
        _addCustomerButton.translatesAutoresizingMaskIntoConstraints = NO;
        _addCustomerButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_addCustomerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addCustomerButton.backgroundColor = SAMC_COLOR_GREY;
        _addCustomerButton.layer.cornerRadius = 20.0f;
        [_addCustomerButton setTitle:@"Add Existing Customers" forState:UIControlStateNormal];
        [_addCustomerButton addTarget:self action:@selector(touchAddCustomer:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addCustomerButton;
}

@end
