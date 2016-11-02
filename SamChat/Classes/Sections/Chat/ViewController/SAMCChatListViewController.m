//
//  SAMCChatListViewController.m
//  SamChat
//
//  Created by HJ on 7/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCChatListViewController.h"
#import "NIMSessionListCell.h"
#import "NIMSessionListCell+SAMC.h"
#import "UIView+NIM.h"
#import "NIMAvatarImageView.h"
#import "NIMKitUtil.h"
#import "NIMKit.h"
#import "SAMCSessionViewController.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "NTESListHeader.h"
#import "NTESClientsTableViewController.h"
#import "NTESSessionUtil.h"
#import "SAMCPersonalCardViewController.h"
#import "NIMCellConfig.h"
#import "NIMSDK.h"
#import "SAMCConversationManager.h"
#import "NIMMessage+SAMC.h"
#import "SAMCAccountManager.h"
#import "SAMCCustomChatListCell.h"
#import "UIActionSheet+NTESBlock.h"
#import "SAMCUserManager.h"
#import "SAMCPublicManager.h"
#import "SAMCServicerCardViewController.h"
#import "SAMCCustomerCardViewController.h"

#define SessionListTitle @"Chat"

@interface SAMCChatListViewController ()<SAMCConversationManagerDelegate,NIMTeamManagerDelegate,SAMCLoginManagerDelegate,NTESListHeaderDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NTESListHeader *header;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UISearchDisplayController *searchResultController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic,readonly) NSMutableArray<SAMCRecentSession *> * recentSessions;

@end

@implementation SAMCChatListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = SessionListTitle;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    self.tableView.tableFooterView  = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    _recentSessions = [self allCurrentUserModeRecentSessions];
    if (!self.recentSessions.count) {
        _recentSessions = [NSMutableArray array];
        self.tableView.hidden = YES;
    }
    [self sort];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
//    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchResultController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                                    contentsController:self];
//    self.searchResultController.delegate = self;
//    self.searchResultController.searchResultsDataSource = self;
//    self.searchResultController.searchResultsDelegate = self;
    
    self.header = [[NTESListHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.delegate = self;
    [self.view addSubview:self.header];
    
//    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    [[SAMCConversationManager sharedManager] addDelegate:self];
    [[SAMCAccountManager sharedManager] addDelegate:self];
    
    extern NSString *const NIMKitTeamInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamInfoHasUpdatedNotification:) name:NIMKitTeamInfoHasUpdatedNotification object:nil];
    
    extern NSString *const NIMKitTeamMembersHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamMembersHasUpdatedNotification:) name:NIMKitTeamMembersHasUpdatedNotification object:nil];
    
    extern NSString *const NIMKitUserInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoHasUpdatedNotification:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
}

