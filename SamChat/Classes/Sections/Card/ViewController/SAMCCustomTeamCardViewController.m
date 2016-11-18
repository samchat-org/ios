//
//  SAMCCustomTeamCardViewController.m
//  SamChat
//
//  Created by HJ on 10/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomTeamCardViewController.h"
#import "NIMCardMemberItem.h"
#import "NIMTeamCardOperationItem.h"
#import "NIMTeam.h"
#import "UIView+NIMKitToast.h"
#import "NIMTeamCardRowItem.h"
#import "NIMTeamCardHeaderCell.h"
#import "NIMTeamMemberCardViewController.h"
#import "NIMUsrInfoData.h"
#import "UIView+NIM.h"
#import "NIMMemberGroupView.h"
#import "NIMKitColorButtonCell.h"
#import "NIMTeamSwitchTableViewCell.h"
#import "NIMContactSelectConfig.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "NIMGlobalMacro.h"
#import "SAMCTableCellFactory.h"
#import "SAMCServicerCardViewController.h"

@interface SAMCCustomTeamCardViewController()<NIMTeamManagerDelegate, NIMTeamMemberCardActionDelegate,UITableViewDataSource,UITableViewDelegate,NIMTeamSwitchProtocol>{
    UIAlertView *_quitTeamAlertView;
}

@property (nonatomic,strong) NIMTeamMember *myTeamInfo;

@property (nonatomic,strong) NIMTeam *team;

@property (nonatomic,copy)   NSArray *teamMembers;

@property (nonatomic,strong) NIMMemberGroupView *memberGroupView;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,assign) NIMKitCardHeaderOpeator currentOpera;

@property (nonatomic,strong) NSMutableArray *headerData; //表头collectionView数据

@end

@implementation SAMCCustomTeamCardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NIMSDK sharedSDK].teamManager addDelegate:self];
    }
    return self;
}


- (instancetype)initWithTeam:(NIMTeam *)team{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _team = team;
    }
    return self;
}

- (void)dealloc{
    [[NIMSDK sharedSDK].teamManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Chat Options";
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    _tableView.tableHeaderView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _tableView.backgroundColor = SAMC_COLOR_LIGHTGREY;
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    [self.view addSubview:_tableView];
    __weak typeof(self) wself = self;
    [self requestData:^(NSError *error, NSArray *data) {
        if (!error) {
            [wself refreshWithMembers:data];
        }else{
            [wself.view nimkit_makeToast:@"讨论组成员获取失败"];
        }
        
    }];
}

#pragma mark - Data
- (void)requestData:(void(^)(NSError *error,NSArray *data)) handler
{
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:self.team.teamId completion:^(NSError *error, NSArray *members) {
        NSMutableArray *array = nil;
        if (!error) {
            NSString *myAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
            for (NIMTeamMember *item in members) {
                if ([item.userId isEqualToString:myAccount]) {
                    wself.myTeamInfo = item;
                }
            }
            array = [[NSMutableArray alloc]init];
            for (NIMTeamMember *member in members) {
                NIMTeamCardMemberItem *item = [[NIMTeamCardMemberItem alloc] initWithMember:member];
                [array addObject:item];
            }
            wself.teamMembers = members;
        }else if(error.code == NIMRemoteErrorCodeTeamNotMember){
            [wself.view nimkit_makeToast:@"你已经不在讨论组里"];
        }else{
            [wself.view nimkit_makeToast:@"拉好友失败"];
        }
        handler(error,array);
    }];
}


#pragma mark - UITableViewAction
- (void)quitTeam
{
    _quitTeamAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"确认退出讨论组?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [_quitTeamAlertView show];
}

#pragma mark - TeamSwitchProtocol
- (void)onStateChanged:(BOOL)on
{
    __weak typeof(self) weakSelf = self;
    [[[NIMSDK sharedSDK] teamManager] updateNotifyState:on
                                                 inTeam:[self.team teamId]
                                             completion:^(NSError *error) {
                                                 [weakSelf.tableView reloadData];
                                             }];
}

#pragma mark - NIMTeamManagerDelegate
- (void)onTeamUpdated:(NIMTeam *)team
{
    if ([team.teamId isEqualToString:self.team.teamId]) {
        __weak typeof(self) wself = self;
        [self requestData:^(NSError *error, NSArray *data) {
            [wself refreshWithMembers:data];
        }];
    }
}

