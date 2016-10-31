//
//  SAMCContactListViewController.m
//  SamChat
//
//  Created by HJ on 7/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCContactListViewController.h"
#import "NTESSessionUtil.h"
#import "SAMCSessionViewController.h"
#import "NTESContactUtilItem.h"
#import "NTESContactDefines.h"
#import "SAMCGroupedContacts.h"
#import "UIView+Toast.h"
#import "NTESCustomNotificationDB.h"
#import "NTESNotificationCenter.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESSearchTeamViewController.h"
#import "NTESContactAddFriendViewController.h"
#import "SAMCPersonalCardViewController.h"
#import "UIAlertView+NTESBlock.h"
#import "SVProgressHUD.h"
#import "NTESContactUtilCell.h"
#import "NIMContactDataCell.h"
#import "NIMContactSelectViewController.h"
#import "NTESUserUtil.h"
#import "SAMCSession.h"
#import "SAMCPreferenceManager.h"
#import "SAMCAccountManager.h"
#import "SAMCAddContactViewController.h"
#import "NTESContactDataMember.h"
#import "SAMCTableCellFactory.h"
#import "SAMCServicerCardViewController.h"
#import "SAMCCustomerCardViewController.h"
#import "SAMCUserManager.h"
#import "SAMCPublicManager.h"

