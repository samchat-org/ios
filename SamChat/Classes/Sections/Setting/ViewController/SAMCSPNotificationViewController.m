//
//  SAMCSPNotificationViewController.m
//  SamChat
//
//  Created by HJ on 11/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPNotificationViewController.h"
#import "SAMCTableCellFactory.h"
#import "SAMCPreferenceManager.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"

@interface SAMCSPNotificationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCSPNotificationViewController

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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
                    SAMCCommonSwitcherCell *swithCell = [SAMCTableCellFactory commonSwitcherCell:tableView];
                    swithCell.textLabel.text = @"New Request Notification";
                    [swithCell.switcher setOn:[[SAMCPreferenceManager sharedManager].needQuestionNotify boolValue]];
                    [swithCell.switcher addTarget:self action:@selector(onActionNotificationChanged:) forControlEvents:UIControlEventValueChanged];
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
- (void)onActionNotificationChanged:(UISwitch *)sender
{
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"updating..." maskType:SVProgressHUDMaskTypeBlack];
    [[SAMCSettingManager sharedManager] updateQuestionNotify:sender.on completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSString *toast;
            toast =error.userInfo[NSLocalizedDescriptionKey];
            [sender setOn:!sender.on animated:YES];
            [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
        }
    }];
}

@end
