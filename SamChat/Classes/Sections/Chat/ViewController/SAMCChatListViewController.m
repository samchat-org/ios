//
//  SAMCChatListViewController.m
//  SamChat
//
//  Created by HJ on 7/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCChatListViewController.h"
#import "NIMSessionListCell.h"
#import "UIView+NIM.h"
#import "NIMAvatarImageView.h"
#import "NIMKitUtil.h"
#import "NIMKit.h"
#import "NTESSessionViewController.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "NTESListHeader.h"
#import "NTESClientsTableViewController.h"
#import "NTESSnapchatAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESChartletAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "NTESSessionUtil.h"
#import "NTESPersonalCardViewController.h"
#import "NIMCellConfig.h"
#import "NIMSDK.h"
#import "SAMCDataBaseManager.h"

#define SessionListTitle @"Chat"

@interface SAMCChatListViewController ()<NIMConversationManagerDelegate,NIMTeamManagerDelegate,NIMLoginManagerDelegate,NTESListHeaderDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UILabel *emptyTipLabel;
@property (nonatomic,strong) NTESListHeader *header;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) UISearchDisplayController *searchResultController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic,readonly) NSMutableArray * recentSessions;

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
    }
    
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
    
    self.emptyTipLabel = [[UILabel alloc] init];
    self.emptyTipLabel.text = @"还没有会话，在通讯录中找个人聊聊吧";
    [self.emptyTipLabel sizeToFit];
    self.emptyTipLabel.hidden = self.recentSessions.count;
    [self.view addSubview:self.emptyTipLabel];
    
    
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
    extern NSString *const NIMKitTeamInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamInfoHasUpdatedNotification:) name:NIMKitTeamInfoHasUpdatedNotification object:nil];
    
    extern NSString *const NIMKitTeamMembersHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamMembersHasUpdatedNotification:) name:NIMKitTeamMembersHasUpdatedNotification object:nil];
    
    extern NSString *const NIMKitUserInfoHasUpdatedNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoHasUpdatedNotification:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self refreshSubview];
}

- (void)switchToUserMode:(NSNotification *)notification
{
    _recentSessions = [self allCurrentUserModeRecentSessions];
    [self reload];
}

- (void)reload
{
    if (!self.recentSessions.count) {
        self.tableView.hidden = YES;
        self.emptyTipLabel.hidden = NO;
    }else{
        self.tableView.hidden = NO;
        self.emptyTipLabel.hidden = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NIMRecentSession *recentSession = self.recentSessions[indexPath.row];
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recentSession.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMRecentSession *recentSession = self.recentSessions[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
        
        [manager deleteRecentSession:recentSession];
        
        //清理本地数据
        [self.recentSessions removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //如果删除本地会话后就不允许漫游当前会话，则需要进行一次删除服务器会话的操作
        [manager deleteRemoteSessions:@[recentSession.session] completion:nil];
        self.emptyTipLabel.hidden = self.recentSessions.count;
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recentSessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellId";
    NIMSessionListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[NIMSessionListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell.avatarImageView addTarget:self action:@selector(onTouchAvatar:) forControlEvents:UIControlEventTouchUpInside];
    }
    NIMRecentSession *recent = self.recentSessions[indexPath.row];
    cell.nameLabel.text = [self nameForRecentSession:recent];
    [cell.avatarImageView setAvatarBySession:recent.session];
    [cell.nameLabel sizeToFit];
    cell.messageLabel.text  = [self contentForRecentSession:recent];
    [cell.messageLabel sizeToFit];
    cell.timeLabel.text = [self timestampDescriptionForRecentSession:recent];
    [cell.timeLabel sizeToFit];
    
    [cell refresh:recent];
    return cell;
}


#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    [self.recentSessions addObject:recentSession];
    [self sort];
    [self reload];
}


- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    for (NIMRecentSession *recent in self.recentSessions) {
        if ([recentSession.session.sessionId isEqualToString:recent.session.sessionId]) {
            [self.recentSessions removeObject:recent];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:recentSession];
    [self.recentSessions insertObject:recentSession atIndex:insert];
    [self reload];
}

- (void)messagesDeletedInSession:(NIMSession *)session
{
//    _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    _recentSessions = [self allCurrentUserModeRecentSessions];
    [self reload];
}

- (void)allMessagesDeleted
{
//    _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    _recentSessions = [self allCurrentUserModeRecentSessions];
    [self reload];
}

#pragma mark - NIMLoginManagerDelegate
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
- (NSMutableArray<NIMRecentSession *> *)allCurrentUserModeRecentSessions
{
    __block NSMutableArray<NIMRecentSession *> *sessions = [[NSMutableArray alloc] init];
    NSArray<SAMCSession *> *modeSessions = nil;
    if (self.currentUserMode == SAMCUserModeTypeSP) {
        modeSessions = [[SAMCDataBaseManager sharedManager].messageDB allSPSessions];
    } else {
        modeSessions = [[SAMCDataBaseManager sharedManager].messageDB allCustomSessions];
    }
    [[NIMSDK sharedSDK].conversationManager.allRecentSessions enumerateObjectsUsingBlock:^(NIMRecentSession * _Nonnull recentSession, NSUInteger idx, BOOL * _Nonnull stop) {
        [modeSessions enumerateObjectsUsingBlock:^(SAMCSession * _Nonnull modeSession, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([recentSession.session.sessionId isEqual:modeSession.sessionId]) {
                *stop = YES;
                [sessions addObject:recentSession];
            }
        }];
    }];
    return sessions;
}

- (NSString *)nameForRecentSession:(NIMRecentSession *)recent
{
    if ([recent.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        return @"我的电脑";
    }
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        return [NIMKitUtil showNick:recent.session.sessionId inSession:recent.session];
    }else{
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recent.session.sessionId];
        return team.teamName;
    }
}

