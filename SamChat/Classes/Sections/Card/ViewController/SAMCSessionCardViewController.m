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
#import "SAMCTableCellFactory.h"
#import "SAMCOptionPortraitCell.h"
#import "SAMCMemberGroupCell.h"
#import "SAMCContactSelectViewController.h"
#import "SAMCAccountManager.h"

@interface SAMCSessionCardViewController ()<UITableViewDelegate,UITableViewDataSource,NIMMemberGroupViewDelegate,SAMCContactSelectDelegate>

@property (nonatomic, strong) SAMCSession *session;
@property (nonatomic, strong) NIMMemberGroupView *memberGroupView;

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
    [self setupMemberGroupView:self.view.width];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = SAMC_COLOR_LIGHTGREY;
//    _tableView.estimatedRowHeight = 100;
//    _tableView.rowHeight = UITableViewAutomaticDimension;
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

- (void)setupMemberGroupView:(CGFloat)width
{
    _memberGroupView = [[NIMMemberGroupView alloc] initWithFrame:CGRectZero];
    _memberGroupView.delegate = self;
    [_memberGroupView refreshUids:@[self.session.sessionId] operators:CardHeaderOpeatorAdd];
    [_memberGroupView setTitle:@"Add" forOperator:CardHeaderOpeatorAdd];
    CGSize size = [_memberGroupView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    _memberGroupView.size = size;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        if (_session.sessionMode == SAMCUserModeTypeSP) {
            return _memberGroupView.height;
        } else {
            return 90.0f;
        }
    } else {
        return 44.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section == 0) && (_session.sessionMode == SAMCUserModeTypeCustom)) {
        return 0.0f;
    }
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    return CGFLOAT_MIN;
    return 12.0f;
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
            if (self.session.sessionMode == SAMCUserModeTypeSP) {
                title = @"participants";
            } else {
                title = @"";
            }
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
                    if (_session.sessionMode == SAMCUserModeTypeSP) {
                        SAMCMemberGroupCell *memberGroupCell = [SAMCTableCellFactory memberGroupCell:tableView];
                        memberGroupCell.memberGroupView = _memberGroupView;
                        cell = memberGroupCell;
                    } else {
                        SAMCOptionPortraitCell *portraitCell = [SAMCTableCellFactory optionPortraitCell:tableView];
                        [portraitCell refreshData:[[NIMKit sharedKit] infoByUser:self.session.sessionId inSession:self.session.nimSession]];
                        cell = portraitCell;
                    }
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
                    SAMCCommonSwitcherCell *switchCell = [SAMCTableCellFactory commonSwitcherCell:tableView];
                    switchCell.textLabel.text = @"Mute chat";
                    BOOL needNotify = [[NIMSDK sharedSDK].userManager notifyForNewMsg:self.session.sessionId];
                    [switchCell.switcher setOn:!needNotify];
                    [switchCell.switcher addTarget:self action:@selector(onActionNeedNotifyValueChange:) forControlEvents:UIControlEventValueChanged];
                    cell = switchCell;
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Clear chat history";
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
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

#pragma mark - NIMMemberGroupViewDelegate
- (void)didSelectOperator:(NIMKitCardHeaderOpeator )opera
{
    if (opera == CardHeaderOpeatorAdd) {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSString *currentUserID = [[SAMCAccountManager sharedManager] currentAccount];
        [users addObject:currentUserID];
        NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
        config.filterIds = users;
        config.needMutiSelected = YES;
        config.alreadySelectedMemberId = @[self.session.sessionId];
        SAMCContactSelectViewController *vc = [[SAMCContactSelectViewController alloc] initWithConfig:config];
        vc.delegate = self;
        [vc show];
        
    }
}

#pragma mark - SAMCContactSelectDelegate
- (void)didFinishedSelect:(NSArray *)selectedContacts
{
    if (!selectedContacts.count) {
        return;
    }
    DDLogDebug(@"didFinishedSelect: %@", selectedContacts);
    NSString *uid = [SAMCAccountManager sharedManager].currentAccount;
    NSArray *users = [@[uid] arrayByAddingObjectsFromArray:selectedContacts];
    NSString *groupName;
    for (int i=0; i<users.count; i++) {
        if (i>=5) {
            groupName = [groupName stringByAppendingString:@", ..."];
            break;
        }
        NSString *userId = users[i];
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:userId];
        if (i == 0) {
            groupName = info.showName;
            continue;
        }
        groupName = [groupName stringByAppendingString:[NSString stringWithFormat:@", %@", info.showName]];
    }
    
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
    option.name = groupName;
    option.type = NIMTeamTypeNormal;
    __weak typeof(self) wself = self;
    [SVProgressHUD show];
    [[NIMSDK sharedSDK].teamManager createTeam:option
                                         users:users
                                    completion:^(NSError *error, NSString *teamId) {
                                        [SVProgressHUD dismiss];
                                        if (!error) {
                                            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                                            UINavigationController *nav = wself.navigationController;
                                            [nav popToRootViewControllerAnimated:NO];
                                            SAMCSession *samcsession = [SAMCSession session:session.sessionId
                                                                                       type:session.sessionType
                                                                                       mode:SAMCUserModeTypeSP];
                                            SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:samcsession];
                                            [nav pushViewController:vc animated:YES];
                                        }else{
                                            [wself.view makeToast:@"创建讨论组失败" duration:2.0 position:CSToastPositionCenter];
                                        }
                                    }];
}


#pragma mark - Action
- (void)onActionNeedNotifyValueChange:(id)sender{
    UISwitch *switcher = sender;
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].userManager updateNotifyState:!switcher.on forUser:self.session.sessionId completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:@"操作失败"duration:2.0f position:CSToastPositionCenter];
            [switcher setOn:!switcher.on animated:YES];
        }
    }];
}

@end