- (NIMTeamMember*)teamInfo:(NSString*)uid
{
    for (NIMTeamMember *member in self.teamMembers) {
        if ([member.userId isEqualToString:uid]) {
            return member;
        }
    }
    return nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 1;
    if (section == 2) {
        number = 4;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 90.0f;
    } else if (indexPath.section == 1){
        return self.memberGroupView.nim_height;
    } else {
        return 44.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0f;
    }
    return 30.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //    return CGFLOAT_MIN;
    return 12.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == 1) {
        title = @"participants";
    } else if (section == 2){
        title = @"options";
    }
    return title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
        {
            SAMCOptionPortraitCell *portraitCell = [SAMCTableCellFactory optionPortraitCell:tableView];
            [portraitCell refreshData:[[NIMKit sharedKit] infoByUser:self.team.owner inSession:nil]];
            cell = portraitCell;
        }
            break;
        case 1:
        {
            SAMCMemberGroupCell *memberGroupCell = [SAMCTableCellFactory memberGroupCell:tableView];
            memberGroupCell.memberGroupView = _memberGroupView;
            cell = memberGroupCell;
        }
            break;
        case 2:
        {
            return [self cellOfOptionsRow:indexPath.row tableView:tableView];
        }
            break;
        default:
            break;
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        SAMCServicerCardViewController *vc = [[SAMCServicerCardViewController alloc] initWithUserId:self.team.owner];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 3) {
            [self quitTeam];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView == _quitTeamAlertView) {
        switch (buttonIndex) {
            case 0://取消
                break;
            case 1:{
                [[NIMSDK sharedSDK].teamManager quitTeam:self.team.teamId completion:^(NSError *error) {
                    if (!error) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }else{
                        [self.view nimkit_makeToast:@"退出失败"];
                    }
                }];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Refresh
- (void)refreshWithMembers:(NSArray*)members
{
    self.headerData = [members mutableCopy];
    [self setupMemberGroupView:self.view.nim_width];
    [self.tableView reloadData];
}

- (void)setupMemberGroupView:(CGFloat)width
{
    self.memberGroupView = [[NIMMemberGroupView alloc] initWithFrame:CGRectZero];
    self.memberGroupView.delegate = nil;
    NIMKitCardHeaderOpeator opeartor;
    opeartor = CardHeaderOpeatorNone;
    [self.memberGroupView refreshUids:self.headerUserIds operators:opeartor];
    CGSize size = [self.memberGroupView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    self.memberGroupView.nim_size = size;
    self.memberGroupView.enableRemove = self.currentOpera == CardHeaderOpeatorRemove;
}


#pragma mark - Private
- (NSArray*)headerUserIds
{
    NSMutableArray * uids = [[NSMutableArray alloc] init];
    for (id<NIMKitCardHeaderData> data in self.headerData) {
        if ([data respondsToSelector:@selector(memberId)] && data.memberId.length) {
            [uids addObject:data.memberId];
        }
    }
    return uids;
}

#pragma mark -
- (UITableViewCell *)cellOfOptionsRow:(NSInteger)row tableView:(UITableView *)tableView
{
    UITableViewCell *cell;
    switch (row) {
        case 0:
        {
            SAMCCommonSwitcherCell *swithCell = [SAMCTableCellFactory commonSwitcherCell:tableView];
            swithCell.textLabel.text = @"Mute chat";
            [swithCell.switcher setOn:![self.team notifyForNewMsg]];
            [swithCell.switcher addTarget:self action:@selector(onActionNeedNotifyValueChange:) forControlEvents:UIControlEventValueChanged];
            cell = swithCell;
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
        case 3:
        {
            cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryNone];
            cell.textLabel.text = @"Quit group";
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)onActionNeedNotifyValueChange:(id)sender
{
    UISwitch *switcher = sender;
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    [[[NIMSDK sharedSDK] teamManager] updateNotifyState:!switcher.on inTeam:[self.team teamId] completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:@"操作失败"duration:2.0f position:CSToastPositionCenter];
            [switcher setOn:!switcher.on animated:YES];
        }
    }];
}

@end
