//
//  SAMCServicerCardViewController.m
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServicerCardViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCServicerInfoCell.h"
#import "SAMCProfileSwitcherCell.h"

@interface SAMCServicerCardViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCServicerCardViewController

- (instancetype)initWithUser:(SAMCUser *)user{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    [self refresh];
    
    SAMCCardPortraitView *headerView = [[SAMCCardPortraitView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    headerView.avatarUrl = _user.userInfo.avatar;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)refresh
{
    [self.tableView reloadData];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 4;
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
                    cell.textLabel.text = @"Chat now";
                    cell.imageView.image = [UIImage imageNamed:@"icon_chatnow_normal"];
                }
                    break;
                    
                case 2:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"QR code";
                    cell.imageView.image = [UIImage imageNamed:@"icon_qrcode_normal"];
                }
                    break;
                case 3:
                {
                    cell = [self followCell:tableView];
                }
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
                    cell.detailTextLabel.text = self.user.userInfo.spInfo.phone;
                    cell.imageView.image = [UIImage imageNamed:@"icon_phone_normal"];
                }
                    break;
                case 1:
                {
                    cell = [self commonDetailCell:tableView];
                    cell.textLabel.text = @"Email";
                    cell.detailTextLabel.text = self.user.userInfo.spInfo.email;
                    cell.imageView.image = [UIImage imageNamed:@"icon_email_normal"];
                }
                    break;
                case 2:
                {
                    cell = [self commonDetailCell:tableView];
                    cell.textLabel.text = @"Location";
                    cell.detailTextLabel.text = self.user.userInfo.spInfo.address;
                    cell.imageView.image = [UIImage imageNamed:@"icon_address_normal"];
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

- (UITableViewCell *)followCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCProfileSwitcherCellId";
    SAMCProfileSwitcherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCProfileSwitcherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textColor = UIColorFromRGB(0x172843);
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    cell.textLabel.text = @"Follow";
    cell.imageView.image = [UIImage imageNamed:@"icon_follow_normal"];
    return cell;

}

#pragma mark - lazy load

@end