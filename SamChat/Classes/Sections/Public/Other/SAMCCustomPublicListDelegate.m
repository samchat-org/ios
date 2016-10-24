//
//  SAMCCustomPublicListDelegate.m
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomPublicListDelegate.h"
#import "SAMCCustomPublicListCell.h"
#import "SAMCPublicSession.h"
#import "SAMCPublicManager.h"
#import "SAMCPublicMessageViewController.h"

@interface SAMCCustomPublicListDelegate ()<SAMCPublicManagerDelegate>

@end

@implementation SAMCCustomPublicListDelegate

- (instancetype) initWithTableData:(NSMutableArray *(^)(void))data viewController:(UIViewController<SAMCTableReloadDelegate> *)controller
{
    self = [super initWithTableData:data viewController:controller];
    if (self) {
        [[SAMCPublicManager sharedManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[SAMCPublicManager sharedManager] removeDelegate:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCCustomPublicListCellId";
    SAMCCustomPublicListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCCustomPublicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SAMCPublicSession *session = [self data][indexPath.row];
    cell.publicSession = session;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SAMCPublicMessageViewController *vc = [[SAMCPublicMessageViewController alloc] init];
    SAMCPublicSession *session = [self data][indexPath.row];
    vc.publicSession = session;
    [[SAMCPublicManager sharedManager] markAllMessagesReadInSession:session];
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

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Unfollow";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAMCPublicSession *session = [self data][indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[SAMCPublicManager sharedManager] follow:NO officialAccount:session.spBasicInfo completion:^(NSError * _Nullable error) {
            if (error == nil) {
                [[self data] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
}

#pragma mark - SAMCPublicManagerDelegate
- (void)didAddPublicSession:(SAMCPublicSession *)publicSession
{
    [[self data] addObject:publicSession];
    [self.viewController sortAndReload];
}

- (void)didUpdatePublicSession:(SAMCPublicSession *)publicSession
{
    NSMutableArray *sessions= [self data];
    for (SAMCPublicSession *session in sessions) {
        if ([session isEqual:publicSession]) {
            [sessions removeObject:session];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:publicSession];
    [sessions insertObject:publicSession atIndex:insert];
    [self.viewController sortAndReload];
}

- (NSInteger)findInsertPlace:(SAMCPublicSession *)session
{
    return 0; // TODO: find insert place
}

@end
