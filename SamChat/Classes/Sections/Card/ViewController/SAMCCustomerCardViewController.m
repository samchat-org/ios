//
//  SAMCCustomerCardViewController.m
//  SamChat
//
//  Created by HJ on 10/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomerCardViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCSessionViewController.h"
#import "SAMCUserQRViewController.h"
#import "SAMCPublicManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCUserManager.h"
#import "SAMCTableCellFactory.h"

@interface SAMCCustomerCardViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, assign) BOOL isMyCustomer;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCCustomerCardViewController

- (instancetype)initWithUserId:(NSString *)userId
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _showInfoOnly = false;
        _user = [[SAMCUserManager sharedManager] userInfo:userId];
        _isMyCustomer = [[SAMCUserManager sharedManager] isMyCustomer:userId];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.estimatedRowHeight = 100;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:_tableView];
    UIEdgeInsets separatorInset   = _tableView.separatorInset;
    separatorInset.right          = 0;
    _tableView.separatorInset = separatorInset;
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    
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
    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self updateUser];
}

- (void)updateUser
{
    __weak typeof(self) wself = self;
    [[SAMCUserManager sharedManager] queryAccurateUser:@([_user.userId integerValue]) type:SAMCQueryAccurateUserTypeUniqueId completion:^(NSDictionary * _Nullable userDict, NSError * _Nullable error) {
        if ((error == nil) && (userDict != nil)) {
            SAMCUser *user = [SAMCUser userFromDict:userDict];
            [[SAMCUserManager sharedManager] updateUser:user];
            wself.user = user;
            [wself.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            SAMCUserQRViewController *vc = [[SAMCUserQRViewController alloc] initWithUser:self.user userType:SAMCUserTypeCustom];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if ((!_showInfoOnly) && (indexPath.section == 1)) {
        // chat
        if (indexPath.row == 0) {
            UINavigationController *nav = self.navigationController;
            SAMCSession *session = [SAMCSession session:self.user.userId type:NIMSessionTypeP2P mode:SAMCUserModeTypeSP];
            SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:session];
            [nav pushViewController:vc animated:YES];
            UIViewController *root = nav.viewControllers[0];
            nav.viewControllers = @[root,vc];
        }
        // add or delete customer
        if (indexPath.row == 1) {
            [self addOrDeleteCustomer];
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
    return _showInfoOnly ? 2 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
            rows = _showInfoOnly ? 3 : 2;
            break;
        case 2:
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
            title = _showInfoOnly ? @"contact details" : @"";
            break;
        case 2:
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
    NSInteger section = indexPath.section;
    if (_showInfoOnly && (section==1)) {
        section = 2;
    }
    switch (section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = _user.userInfo.username;
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
                    cell.detailTextLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
                    cell.detailTextLabel.text = @"QR code";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_username"];
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
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Chat now";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_chat"];
                }
                    break;
                    
                case 1:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    if (_isMyCustomer) {
                        cell.textLabel.text = @"Delete Customer";
                    } else {
                        cell.textLabel.text = @"Add to Customer";
                    }
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_add"];
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
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Phone no.";
                    NSString *phone = self.user.userInfo.cellPhone;
                    cell.detailTextLabel.text = [phone length] ? phone :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_phone"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Email";
                    NSString *email = self.user.userInfo.email;
                    cell.detailTextLabel.text = [email length] ? email :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_email"];
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Location";
                    NSString *address = self.user.userInfo.address;
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

#pragma mark - Action
- (void)addOrDeleteCustomer
{
    BOOL isAdd;
    NSString *showMsg;
    if (self.isMyCustomer) {
        isAdd = NO;
        showMsg = @"Deleting...";
    } else {
        isAdd = YES;
        showMsg = @"Adding...";
    }
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:showMsg maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCUserManager sharedManager] addOrRemove:isAdd contact:_user type:SAMCContactListTypeCustomer completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        NSString *toast;
        if (error) {
            toast = error.userInfo[NSLocalizedDescriptionKey];
        } else {
            if (isAdd) {
                toast = @"add success";
                wself.isMyCustomer = YES;
            } else {
                toast = @"delete success";
                wself.isMyCustomer = NO;
            }
            [wself.tableView reloadData];
        }
        [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
    }];
}

@end