@interface SAMCContactListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,
NIMSystemNotificationManagerDelegate,NTESContactUtilCellDelegate,NIMContactDataCellDelegate,SAMCLoginManagerDelegate,SAMCUserManagerDelegate>
{
    SAMCGroupedContacts *_contacts;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchDisplayController *searchResultController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *contactUtils;

@property (nonatomic, strong) NSArray *searchResultData;

@end

@implementation SAMCContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoHasUpdatedNotification:)
                                                 name:NIMKitUserInfoHasUpdatedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoHasUpdatedNotification:)
                                                 name:NIMKitUserBlackListHasUpdatedNotification
                                               object:nil];
    
    [self prepareData];
    
    [[[NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
    [[SAMCAccountManager sharedManager] addDelegate:self];
    [[SAMCUserManager sharedManager] addDelegate:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    [[SAMCAccountManager sharedManager] removeDelegate:self];
    [[SAMCUserManager sharedManager] removeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchResultController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                                    contentsController:self];
    self.searchResultController.delegate = self;
    self.searchResultController.searchResultsDataSource = self;
    self.searchResultController.searchResultsDelegate = self;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)prepareData{
    NSString *addButtonNormalImage;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        self.navigationItem.title = @"Service Provider";
        addButtonNormalImage = @"ico_nav_add_light";
        _contacts = [[SAMCGroupedContacts alloc] initWithType:SAMCContactListTypeServicer];
    } else {
        self.navigationItem.title = @"My Clients";
        addButtonNormalImage = @"ico_nav_add_dark";
        _contacts = [[SAMCGroupedContacts alloc] initWithType:SAMCContactListTypeCustomer];
    }
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn addTarget:self action:@selector(onOpera:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setImage:[UIImage imageNamed:addButtonNormalImage] forState:UIControlStateNormal];
    //    [teamBtn setImage:[UIImage imageNamed:@"icon_tinfo_pressed"] forState:UIControlStateHighlighted];
    [addBtn sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    
//    [_contacts addGroupAboveWithTitle:@"" members:self.contactUtils];
}


#pragma mark - Action
- (void)onOpera:(id)sender{
    SAMCAddContactViewController *vc = [[SAMCAddContactViewController alloc] init];
    vc.currentUserMode = self.currentUserMode;
    [self.navigationController pushViewController:vc animated:YES];
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择操作" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加好友",@"创建高级群",@"创建讨论组",@"搜索高级群", nil];
//    __weak typeof(self) wself = self;
//    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
//    [sheet showInView:self.view completionHandler:^(NSInteger index) {
//        UIViewController *vc;
//        switch (index) {
//            case 0:
//                vc = [[NTESContactAddFriendViewController alloc] initWithNibName:nil bundle:nil];
//                break;
//            case 1:{  //创建高级群
//                [wself presentMemberSelector:^(NSArray *uids) {
//                    NSArray *members = [@[currentUserId] arrayByAddingObjectsFromArray:uids];
//                    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
//                    option.name       = @"高级群";
//                    option.type       = NIMTeamTypeAdvanced;
//                    option.joinMode   = NIMTeamJoinModeNoAuth;
//                    option.postscript = @"邀请你加入群组";
//                    [SVProgressHUD show];
//                    [[NIMSDK sharedSDK].teamManager createTeam:option users:members completion:^(NSError *error, NSString *teamId) {
//                        [SVProgressHUD dismiss];
//                        if (!error) {
////                            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
//                            SAMCUserModeType mode = [[[SAMCPreferenceManager sharedManager] currentUserMode] integerValue];
//                            SAMCSession *session = [SAMCSession session:teamId type:NIMSessionTypeTeam mode:mode];
//                            SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:session];
//                            [wself.navigationController pushViewController:vc animated:YES];
//                        }else{
//                            [wself.view makeToast:@"创建失败" duration:2.0 position:CSToastPositionCenter];
//                        }
//                    }];
//                }];
//                break;
//            }
//            case 2:{ //创建讨论组
//                [wself presentMemberSelector:^(NSArray *uids) {
//                    if (!uids.count) {
//                        return; //讨论组必须除自己外必须要有一个群成员
//                    }
//                    NSArray *members = [@[currentUserId] arrayByAddingObjectsFromArray:uids];
//                    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
//                    option.name       = @"讨论组";
//                    option.type       = NIMTeamTypeNormal;
//                    [SVProgressHUD show];
//                    [[NIMSDK sharedSDK].teamManager createTeam:option users:members completion:^(NSError *error, NSString *teamId) {
//                        [SVProgressHUD dismiss];
//                        if (!error) {
////                            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
//                            SAMCUserModeType mode = [[[SAMCPreferenceManager sharedManager] currentUserMode] integerValue];
//                            SAMCSession *session = [SAMCSession session:teamId type:NIMSessionTypeTeam mode:mode];
//                            SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:session];
//                            [wself.navigationController pushViewController:vc animated:YES];
//                        }else{
//                            [wself.view makeToast:@"创建失败" duration:2.0 position:CSToastPositionCenter];
//                        }
//                    }];
//                }];
//                break;
//            }
//            case 3:
//                vc = [[NTESSearchTeamViewController alloc] initWithNibName:nil bundle:nil];
//                break;
//            default:
//                break;
//        }
//        if (vc) {
//            [wself.navigationController pushViewController:vc animated:YES];
//        }
//    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NTESContactDataMember *member;
    if ([tableView isEqual:self.tableView]) {
        member = [_contacts memberOfIndex:indexPath];
    } else {
        member = self.searchResultData[indexPath.row];
    }
    NSString *userId = member.info.infoId;
    [self enterPersonalCard:userId];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return 30.0f;
    } else {
        return CGFLOAT_MIN;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
//    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
//    return contactItem.uiHeight;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return [_contacts memberCountOfGroup:section];
    } else {
        return [self.searchResultData count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        return [_contacts groupCount];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTESContactDataMember *member;
    if ([tableView isEqual:self.tableView]) {
        member = [_contacts memberOfIndex:indexPath];
    } else {
        member = self.searchResultData[indexPath.row];
    }
    UITableViewCell *cell;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        cell = [SAMCTableCellFactory customContactCell:tableView];
        [(SAMCCustomContactCell *)cell refreshData:member.info];
    } else {
        cell = [SAMCTableCellFactory spContactCell:tableView];
        [(SAMCSPContactCell *)cell refreshData:member.info];
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return [_contacts titleOfGroup:section];
    } else {
        return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        return _contacts.sortedGroupTitles;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![tableView isEqual:self.tableView]) {
        return NO;
    }
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    return [contactItem userId].length;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak typeof(self) wself = self;
        [SVProgressHUD show];
        id<NTESContactItem,NTESGroupMemberProtocol> contactItem = (id<NTESContactItem,NTESGroupMemberProtocol>)[_contacts memberOfIndex:indexPath];
        NSString *userId = [contactItem userId];
        SAMCContactListType listType;
        if (wself.currentUserMode == SAMCUserModeTypeCustom) {
            listType = SAMCContactListTypeServicer;
        } else {
            listType = SAMCContactListTypeCustomer;
        }
        SAMCUser *user = [[SAMCUserManager sharedManager] userInfo:userId];
        [[SAMCUserManager sharedManager] addOrRemove:NO contact:user type:listType completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (!error) {
                // use SAMCUserManagerDelegate to delete
                // [_contacts removeGroupMember:contactItem];
            } else {
                [wself.view makeToast:@"delete failed" duration:2.0f position:CSToastPositionCenter];
            }
        }];
    }
}

#pragma mark - NIMContactDataCellDelegate
- (void)onPressAvatar:(NSString *)memberId{
    [self enterPersonalCard:memberId];
}

