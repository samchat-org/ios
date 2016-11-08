//
//  SAMCSPTeamCardViewController.m
//  SamChat
//
//  Created by HJ on 10/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPTeamCardViewController.h"
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
#import "SAMCContactSelectViewController.h"
#import "NIMProgressHUD.h"
#import "NIMGlobalMacro.h"
#import "SAMCTableCellFactory.h"
#import "SAMCEditTeamNameViewController.h"

@interface SAMCSPTeamCardViewController ()<NIMTeamManagerDelegate, NIMTeamMemberCardActionDelegate,UITableViewDataSource,UITableViewDelegate,NIMTeamSwitchProtocol,SAMCContactSelectDelegate,NIMMemberGroupViewDelegate>{
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

@implementation SAMCSPTeamCardViewController

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

- (void)addHeaderDatas:(NSArray*)members
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NIMTeamMember *member in members) {
        NIMTeamCardMemberItem* item = [[NIMTeamCardMemberItem alloc] initWithMember:member];
        [array addObject:item];
    }
    [self addMembers:array];
}

#pragma mark - UITableViewAction
- (void)updateTeamInfoName
{
    SAMCEditTeamNameViewController *vc = [[SAMCEditTeamNameViewController alloc] initWithTeam:self.team];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)quitTeam
{
    _quitTeamAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"确认退出讨论组?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [_quitTeamAlertView show];
}

#pragma mark - ContactSelectDelegate
- (void)didFinishedSelect:(NSArray *)selectedContacts
{
    if (selectedContacts.count) {
        __weak typeof(self) wself = self;
        switch (self.currentOpera) {
            case CardHeaderOpeatorAdd:{
                [NIMProgressHUD show];
                [[NIMSDK sharedSDK].teamManager addUsers:selectedContacts
                                                  toTeam:self.team.teamId
                                              postscript:@"邀请你加入讨论组"
                                              completion:^(NSError *error,NSArray *members) {
                                                  [NIMProgressHUD dismiss];
                                                  if (!error) {
                                                      if (self.team.type == NIMTeamTypeNormal) {
                                                          [wself addHeaderDatas:members];
                                                      }
                                                  }else{
                                                      [wself.view nimkit_makeToast:@"邀请失败"];
                                                  }
                                                  wself.currentOpera = CardHeaderOpeatorNone;
                                                  
                                              }];
            }
                break;
            default:
                break;
        }
    }
}

- (void)didCancelledSelect
{
    self.currentOpera = CardHeaderOpeatorNone;
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
        wself.team = team;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 1;
    if (section == 1) {
        number = 4;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        return self.memberGroupView.nim_height;
    } else {
        return 44.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //    return CGFLOAT_MIN;
    return 12.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == 0) {
        title = @"participants";
    } else {
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
            switch (indexPath.row) {
                case 0:
                {
                    SAMCMemberGroupCell *memberGroupCell = [SAMCTableCellFactory memberGroupCell:tableView];
                    memberGroupCell.memberGroupView = _memberGroupView;
                    cell = memberGroupCell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
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
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self updateTeamInfoName];
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


#pragma mark - NIMMemberGroupViewDelegate
- (void)didSelectRemoveButtonWithMemberId:(NSString *)uid
{
    __weak typeof(self) wself = self;
    [NIMProgressHUD show];
    [[NIMSDK sharedSDK].teamManager kickUsers:@[uid] fromTeam:self.team.teamId completion:^(NSError *error) {
        [NIMProgressHUD dismiss];
        if (!error) {
            [wself removeMembers:@[uid]];
        }else{
            [wself.view nimkit_makeToast:@"Remove error"];
        }
    }];
}

- (void)didSelectOperator:(NIMKitCardHeaderOpeator)opera
{
    switch (opera) {
        case CardHeaderOpeatorAdd:{
            self.currentOpera = CardHeaderOpeatorAdd;
            NSMutableArray *users = [[NSMutableArray alloc] init];
            NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
            [users addObject:currentUserID];
            [users addObjectsFromArray:self.headerUserIds];
            NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
            config.filterIds = users;
            config.needMutiSelected = YES;
            SAMCContactSelectViewController *vc = [[SAMCContactSelectViewController alloc] initWithConfig:config];
            vc.delegate = self;
            [vc show];
            break;
        }
        case CardHeaderOpeatorRemove:{
            self.currentOpera = self.currentOpera==CardHeaderOpeatorRemove? CardHeaderOpeatorNone : CardHeaderOpeatorRemove;
            [self setupMemberGroupView:self.view.nim_width];
            [self.tableView reloadData];
            break;
        }
        default:
            break;
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
    self.memberGroupView.delegate = self;
    NIMKitCardHeaderOpeator opeartor;
    if (self.myTeamInfo.type == NIMTeamMemberTypeOwner) {
        opeartor = CardHeaderOpeatorAdd | CardHeaderOpeatorRemove;
    }else{
        opeartor = CardHeaderOpeatorNone;
    }
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


- (void)addMembers:(NSArray*)members
{
    NSInteger opeatorCount = 0;
    for (id<NIMKitCardHeaderData> data in self.headerData.reverseObjectEnumerator.allObjects) {
        if ([data respondsToSelector:@selector(opera)]) {
            opeatorCount++;
        }else{
            break;
        }
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.headerData.count - opeatorCount, members.count)];
    [self.headerData insertObjects:members atIndexes:indexSet];
    [self refreshWithMembers:self.headerData];
}

- (void)removeMembers:(NSArray*)members
{
    for (id object in members) {
        if ([object isKindOfClass:[NSString class]]) {
            for (id<NIMKitCardHeaderData> data in self.headerData) {
                if ([data respondsToSelector:@selector(memberId)] && [data.memberId isEqualToString:object]) {
                    [self.headerData removeObject:data];
                    break;
                }
            }
        }else{
            [self.headerData removeObject:object];
        }
    }
    [self refreshWithMembers:self.headerData];
}

#pragma mark -
- (UITableViewCell *)cellOfOptionsRow:(NSInteger)row tableView:(UITableView *)tableView
{
    UITableViewCell *cell;
    switch (row) {
        case 0:
        {
            SAMCTipRightCell *tipCell = [SAMCTableCellFactory tipRightCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            tipCell.textLabel.text = @"Group name";
            tipCell.tipRightLabel.text = self.team.teamName;
            cell = tipCell;
        }
            break;
        case 1:
        {
            SAMCCommonSwitcherCell *swithCell = [SAMCTableCellFactory commonSwitcherCell:tableView];
            swithCell.textLabel.text = @"Mute chat";
            //    [cell.switcher setOn:];
            //    [cell.switcher addTarget:self action:@selector() forControlEvents:UIControlEventValueChanged];
            cell = swithCell;
        }
            break;
        case 2:
        {
            cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryNone];
            cell.textLabel.text = @"Clear chat history";
        }
            break;
        case 3:
        {
            cell = [SAMCTableCellFactory commonBasicCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = @"Report abuse";
        }
            break;
            
        default:
            break;
    }
    return cell;
}


@end
