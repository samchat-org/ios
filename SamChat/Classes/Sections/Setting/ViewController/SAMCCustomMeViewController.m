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
#import "SAMCQRCodeScanViewController.h"
#import "SAMCSPIntroViewController.h"
#import "SAMCCellButton.h"
#import "SAMCNotificationSettingViewController.h"

@interface SAMCCustomMeViewController ()<UITableViewDelegate, UITableViewDataSource, SAMCUserManagerDelegate, SAMCUnreadCountManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SAMCBadgeRightCell *switchUserModeCell;

@end

@implementation SAMCCustomMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentViewController.navigationItem.title = @"My Account";
    
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
                case 0: // My profile
                {
                    SAMCMyProfileViewController *vc = [[SAMCMyProfileViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:
                {
                    SAMCQRCodeScanViewController *vc = [[SAMCQRCodeScanViewController alloc] initWithUserMode:SAMCUserModeTypeCustom segmentIndex:1];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2: // Change password
                {
                    SAMCChangePasswordViewController *vc = [[SAMCChangePasswordViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:
                {
                    SAMCNotificationSettingViewController *vc = [[SAMCNotificationSettingViewController alloc] init];
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
                case 1:
                {
                    SAMCWebViewController *vc = [[SAMCWebViewController alloc] initWithTitle:@"F.A.Q" htmlName:@"faq"];
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
                    BOOL disableRemoteNotification = [UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone;
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = @"Notification";
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
                    cell.detailTextLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
                    cell.detailTextLabel.text = disableRemoteNotification ? @"Off" : @"On";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_notification"];
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
                        [self addLearnMoreButton:cell];
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
                [[SAMCAccountManager sharedManager] logout:^(NSError * _Nullable error) { }];
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

- (void)learnMore:(id)sender
{
    SAMCSPIntroViewController *vc = [[SAMCSPIntroViewController alloc] initWithTitle:@"Become a Service Provider" htmlName:@"becomesp"];
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

- (void)addLearnMoreButton:(UITableViewCell *)cell
{
    SAMCCellButton *learnMoreButton = [[SAMCCellButton alloc] init];
    learnMoreButton.translatesAutoresizingMaskIntoConstraints = NO;
    learnMoreButton.layer.cornerRadius = 14.0f;
    learnMoreButton.layer.masksToBounds = YES;
    learnMoreButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [learnMoreButton setTitle:@"Learn more" forState:UIControlStateNormal];
    [learnMoreButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
    [learnMoreButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
    [learnMoreButton addTarget:self action:@selector(learnMore:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:learnMoreButton];
    [learnMoreButton addConstraint:[NSLayoutConstraint constraintWithItem:learnMoreButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:0.0f
                                                                 constant:28.0f]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:learnMoreButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:learnMoreButton
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    
}

@end
