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

@interface SAMCCustomMeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

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
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:uid];
    headerView.avatarUrl = info.avatarUrlString;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
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
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"My profile";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_username"];
                }
                    break;
                case 1:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"My QR code";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_qr"];
                }
                    break;
                case 2:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"Change password";
                    cell.imageView.image = [UIImage imageNamed:@"ico_password"];
                }
                    break;
                case 3:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"Notification";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_notification"];
                }
                    break;
                case 4:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.text = @"Log out";
                    cell.imageView.image = [UIImage imageNamed:@"icon_logout_normal"];
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
                    cell = [self commonBasicCell:tableView];
                    if ([[SAMCAccountManager sharedManager] isCurrentUserServicer]) {
                        cell.textLabel.text = @"Switch to Service Account";
                        cell.imageView.image = [UIImage imageNamed:@"ico_option_switch"];
                    } else {
                        cell.textLabel.text = @"List my service";
                        cell.imageView.image = [UIImage imageNamed:@"icon_create_servicer_name"];
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
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"About Samchat";
                    cell.imageView.image = [UIImage imageNamed:@"icon_about_normal"];
                }
                    break;
                case 1:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"F.A.Q";
                    cell.imageView.image = [UIImage imageNamed:@"icon_faq_normal"];
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

#pragma mark - 
- (UITableViewCell *)commonBasicCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCMeCommonBasicCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

@end
