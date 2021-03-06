//
//  SAMCSPMeViewController.m
//  SamChat
//
//  Created by HJ on 10/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPMeViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCServiceProfileViewController.h"
#import "SAMCTableCellFactory.h"
#import "SAMCAccountManager.h"
#import "SAMCUnreadCountManager.h"
#import "SAMCQRCodeScanViewController.h"
#import "SAMCSPNotificationViewController.h"

@interface SAMCSPMeViewController ()<UITableViewDelegate, UITableViewDataSource, SAMCUnreadCountManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SAMCBadgeRightCell *switchUserModeCell;

@end

@implementation SAMCSPMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentViewController.navigationItem.title = @"Service Account";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
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
    headerView.avatarUrl = [SAMCAccountManager sharedManager].currentUser.userInfo.avatar;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[SAMCUnreadCountManager sharedManager] addDelegate:self];
    extern NSString *const NIMKitUserInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoHasUpdatedNotification:)
                                                 name:NIMKitUserInfoHasUpdatedNotification
                                               object:nil];
}

- (void)dealloc
{
    [[SAMCUnreadCountManager sharedManager] removeDelegate:self];
}

#pragma mark - NIMKitUserInfoHasUpdatedNotification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification
{
    SAMCCardPortraitView *headerView = (SAMCCardPortraitView *)self.tableView.tableHeaderView;
    headerView.avatarUrl = [SAMCAccountManager sharedManager].currentUser.userInfo.avatar;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    SAMCServiceProfileViewController *vc = [[SAMCServiceProfileViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                    
                case 1:
                {
                    SAMCQRCodeScanViewController *vc = [[SAMCQRCodeScanViewController alloc] initWithUserMode:SAMCUserModeTypeSP segmentIndex:1];
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
                case 0:
                    break;
                case 1:
                {
                    extern NSString *SAMCUserModeSwitchNotification;
                    [[NSNotificationCenter defaultCenter] postNotificationName:SAMCUserModeSwitchNotification
                                                                        object:nil
                                                                      userInfo:nil];
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
                    SAMCSPNotificationViewController *vc = [[SAMCSPNotificationViewController alloc] init];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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
            rows = 2;
            break;
        case 1:
            rows = 2;
            break;
        case 2:
            rows = 1;
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
                    cell.textLabel.text = @"Service profile";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_sp"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"My service QR code";
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
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Subscription and plans";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_subscription"];
                }
                    break;
                case 1:
                {
                    self.switchUserModeCell = [SAMCTableCellFactory badgeRightCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [self.switchUserModeCell refreshBadge:[[SAMCUnreadCountManager sharedManager] allUnreadCountOfUserMode:SAMCUserModeTypeCustom]];
                    cell = self.switchUserModeCell;
                    cell.textLabel.text = @"Switch to personal account";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_switch"];
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
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = @"Notification";
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
                    cell.detailTextLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
                    cell.detailTextLabel.text = @"On";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_notification"];
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

#pragma mark - SAMCUnreadCountManagerDelegate
- (void)chatUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode != SAMCUserModeTypeSP) {
        [self refreshOtherModeBadge];
    }
}

- (void)serviceUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode != SAMCUserModeTypeSP) {
        [self refreshOtherModeBadge];
    }
}

- (void)publicUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode
{
    if (mode != SAMCUserModeTypeSP) {
        [self refreshOtherModeBadge];
    }
}

#pragma mark - 
- (void)refreshOtherModeBadge
{
    [self.switchUserModeCell refreshBadge:[[SAMCUnreadCountManager sharedManager] allUnreadCountOfUserMode:SAMCUserModeTypeCustom]];
}

@end
