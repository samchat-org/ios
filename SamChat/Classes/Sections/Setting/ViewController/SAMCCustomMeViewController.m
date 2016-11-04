//
//  SAMCCustomMeViewController.m
//  SamChat
//
//  Created by HJ on 10/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomMeViewController.h"
#import "SAMCCardPortraitView.h"
#import "UIAlertView+NTESBlock.h"
#import "SAMCAccountManager.h"
#import "SAMCCSAStepOneViewController.h"
#import "SAMCTabViewController.h"
#import "SVProgressHUD.h"
#import "SAMCMyProfileViewController.h"
#import "SAMCTableCellFactory.h"
#import "SAMCUserManager.h"
#import "SAMCUnreadCountManager.h"
#import "SAMCChangePasswordViewController.h"
#import "SAMCWebViewController.h"

@interface SAMCCustomMeViewController ()<UITableViewDelegate, UITableViewDataSource, SAMCUserManagerDelegate, SAMCUnreadCountManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SAMCUser *currentUser;

@property (nonatomic, strong) SAMCBadgeRightCell *switchUserModeCell;

@end

@implementation SAMCCustomMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentViewController.navigationItem.title = @"My Account";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:self.tableView];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    
    SAMCCardPortraitView *headerView = [[SAMCCardPortraitView alloc] initWithFrame:CGRectMake(0, 0, 0, 140) effect:NO];
    _currentUser = [SAMCAccountManager sharedManager].currentUser;
    headerView.avatarUrl = _currentUser.userInfo.avatar;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[SAMCUserManager sharedManager] addDelegate:self];
    [[SAMCUnreadCountManager sharedManager] addDelegate:self];
}

- (void)dealloc
{
    [[SAMCUserManager sharedManager] removeDelegate:self];
    [[SAMCUnreadCountManager sharedManager] removeDelegate:self];
}

#pragma mark - SAMCUserManagerDelegate
- (void)onUserInfoChanged:(SAMCUser *)user
{
    if ([user.userId isEqualToString:_currentUser.userId]) {
        _currentUser = user;
        SAMCCardPortraitView *headerView = (SAMCCardPortraitView *)self.tableView.tableHeaderView;
        headerView.avatarUrl = user.userInfo.avatar;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0: // My profile
                {
                    SAMCMyProfileViewController *vc = [[SAMCMyProfileViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2: // Change password
                {
                    SAMCChangePasswordViewController *vc = [[SAMCChangePasswordViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 4:
                {
                    [self logoutCurrentAccount];
                }
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if ([[SAMCAccountManager sharedManager] isCurrentUserServicer]) {
//                [SVProgressHUD showWithStatus:@"Switching" maskType:SVProgressHUDMaskTypeBlack];
                extern NSString *SAMCUserModeSwitchNotification;
                [[NSNotificationCenter defaultCenter] postNotificationName:SAMCUserModeSwitchNotification
                                                                    object:nil
                                                                  userInfo:nil];
            } else {
                [self createSamPros];
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    SAMCWebViewController *vc = [[SAMCWebViewController alloc] initWithTitle:@"About Samchat" htmlName:@"about"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 5;
            break;
        case 1:
            rows = 1;
            break;
        case 2:
            rows = 2;
            break;
        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"My profile";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_username"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"My QR code";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_qr"];
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Change password";
                    cell.imageView.image = [UIImage imageNamed:@"ico_password"];
                }
                    break;
                case 3:
                {
                    SAMCTipRightCell *tipCell = [SAMCTableCellFactory tipRightCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    tipCell.textLabel.text = @"Notification";
                    tipCell.tipRightLabel.text = @"On";
                    tipCell.imageView.image = [UIImage imageNamed:@"ico_option_notification"];
                    cell = tipCell;
                }
                    break;
                case 4:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.text = @"Log out";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_logout"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    self.switchUserModeCell = [SAMCTableCellFactory badgeRightCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [self.switchUserModeCell refreshBadge:[[SAMCUnreadCountManager sharedManager] allUnreadCountOfUserMode:SAMCUserModeTypeSP]];
                    cell = self.switchUserModeCell;
                    if ([[SAMCAccountManager sharedManager] isCurrentUserServicer]) {
                        cell.textLabel.text = @"Switch to Service Account";
                        cell.imageView.image = [UIImage imageNamed:@"ico_option_switch"];
                    } else {
                        cell.textLabel.text = @"List my service";
                        cell.imageView.image = [UIImage imageNamed:@"ico_option_sp"];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"About Samchat";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_info"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"F.A.Q";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_help"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark - Action
- (void)logoutCurrentAccount
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"logout?" message:nil delegate:nil cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
                [[SAMCAccountManager sharedManager] logout:^(NSError * _Nullable error) {
                    extern NSString *NTESNotificationLogout;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
                }];
                break;
            default:
                break;
        }
    }];
}

- (void)createSamPros
{
    SAMCCSAStepOneViewController *vc = [[SAMCCSAStepOneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SAMCUnreadCountManagerDelegate
- (void)chatUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode != SAMCUserModeTypeCustom) {
        [self refreshOtherModeBadge];
    }
}

- (void)serviceUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode != SAMCUserModeTypeCustom) {
        [self refreshOtherModeBadge];
    }
}

- (void)publicUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode != SAMCUserModeTypeCustom) {
        [self refreshOtherModeBadge];
    }
}

#pragma mark -
- (void)refreshOtherModeBadge
{
    [self.switchUserModeCell refreshBadge:[[SAMCUnreadCountManager sharedManager] allUnreadCountOfUserMode:SAMCUserModeTypeSP]];
}

@end