- (void)dealloc
{
//    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
    [[SAMCConversationManager sharedManager] removeDelegate:self];
    [[SAMCAccountManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self refreshSubview];
}

- (void)reload
{
    if (!self.recentSessions.count) {
        self.tableView.hidden = YES;
    }else{
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SAMCRecentSession *recentSession = self.recentSessions[indexPath.row];
    SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:recentSession.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.recentSessions[indexPath.row].session.sessionType == NIMSessionTypeP2P) {
        return @[[self deleteAction], [self muteAction], [self moreAction]];
    } else {
        return @[[self deleteAction], [self muteAction]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recentSessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCCustomChatListCellId";
    SAMCCustomChatListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCCustomChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.recentSession = self.recentSessions[indexPath.row];
    return cell;
}


#pragma mark - SAMCConversationManagerDelegate
- (void)didAddRecentSession:(SAMCRecentSession *)recentSession
{
    if (![self isCurrentModeSession:recentSession.session]) {
        return;
    }
    [self.recentSessions addObject:recentSession];
    [self sort];
    [self reload];
}


- (void)didUpdateRecentSession:(SAMCRecentSession *)recentSession
{
    if (![self isCurrentModeSession:recentSession.session]) {
        return;
    }
    for (SAMCRecentSession *recent in self.recentSessions) {
        if ([recentSession.session.sessionId isEqualToString:recent.session.sessionId]) {
            [self.recentSessions removeObject:recent];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:recentSession];
    [self.recentSessions insertObject:recentSession atIndex:insert];
    [self reload];
}

- (void)messagesDeletedInSession:(SAMCSession *)session
{
    if (![self isCurrentModeSession:session]) {
        return;
    }
    _recentSessions = [self allCurrentUserModeRecentSessions];
    [self reload];
}

- (void)allMessagesDeleted
{
    _recentSessions = [self allCurrentUserModeRecentSessions];
    [self reload];
}

#pragma mark - SAMCLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        [self reload];
    }
    switch (step) {
        case NIMLoginStepLinkFailed:
            self.navigationItem.title = [SessionListTitle stringByAppendingString:@"(未连接)"];
            break;
        case NIMLoginStepLinking:
            self.navigationItem.title = [SessionListTitle stringByAppendingString:@"(连接中)"];
            break;
        case NIMLoginStepLinkOK:
        case NIMLoginStepSyncOK:
            self.navigationItem.title = SessionListTitle;
            break;
        case NIMLoginStepSyncing:
            self.navigationItem.title = [SessionListTitle stringByAppendingString:@"(同步数据)"];
            break;
        default:
            break;
    }
    [self.header refreshWithType:ListHeaderTypeNetStauts value:@(step)];
    [self.view setNeedsLayout];
}

- (void)onMultiLoginClientsChanged
{
    [self.header refreshWithType:ListHeaderTypeLoginClients value:[NIMSDK sharedSDK].loginManager.currentLoginClients];
    [self.view setNeedsLayout];
}

#pragma mark - SessionListHeaderDelegate
- (void)didSelectRowType:(NTESListHeaderType)type
{
    //多人登录
    switch (type) {
        case ListHeaderTypeLoginClients:{
            NTESClientsTableViewController *vc = [[NTESClientsTableViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private
- (NSMutableArray<SAMCRecentSession *> *)allCurrentUserModeRecentSessions
{
    return [[[SAMCConversationManager sharedManager] allSessionsOfUserMode:self.currentUserMode] mutableCopy];
}

- (NSString *)nameForRecentSession:(SAMCRecentSession *)recent
{
    if ([recent.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        return @"我的电脑";
    }
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NIMSession *session = [NIMSession session:recent.session.sessionId type:recent.session.sessionType];
        return [NIMKitUtil showNick:recent.session.sessionId inSession:session];
    }else{
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recent.session.sessionId];
        return team.teamName;
    }
}

- (NSString *)timestampDescriptionForRecentSession:(SAMCRecentSession *)recent
{
    return [NIMKitUtil showTime:recent.lastMessageTime showDetail:NO];
}

- (void)refreshSubview
{
    self.tableView.top = self.header.height;
    self.tableView.height = self.view.height - self.tableView.top;
    self.header.bottom    = self.tableView.top + self.tableView.contentInset.top;
}

#pragma mark - Misc
- (NSInteger)findInsertPlace:(SAMCRecentSession *)recentSession
{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.recentSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SAMCRecentSession *item = obj;
        if (item.lastMessageTime <= recentSession.lastMessageTime) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.recentSessions.count;
    }
}

- (void)sort
{
    [self.recentSessions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SAMCRecentSession *item1 = obj1;
        SAMCRecentSession *item2 = obj2;
        if (item1.lastMessageTime < item2.lastMessageTime) {
            return NSOrderedDescending;
        }
        if (item1.lastMessageTime > item2.lastMessageTime) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)onTouchAvatar:(id)sender
{
    UIView *view = [sender superview];
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    UITableViewCell *cell  = (UITableViewCell *)view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SAMCRecentSession *recent = self.recentSessions[indexPath.row];
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        SAMCPersonalCardViewController *vc = [[SAMCPersonalCardViewController alloc] initWithUserId:recent.session.sessionId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Notification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification
{
    [self reload];
}

- (void)onTeamInfoHasUpdatedNotification:(NSNotification *)notification
{
    [self reload];
}

- (void)onTeamMembersHasUpdatedNotification:(NSNotification *)notification
{
    [self reload];
}

#pragma mark - Private
- (BOOL)isCurrentModeSession:(SAMCSession *)session
{
    return (session.sessionMode == self.currentUserMode);
}

- (void)enterPersonalCard:(NSString *)userId
{
    SAMCUser *user = [[SAMCUserManager sharedManager] userInfo:userId];
    UIViewController *vc;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        BOOL isFollow = [[SAMCPublicManager sharedManager] isFollowing:userId];
        BOOL isMyProvider = [[SAMCUserManager sharedManager] isMyProvider:userId];
        vc = [[SAMCServicerCardViewController alloc] initWithUser:user isFollow:isFollow isMyProvider:isMyProvider];
    } else {
        BOOL isMyCustomer = [[SAMCUserManager sharedManager] isMyCustomer:userId];
        vc = [[SAMCCustomerCardViewController alloc] initWithUser:user isMyCustomer:isMyCustomer];
    }
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UITableViewRowAction
- (UITableViewRowAction *)moreAction
{
    __weak typeof(self) wself = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"More" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:@"View Profle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SAMCRecentSession *recentSession = wself.recentSessions[indexPath.row];
            [wself enterPersonalCard:recentSession.session.sessionId];
        }];
        UIAlertAction *blockAction = [UIAlertAction actionWithTitle:@"Block User" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            DDLogDebug(@"touch block user");
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:viewProfileAction];
        [alertController addAction:blockAction];
        
        [wself presentViewController:alertController animated:YES completion:nil];
    }];
    action.backgroundColor = SAMC_COLOR_LIMEGREY;
    return action;
}

- (UITableViewRowAction *)muteAction
{
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Mute" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        DDLogDebug(@"touch mute");
    }];
    action.backgroundColor = SAMC_COLOR_GREY;
    return action;
}

- (UITableViewRowAction *)deleteAction
{
    __weak typeof(self) wself = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        SAMCRecentSession *recentSession = wself.recentSessions[indexPath.row];
        [[SAMCConversationManager sharedManager] deleteRecentSession:recentSession];
        [wself.recentSessions removeObjectAtIndex:indexPath.row];
        [wself.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    action.backgroundColor = SAMC_COLOR_RED;
    return action;
}

@end
