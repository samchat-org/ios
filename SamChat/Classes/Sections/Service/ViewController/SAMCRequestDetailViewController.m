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
#import "NIMSessionListCell.h"
#import "NIMSessionListCell+SAMC.h"
#import "NIMAvatarImageView.h"
#import "NIMKitUtil.h"
#import "NIMMessage+SAMC.h"

@interface SAMCRequestDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) SAMCRequestDetailInfoView *requestView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,readonly) NSMutableArray<SAMCRecentSession *> *answerSessions;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Request Details";
    _requestView = [[SAMCRequestDetailInfoView alloc] initWithQuestionSession:_questionSession];
    _requestView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_requestView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor greenColor];
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    self.tableView.tableFooterView  = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_requestView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_requestView][_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestView,_tableView)]];
}

#pragma mark - UITableViewDelegate
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
    // TODO: delete
//    SAMCRecentSession *recentSession = self.answerSessions[indexPath.row];
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [[SAMCConversationManager sharedManager] deleteRecentSession:recentSession];
//        
//        [self.answerSessions removeObjectAtIndex:indexPath.row];
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.answerSessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellId";
    NIMSessionListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[NIMSessionListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell.avatarImageView addTarget:self action:@selector(onTouchAvatar:) forControlEvents:UIControlEventTouchUpInside];
    }
    SAMCRecentSession *recent = self.answerSessions[indexPath.row];
    NIMSession *nimsession = [NIMSession session:recent.session.sessionId type:recent.session.sessionType];
    cell.nameLabel.text = [self nameForRecentSession:recent];
    [cell.avatarImageView setAvatarBySession:nimsession];
    [cell.nameLabel sizeToFit];
    cell.messageLabel.text = [recent.lastMessage.nimMessage messageContent];
    [cell.messageLabel sizeToFit];
    cell.timeLabel.text = [self timestampDescriptionForRecentSession:recent];
    [cell.timeLabel sizeToFit];
    
    [cell refreshBadge:recent.unreadCount];
    return cell;
}

#pragma mark - Private
- (NSMutableArray *)allCurrentQuestionAnswerSessions
{
    return [[[SAMCConversationManager sharedManager] answerSessionsOfAnswers:self.questionSession.answers] mutableCopy];
}

- (void)sort
{
    [self.answerSessions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SAMCRecentSession *item1 = obj1;
        SAMCRecentSession *item2 = obj2;
        if (item1.lastMessage.nimMessage.timestamp < item2.lastMessage.nimMessage.timestamp) {
            return NSOrderedDescending;
        }
        if (item1.lastMessage.nimMessage.timestamp > item2.lastMessage.nimMessage.timestamp) {
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
    return [NIMKitUtil showTime:recent.lastMessage.nimMessage.timestamp showDetail:NO];
}

@end
