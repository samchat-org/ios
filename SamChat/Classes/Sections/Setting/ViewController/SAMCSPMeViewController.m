//
//  SAMCSPMeViewController.m
//  SamChat
//
//  Created by HJ on 10/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPMeViewController.h"
#import "SAMCCardPortraitView.h"

@interface SAMCSPMeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCSPMeViewController

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
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"Service profile";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_sp"];
                }
                    break;
                case 1:
                {
                    cell = [self commonBasicCell:tableView];
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
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"Subscription and plans";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_subscription"];
                }
                    break;
                case 1:
                {
                    cell = [self commonBasicCell:tableView];
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
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"Notification";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_notification"];
                    cell.imageView.frame = CGRectMake(0, 0, 44, 44);
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
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