- (NSString *)timestampDescriptionForRecentSession:(NIMRecentSession *)recent
{
    return [NIMKitUtil showTime:recent.lastMessage.timestamp showDetail:NO];
}

- (void)refreshSubview
{
    self.tableView.top = self.header.height;
    self.tableView.height = self.view.height - self.tableView.top;
    self.header.bottom    = self.tableView.top + self.tableView.contentInset.top;
    self.emptyTipLabel.centerX = self.view.width * .5f;
    self.emptyTipLabel.centerY = self.tableView.height * .5f;
}

- (NSString *)contentForRecentSession:(NIMRecentSession *)recent
{
    NSString *text = @"";
    switch (recent.lastMessage.messageType) {
        case NIMMessageTypeCustom:
            text = [self customMessageContent:recent.lastMessage];
            break;
        case NIMMessageTypeText:
            text = recent.lastMessage.text;
            break;
        case NIMMessageTypeAudio:
            text = @"[语音]";
            break;
        case NIMMessageTypeImage:
            text = @"[图片]";
            break;
        case NIMMessageTypeVideo:
            text = @"[视频]";
            break;
        case NIMMessageTypeLocation:
            text = @"[位置]";
            break;
        case NIMMessageTypeNotification:
            return [self notificationMessageContent:recent.lastMessage];
        case NIMMessageTypeFile:
            text = @"[文件]";
            break;
        case NIMMessageTypeTip:
            text = @"[提醒消息]";   //调整成你需要显示的文案
            break;
        default:
            text = @"[未知消息]";
    }
    if (recent.lastMessage.session.sessionType == NIMSessionTypeP2P) {
        return text;
    }else{
        NSString *nickName = [NIMKitUtil showNick:recent.lastMessage.from inSession:recent.lastMessage.session];
        return nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
    }
}

#pragma mark - Misc
- (NSInteger)findInsertPlace:(NIMRecentSession *)recentSession
{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.recentSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NIMRecentSession *item = obj;
        if (item.lastMessage.timestamp <= recentSession.lastMessage.timestamp) {
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
        NIMRecentSession *item1 = obj1;
        NIMRecentSession *item2 = obj2;
        if (item1.lastMessage.timestamp < item2.lastMessage.timestamp) {
            return NSOrderedDescending;
        }
        if (item1.lastMessage.timestamp > item2.lastMessage.timestamp) {
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
    NIMRecentSession *recent = self.recentSessions[indexPath.row];
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NTESPersonalCardViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:recent.session.sessionId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Private
- (NSString *)customMessageContent:(NIMMessage *)lastMessage
{
    NSString *text = @"";
    NIMCustomObject *object = lastMessage.messageObject;
    if ([object.attachment isKindOfClass:[NTESSnapchatAttachment class]]) {
        text = @"[阅后即焚]";
    }
    else if ([object.attachment isKindOfClass:[NTESJanKenPonAttachment class]]) {
        text = @"[猜拳]";
    }
    else if ([object.attachment isKindOfClass:[NTESChartletAttachment class]]) {
        text = @"[贴图]";
    }
    else if ([object.attachment isKindOfClass:[NTESWhiteboardAttachment class]]) {
        text = @"[白板]";
    }else{
        text = @"[未知消息]";
    }
    return text;
}

- (NSString *)notificationMessageContent:(NIMMessage *)lastMessage
{
    NIMNotificationObject *object = lastMessage.messageObject;
    if (object.notificationType == NIMNotificationTypeNetCall) {
        NIMNetCallNotificationContent *content = (NIMNetCallNotificationContent *)object.content;
        if (content.callType == NIMNetCallTypeAudio) {
            return @"[网络通话]";
        }
        return @"[视频聊天]";
    }
    if (object.notificationType == NIMNotificationTypeTeam) {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:lastMessage.session.sessionId];
        if (team.type == NIMTeamTypeNormal) {
            return @"[讨论组信息更新]";
        }else{
            return @"[群信息更新]";
        }
    }
    return @"[未知消息]";
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

@end
