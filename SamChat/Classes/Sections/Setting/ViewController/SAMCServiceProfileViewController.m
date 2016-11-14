//
//  SAMCServiceProfileViewController.m
//  SamChat
//
//  Created by HJ on 10/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServiceProfileViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCSessionViewController.h"
#import "SAMCUserQRViewController.h"
#import "SAMCPublicManager.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCTableCellFactory.h"
#import "SAMCEditProfileViewController.h"
#import "SAMCSelectLocationViewController.h"
#import "SAMCSettingManager.h"
#import "SAMCServerAPIMacro.h"

@interface SAMCServiceProfileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCServiceProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Service Profile";
    
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
    headerView.avatarUrl = [SAMCAccountManager sharedManager].currentUser.userInfo.avatar;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    extern NSString *const NIMKitUserInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoHasUpdatedNotification:)
                                                 name:NIMKitUserInfoHasUpdatedNotification
                                               object:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAMCUser *user = [SAMCAccountManager sharedManager].currentUser;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0: // company name
                {
                    NSString *companyName = user.userInfo.spInfo.companyName ?:@"";
                    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_COMPANY_NAME:companyName}};
                    SAMCEditProfileViewController *vc = [[SAMCEditProfileViewController alloc] initWithProfileType:SAMCEditProfileTypeSPCompanyName
                                                                                                       profileDict:profileDict];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1: // service category
                {
                    NSString *category = user.userInfo.spInfo.serviceCategory ?:@"";
                    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_SERVICE_CATEGORY:category}};
                    SAMCEditProfileViewController *vc = [[SAMCEditProfileViewController alloc] initWithProfileType:SAMCEditProfileTypeSPServiceCategory
                                                                                                       profileDict:profileDict];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2: // service desc
                {
                    NSString *desc = user.userInfo.spInfo.serviceDescription ?:@"";
                    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_SERVICE_DESCRIPTION:desc}};
                    SAMCEditProfileViewController *vc = [[SAMCEditProfileViewController alloc] initWithProfileType:SAMCEditProfileTypeSPDescription
                                                                                                       profileDict:profileDict];
                    [self.navigationController pushViewController:vc animated:YES];
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
                case 0: // work phone
                {
                    NSString *phone = user.userInfo.spInfo.phone ?:@"";
                    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_PHONE:phone}};
                    SAMCEditProfileViewController *vc = [[SAMCEditProfileViewController alloc] initWithProfileType:SAMCEditProfileTypeSPPhone
                                                                                                       profileDict:profileDict];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1: // work email
                {
                    NSString *email = user.userInfo.spInfo.email ?:@"";
                    NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_EMAIL:email}};
                    SAMCEditProfileViewController *vc = [[SAMCEditProfileViewController alloc] initWithProfileType:SAMCEditProfileTypeSPEmail
                                                                                                       profileDict:profileDict];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2: // work location
                {
                    [self updateLocation];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 3;
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
    SAMCUser *user = [SAMCAccountManager sharedManager].currentUser;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Company name";
                    NSString *companyName = user.userInfo.spInfo.companyName;
                    cell.detailTextLabel.text = [companyName length] ? companyName :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_sp"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Service category";
                    NSString *category = user.userInfo.spInfo.serviceCategory;
                    cell.detailTextLabel.text = [category length] ? category :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_category"];
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Service description";
                    NSString *desc = user.userInfo.spInfo.serviceDescription;
                    cell.detailTextLabel.text = [desc length] ? desc :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_description"];
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
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Work phone";
                    NSString *phone = user.userInfo.spInfo.phone;
                    cell.detailTextLabel.text = [phone length] ? phone :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_phone"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Email";
                    NSString *email = user.userInfo.spInfo.email;
                    cell.detailTextLabel.text = [email length] ? email :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_email"];
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Location";
                    NSString *address = user.userInfo.spInfo.address;
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

#pragma mark - NIMKitUserInfoHasUpdatedNotification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)updateLocation
{
    SAMCSelectLocationViewController *vc = [[SAMCSelectLocationViewController alloc] initWithHideCurrentLocation:YES userMode:SAMCUserModeTypeSP];
    __weak typeof(self) wself = self;
    vc.selectBlock = ^(NSDictionary *location, BOOL isCurrentLocation){
        if (isCurrentLocation) {
            return;
        }
        NSDictionary *profileDict = @{SAMC_SAM_PROS_INFO:@{SAMC_LOCATION:location}};
        [SVProgressHUD showWithStatus:@"updating" maskType:SVProgressHUDMaskTypeBlack];
        [[SAMCSettingManager sharedManager] updateProfile:profileDict completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (error) {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
            } else {
                [wself.view makeToast:@"success" duration:2 position:CSToastPositionCenter];
            }
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
