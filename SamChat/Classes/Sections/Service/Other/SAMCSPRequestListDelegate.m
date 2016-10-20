//
//  SAMCSPRequestListDelegate.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPRequestListDelegate.h"
#import "SAMCQuestionManager.h"
#import "SAMCQuestionSession.h"
#import "SAMCConversationManager.h"
#import "SAMCSessionViewController.h"
#import "SAMCSPRequestListCell.h"

@interface SAMCSPRequestListDelegate ()<SAMCQuestionManagerDelegate>

@end

@implementation SAMCSPRequestListDelegate

- (instancetype) initWithTableData:(NSMutableArray *(^)(void))data viewController:(UIViewController<SAMCTableReloadDelegate> *)controller
{
    self = [super initWithTableData:data viewController:controller];
    if (self) {
        [[SAMCQuestionManager sharedManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[SAMCQuestionManager sharedManager] removeDelegate:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SAMCSPRequestListCellId";
    SAMCSPRequestListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCSPRequestListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    SAMCQuestionSession *session = [self data][indexPath.row];
    [cell updateWithSession:session];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SAMCQuestionSession *questionsession = [self data][indexPath.row];
    [self saveQuestionMessage:questionsession];
    
    NSString *senderId = [NSString stringWithFormat:@"%@",@(questionsession.senderId)];
    SAMCSession *samcsession = [SAMCSession session:senderId type:NIMSessionTypeP2P mode:SAMCUserModeTypeSP];
    SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:samcsession];
    // 如果问题未回复，则设置vc的问题，vc中会判断此项，如果存在，则会加入到发送消息的扩展中
    // 并在发送消息回调中判断，发送成功时会更新数据库，同时vc中根据发送成功也会置为nil，使得之后发送的消息中不带扩展
    if (questionsession.status != SAMCReceivedQuestionStatusResponsed) {
        vc.questionId = @(questionsession.questionId);
    }
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70.f;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAMCQuestionSession *session = [self data][indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[SAMCQuestionManager sharedManager] deleteReceivedQuestion:session];
        [[self data] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (![[self data] count]) {
            [self.viewController sortAndReload];
        }
    }
}

#pragma mark - SAMCQuestionManagerDelegate
- (void)didAddQuestionSession:(SAMCQuestionSession *)questionSession
{
    if (questionSession.type != SAMCQuestionSessionTypeReceived) {
        return;
    }
    [self.data addObject:questionSession];
    [self.viewController sortAndReload];
}

- (void)didUpdateQuestionSession:(SAMCQuestionSession *)questionSession
{
}

#pragma mark - Insert Message
- (void)saveQuestionMessage:(SAMCQuestionSession *)questionSession
{
    if (questionSession.status != SAMCReceivedQuestionStatusNew) {
        return;
    }
    NSString *senderId = [NSString stringWithFormat:@"%@",@(questionSession.senderId)];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = questionSession.question;
    message.from = senderId;

    // set unread flag extention
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:message.remoteExt];
    [ext addEntriesFromDictionary:@{MESSAGE_EXT_FROM_USER_MODE_KEY:MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM,
                                    MESSAGE_EXT_UNREAD_FLAG_KEY:MESSAGE_EXT_UNREAD_FLAG_NO}];
    message.remoteExt = ext;
    NIMSession *session = [NIMSession session:senderId type:NIMSessionTypeP2P];
    
    questionSession.status = SAMCReceivedQuestionStatusInserted;
    [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:^(NSError * _Nullable error) {
        if (error) {
            questionSession.status = SAMCReceivedQuestionStatusNew;
        } else {
            [[SAMCQuestionManager sharedManager] updateReceivedQuestion:questionSession.questionId status:SAMCReceivedQuestionStatusInserted];
        }
    }];
}

@end
