//
//  SAMCCustomPublicListDelegate.m
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomPublicListDelegate.h"
#import "SAMCCustomPublicListCell.h"
#import "SAMCSPBasicInfo.h"

@implementation SAMCCustomPublicListDelegate

- (instancetype) initWithTableData:(NSMutableArray *(^)(void))data viewController:(UIViewController<SAMCTableReloadDelegate> *)controller
{
    self = [super initWithTableData:data viewController:controller];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
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
    
    SAMCSPBasicInfo *info = [self data][indexPath.row];
    cell.messageLabel.text = @"message text";
    cell.nameLabel.text = info.username;
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
