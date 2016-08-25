//
//  SAMCSPRequestListDelegate.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPRequestListDelegate.h"
#import "SAMCRequestListCell.h"
#import "SAMCQuestionManager.h"
#import "SAMCQuestionSession.h"
#import "SAMCConversationManager.h"
#import "SAMCSessionViewController.h"

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
    static NSString * cellId = @"cellId";
    SAMCRequestListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCRequestListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SAMCQuestionSession *session = [self data][indexPath.row];
    cell.messageLabel.text = session.question;
    cell.leftLabel.text = [session questionTimeDescription];
    cell.middleLabel.text = session.address;
    cell.rightLabel.text = session.senderUsername;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SAMCQuestionSession *questionsession = [self data][indexPath.row];
    NSString *senderId = [NSString stringWithFormat:@"%@",@(questionsession.senderId)];
    SAMCSession *samcsession = [SAMCSession session:senderId type:NIMSessionTypeP2P mode:SAMCUserModeTypeSP];
    SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:samcsession];
    [self.viewController.navigationController pushViewController:vc animated:YES];
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

@end
