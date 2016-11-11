//
//  SAMCNotificationSettingViewController.m
//  SamChat
//
//  Created by HJ on 11/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCNotificationSettingViewController.h"
#import "SAMCFooterView.h"
#import "SAMCTableCellFactory.h"
#import "SAMCPreferenceManager.h"

@interface SAMCNotificationSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCNotificationSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Notifications";
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    _tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    _tableView.estimatedSectionFooterHeight = 44;
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
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    SAMCFooterView *footerView = [[SAMCFooterView alloc] init];
    if (section == 0) {
        footerView.textLabel.text = @"Enable or disable SamChat Notifications via \"Settings\"->\"Notifications\" on your iPhone.";
    } else if (section == 1) {
        footerView.textLabel.text = @"Specify preference to be notified by Sound or Vibration when receiving new message.";
    }
    return footerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 2;
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
                    BOOL disableRemoteNotification = [UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone;
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    cell.textLabel.text = @"Notification";
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
                    cell.detailTextLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
                    cell.detailTextLabel.text = disableRemoteNotification ? @"Off" : @"On";
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
                    SAMCCommonSwitcherCell *swithCell = [SAMCTableCellFactory commonSwitcherCell:tableView];
                    swithCell.textLabel.text = @"In-App Alert Sound";
                    [swithCell.switcher setOn:[[SAMCPreferenceManager sharedManager].needSound boolValue]];
                    [swithCell.switcher addTarget:self action:@selector(onActionAlertSoundChanged:) forControlEvents:UIControlEventValueChanged];
                    cell = swithCell;
                }
                    break;
                case 1:
                {
                    SAMCCommonSwitcherCell *swithCell = [SAMCTableCellFactory commonSwitcherCell:tableView];
                    swithCell.textLabel.text = @"Vibrate";
                    [swithCell.switcher setOn:[[SAMCPreferenceManager sharedManager].needVibrate boolValue]];
                    [swithCell.switcher addTarget:self action:@selector(onActionVibrateChanged:) forControlEvents:UIControlEventValueChanged];
                    cell = swithCell;
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
- (void)onActionAlertSoundChanged:(UISwitch *)sender
{
    [SAMCPreferenceManager sharedManager].needSound = @(sender.on);
}

- (void)onActionVibrateChanged:(UISwitch *)sender
{
    [SAMCPreferenceManager sharedManager].needVibrate = @(sender.on);
}

@end
