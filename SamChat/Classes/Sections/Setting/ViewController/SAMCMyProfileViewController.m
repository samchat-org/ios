//
//  SAMCMyProfileViewController.m
//  SamChat
//
//  Created by HJ on 10/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMyProfileViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCServicerInfoCell.h"
#import "SAMCProfileSwitcherCell.h"
#import "SAMCSessionViewController.h"
#import "SAMCServicerQRViewController.h"
#import "SAMCPublicManager.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"

@interface SAMCMyProfileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"My Profile";
    
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
    [headerView.avatarView addTarget:self action:@selector(onTouchPortraitAvatar:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
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
                    cell = [self commonDetailCell:tableView];
                    cell.textLabel.text = @"Name";
                    NSString *name = self.user.userInfo.username;
                    cell.detailTextLabel.text = [name length] ? name :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_username"];
                }
                    break;
                case 1:
                {
                    cell = [self commonDetailCell:tableView];
                    cell.textLabel.text = @"Phone no.";
                    NSString *phone = self.user.userInfo.cellPhone;
                    cell.detailTextLabel.text = [phone length] ? phone :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_phone"];
                }
                    break;
                case 2:
                {
                    cell = [self commonDetailCell:tableView];
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
- (void)onTouchPortraitAvatar:(id)sender
{
    DDLogDebug(@"onTouchPortraitAvatar");
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.allowsEditing = YES;
//    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Cell
- (UITableViewCell *)commonDetailCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCProfileCommonDetailCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
        cell.detailTextLabel.textColor = SAMC_COLOR_INK;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return cell;
}

@end
