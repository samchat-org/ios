//
//  SAMCCustomRequestListDelegate.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomRequestListDelegate.h"
#import "SAMCRequestListCell.h"
#import "SAMCRequestDetailViewController.h"
#import "SAMCQuestionManager.h"
#import "SAMCQuestionSession.h"

@interface SAMCCustomRequestListDelegate ()<SAMCQuestionManagerDelegate>

@end

@implementation SAMCCustomRequestListDelegate

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
    cell.leftLabel.text = [session newResponseDescription];
    cell.middleLabel.text = [session responseTimeDescription];
    cell.rightLabel.text = session.address;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SAMCRequestDetailViewController *vc = [[SAMCRequestDetailViewController alloc] init];
    SAMCQuestionSession *session = [self data][indexPath.row];
    vc.questionSession = session;
    [[SAMCQuestionManager sharedManager] clearSendQuestionNewResponseCount:session];
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
    SAMCQuestionSession *session = [self data][indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[SAMCQuestionManager sharedManager] deleteSendQuestion:session];
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
    if (questionSession.type != SAMCQuestionSessionTypeSend) {
        return;
    }
    [self.data addObject:questionSession];
    [self.viewController sortAndReload];
}

- (void)didUpdateQuestionSession:(SAMCQuestionSession *)questionSession
{
    if (questionSession.type != SAMCQuestionSessionTypeSend) {
        return;
    }
    for (SAMCQuestionSession *session in self.data) {
        if (questionSession.questionId == session.questionId) {
            [self.data removeObject:session];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:questionSession];
    [self.data insertObject:questionSession atIndex:insert];
    [self.viewController sortAndReload];
}

#pragma mark - Private
- (NSInteger)findInsertPlace:(SAMCQuestionSession *)questionSession
{
    // TODO: add time sorting to find the insert place
    return 0; // for test now
}

@end
