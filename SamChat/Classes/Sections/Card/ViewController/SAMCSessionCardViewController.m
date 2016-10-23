//
//  SAMCSessionCardViewController.m
//  SamChat
//
//  Created by HJ on 8/10/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSessionCardViewController.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "SAMCSessionViewController.h"
#import "SAMCSession.h"
#import "SAMCOptionPortraitCell.h"
#import "SAMCProfileSwitcherCell.h"

@interface SAMCSessionCardViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) SAMCSession *session;

@end

@implementation SAMCSessionCardViewController

- (instancetype)initWithSession:(SAMCSession *)session{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Chat Options";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.estimatedRowHeight = 100;
    _tableView.backgroundColor = SAMC_COLOR_LIGHTGREY;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:_tableView];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    _tableView.tableHeaderView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    
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
            rows = 1;
            break;
        case 1:
            rows = 3;
        default:
            break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section) {
        case 0:
            title = @"";
            break;
        case 1:
            title = @"options";
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
                    cell = [self optionPortraitCell:tableView];
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
                    cell = [self commonSwitcherCell:tableView];
                    cell.textLabel.text = @"Mute chat";
                    //    [cell.switcher setOn:];
                    //    [cell.switcher addTarget:self action:@selector() forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case 1:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"Clear chat history";
                }
                    break;
                case 2:
                {
                    cell = [self commonBasicCell:tableView];
                    cell.textLabel.text = @"Report abuse";
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
- (UITableViewCell *)optionPortraitCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCOptionPortraitCellId";
    SAMCOptionPortraitCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCOptionPortraitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell refreshData:[[NIMKit sharedKit] infoByUser:self.session.sessionId inSession:self.session.nimSession]];
    return cell;
}

- (UITableViewCell *)commonBasicCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCCommonBasicCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)commonSwitcherCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCCommonSwitcherCellId";
    SAMCProfileSwitcherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCProfileSwitcherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textColor = SAMC_COLOR_INK;
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    return cell;
}

@end
