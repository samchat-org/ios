//
//  SAMCRequestDetailViewController.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRequestDetailViewController.h"
#import "SAMCRequestDetailInfoView.h"
#import "SAMCConversationManager.h"
#import "SAMCSessionViewController.h"
#import "SAMCPersonalCardViewController.h"
#import "NIMAvatarImageView.h"
#import "NIMKitUtil.h"
#import "NIMMessage+SAMC.h"
#import "SAMCQuestionManager.h"
#import "SAMCRequestEmptyView.h"
#import "SAMCCustomChatListCell.h"

@interface SAMCRequestDetailViewController ()<UITableViewDataSource,UITableViewDelegate,SAMCQuestionManagerDelegate,SAMCConversationManagerDelegate>

@property (nonatomic, strong) SAMCRequestDetailInfoView *requestView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SAMCRequestEmptyView *emptyView;

@property (nonatomic, strong) NSMutableArray<SAMCRecentSession *> *answerSessions;

@end

@implementation SAMCRequestDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    
    _answerSessions = [self allCurrentQuestionAnswerSessions];
    if (!self.answerSessions.count) {
        _answerSessions = [NSMutableArray array];
    }
    [self sort];
    
    [[SAMCQuestionManager sharedManager] addDelegate:self];
    [[SAMCConversationManager sharedManager] addDelegate:self];
}

- (void)dealloc
{
    [[SAMCQuestionManager sharedManager] removeDelegate:self];
    [[SAMCConversationManager sharedManager] removeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Request Details";
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    _requestView = [[SAMCRequestDetailInfoView alloc] init];
    _requestView.questionSession = _questionSession;
    _requestView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_requestView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate         = self;
    _tableView.dataSource       = self;
    _tableView.tableFooterView  = [[UIView alloc] init];
    _tableView.hidden = YES;
    [self.view addSubview:_tableView];
    
    _emptyView = [[SAMCRequestEmptyView alloc] init];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    _emptyView.daysEarlier = [self.questionSession daysEarlier];
    [self.view addSubview:_emptyView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_requestView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_emptyView]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_emptyView)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_emptyView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_requestView][_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestView,_tableView)]];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SAMCRecentSession *recentSession = self.answerSessions[indexPath.row];
    SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:recentSession.session];
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SAMCRecentSession *recentSession = self.answerSessions[indexPath.row];
        NSString *answerId = recentSession.session.sessionId;
        [[SAMCQuestionManager sharedManager] removeAnswer:answerId fromSendQuestion:@(self.questionSession.questionId)];
    }
}

#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"responses";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.answerSessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCCustomChatListCellId";
    SAMCCustomChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCCustomChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.recentSession = self.self.answerSessions[indexPath.row];
    return cell;
}

#pragma mark - Private
- (NSMutableArray *)allCurrentQuestionAnswerSessions
{
    return [[[SAMCConversationManager sharedManager] answerSessionsOfAnswers:self.questionSession.answers] mutableCopy];
}

- (void)sort
{
    if ([self.answerSessions count]) {
        self.tableView.hidden = NO;
        self.emptyView.hidden = YES;
    } else {
        self.tableView.hidden = YES;
        self.emptyView.hidden = NO;
    }
    [self.answerSessions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
    SAMCRecentSession *recent = self.answerSessions[indexPath.row];
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        SAMCPersonalCardViewController *vc = [[SAMCPersonalCardViewController alloc] initWithUserId:recent.session.sessionId];
        [self.navigationController pushViewController:vc animated:YES];
    }
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

#pragma mark - SAMCQuestionManagerDelegate
- (void)didUpdateQuestionSession:(SAMCQuestionSession *)questionSession
{
    if (!(self.questionSession.questionId == questionSession.questionId)) {
        return;
    }
    self.questionSession = questionSession;
    [self.answerSessions removeAllObjects];
    [self.answerSessions addObjectsFromArray:[self allCurrentQuestionAnswerSessions]];
    [self sort];
    [self.tableView reloadData];
}

#pragma mark - SAMCConversationManagerDelegate
- (void)didUpdateRecentSession:(SAMCRecentSession *)recentSession
{
    if (recentSession.session.sessionMode != SAMCUserModeTypeCustom) {
        return;
    }
    
    BOOL find = NO;
    for (int i=0; i<[self.answerSessions count]; i++) {
        SAMCRecentSession *recent = self.answerSessions[i];
        if ([recentSession.session.sessionId isEqualToString:recent.session.sessionId]) {
            [self.answerSessions replaceObjectAtIndex:i withObject:recentSession];
            find = YES;
            break;
        }
    }
    if (find) {
        [self sort];
        [self.tableView reloadData];
    }
}

@end