#pragma mark - NTESContactUtilCellDelegate
- (void)onPressUtilImage:(NSString *)content{
    [self.view makeToast:[NSString stringWithFormat:@"点我干嘛 我是<%@>",content] duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - NIMContactSelectDelegate
- (void)didFinishedSelect:(NSArray *)selectedContacts{
    
}

#pragma mark - NIMSDK Delegate
#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
{
    [self prepareData];
    [self.tableView reloadData];
}

#pragma mark - SAMCLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        if (self.isViewLoaded) {//没有加载view的话viewDidLoad里会走一遍prepareData
            [self prepareData];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Notification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notfication{
    [self prepareData];
    [self.tableView reloadData];
}

#pragma mark - Private
- (void)enterPersonalCard:(NSString *)userId{
    SAMCUser *user = [[SAMCUserManager sharedManager] userInfo:userId];
    UIViewController *vc;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        BOOL isFollow = [[SAMCPublicManager sharedManager] isFollowing:userId];
        vc = [[SAMCServicerCardViewController alloc] initWithUser:user isFollow:isFollow isMyProvider:YES];
    } else {
        BOOL isMyCustomer = YES;
        vc = [[SAMCCustomerCardViewController alloc] initWithUser:user isMyCustomer:isMyCustomer];
    }
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)presentMemberSelector:(ContactSelectFinishBlock) block{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    //使用内置的好友选择器
    NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
    //获取自己id
    NSString *currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    [users addObject:currentUserId];
    //将自己的id过滤
    config.filterIds = users;
    //需要多选
    config.needMutiSelected = YES;
    //初始化联系人选择器
    NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
    //回调处理
    vc.finshBlock = block;
    [vc show];
}

- (NSArray *)contactUtils
{
    if (_contactUtils == nil) {
        NSString *contactCellUtilIcon   = @"icon";
        NSString *contactCellUtilVC     = @"vc";
        NSString *contactCellUtilBadge  = @"badge";
        NSString *contactCellUtilTitle  = @"title";
        NSString *contactCellUtilUid    = @"uid";
        NSString *contactCellUtilSelectorName = @"selName";
        //原始数据
        
        NSInteger systemCount = [[[NIMSDK sharedSDK] systemNotificationManager] allUnreadCount];
        NSMutableArray *utils =
        [@[
           @{
               contactCellUtilIcon:@"icon_notification_normal",
               contactCellUtilTitle:@"验证消息",
               contactCellUtilVC:@"NTESSystemNotificationViewController",
               contactCellUtilBadge:@(systemCount)
               },
           @{
               contactCellUtilIcon:@"icon_team_advance_normal",
               contactCellUtilTitle:@"高级群",
               contactCellUtilVC:@"NTESAdvancedTeamListViewController"
               },
           @{
               contactCellUtilIcon:@"icon_team_normal_normal",
               contactCellUtilTitle:@"讨论组",
               contactCellUtilVC:@"NTESNormalTeamListViewController"
               },
           @{
               contactCellUtilIcon:@"icon_blacklist_normal",
               contactCellUtilTitle:@"黑名单",
               contactCellUtilVC:@"NTESBlackListViewController"
               },
           ] mutableCopy];
        
        //构造显示的数据模型
        NSMutableArray * members = [[NSMutableArray alloc] init];
        for (NSDictionary *item in utils) {
            NTESContactUtilMember *utilItem = [[NTESContactUtilMember alloc] init];
            utilItem.nick              = item[contactCellUtilTitle];
            utilItem.icon              = [UIImage imageNamed:item[contactCellUtilIcon]];
            utilItem.vcName            = item[contactCellUtilVC];
            utilItem.badge             = [item[contactCellUtilBadge] stringValue];
            utilItem.userId            = item[contactCellUtilUid];
            utilItem.selName           = item[contactCellUtilSelectorName];
            [members addObject:utilItem];
        }
        _contactUtils = members;
    }
    return _contactUtils;
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *members = [[NSMutableArray alloc] init];
    for (int i=0; i<[_contacts groupCount]; i++) {
        [members addObjectsFromArray:[_contacts membersOfGroup:i]];
    }
    
    __block NSMutableArray *tempResultArray = [[NSMutableArray alloc] init];
    [members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NTESContactDataMember *member = obj;
        NSRange range = [member.info.showName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [tempResultArray addObject:member];
        }
    }];
   
    self.searchResultData = tempResultArray;
    [self.searchResultController.searchResultsTableView reloadData];
}

#pragma mark - SAMCUserManagerDelegate
- (void)didAddContact:(SAMCUser *)user type:(SAMCContactListType)type
{
    if ((self.currentUserMode == SAMCUserModeTypeCustom) && (type == SAMCContactListTypeCustomer)) {
        return;
    }
    if ((self.currentUserMode == SAMCUserModeTypeSP) && (type == SAMCContactListTypeServicer)) {
        return;
    }
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:user.userId];
    NTESContactDataMember *contact = [[NTESContactDataMember alloc] init];
    contact.info = info;
    [_contacts addGroupMember:contact];
    [self.tableView reloadData];
}

- (void)didRemoveContact:(SAMCUser *)user type:(SAMCContactListType)type
{
    if ((self.currentUserMode == SAMCUserModeTypeCustom) && (type == SAMCContactListTypeCustomer)) {
        return;
    }
    if ((self.currentUserMode == SAMCUserModeTypeSP) && (type == SAMCContactListTypeServicer)) {
        return;
    }
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:user.userId];
    NTESContactDataMember *contact = [[NTESContactDataMember alloc] init];
    contact.info = info;
    
    NSIndexPath *indexPath = [_contacts indexPathOfMember:contact];
    if (indexPath) {
        [_contacts removeGroupMember:contact];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
