//
//  SAMCSPPublicMessageDelegate.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPPublicMessageDelegate.h"

@implementation SAMCSPPublicMessageDelegate

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
//    UITableViewCell *cell = nil;
//    id model = [[_sessionDatasource modelArray] objectAtIndex:indexPath.row];
//    if ([model isKindOfClass:[NIMMessageModel class]]) {
//        cell = [NIMMessageCellMaker cellInTable:tableView
//                                 forMessageMode:model];
//        [(NIMMessageCell *)cell setMessageDelegate:self];
//    }
//    else if ([model isKindOfClass:[NIMTimestampModel class]])
//    {
//        cell = [NIMMessageCellMaker cellInTable:tableView
//                                   forTimeModel:model];
//    }
//    else
//    {
//        NSAssert(0, @"not support model");
//    }
//    return cell;
    static NSString * cellId = @"SAMCSPPublicMessageCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = @"test";
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
//    CGFloat cellHeight = 0;
//    id modelInArray = [[_sessionDatasource modelArray] objectAtIndex:indexPath.row];
//    if ([modelInArray isKindOfClass:[NIMMessageModel class]])
//    {
//        NIMMessageModel *model = (NIMMessageModel *)modelInArray;
//        NSAssert([model respondsToSelector:@selector(contentSize)], @"config must have a cell height value!!!");
//        [self layoutConfig:model];
//        CGSize size = model.contentSize;
//        UIEdgeInsets contentViewInsets = model.contentViewInsets;
//        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
//        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom;
//    }
//    else if ([modelInArray isKindOfClass:[NIMTimestampModel class]])
//    {
//        cellHeight = [modelInArray height];
//    }
//    else
//    {
//        NSAssert(0, @"not support model");
//    }
//    return cellHeight;
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
//    SAMCPublicSession *session = [self data][indexPath.row];
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [[SAMCPublicManager sharedManager] follow:NO officialAccount:session.spBasicInfo completion:^(NSError * _Nullable error) {
//            if (error == nil) {
//                [[self data] removeObjectAtIndex:indexPath.row];
//                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            }
//        }];
//    }
}

@end
