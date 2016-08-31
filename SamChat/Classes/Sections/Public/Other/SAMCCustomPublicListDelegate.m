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
    cell.messageLabel.text = session.lastMessageContent;
    cell.nameLabel.text = session.spBasicInfo.username;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    [[self data] addObject:publicSession];
    [self.viewController sortAndReload];
}


@end
