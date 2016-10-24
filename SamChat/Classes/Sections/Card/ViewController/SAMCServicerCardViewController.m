//
//  SAMCServicerCardViewController.m
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServicerCardViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCSessionViewController.h"
#import "SAMCServicerQRViewController.h"
#import "SAMCPublicManager.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCUserManager.h"
#import "SAMCTableCellFactory.h"
#import "SAMCUserManager.h"

@interface SAMCServicerCardViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, assign) BOOL isMyProvider;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCServicerCardViewController

- (instancetype)initWithUser:(SAMCUser *)user isFollow:(BOOL)isFollow isMyProvider:(BOOL)isMyProvider
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _user = user;
        _isFollow = isFollow;
        _isMyProvider = isMyProvider;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    
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
        // chat
        if (indexPath.row == 1) {
            UINavigationController *nav = self.navigationController;
            SAMCSession *session = [SAMCSession session:self.user.userId type:NIMSessionTypeP2P mode:SAMCUserModeTypeCustom];
            SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:session];
            [nav pushViewController:vc animated:YES];
            UIViewController *root = nav.viewControllers[0];
            nav.viewControllers = @[root,vc];
        }
        // qr code
        if (indexPath.row == 2) {
            SAMCServicerQRViewController *vc = [[SAMCServicerQRViewController alloc] initWithUser:self.user];
            [self.navigationController pushViewController:vc animated:YES];
        }
        // add or delete provider
        if (indexPath.row == 3) {
            [self addOrDeleteProvider];
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
            rows = 5;
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
                {
                    SAMCServicerInfoCell *infoCell = [SAMCTableCellFactory servicerInfoCell:tableView];
                    [infoCell refreshData:self.user];
                    cell = infoCell;
                }
                    break;
                    
                case 1:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Chat now";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_chat"];
                }
                    break;
                    
                case 2:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"QR code";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_qr"];
                }
                    break;
                    
                case 3:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    if (_isMyProvider) {
                        cell.textLabel.text = @"Delete Provider";
                    } else {
                        cell.textLabel.text = @"Add to Provider";
                    }
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_add"];
                }
                    break;
                    
                case 4:
                {
                    cell = [self followCell:tableView];
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
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Work phone";
                    NSString *phone = self.user.userInfo.spInfo.phone;
                    cell.detailTextLabel.text = [phone length] ? phone :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_phone"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Email";
                    NSString *email = self.user.userInfo.spInfo.email;
                    cell.detailTextLabel.text = [email length] ? email :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_email"];
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
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
- (UITableViewCell *)followCell:(UITableView *)tableView
{
    SAMCCommonSwitcherCell *cell = [SAMCTableCellFactory commonSwitcherCell:tableView];
    [cell.switcher setOn:_isFollow];
    [cell.switcher addTarget:self action:@selector(follow:) forControlEvents:UIControlEventValueChanged];
    cell.textLabel.text = @"Follow";
    cell.imageView.image = [UIImage imageNamed:@"ico_option_follow"];
    return cell;

}

- (void)follow:(UISwitch *)switcher
{
    DDLogDebug(@"follow");
    [SVProgressHUD showWithStatus:@"operating..." maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    BOOL follow = !_isFollow;
    [[SAMCPublicManager sharedManager] follow:follow officialAccount:_user.spBasicInfo completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        NSString *toast;
        if (error) {
            toast =error.userInfo[NSLocalizedDescriptionKey];
            [switcher setOn:!follow animated:YES];
        } else {
            if (follow) {
                toast = @"follow success";
                wself.isFollow = true;
                [[SAMCUserManager sharedManager] updateUser:_user];
            } else {
                toast = @"unfollow success";
                wself.isFollow = false;
            }
        }
        [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
    }];
}

- (void)addOrDeleteProvider
{
    BOOL isAdd;
    NSString *showMsg;
    if (self.isMyProvider) {
        isAdd = NO;
        showMsg = @"Deleting...";
    } else {
        isAdd = YES;
        showMsg = @"Adding...";
    }
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:showMsg maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCUserManager sharedManager] addOrRemove:isAdd contact:_user type:SAMCContactListTypeServicer completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        NSString *toast;
        if (error) {
            toast = error.userInfo[NSLocalizedDescriptionKey];
        } else {
            if (isAdd) {
                toast = @"add success";
                wself.isMyProvider = YES;
            } else {
                toast = @"delete success";
                wself.isMyProvider = NO;
            }
            [wself.tableView reloadData];
        }
        [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
    }];
}

@end