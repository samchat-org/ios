//
//  SAMCServiceProfileViewController.m
//  SamChat
//
//  Created by HJ on 10/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServiceProfileViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCServicerInfoCell.h"
#import "SAMCProfileSwitcherCell.h"
#import "SAMCSessionViewController.h"
#import "SAMCServicerQRViewController.h"
#import "SAMCPublicManager.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"

@interface SAMCServiceProfileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCServiceProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Service Profile";
    
    self.user = [SAMCAccountManager sharedManager].currentUser;
    
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
    
    SAMCCardPortraitView *headerView = [[SAMCCardPortraitView alloc] initWithFrame:CGRectMake(0, 0, 0, 140)];
    headerView.avatarUrl = _user.userInfo.avatar;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            SAMCServicerQRViewController *vc = [[SAMCServicerQRViewController alloc] initWithUser:self.user];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 2;
            break;
        case 1:
            rows = 3;
            break;
        default:
            break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section) {
        case 1:
            title = @"contact details";
            break;
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    cell = [self servicerInfoCell:tableView];
                    break;
                case 1:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"QR code";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_qr"];
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
                    cell = [self commonDetailCell:tableView];
                    cell.textLabel.text = @"Work phone";
                    NSString *phone = self.user.userInfo.spInfo.phone;
                    cell.detailTextLabel.text = [phone length] ? phone :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_phone"];
                }
                    break;
                case 1:
                {
                    cell = [self commonDetailCell:tableView];
                    cell.textLabel.text = @"Email";
                    NSString *email = self.user.userInfo.spInfo.email;
                    cell.detailTextLabel.text = [email length] ? email :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_email"];
                }
                    break;
                case 2:
                {
                    cell = [self commonDetailCell:tableView];
                    cell.textLabel.text = @"Location";
                    NSString *address = self.user.userInfo.spInfo.address;
                    cell.detailTextLabel.text = [address length] ? address :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_location"];
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
- (UITableViewCell *)servicerInfoCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCServicerInfoCellId";
    SAMCServicerInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCServicerInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell refreshData:self.user];
    return cell;
}

- (UITableViewCell *)commonBasicCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCProfileCommonBasicCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textColor = UIColorFromRGB(0x172843);
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (UITableViewCell *)commonDetailCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCProfileCommonDetailCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.textColor = UIColorFromRGB(0x586874);
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.detailTextLabel.textColor = UIColorFromRGB(0x172843);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return cell;
}

@end