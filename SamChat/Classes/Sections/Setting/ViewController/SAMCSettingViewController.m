//
//  SAMCSettingViewController.m
//  SamChat
//
//  Created by HJ on 7/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableViewCell.h"
#import "UIAlertView+NTESBlock.h"
#import "SAMCAccountManager.h"
#import "SAMCCSAStepOneViewController.h"

@interface SAMCSettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *data;

@end

@implementation SAMCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self prepareCustomModeData];
    } else {
        [self prepareSPModeData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchToUserMode:(NSNotification *)notification
{
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    if (mode == SAMCUserModeTypeCustom) {
        [self prepareCustomModeData];
    } else {
        [self prepareSPModeData];
    }
    [self.tableView reloadData];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Settings";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)prepareCustomModeData
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"Account",
                          RowContent :@[
                                  @{
                                      ExtraInfo     : uid.length ? uid : [NSNull null],
                                      CellClass     : @"SAMCSettingPortraitCell",
                                      RowHeight     : @(100),
                                      CellAction    : @"onActionTouchPortrait:",
                                      ShowAccessory : @(NO)
                                      },
                                  @{
                                      Title         : @"Create Service Account",
                                      CellClass     : @"NTESColorButtonCell",
                                      RowHeight     : @(60),
                                      CellAction    : @"createSamPros:",
                                      ExtraInfo     : @(1),
                                      ForbidSelect  : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"Preferences",
                          RowContent :@[
                                  @{
                                      Title        : @"Notifications",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  @{
                                      Title        : @"Options",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"About",
                          RowContent :@[
                                  @{
                                      Title        : @"About SamChat",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  @{
                                      Title        : @"F.A.Q.",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)prepareSPModeData
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"Service Account",
                          RowContent :@[
                                  @{
                                      ExtraInfo     : uid.length ? uid : [NSNull null],
                                      CellClass     : @"SAMCSettingPortraitCell",
                                      RowHeight     : @(100),
                                      CellAction    : @"onActionTouchPortrait:",
                                      ShowAccessory : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"Service Preferences",
                          RowContent :@[
                                  @{
                                      Title        : @"Notifications",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  @{
                                      Title        : @"Subscription and plans",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NIMCommonTableSection *tableSection = self.data[section];
    return [tableSection.rows count];
}

#define SepViewTag 10001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DefaultTableCell = @"UITableViewCell";
    NIMCommonTableSection *tableSection = self.data[indexPath.section];
    NIMCommonTableRow     *tableRow     = tableSection.rows[indexPath.row];
    NSString *identity = tableRow.cellClassName.length ? tableRow.cellClassName : DefaultTableCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        Class clazz = NSClassFromString(identity);
        cell = [[clazz alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identity];
        UIView *sep = [[UIView alloc] initWithFrame:CGRectZero];
        sep.tag = SepViewTag;
        sep.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        sep.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:sep];
    }
    if (![cell respondsToSelector:@selector(refreshData:tableView:)]) {
        UITableViewCell *defaultCell = (UITableViewCell *)cell;
        [self refreshData:tableRow cell:defaultCell];
    }else{
        [(id<NIMCommonTableViewCell>)cell refreshData:tableRow tableView:tableView];
    }
    cell.accessoryType = tableRow.showAccessory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20*2, 44)];
    customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:customView.frame];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.opaque = NO;
    headerLabel.highlightedTextColor = [UIColor darkGrayColor];
    
    NIMCommonTableSection *tableSection = self.data[section];
    headerLabel.text = tableSection.headerTitle;
    [customView addSubview:headerLabel];
    
    return customView;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NIMCommonTableSection *tableSection = self.data[section];
//    return tableSection.headerTitle;
//}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMCommonTableSection *tableSection = self.data[indexPath.section];
    NIMCommonTableRow     *tableRow     = tableSection.rows[indexPath.row];
    return tableRow.uiRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Private
- (void)refreshData:(NIMCommonTableRow *)rowData cell:(UITableViewCell *)cell{
    cell.textLabel.text = rowData.title;
    cell.detailTextLabel.text = rowData.detailTitle;
}

#pragma mark - Action
- (void)logoutCurrentAccount:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"退出当前帐号？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
                [[SAMCAccountManager sharedManager] logout:^(NSError * _Nullable error) {
                     extern NSString *NTESNotificationLogout;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
                }];
                break;
            default:
                break;
        }
    }];
}

- (void)createSamPros:(id)sender
{
    SAMCCSAStepOneViewController *vc = [[SAMCCSAStepOneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
